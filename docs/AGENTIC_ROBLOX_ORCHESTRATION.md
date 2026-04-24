# Agentic Roblox Orchestration Architecture

Date: 2026-04-24

This document defines the proposed architecture for assigning agentic behavior to Roblox game objects at runtime, using an external backend and an LLM-powered game director. The immediate project context is the cell biology experience, but the design should work for any Roblox object whose parameters can be interpreted as simulation state.

## Goal

Each meaningful game object should expose a compact state model to the backend. The backend assigns or updates an agent profile for that object, evaluates deterministic simulation rules, and optionally asks an LLM director to choose high-level intent. Roblox remains the rendering and interaction layer. The backend remains the authority for state transitions. The LLM never writes directly into Roblox state.

Example:

```json
{
  "object_id": "mitochondrion-07",
  "class": "organelle",
  "archetype": "mitochondrion",
  "parameters": {
    "oxygenated": true,
    "energy_charge": 0.72,
    "size": "medium",
    "position_band": "inner_cytoplasm",
    "stress": 0.18
  },
  "agent_state": {
    "role": "energy_producer",
    "status": "stable",
    "current_intent": "increase_atp_output",
    "cooldown_until_tick": 1830
  }
}
```

The LLM can reason over this as biology: oxygenated vs. not oxygenated, energy rich vs. depleted, enlarged vs. shrinking, stressed vs. stable. Roblox only needs the resulting state delta: color, animation cue, label, sound, target movement, or interaction affordance.

## Research Summary

Roblox server scripts can call external HTTPS endpoints through `HttpService`, including JSON request and response bodies. The existing repo already uses this shape through `roblox_bridge/CellBackendBridge.server.lua` and the FastAPI service under `backend`.

Roblox Open Cloud Messaging lets external services publish messages to live Roblox servers, which is useful for global announcements or out-of-band backend commands. It should be treated as a complement, not the primary per-frame transport.

Roblox MemoryStore is designed for high-throughput, low-latency ephemeral data shared across servers. It is useful for Roblox-native cross-server coordination, but it is not a durable source of truth and still has quotas and partition considerations.

Cloudflare Workers can receive normal HTTPS calls from Roblox. Cloudflare Durable Objects are a strong fit for per-session coordination because they provide a single stateful coordination point and integrate with WebSockets. However, Roblox `HttpService` should be assumed to use request/response polling or long-polling rather than persistent WebSockets from inside the game server.

OpenAI Structured Outputs and tool/function calling are important because the LLM director must return schema-constrained actions. Free-form prose should never be parsed into gameplay state.

## Design Principles

1. Roblox is the visual and input runtime, not the intelligence authority.
2. The backend owns canonical object state, agent state, validation, and audit logs.
3. LLM output is advisory until it passes deterministic validation.
4. Every object state sent to an LLM must be compact, typed, and schema-versioned.
5. The LLM should direct groups and priorities, not micromanage every object every tick.
6. Fast local rules handle urgent behavior; the LLM handles narrative, teaching, prioritization, and exception handling.
7. The game should continue gracefully when the LLM provider is slow, unavailable, or rate-limited.
8. Player-facing changes must be returned as Roblox-friendly deltas, not backend internals.

## Recommended Architecture

```text
Roblox Clients
  |
  | RemoteEvents / RemoteFunctions
  v
Roblox Server Bridge
  - samples game object parameters
  - sends player actions and state observations
  - applies backend deltas to Workspace objects
  |
  | HTTPS RequestAsync, polling / long-polling
  v
Backend Ingress API
  |
  +-- Session Coordinator
  |     one active simulation context per Roblox server or game room
  |
  +-- Object Registry
  |     object_id, archetype, parameter schema, ownership, visibility
  |
  +-- Agent Runtime
  |     per-object role, memory, status, policy, cooldowns
  |
  +-- Deterministic Simulation Engine
  |     biology rules, resource flows, collision with game constraints
  |
  +-- Director Scheduler
  |     chooses when a director call is needed
  |
  +-- LLM Director Provider
  |     structured output only, provider-swappable
  |
  +-- Validator / Reducer
  |     converts proposed actions into legal state transitions
  |
  +-- Delta Builder
  |     compact updates for Roblox visuals and UI
  |
  +-- Storage / Observability
        snapshots, event log, metrics, traces
```

## Runtime Loop

1. Roblox starts a session and registers the current object manifest.
2. Backend assigns each object an archetype and initial agent profile.
3. Roblox sends periodic observations: player interactions, object parameter changes, and requested inspections.
4. Backend advances the deterministic simulation on a fixed tick.
5. Director Scheduler decides whether an LLM call is warranted.
6. LLM Director receives a compressed world summary, not the entire Workspace.
7. LLM returns structured directives such as `prioritize`, `change_status`, `emit_event`, `assign_task`, or `request_visual_cue`.
8. Validator rejects impossible or unsafe directives and clamps numeric changes.
9. Reducer commits validated changes to canonical state.
10. Roblox polls for deltas and applies them to game objects.

## Object Parameter Model

Each object should have two layers of state:

### Engine Parameters

These are game-facing facts sampled or applied by Roblox.

- `object_id`
- `archetype`
- `position`
- `size`
- `color`
- `animation_state`
- `is_visible`
- `is_interactable`
- `nearby_objects`

### Domain Parameters

These are model-facing semantic facts.

- `oxygenated`
- `energy_charge`
- `stress`
- `damage`
- `cargo`
- `signal_level`
- `phase`
- `health_status`
- `learning_focus`

The bridge should translate between the two. For example, a blue glow in Roblox may map to `oxygenated: true`; a dim red mitochondrion may map to `stress: high`.

## Agent Model

Agents should be backend records, not Roblox scripts attached to every object.

```json
{
  "agent_id": "agent:mitochondrion-07",
  "object_id": "mitochondrion-07",
  "role": "energy_producer",
  "policy": "biology_mvp_v1",
  "status": "stable",
  "current_task": "maintain_atp",
  "memory": {
    "last_director_intent": "restore_energy_balance",
    "last_player_interaction_tick": 1702
  },
  "constraints": {
    "min_energy_charge": 0.0,
    "max_energy_charge": 1.0,
    "allowed_statuses": ["stable", "strained", "recovering", "failing"]
  }
}
```

The backend can maintain thousands of lightweight agent records, but the LLM should only see selected summaries. Most agents should be controlled by deterministic rules unless they are near the player, pedagogically important, or part of the current scenario.

## Game Director Role

The LLM Director should operate at scene level:

- decide which biological process should become salient
- assign priorities to object groups
- select a teaching moment based on player behavior
- generate short explanations for inspections
- choose narrative events such as oxygen shortage, repair, transport backlog, or energy crisis
- resolve ambiguous cases where multiple valid biological responses are possible

The Director should not:

- set raw positions every frame
- generate unbounded Lua code
- bypass backend validators
- own canonical state
- receive secrets, player PII, or full chat logs by default

## LLM Request Shape

Use a compact director context:

```json
{
  "schema_version": "director_context_v1",
  "session": {
    "cell_id": "cell-abc",
    "tick": 1830,
    "mode": "learning",
    "active_learning_goal": "mitochondria_and_oxygen"
  },
  "world_summary": {
    "energy_level": 0.42,
    "oxygen_level": 0.31,
    "stress_level": 0.65,
    "recent_player_focus": ["mitochondrion", "membrane"]
  },
  "object_groups": [
    {
      "group_id": "mitochondria_low_oxygen",
      "archetype": "mitochondrion",
      "count": 8,
      "representative_parameters": {
        "oxygenated": false,
        "energy_charge_avg": 0.34,
        "stress_avg": 0.71
      }
    }
  ],
  "available_actions": [
    "assign_task",
    "change_status",
    "emit_learning_event",
    "request_visual_cue"
  ]
}
```

Expected response should be schema-constrained:

```json
{
  "directives": [
    {
      "type": "assign_task",
      "target": {"group_id": "mitochondria_low_oxygen"},
      "task": "conserve_energy_until_oxygen_recovers",
      "priority": 0.86,
      "ttl_ticks": 120
    },
    {
      "type": "emit_learning_event",
      "target": {"archetype": "mitochondrion"},
      "message_key": "oxygen_needed_for_atp",
      "tone": "concise"
    }
  ]
}
```

## Transport Recommendation

For the MVP, keep the current pattern:

- Roblox server to backend: `HttpService:RequestAsync`
- Backend to Roblox: polling or long-polling state deltas
- Client to Roblox server: RemoteEvents only
- Backend token: server-side only

For scale, use one of these deployment shapes:

### Option A: FastAPI Authority

Keep the current backend as the authoritative service. Add Redis or Postgres for active state when one-process memory is no longer enough. This is easiest because the repo already has FastAPI, schemas, tests, validation, mock provider, and optional OpenAI provider.

### Option B: Cloudflare Edge Coordinator

Use Cloudflare Workers as the HTTP ingress and one Durable Object per Roblox server/session as the active coordinator. Durable Objects fit the "single stateful coordinator per live session" problem well. Use Queues for asynchronous LLM work and analytics. Persist snapshots to D1, R2, Postgres, or the current backend service.

### Option C: Hybrid

Use Cloudflare Workers/Durable Objects for low-latency session coordination, then call the existing FastAPI service for deeper simulation, persistence, admin tools, and local development parity. This gives a clean migration path without throwing away the current backend.

Recommended path: start with Option A, design the session abstraction so it can move to Option B or C later.

## Scheduling Strategy

Do not call the LLM every frame or for every object.

Use three loops:

- `visual_tick`: Roblox-local animations, 30-60 Hz.
- `simulation_tick`: backend deterministic rules, 1-5 Hz.
- `director_tick`: LLM orchestration, event-driven or every 5-30 seconds depending on scenario.

Trigger director calls when:

- player inspects or manipulates an important object
- global stress crosses a threshold
- a scenario starts or ends
- deterministic agents produce conflicting priorities
- the learning objective needs a new prompt or event

## Validation And Safety

Every LLM directive must pass:

- schema validation
- target existence checks
- permission checks by object archetype
- biology/game-rule validation
- numeric clamping
- cooldown and rate limits
- player safety and content filtering for generated text

Invalid directives should be logged and ignored or downgraded to safe alternatives. The game should never wait indefinitely on the LLM.

## State And Persistence

Use these state tiers:

- Roblox Workspace: current visuals only.
- Backend active state: canonical live simulation state.
- Snapshot store: periodic recoverable state.
- Event log: append-only player actions, director directives, validator results, and emitted deltas.
- Analytics store: aggregate learning and balancing metrics.

For this repo, the existing SQLite snapshots are acceptable for local MVP work. Production should move snapshots and event logs to a managed persistent store.

## Security

- Never expose LLM provider keys to Roblox.
- Roblox clients must not call the backend directly.
- Use server-side bearer tokens or signed requests between Roblox server and backend.
- Validate `universe_id`, `place_id`, server id, and schema version.
- Keep prompt templates server-side.
- Strip or hash player identifiers before they enter LLM context.
- Rate-limit per Roblox server and per session.

## Observability

Minimum logs:

- session start/end
- object manifest registration
- tick duration and queue lag
- LLM request id, model, latency, token use, and structured parse result
- directives accepted/rejected
- delta count and payload size
- validator rejection reasons

Minimum metrics:

- backend tick rate
- director calls per minute
- LLM latency p50/p95
- rejected directive rate
- Roblox polling latency
- active object count
- active agent count

## MVP Implementation Plan

1. Extend the current backend schemas with `GameObject`, `ObjectParameters`, and `AgentState`.
2. Add an object registry endpoint: `POST /v1/cells/{cell_id}/objects/register`.
3. Add an observation endpoint: `POST /v1/cells/{cell_id}/observations`.
4. Add a director context builder that groups objects before LLM calls.
5. Add a structured `DirectorDirective` schema.
6. Add validator rules that convert directives into existing simulation actions or visual cues.
7. Extend `CellBackendBridge.server.lua` to map Roblox object attributes/tags into backend parameters.
8. Keep mock provider as the default so test runs and demos do not depend on external LLM availability.
9. Add one scenario: oxygen depletion affects mitochondria, membrane signaling, and learning prompts.

## Open Questions

- Should each Roblox object have a persistent backend id authored at build time, or should ids be assigned during session registration?
- What is the maximum active agent count per Roblox server for the first playable prototype?
- Which object parameters are purely visual, and which are canonical biological state?
- Should teacher/admin controls be routed through Roblox, a web dashboard, or both?
- Is Cloudflare required for production, or is the current FastAPI service the production baseline?

## Blockers, Tradeoffs, And Final Decision

This section evaluates the main design possibilities for stability, scalability, and implementation risk.

### Key Blockers

1. Roblox HTTP limits require batching.
   - `HttpService` is the practical game-server-to-backend bridge, but external HTTP requests are limited. The bridge must batch observations and poll/long-poll for deltas instead of sending one request per object.

2. LLM latency is incompatible with per-frame gameplay.
   - The LLM cannot sit in the critical visual loop. Roblox must animate locally, the backend must simulate deterministically, and the LLM should only run on scenario changes, player inspections, teaching moments, or threshold crossings.

3. Per-object LLM agents will not scale.
   - Thousands of objects can have backend agent records, but not thousands of live LLM conversations. The LLM should reason over grouped summaries, nearby/high-importance objects, and current learning objectives.

4. Backend state must survive Roblox server churn.
   - Roblox servers start, stop, and reconnect. Backend sessions need ids, snapshots, event logs, and replay/recovery paths.

5. LLM output is not a trusted state transition.
   - Structured outputs reduce parsing risk, but biology validity, game balance, cooldowns, safety, and permissions still require deterministic validation.

6. Global coordinators become bottlenecks.
   - A single global room, queue, or Durable Object should not coordinate every active game. Coordination should be sharded by Roblox server/session/cell.

7. Generated text needs moderation and fallbacks.
   - Student-facing explanations should prefer approved message keys/templates. LLM-generated text should be short, filtered, and replaceable with canned fallback copy.

### Design Possibility 1: Roblox-Only Agents

All agent behavior runs in Roblox scripts. MemoryStore or DataStore is used only for cross-server support.

Pros:

- Lowest external infrastructure complexity.
- Lowest latency for visual reactions.
- Works even when external AI providers are unavailable.
- Good for deterministic animation, simple states, and local interactions.

Cons:

- Hard to run real LLM orchestration safely from Roblox.
- API keys cannot live in Roblox.
- Complex simulation and auditability become harder to maintain.
- Roblox MemoryStore is fast and ephemeral, but not durable canonical state.
- Scaling cross-server intelligence requires careful sharding and throttling.

Decision:

- Use Roblox-only logic for local visuals and immediate feedback.
- Do not use Roblox as the main intelligence or canonical state layer.

### Design Possibility 2: FastAPI Backend Authority

The current backend remains the simulation authority. Roblox sends observations over HTTPS and receives approved deltas.

Pros:

- Best fit for the existing repo.
- Easy to test locally with deterministic mock agents.
- Python is strong for simulation, validation, schemas, logging, and OpenAI integration.
- Clear security boundary: Roblox clients never call the backend, and API keys stay server-side.
- Easier to inspect and debug than edge-first distributed state.

Cons:

- A single process or single region can become a latency and availability issue.
- In-memory active state will not be enough for production.
- Needs Redis/Postgres or another managed store as sessions grow.
- Requires deployment, monitoring, autoscaling, and failure handling.

Stability:

- High for MVP if mock mode and deterministic rules are the default.
- Medium for production until active state moves out of process memory.

Scalability:

- Good with batching, stateless API replicas, Redis/Postgres, and sharded session workers.
- Not good if each request loads large world state or each object causes an LLM call.

Decision:

- This is the recommended MVP baseline.

### Design Possibility 3: Cloudflare Worker + Durable Object Authority

Cloudflare Workers receive Roblox HTTP calls. Each Roblox server/session maps to one Durable Object that owns live session state.

Pros:

- Strong fit for per-session coordination.
- Low-latency global ingress.
- Durable Objects provide a natural single coordinator per live game session.
- Horizontal scaling works if each session has its own object.
- Durable Objects support WebSockets for external dashboards or tools, even if Roblox uses HTTP polling.

Cons:

- More operational complexity than the current FastAPI backend.
- Durable Objects are single-threaded per object; one global object would bottleneck.
- CPU, message size, and storage limits require careful design.
- TypeScript edge runtime is less convenient for biology simulation than Python.
- Local development and testing are more complex.

Stability:

- High if each live session has its own Durable Object and state is compact.
- Lower if used for heavy simulation, analytics, or global coordination.

Scalability:

- Very good across many sessions.
- Limited inside one hot session if too many requests target the same Durable Object.

Decision:

- Do not start here for the MVP.
- Keep it as the production coordination layer once gameplay patterns and payloads are proven.

### Design Possibility 4: Hybrid Edge Coordinator + FastAPI Brain

Cloudflare handles ingress, per-session coordination, buffering, and low-latency delta queues. FastAPI handles deeper simulation, validation, persistence, admin tools, and LLM provider integration.

Pros:

- Best long-term architecture.
- Edge layer absorbs Roblox polling and session fan-in.
- FastAPI remains the testable simulation and AI integration brain.
- Allows gradual migration from the current backend.
- Durable Objects can coordinate live sessions while Python services handle heavier work.

Cons:

- Highest moving-part count.
- Requires clear ownership boundaries between edge state and canonical state.
- Failure handling is more complex.
- More expensive to build before the core game loop is proven.

Stability:

- High once mature, because each layer has a focused responsibility.
- Medium during early development because distributed state bugs are likely.

Scalability:

- Best option for production if concurrency grows.
- Scales by sharding sessions across Durable Objects and keeping simulation/LLM work asynchronous.

Decision:

- This is the recommended production target, but not the first implementation step.

### Design Possibility 5: Direct LLM From Roblox

Roblox scripts call an LLM provider directly.

Pros:

- Appears simple in a prototype.
- Fewer backend components on paper.

Cons:

- API keys and provider credentials would be exposed or difficult to protect.
- Clients or game servers could bypass validation.
- Hard to rate-limit, audit, moderate, or recover.
- LLM latency would directly affect gameplay.
- Provider-specific errors would leak into the game loop.

Decision:

- Reject this design.

### Design Possibility 6: One LLM Agent Per Object

Each important object has its own LLM-backed agent loop.

Pros:

- Conceptually attractive.
- Can produce rich individual behavior for a small number of characters or objects.

Cons:

- Does not scale to many Roblox parts or organelles.
- Cost and latency grow with object count.
- Coordination becomes chaotic without a director layer.
- Hard to keep biology/game rules consistent.

Decision:

- Reject as a general architecture.
- Use backend agent records per object, but use LLM calls only for grouped director decisions or selected hero objects.

### Final Decision

Build the MVP as `FastAPI Backend Authority` with a director-ready schema.

The immediate architecture should be:

```text
Roblox Server Bridge
  -> batched HTTPS observations
  -> FastAPI Backend Authority
  -> deterministic simulation + object agent records
  -> optional LLM Game Director with structured directives
  -> validator/reducer
  -> queued visual deltas
  -> Roblox polling/long-polling
```

The production target should be `Hybrid Edge Coordinator + FastAPI Brain` only after the MVP proves:

- expected active object count per server
- observation packet size
- polling frequency
- director-call frequency
- LLM latency and cost
- player-facing educational value

In practical terms:

1. Keep canonical state in the backend, not Roblox.
2. Keep deterministic simulation as the main loop.
3. Use the LLM as a game director, not as per-object physics or per-frame logic.
4. Send grouped summaries to the LLM, not the whole Workspace.
5. Validate every directive before it changes state.
6. Batch Roblox traffic aggressively.
7. Design session boundaries so a future Durable Object can coordinate each live Roblox server without rewriting the simulation core.

### Implementation Decision For This Repo

Next build step:

- Add `GameObject`, `ObjectParameters`, `AgentState`, and `DirectorDirective` schemas to the existing FastAPI backend.
- Add object registration and observation endpoints.
- Add a director context builder that groups objects.
- Keep `AGENT_PROVIDER=mock` as default.
- Add one end-to-end scenario: oxygen depletion causes grouped mitochondria status changes, validated backend deltas, and a concise learning event.

Do not build yet:

- Cloudflare Durable Object layer.
- one LLM conversation per object.
- direct Roblox-to-LLM calls.
- WebSocket dependency for Roblox gameplay.

## Source Notes

- Roblox `HttpService` supports server-side HTTP requests and JSON encode/decode, making it the practical bridge from Roblox server scripts to the backend: https://create.roblox.com/docs/reference/engine/classes/HttpService
- Roblox Open Cloud Messaging can publish messages from external tools to live servers, useful for out-of-band operations: https://create.roblox.com/docs/cloud/guides/usage-messaging
- Roblox MemoryStore is intended for fast ephemeral cross-server state, not durable canonical simulation state: https://create.roblox.com/docs/cloud-services/memory-stores
- Cloudflare Workers support WebSockets, and Durable Objects are recommended as single coordination points for multi-connection real-time sessions: https://developers.cloudflare.com/workers/runtime-apis/websockets/ and https://developers.cloudflare.com/durable-objects/best-practices/websockets/
- OpenAI Structured Outputs are the right pattern for schema-constrained LLM directives instead of free-form parsing: https://platform.openai.com/docs/guides/structured-outputs
