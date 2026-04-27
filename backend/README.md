# Cell Organelle Agents Backend

This backend is the simulation authority for the Roblox cell-learning experience in this repo. It maintains live cell state, runs deterministic organelle logic, validates every action against biology rules, and exposes an HTTP API that Roblox server scripts can call through `HttpService:RequestAsync()`.

## Architecture

```text
Roblox Client UI / 3D Cell
        |
        | RemoteEvent / RemoteFunction
        v
Roblox Server Bridge (Luau, server-authoritative)
        |
        | HTTPS via HttpService:RequestAsync
        v
FastAPI Backend
        |
        +-- API Layer
        +-- Session / Active Cell Store
        +-- Deterministic Simulation Engine
        +-- Biological Action Validator
        +-- Organelle Agent Runtime
        +-- Optional LLM Provider Abstraction
        +-- SQLite Snapshot Store
        +-- Metrics / Structured Logs
```

## What It Does

- Starts per-cell sessions for Roblox game servers.
- Simulates an animal eukaryotic cell with nucleus, ribosome, ER, Golgi, mitochondrion, membrane, lysosome, cytoskeleton, and supporting organelles.
- Produces Roblox-friendly state deltas with semantic visual cues and short student-facing explanations.
- Supports deterministic mock mode with no API keys.
- Provides guarded dev endpoints for scenarios, forced phase changes, stress injection, and metrics.

## Setup

```bash
cd backend
python3 -m venv .venv
./.venv/bin/pip install -e .[dev]
cp .env.example .env
```

## Run Locally

```bash
cd backend
PYTHONPATH=. ./.venv/bin/uvicorn app.main:app --reload
```

Health check:

```bash
curl http://127.0.0.1:8000/health
```

## Run Tests

```bash
cd backend
./.venv/bin/pytest
```

## API Examples

All `/v1/*` endpoints require the shared bearer token from `BACKEND_AUTH_TOKEN`.

Start a session:

```bash
curl -X POST http://127.0.0.1:8000/v1/sessions \
  -H "Authorization: Bearer change-me-local-dev-token" \
  -H "Content-Type: application/json" \
  -d '{
    "roblox_server_id": "server-1",
    "universe_id": "universe-1",
    "place_id": "place-1",
    "player_id_hash": "player-1",
    "cell_type": "animal",
    "frontend_version": "local-dev"
  }'
```

Tick the simulation:

```bash
curl -X POST http://127.0.0.1:8000/v1/cells/<cell_id>/tick \
  -H "Authorization: Bearer change-me-local-dev-token" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "<session_id>",
    "dt": 1.0,
    "last_seen_version": 0,
    "max_events": 50
  }'
```

Inspect an organelle:

```bash
curl -X POST "http://127.0.0.1:8000/v1/cells/<cell_id>/organelles/nucleus-1/inspect?session_id=<session_id>" \
  -H "Authorization: Bearer change-me-local-dev-token"
```

Apply a dev scenario:

```bash
curl -X POST "http://127.0.0.1:8000/v1/dev/scenarios/energy_crisis?cell_id=<cell_id>&session_id=<session_id>" \
  -H "Authorization: Bearer change-me-local-dev-token"
```

## Mock Mode vs OpenAI Mode

Default mode is deterministic mock mode:

```bash
AGENT_PROVIDER=mock
```

This mode is what tests use. It requires no external API access.

Optional OpenAI mode:

```bash
./.venv/bin/pip install openai
OPENAI_API_KEY=...
AGENT_PROVIDER=openai
OPENAI_MODEL=gpt-5.4-mini
```

Notes:

- The deterministic engine still remains the source of truth.
- LLM actions are treated as untrusted and run through the same validator as rule-based actions.
- The current OpenAI provider is intentionally optional and conservative. Mock mode is the supported default.

## Roblox Integration

Example bridge scripts live in [`/roblox_bridge`](../roblox_bridge).

Recommended wiring:

1. Keep the current 3D cell frontend as-is.
2. Add the server bridge script to `ServerScriptService`.
3. Add `CellRemotes.lua` where the bridge can require it.
4. Point `BACKEND_BASE_URL` at this FastAPI service.
5. Keep the bearer token server-side only.

## Environment Variables

See [.env.example](./.env.example).

Important ones:

- `BACKEND_AUTH_TOKEN`
- `AGENT_PROVIDER`
- `DATABASE_URL`
- `TICK_RATE_HZ`
- `DEV_ENDPOINTS_ENABLED`

## Known Limitations

- Active state is stored in-memory with SQLite snapshots for the MVP.
- The simulation models one cell per session.
- Plant cell support is only a future hook.
- Cytokinesis emits a simplified reset path rather than creating daughter-cell game instances.
- Long-polling is implemented; streaming transports are not.
- The optional OpenAI provider is scaffolded, but the tested mode is `mock`.

## Future Hooks

- Redis/Postgres-backed active state
- Multi-cell or multiplayer sessions
- Teacher-mode verbosity
- Persistent progression
- Plant-cell mode
- Real daughter-cell instances after cytokinesis

