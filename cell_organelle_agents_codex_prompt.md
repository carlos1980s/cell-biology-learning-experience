# Codex Prompt: Intelligent Cell Organelle Agents Backend for a Roblox Cell Simulation

Paste this entire document into Codex as the implementation prompt. The goal is to create a backend application that powers a Roblox cell-simulation game whose front end already exists. The backend must maintain live cell state, run a biologically grounded simulation, and expose an API that Roblox server scripts can call. Each major organelle/component should behave like a stateful agent with its own identity, goals, constraints, memory, and interaction rules.

The key product idea is: the Roblox world shows a living cell, while the backend continuously simulates the cell and gives each organelle an intelligence layer. The nucleus, ribosomes, mitochondria, membrane, ER, Golgi, lysosomes, cytoskeleton, and other components should know what they are, where they are, what they are doing, what they need, what they can produce, what they can request from other organelles, and how their local state affects the whole cell.

## 1. Your role

You are Codex acting as a senior full-stack/backend engineer, simulation designer, Roblox integration engineer, and applied AI architect. Build the application, not just a sketch. Favor a working, testable MVP with clear extension points over a fragile over-engineered prototype.

Do not ask blocking questions unless the repository structure makes progress impossible. Make reasonable assumptions and document them in `README.md`.

## 2. Project assumptions

Assume the Roblox front end is already mostly done. The backend should be added as a separate service plus a small Roblox server-side bridge.

Default assumptions unless the existing repository contradicts them:

- The Roblox client/front end already contains 3D organelle objects or UI representations.
- Roblox should not call any LLM API directly.
- Roblox server scripts communicate with this backend using `HttpService:RequestAsync()`.
- Roblox clients communicate with Roblox server scripts using `RemoteEvent`/`RemoteFunction`, not directly with the backend.
- The backend is the simulation authority. The Roblox server is the game authority. The Roblox client is never trusted as a state authority.
- The simulation should start as an animal/eukaryotic cell. Add optional plant-cell support behind feature flags.
- The backend must function in deterministic mock mode without an external LLM so automated tests and local development work without API keys.

## 3. Non-negotiable design principles

1. **Do not run an LLM every frame.** A Roblox game may render at many frames per second, but LLM calls are expensive and slow. The core simulation must be deterministic and tick-based. LLM agents should make periodic or event-triggered high-level decisions, then return strict JSON actions that the deterministic engine validates.

2. **Use strict state schemas.** All state passed between Roblox, backend, and agents must be structured JSON. Do not let free-form model text directly mutate cell state.

3. **Biology first, game second, LLM third.** The LLM layer should make organelles feel intelligent, but the physics/biology rules must prevent impossible actions.

4. **Every action must be validated.** If a ribosome tries to translate without mRNA or amino acids, reject or downgrade the action. If the nucleus tries to enter mitosis before DNA replication is complete, block it through checkpoints.

5. **Backend is source of truth.** The Roblox client should receive deltas and visual cues, not own canonical cell state.

6. **Keep latency predictable.** Return immediate state deltas from deterministic simulation. Queue slower LLM deliberations and merge their validated actions later.

7. **Build educational explainability.** Each organelle action should optionally include a short plain-English explanation suitable for player feedback, debug panels, or teacher mode.

8. **Avoid wet-lab protocol content.** This is a game simulation. Keep biology conceptual and educational; do not generate real experimental protocols.

## 4. Recommended implementation stack

Use this stack unless the repository already has a clear different stack:

- Backend language: Python 3.12+
- API framework: FastAPI
- Data validation: Pydantic v2
- Local persistence: SQLite for MVP
- Production-ready persistence abstraction: Postgres-compatible repository interface
- Ephemeral active state/cache: in-memory store for MVP, Redis-compatible adapter later
- Background tasks: asyncio task loop for MVP; leave adapter for Celery/RQ/Arq if needed
- LLM provider: abstraction layer with `MockAgentProvider` and `OpenAIResponsesProvider`
- Testing: pytest
- API documentation: FastAPI OpenAPI + README
- Roblox bridge: Luau scripts under `/roblox` or `/roblox_bridge`

If using TypeScript is strongly preferred by the existing repo, implement the same architecture with Fastify/NestJS, Zod, Prisma, and Vitest. Preserve the API contracts and behavior from this document.

## 5. Research-informed constraints to encode

Use these biological constraints as rules in the simulation. They are simplified for game use but should preserve the main causal relationships.

### 5.1 Core eukaryotic cell compartments

Major animal/eukaryotic organelles include nucleus, endoplasmic reticulum, Golgi apparatus, mitochondria, lysosomes, endosomes, peroxisomes, cytosol/cytoplasm, and plasma membrane. Plant mode can add chloroplasts, central vacuole, and cell wall.

### 5.2 Nucleus

The nucleus houses the genome and functions as the control center for genetic information. DNA replication, transcription, and RNA processing happen in the nucleus. Translation happens in the cytoplasm/at ribosomes, not inside the nucleus.

Simulation rules:

- Nucleus can transcribe genes into pre-mRNA/mRNA.
- Nucleus can process/export mRNA.
- Nucleus can start DNA replication only in S phase.
- Nucleus can request DNA repair if damage exceeds threshold.
- Nucleus controls cell-cycle transitions through checkpoints but cannot override failed checkpoint validation.

### 5.3 Ribosomes

Ribosomes translate mRNA into proteins. Free ribosomes synthesize proteins used in cytosol and some organelles. ER-bound ribosomes synthesize proteins destined for secretion, membranes, ER, Golgi, lysosomes, and endomembrane pathways.

Simulation rules:

- Ribosome requires mRNA, amino acids, and energy to produce protein products.
- Protein output depends on mRNA job type.
- Ribosomes may be `free` or `rough_er_bound`.
- Ribosome load increases when transcript queues are high.

### 5.4 Endoplasmic reticulum

The ER is a major site for lipid and protein biosynthesis. Rough ER handles membrane/secretory protein synthesis and folding/QC; smooth ER handles lipid synthesis, detox-style abstraction, and calcium storage.

Simulation rules:

- Rough ER receives membrane/secretory proteins from ribosomes.
- Rough ER can fold, modify, or reject misfolded proteins.
- Misfolded-protein load creates ER stress.
- Smooth ER produces lipids and regulates calcium pool.

### 5.5 Golgi apparatus

The Golgi modifies, sorts, packages, and dispatches proteins/lipids received from the ER. It sends vesicles to lysosomes, plasma membrane, or secretion/export destinations.

Simulation rules:

- Golgi receives vesicles from ER.
- Golgi modifies cargo and assigns destinations.
- Golgi output creates vesicle jobs.
- Golgi backlog creates trafficking stress.

### 5.6 Mitochondria

Mitochondria produce most of the useful ATP energy from carbohydrates/lipids in animal cells. They also manage metabolic stress signals.

Simulation rules:

- Mitochondria consume nutrients and oxygen-like resources to generate ATP.
- Low nutrients or oxygen reduces ATP output.
- High workload can increase ROS-like stress.
- Mitochondria can request glucose/oxygen import via membrane and warn nucleus under severe stress.

### 5.7 Plasma membrane

The plasma membrane is a selective barrier. Transport proteins determine selective permeability and allow specific molecules to cross.

Simulation rules:

- Membrane regulates import/export of glucose, amino acids, oxygen-like resource, ions, water, waste, and signaling molecules.
- Membrane can react to external environment and player-triggered stimuli.
- Membrane damage affects leakiness/osmotic stress.

### 5.8 Lysosomes/endosomes

Lysosomes digest and recycle material taken up from outside the cell or from damaged internal components. Endosomes sort material from endocytosis and can route material to recycling or lysosomes.

Simulation rules:

- Lysosomes consume waste/damaged cargo and return recycled resources.
- Endosomes sort incoming material and route to membrane recycling or lysosomal degradation.
- Lysosomal capacity can be overloaded.

### 5.9 Peroxisomes

Peroxisomes perform oxidation reactions, fatty-acid metabolism, and detoxify hydrogen peroxide-like stress through catalase-style abstraction.

Simulation rules:

- Peroxisomes reduce ROS/toxin-like stress.
- Peroxisomes can process lipid/fatty-acid resources.
- Low peroxisome health increases oxidative stress.

### 5.10 Cytoskeleton and centrosome

The cytoskeleton supports cell shape, transport, organelle positioning, and mitotic spindle formation. Centrosomes organize microtubules and are important during mitosis.

Simulation rules:

- Cytoskeleton moves vesicles and organelles.
- Cytoskeleton integrity affects transport speed.
- During mitosis, centrosome/cytoskeleton must prepare spindle and chromosome alignment.

### 5.11 Cell cycle

The eukaryotic cell cycle uses G1, S, G2, and M phases. S phase is DNA replication; M phase is mitosis and usually cytokinesis. Checkpoints should gate transitions: G1/S, G2/M, and metaphase/anaphase.

Simulation rules:

- G1: growth, normal metabolism, protein production, resource accumulation.
- S: DNA replication, higher nucleotide/ATP demand.
- G2: repair/check, preparation for mitosis.
- M: prophase → prometaphase → metaphase → anaphase → telophase → cytokinesis.
- Do not allow mitosis if DNA replication incomplete, severe DNA damage exists, ATP too low, or spindle checkpoint fails.

## 6. Product behavior

The player should experience the cell as a living system:

- Each organelle can be inspected.
- Each organelle reports current task, health, stress, inputs, outputs, and recent decisions.
- Organelle behavior changes when resources, damage, stress, or player actions change.
- Organelles collaborate: the nucleus emits mRNA jobs, ribosomes translate, ER folds, Golgi packages, mitochondria supply ATP, membrane imports nutrients, lysosomes recycle waste.
- The cell can enter states such as `homeostasis`, `growth`, `stress_response`, `dna_repair`, `protein_production_surge`, `energy_crisis`, `mitosis_preparation`, `mitosis`, and `recovery`.
- The backend sends Roblox visual cues: color shifts, glow intensity, particle cue names, animations, UI text, state deltas, and organelle status labels.

## 7. Architecture overview

Implement this layered architecture:

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
        +-- Session Manager
        +-- Cell Simulation Engine
        +-- Event Bus / State Delta Reducer
        +-- Organelle Agent Runtime
        +-- LLM Provider Abstraction
        +-- Persistence Layer
        +-- Metrics / Logs
```

### Important Roblox transport note

For production reliability, assume the Roblox game server makes outbound HTTPS requests to the backend using `HttpService:RequestAsync()`. Use polling or long-polling for state deltas. If WebStreamClient/SSE/WebSocket support is available in the target Roblox runtime, implement it only as an optional adapter after confirming live-server support; do not make streaming the only transport.

## 8. Backend modules to create

Create a repository structure similar to this:

```text
/backend
  app/
    main.py
    config.py
    api/
      routes_sessions.py
      routes_cells.py
      routes_agents.py
      routes_admin.py
    schemas/
      common.py
      cell_state.py
      organelles.py
      events.py
      actions.py
      api.py
    sim/
      engine.py
      reducer.py
      biological_rules.py
      cell_cycle.py
      resources.py
      scenarios.py
    agents/
      base.py
      runtime.py
      prompts.py
      provider_base.py
      provider_mock.py
      provider_openai.py
      registry.py
      organelle_cards.py
    storage/
      base.py
      sqlite_store.py
      memory_store.py
    security/
      auth.py
      rate_limit.py
    observability/
      logging.py
      metrics.py
  tests/
    test_simulation_rules.py
    test_cell_cycle.py
    test_api_contracts.py
    test_agent_validation.py
    test_scenarios.py
  README.md
  pyproject.toml
  .env.example
/roblox_bridge
  CellBackendBridge.server.lua
  CellRemotes.lua
  CellClientExample.client.lua
  README.md
```

If the repo already has a structure, adapt this cleanly and do not duplicate unnecessary roots.

## 9. Core data model

Use Pydantic models. Names may vary, but preserve these concepts.

### 9.1 Enums

```python
OrganelleType = Literal[
    "nucleus", "nucleolus", "ribosome", "rough_er", "smooth_er", "golgi",
    "mitochondrion", "plasma_membrane", "cytoplasm", "cytoskeleton",
    "lysosome", "endosome", "peroxisome", "centrosome", "vesicle",
    "chloroplast", "vacuole", "cell_wall"
]

CellCyclePhase = Literal[
    "G0", "G1", "S", "G2", "M_PROPHASE", "M_PROMETAPHASE", "M_METAPHASE",
    "M_ANAPHASE", "M_TELOPHASE", "CYTOKINESIS"
]

CellMode = Literal[
    "homeostasis", "growth", "stress_response", "energy_crisis", "dna_repair",
    "protein_production_surge", "mitosis_preparation", "mitosis", "recovery"
]

ActionType = Literal[
    "transcribe_gene", "export_mrna", "replicate_dna", "repair_dna",
    "translate_mrna", "fold_protein", "package_cargo", "dispatch_vesicle",
    "produce_atp", "import_resource", "export_waste", "recycle_waste",
    "reduce_stress", "move_cargo", "prepare_spindle", "advance_cell_cycle",
    "send_signal", "request_resource", "idle", "explain_state"
]
```

### 9.2 CellState

```python
class CellState(BaseModel):
    cell_id: str
    session_id: str
    tick: int
    sim_time_seconds: float
    cell_type: Literal["animal", "plant"] = "animal"
    cycle_phase: CellCyclePhase
    mode: CellMode
    health: float  # 0..1
    resources: ResourcePools
    environment: EnvironmentState
    organelles: dict[str, OrganelleState]
    queues: CellQueues
    global_signals: list[Signal]
    recent_events: list[CellEvent]
    version: int
```

### 9.3 ResourcePools

Use normalized game units, not real molar concentrations.

```python
class ResourcePools(BaseModel):
    atp: float
    adp: float
    glucose: float
    oxygen: float
    amino_acids: float
    nucleotides: float
    lipids: float
    water: float
    ions: float
    mrna: float
    proteins: float
    folded_proteins: float
    membrane_proteins: float
    secretory_cargo: float
    waste: float
    damaged_components: float
    ros: float
    calcium: float
```

Clamp all resource values to safe ranges. Values should not go negative.

### 9.4 OrganelleState

```python
class OrganelleState(BaseModel):
    organelle_id: str
    type: OrganelleType
    display_name: str
    location: Vector3Like
    health: float
    activity: float
    stress: float
    energy_budget: float
    current_task: str
    task_progress: float
    local_resources: dict[str, float]
    inbox: list[Signal]
    outbox: list[Signal]
    memory: OrganelleMemory
    cooldowns: dict[str, float]
    visual_state: VisualState
```

### 9.5 OrganelleMemory

```python
class OrganelleMemory(BaseModel):
    summary: str
    recent_observations: list[str]
    recent_actions: list[str]
    known_dependencies: list[str]
    known_outputs: list[str]
```

Keep memory short and compress frequently. Do not pass entire game history to an LLM.

### 9.6 AgentAction

The LLM and mock agents must emit this type only:

```python
class AgentAction(BaseModel):
    action_id: str
    organelle_id: str
    action_type: ActionType
    target_id: str | None = None
    priority: int = Field(ge=0, le=10)
    magnitude: float = Field(ge=0, le=1)
    duration_ticks: int = Field(ge=1, le=100)
    consumes: dict[str, float] = {}
    produces: dict[str, float] = {}
    signal: Signal | None = None
    visual_cue: VisualCue | None = None
    explanation: str = ""
    confidence: float = Field(ge=0, le=1)
```

### 9.7 CellEvent

```python
class CellEvent(BaseModel):
    event_id: str
    seq: int
    tick: int
    source: str
    type: str
    payload: dict[str, Any]
    created_at: datetime
```

### 9.8 StateDelta for Roblox

Roblox should usually receive deltas, not full state.

```python
class StateDelta(BaseModel):
    cell_id: str
    from_version: int
    to_version: int
    tick: int
    organelle_updates: list[OrganelleVisualUpdate]
    resource_updates: dict[str, float]
    cell_mode: CellMode
    cycle_phase: CellCyclePhase
    alerts: list[str]
    events: list[CellEvent]
```

## 10. Agent runtime

Implement an `OrganelleAgent` base class with:

```python
class OrganelleAgent(Protocol):
    organelle_type: OrganelleType
    def build_observation(self, cell: CellState, self_state: OrganelleState) -> AgentObservation: ...
    async def decide(self, observation: AgentObservation) -> list[AgentAction]: ...
```

Then implement:

- `RuleBasedOrganelleAgent`: deterministic behavior for each organelle.
- `LLMOrganelleAgent`: calls provider only when `should_deliberate(...)` returns true.
- `HybridOrganelleAgent`: starts with rule-based suggestions, lets LLM choose or explain under event triggers.

### 10.1 Agent scheduling

Create an `AgentRuntime` that:

- Maintains a registry of organelle agents.
- On every simulation tick, runs fast deterministic rules.
- Every N ticks, or when stress/event thresholds are crossed, asks selected agents to deliberate.
- Limits concurrent LLM deliberations.
- Times out slow LLM calls.
- Validates all actions through `biological_rules.validate_action`.
- Converts valid actions into state mutations using the reducer.

Suggested cadence:

- Simulation tick: 2-10 ticks/second on backend.
- Roblox delta polling: 0.5-2 seconds, configurable.
- LLM organelle deliberation: 5-20 seconds per selected organelle, or event-triggered.
- Emergency deterministic responses: immediate, no LLM needed.

### 10.2 When to call an LLM

Call the LLM only for:

- Strategic organelle decisions when multiple valid options exist.
- Explaining state to player/teacher mode.
- Creating personality-like status lines for organelles.
- Handling unusual player events.
- Coordinating multi-organelle plans.

Do not call an LLM for:

- Simple resource arithmetic.
- Every frame/tick.
- Validating physics/biology.
- Security decisions.

## 11. LLM provider

Implement provider abstraction:

```python
class AgentProvider(Protocol):
    async def propose_actions(
        self,
        agent_card: OrganelleCard,
        observation: AgentObservation,
        schema: type[BaseModel]
    ) -> list[AgentAction]: ...
```

### 11.1 Mock provider

`MockAgentProvider` must return deterministic JSON actions so tests can run without API calls.

### 11.2 OpenAI provider

`OpenAIResponsesProvider` should:

- Read `OPENAI_API_KEY` from environment.
- Use structured outputs / JSON schema.
- Keep prompts short and include only relevant observation fields.
- Never allow model output to directly mutate state.
- Return only validated `AgentAction` objects.
- Log model latency and token/cost metadata when available.
- Use a model configurable by env, defaulting to a small/fast model for development.

Do not hard-code API keys. Do not put API keys in Roblox files.

### 11.3 Generic system prompt for organelle agents

Create reusable prompt text similar to:

```text
You are the intelligence layer for one organelle in an educational Roblox cell simulation.
You are not a human character. You are a bounded biological controller for your organelle.
You must preserve biological plausibility and obey the provided action schema.
You cannot directly change the world. You can only propose actions.
You must not invent resources, bypass checkpoints, or perform another organelle's role.
Return only actions that your organelle can perform.
Keep explanations short, accurate, and suitable for students.
```

### 11.4 Agent card prompt fields

Every organelle agent should have an `OrganelleCard`:

```python
class OrganelleCard(BaseModel):
    type: OrganelleType
    name: str
    role: str
    biological_scope: list[str]
    can_do: list[ActionType]
    cannot_do: list[str]
    consumes: list[str]
    produces: list[str]
    depends_on: list[OrganelleType]
    communicates_with: list[OrganelleType]
    failure_modes: list[str]
```

## 12. Organelle agent cards and behavior

Implement cards and rule-based behavior for at least the following.

### 12.1 NucleusAgent

Role: genome manager, transcription planner, cell-cycle checkpoint controller.

Can do:

- `transcribe_gene`
- `export_mrna`
- `replicate_dna`
- `repair_dna`
- `advance_cell_cycle`
- `send_signal`

Consumes:

- ATP, nucleotides

Produces:

- mRNA jobs, cell-cycle signals, repair signals

Depends on:

- Mitochondria for ATP
- Ribosomes/ER/Golgi for proteins needed by cell
- Centrosome/cytoskeleton during mitosis

Rules:

- In G1, prioritize normal transcription and growth-support proteins.
- In S, prioritize DNA replication and use nucleotides/ATP.
- In G2, check DNA replication completeness and stress.
- In M phases, stop normal high-volume transcription and coordinate mitosis.
- If DNA damage high, enter `dna_repair` mode and suppress mitosis.

### 12.2 NucleolusAgent

Role: ribosome subunit production coordinator.

Can do:

- `send_signal`
- `request_resource`
- `explain_state`

Simulation abstraction:

- Increase ribosome capacity when amino acids, nucleotides, ATP, and nucleus health are adequate.
- Reduce capacity under stress or mitosis.

### 12.3 RibosomeAgent

Role: protein synthesis from mRNA.

Can do:

- `translate_mrna`
- `request_resource`
- `send_signal`

Consumes:

- mRNA jobs, amino acids, ATP/GTP-like energy

Produces:

- cytosolic proteins, ER-bound protein cargo, enzymes, membrane protein precursors

Rules:

- Cannot translate without mRNA and amino acids.
- Free ribosome jobs produce cytosolic/internal proteins.
- Rough-ER-bound jobs produce secretory/membrane/endomembrane cargo and hand off to RoughERAgent.
- If mRNA queue is high but amino acids low, request membrane/cytoplasm import.

### 12.4 RoughERAgent

Role: folding, quality control, and early processing of proteins entering endomembrane pathway.

Can do:

- `fold_protein`
- `package_cargo`
- `send_signal`
- `request_resource`

Consumes:

- unfolded cargo, ATP, chaperone capacity abstraction

Produces:

- folded cargo, misfolded cargo/waste, vesicles to Golgi

Rules:

- High unfolded cargo increases activity.
- Misfolded cargo increases ER stress.
- Severe ER stress signals nucleus and slows protein production.

### 12.5 SmoothERAgent

Role: lipid synthesis, calcium store, detoxification abstraction.

Can do:

- `reduce_stress`
- `request_resource`
- `send_signal`

Consumes:

- ATP, lipid precursors

Produces:

- lipids, calcium-buffering effect, reduced toxin/stress

Rules:

- Produces lipids for membranes when growth or repair mode is active.
- Helps reduce toxin-like stress if resources allow.

### 12.6 GolgiAgent

Role: modification, sorting, and dispatch of cargo.

Can do:

- `package_cargo`
- `dispatch_vesicle`
- `send_signal`

Consumes:

- folded ER cargo, ATP

Produces:

- vesicles for plasma membrane, lysosome, secretion/export, or storage

Rules:

- Sort cargo by destination.
- If backlog high, request cytoskeleton transport and signal ER to slow cargo.

### 12.7 MitochondrionAgent

Role: ATP production and metabolic stress manager.

Can do:

- `produce_atp`
- `reduce_stress`
- `request_resource`
- `send_signal`

Consumes:

- glucose, oxygen, ADP

Produces:

- ATP, low-level ROS

Rules:

- Increase ATP production when global ATP low and resources available.
- If oxygen/glucose low, request membrane import.
- If ROS high, coordinate with peroxisome/lysosome/stress response.

### 12.8 PlasmaMembraneAgent

Role: boundary, selective transport, receptor-like sensing.

Can do:

- `import_resource`
- `export_waste`
- `send_signal`
- `reduce_stress`

Consumes:

- ATP for active transport when required

Produces:

- imported nutrients, exported waste, environment signals

Rules:

- Import nutrients based on demand and environment.
- Export waste when waste high.
- Damage increases leakiness and stress.
- Never let client/user directly set internal resource values; player inputs become environment changes or requests.

### 12.9 CytoplasmAgent

Role: shared medium for diffusion and local resource balancing.

Can do:

- `move_cargo`
- `send_signal`
- `explain_state`

Rules:

- Smooth out local resource imbalances.
- Route global signals.
- Provide summary of resource pools.

### 12.10 CytoskeletonAgent

Role: structural support, intracellular transport, spindle prep.

Can do:

- `move_cargo`
- `prepare_spindle`
- `send_signal`

Consumes:

- ATP

Produces:

- transport progress, mitosis readiness

Rules:

- Move vesicles from ER to Golgi, Golgi to membrane/lysosome.
- Under stress/damage, transport efficiency drops.
- During mitosis, prioritize spindle and chromosome alignment.

### 12.11 LysosomeAgent

Role: degradation and recycling.

Can do:

- `recycle_waste`
- `reduce_stress`
- `send_signal`

Consumes:

- waste, damaged components, ATP

Produces:

- amino acids, lipids, recycled resources

Rules:

- Increase activity when waste/damaged components are high.
- Can be overloaded.
- Supports recovery after stress.

### 12.12 EndosomeAgent

Role: sorting internalized membrane/external material.

Can do:

- `dispatch_vesicle`
- `recycle_waste`
- `send_signal`

Rules:

- Route useful components back to membrane/cytoplasm.
- Route harmful or unusable cargo to lysosome.

### 12.13 PeroxisomeAgent

Role: oxidative stress and fatty-acid handling.

Can do:

- `reduce_stress`
- `request_resource`
- `send_signal`

Rules:

- Reduce ROS/toxin-like stress using catalase abstraction.
- Process fatty-acid/lipid resource under energy demand.

### 12.14 CentrosomeAgent

Role: microtubule organization and mitotic spindle coordination.

Can do:

- `prepare_spindle`
- `send_signal`

Rules:

- In interphase, supports cytoskeleton organization.
- During M phase, manages spindle readiness.
- Metaphase/anaphase transition requires spindle checkpoint pass.

### 12.15 Optional Plant Agents

Implement only if easy after MVP or behind `cell_type="plant"`:

- ChloroplastAgent: light-driven ATP/sugar abstraction.
- VacuoleAgent: storage, turgor/osmotic balance.
- CellWallAgent: structural boundary outside plasma membrane.

## 13. Biological rule validator

Create `biological_rules.py` with pure functions that validate actions. Examples:

```python
def validate_action(cell: CellState, action: AgentAction) -> ValidationResult:
    ...
```

Validation examples:

- `transcribe_gene` valid only for nucleus and requires ATP/nucleotides.
- `translate_mrna` valid only for ribosome and requires mRNA/amino_acids/ATP.
- `fold_protein` valid only for rough ER and requires unfolded cargo.
- `package_cargo` valid for rough ER or Golgi depending on cargo stage.
- `produce_atp` valid only for mitochondrion and requires glucose/oxygen/ADP.
- `advance_cell_cycle` valid only through nucleus/coordinator and only if checkpoints pass.
- `prepare_spindle` valid only for cytoskeleton/centrosome during G2/M.
- `dispatch_vesicle` requires cargo and cytoskeleton transport capacity.
- Resources consumed cannot exceed available pools unless action is downgraded.

The validator should return:

```python
class ValidationResult(BaseModel):
    accepted: bool
    adjusted_action: AgentAction | None
    reasons: list[str]
```

If action magnitude is too high but otherwise valid, downgrade it instead of rejecting.

## 14. Simulation loop

Implement `SimulationEngine.step(cell_id, dt)`:

1. Load active `CellState`.
2. Increment tick/time.
3. Apply environment effects.
4. Run deterministic resource metabolism.
5. Run rule-based organelle behaviors.
6. Select any organelles requiring LLM deliberation.
7. Enqueue/await LLM actions with timeout depending on mode.
8. Validate actions.
9. Apply accepted actions through reducer.
10. Check cell-cycle transitions and global modes.
11. Generate Roblox-friendly visual deltas.
12. Persist snapshot every N ticks or important event.
13. Return `StateDelta`.

### 14.1 Reducer rules

Use a reducer so state changes are centralized and auditable:

```python
def apply_action(cell: CellState, action: AgentAction) -> tuple[CellState, list[CellEvent]]:
    ...
```

No agent may mutate state directly.

### 14.2 Resource model

Start simple but consistent:

- ATP decreases with active work.
- ADP increases when ATP consumed.
- Mitochondria convert glucose + oxygen + ADP to ATP.
- Ribosomes convert mRNA + amino acids + ATP to protein products.
- Rough ER converts unfolded cargo to folded cargo or waste.
- Golgi converts folded cargo to vesicle cargo/deliveries.
- Lysosome converts waste/damaged components to recycled amino acids/lipids.
- Membrane imports based on external availability and demand.

Do not try to implement full biochemical kinetics. Use normalized units and clear comments.

## 15. Cell-cycle model

Implement a `cell_cycle.py` module.

State fields should include:

```python
class CellCycleState(BaseModel):
    phase: CellCyclePhase
    phase_progress: float
    dna_replicated: float  # 0..1
    dna_damage: float      # 0..1
    spindle_ready: float   # 0..1
    chromosome_alignment: float # 0..1
    checkpoint_failures: list[str]
```

Transitions:

- G0 → G1 if growth signal and resources adequate.
- G1 → S if cell size/resources sufficient and DNA damage low.
- S → G2 when DNA replication reaches 1.0.
- G2 → M_PROPHASE if replication complete, DNA damage low, ATP sufficient.
- M_PROPHASE → M_PROMETAPHASE → M_METAPHASE based on progress.
- M_METAPHASE → M_ANAPHASE only if spindle/chromosome alignment checkpoint passes.
- M_ANAPHASE → M_TELOPHASE → CYTOKINESIS.
- CYTOKINESIS produces either two daughter cell records or a simplified `division_complete` event depending on MVP scope.

For MVP, it is acceptable to emit `division_complete` and reset to G1 rather than managing two independent Roblox cell instances, but structure the code so daughter cells can be added later.

## 16. API contract

Implement these endpoints.

### 16.1 Health

`GET /health`

Returns:

```json
{ "ok": true, "version": "0.1.0" }
```

### 16.2 Start session

`POST /v1/sessions`

Request:

```json
{
  "roblox_server_id": "string",
  "universe_id": "string",
  "place_id": "string",
  "player_id_hash": "string",
  "cell_type": "animal",
  "frontend_version": "string"
}
```

Response:

```json
{
  "session_id": "string",
  "cell_id": "string",
  "auth_expires_at": "datetime",
  "initial_state": {},
  "initial_delta": {}
}
```

### 16.3 Submit player/game input

`POST /v1/cells/{cell_id}/input`

Request:

```json
{
  "session_id": "string",
  "seq": 123,
  "input_type": "add_resource | stress_event | inspect_organelle | player_command | environment_change",
  "payload": {}
}
```

Input examples:

```json
{ "input_type": "add_resource", "payload": { "resource": "glucose", "amount": 10 } }
```

```json
{ "input_type": "inspect_organelle", "payload": { "organelle_id": "nucleus-1" } }
```

### 16.4 Tick / poll state

`POST /v1/cells/{cell_id}/tick`

Request:

```json
{
  "session_id": "string",
  "dt": 1.0,
  "last_seen_version": 42,
  "max_events": 50
}
```

Response:

```json
{
  "delta": {},
  "server_time": "datetime",
  "recommended_next_poll_ms": 1000
}
```

### 16.5 Get full state

`GET /v1/cells/{cell_id}?session_id=...`

Returns full `CellState`. Use for debug and resync.

### 16.6 Long poll events

`GET /v1/cells/{cell_id}/events?session_id=...&after_seq=123&timeout_ms=15000`

Returns new events or times out. This helps reduce polling spam.

### 16.7 Inspect organelle

`POST /v1/cells/{cell_id}/organelles/{organelle_id}/inspect`

Returns:

```json
{
  "organelle_id": "nucleus-1",
  "display_name": "Nucleus",
  "status": "Preparing transcription plan",
  "health": 0.92,
  "stress": 0.12,
  "inputs_needed": ["ATP", "nucleotides"],
  "outputs": ["mRNA", "cell-cycle signals"],
  "explanation": "The nucleus is producing mRNA instructions for ribosomes while monitoring whether the cell has enough resources to grow."
}
```

### 16.8 Admin/debug scenario endpoints

Implement guarded debug endpoints for local/dev only:

- `POST /v1/dev/scenarios/{scenario_name}`
- `POST /v1/dev/cells/{cell_id}/force_phase`
- `POST /v1/dev/cells/{cell_id}/stress`

Disable in production by config.

## 17. Roblox bridge requirements

Create Luau bridge scripts. The exact frontend object names may differ, so make them configurable.

### 17.1 Server bridge responsibilities

`CellBackendBridge.server.lua` should:

- Read backend base URL from configuration.
- Read backend auth token/secret from Roblox server-side secret/config, never from client.
- Start a backend session when a server/player initializes the cell.
- Use `HttpService:RequestAsync()` for API calls.
- Poll `/tick` or `/events` at a configurable interval.
- Convert backend deltas into `RemoteEvent` messages for clients.
- Receive client requests through `RemoteEvent`, validate allowed request types, and forward sanitized inputs to backend.
- Retry transient HTTP failures with backoff.
- Avoid blocking gameplay if backend temporarily fails; display degraded/offline state.

### 17.2 Suggested RemoteEvents

Create/find these in `ReplicatedStorage`:

- `CellStateDelta` — server → client, carries visual/state deltas.
- `CellInputRequest` — client → server, carries player interactions.
- `OrganelleInspectResult` — server → client, returns inspection info.
- `CellBackendStatus` — server → client, backend health/errors.

### 17.3 Example Luau HTTP request shape

```lua
local HttpService = game:GetService("HttpService")

local function requestBackend(path, method, bodyTable)
    local url = BACKEND_BASE_URL .. path
    local body = bodyTable and HttpService:JSONEncode(bodyTable) or ""

    local response = HttpService:RequestAsync({
        Url = url,
        Method = method,
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. BACKEND_TOKEN,
        },
        Body = body,
    })

    if not response.Success then
        warn("Backend request failed", response.StatusCode, response.Body)
        return nil
    end

    return HttpService:JSONDecode(response.Body)
end
```

If Roblox secret objects are available, use them instead of literal tokens. Keep secrets server-side only.

### 17.4 Client behavior

The client should not compute biology. It should:

- Render organelle status from deltas.
- Send player interactions to server.
- Display inspection result text.
- Gracefully handle missing fields.

## 18. Security requirements

- Never expose the OpenAI API key to Roblox.
- Never expose backend admin endpoints in production.
- Do not trust Roblox client payloads.
- Backend should authenticate Roblox server requests.
- Use per-session IDs and rate limiting.
- Use request sequence numbers to reduce replay/double-submit effects.
- Validate request JSON with Pydantic.
- Cap payload sizes.
- Log suspicious input types and reject unknown commands.
- Treat all LLM output as untrusted until schema-valid and biology-valid.

Implement at least simple Bearer token auth for MVP. Add HMAC request signing later if practical.

## 19. Observability

Add structured logs for:

- Session start/end
- Tick duration
- LLM call latency
- LLM action validation failures
- Cell mode changes
- Cell-cycle transitions
- Resource crisis events
- Backend errors

Add a simple metrics endpoint in dev:

`GET /v1/admin/metrics`

Return JSON counters. Do not require Prometheus in MVP, but design so it can be added.

## 20. Simulation scenarios for testing and demo

Create scenario seeds:

### 20.1 Normal homeostasis

- Adequate glucose, oxygen, amino acids.
- Nucleus transcribes at moderate rate.
- Ribosomes translate.
- Mitochondria maintain ATP.
- Waste remains low.

Expected: stable health and `homeostasis` mode.

### 20.2 Energy crisis

- Low glucose/oxygen.
- ATP drops.
- Mitochondria request import.
- Membrane increases nutrient import if environment has resources.
- Nucleus reduces nonessential transcription.

Expected: `energy_crisis` then recovery if resources added.

### 20.3 Protein production surge

- Player triggers growth/synthesis signal.
- Nucleus increases mRNA.
- Ribosome queue rises.
- Rough ER and Golgi load rise.
- If overload occurs, ER/Golgi stress signals throttle production.

Expected: high activity but no negative resources.

### 20.4 Waste overload

- Damaged components/waste high.
- Lysosome increases recycling.
- Peroxisome reduces stress if ROS high.

Expected: waste decreases, recycled resources increase.

### 20.5 Mitosis preparation

- Resources high, DNA damage low.
- G1 → S → G2 → M.
- S consumes nucleotides/ATP.
- G2 checkpoint validates replication.
- M requires centrosome/cytoskeleton readiness.

Expected: phase transitions occur in order; no skipping.

### 20.6 DNA damage checkpoint

- DNA damage high.
- Nucleus enters repair mode.
- G1/S or G2/M blocked.

Expected: no mitosis until repair lowers damage.

## 21. Tests

Write pytest tests for:

- API health and session start.
- Full `CellState` can serialize/deserialize.
- Resources never go negative after actions.
- Ribosome cannot translate without mRNA/amino acids.
- Nucleus cannot advance to M phase before DNA replication complete.
- Mitochondria produce ATP only with required resources.
- Golgi cannot dispatch cargo it does not have.
- Lysosome recycling reduces waste.
- LLM/mock invalid action is rejected by validator.
- Scenario tests reach expected modes.
- Roblox delta format contains only JSON-serializable primitives.

Tests must not call the real OpenAI API.

## 22. Frontend delta design

Each organelle update should be easy for Roblox to consume:

```json
{
  "organelle_id": "mitochondrion-1",
  "type": "mitochondrion",
  "display_name": "Mitochondrion",
  "health": 0.88,
  "activity": 0.74,
  "stress": 0.22,
  "current_task": "Producing ATP",
  "task_progress": 0.51,
  "visual_cue": {
    "animation": "pulse_energy",
    "color_hint": "energy_high",
    "intensity": 0.74,
    "particles": ["atp_spark"]
  },
  "speech": "ATP production increased because the cell is using more energy.",
  "alerts": []
}
```

Use semantic cue names, not hard-coded Roblox asset IDs, unless existing assets are known.

## 23. Agent interaction examples

### 23.1 Nucleus to Ribosomes

Nucleus action:

```json
{
  "action_type": "transcribe_gene",
  "produces": { "mrna": 4.0 },
  "signal": { "target_type": "ribosome", "message": "Translate growth proteins" }
}
```

Ribosome response:

```json
{
  "action_type": "translate_mrna",
  "consumes": { "mrna": 2.0, "amino_acids": 3.0, "atp": 1.0 },
  "produces": { "proteins": 2.5 }
}
```

### 23.2 Ribosome to Rough ER to Golgi

Ribosome produces ER cargo → Rough ER folds cargo → Golgi packages cargo → Cytoskeleton moves vesicle → Membrane receives membrane protein/export cargo.

### 23.3 Mitochondria to Membrane

Mitochondrion detects low glucose/oxygen and sends resource request. Membrane imports if external resources are available.

### 23.4 Stress response

If ROS and damaged components rise:

- Peroxisome reduces ROS.
- Lysosome recycles damaged components.
- Nucleus slows cell-cycle progression.
- Mitochondria reduce overproduction if stress remains high.

## 24. MVP implementation phases

Work in this order.

### Phase 1: Skeleton

- Create FastAPI app.
- Add config/env handling.
- Add schemas.
- Add health endpoint.
- Add pytest setup.

### Phase 2: State and deterministic simulation

- Implement initial animal cell factory.
- Implement resource model.
- Implement organelle states.
- Implement deterministic tick.
- Implement state delta generation.

### Phase 3: API

- Implement session start.
- Implement input endpoint.
- Implement tick endpoint.
- Implement full state endpoint.
- Implement inspect endpoint.

### Phase 4: Agents

- Implement organelle cards.
- Implement rule-based agents.
- Implement action validator.
- Implement mock provider.
- Add OpenAI provider behind env flag.

### Phase 5: Cell cycle

- Implement G1/S/G2/M model.
- Add checkpoint rules.
- Add mitosis scenario tests.

### Phase 6: Roblox bridge

- Create server bridge script.
- Create remote events helper.
- Add client example script.
- Write Roblox bridge README.

### Phase 7: Polish and docs

- Add README with setup.
- Add `.env.example`.
- Add API examples.
- Add scenario demo commands.
- Add troubleshooting.

## 25. README requirements

Create a backend README with:

- What the system does.
- Architecture diagram in text.
- Setup commands.
- Environment variables.
- How to run locally.
- How to run tests.
- API examples with curl.
- How to connect Roblox.
- How to use mock mode vs OpenAI mode.
- Known limitations.
- Future enhancements.

## 26. Environment variables

`.env.example` should include:

```bash
APP_ENV=development
BACKEND_AUTH_TOKEN=change-me-local-dev-token
OPENAI_API_KEY=
OPENAI_MODEL=gpt-5.4-mini
AGENT_PROVIDER=mock
DATABASE_URL=sqlite:///./cell_agents.db
TICK_RATE_HZ=2
LLM_MAX_CONCURRENCY=2
LLM_TIMEOUT_SECONDS=8
DEV_ENDPOINTS_ENABLED=true
```

If the named model is unavailable in the local environment, make model configurable and document alternatives. Do not fail tests because no model/API key exists.

## 27. Done criteria

The work is done when:

- `pytest` passes.
- Backend starts locally with `uvicorn app.main:app --reload` or equivalent.
- `GET /health` works.
- A session can be created.
- Ticks produce changing cell state.
- At least these agents exist: nucleus, ribosome, mitochondrion, plasma membrane, rough ER, Golgi, lysosome, cytoskeleton.
- Organelle inspect endpoint returns useful explanations.
- Invalid biological actions are rejected or downgraded.
- Roblox bridge scripts exist and show how to connect front end to backend.
- Documentation explains mock mode and production considerations.

## 28. Future enhancements to leave hooks for

Do not implement all of these unless easy, but structure the code so they are possible:

- Multiple cells per player.
- Multiplayer collaborative cell management.
- Disease/stressor scenarios.
- Teacher dashboard.
- Difficulty levels: arcade vs realistic.
- Plant-cell mode.
- Organelle personality tuning.
- Knowledge-base retrieval for educational explanations.
- Persistent player progression.
- Redis/Postgres production deployment.
- Real-time streaming adapter if Roblox runtime supports it in production.
- Replay system for cell events.

## 29. Source notes for implementation context

Use these as background references, not as text to copy into UI:

- Roblox `HttpService` supports outbound HTTP requests from experiences to third-party web services and Open Cloud endpoints.
- Roblox `RemoteEvent` supports asynchronous one-way client/server communication, and `RemoteFunction` supports synchronous two-way callbacks. Prefer RemoteEvents for gameplay state updates.
- Roblox cloud services include DataStoreService for persistent data, MemoryStoreService for rapidly changing ephemeral data, and MessagingService for live cross-server communication.
- Roblox secrets can be used from server scripts with `HttpService:GetSecret()` after HTTP requests are enabled; keep backend tokens server-side.
- OpenAI Responses API supports stateful interactions and function/tool calling; structured outputs can enforce JSON schema adherence.
- The biological model is based on standard eukaryotic cell biology: nucleus for DNA replication/transcription/RNA processing, ribosomes for translation, ER/Golgi for protein/lipid processing and transport, mitochondria for ATP production, membrane for selective transport, lysosomes for degradation/recycling, peroxisomes for oxidative metabolism, and cell-cycle phases/checkpoints.

## 30. Start now

Begin by inspecting the repository. Then implement the MVP in phases. Keep commits/files organized. Prefer clear small modules and tests over one giant file. Do not remove the existing Roblox front end. Add bridge scripts and document how to wire them to existing organelle objects.

## 31. Reference links consulted while preparing this prompt

These links are included so future developers can verify the technical and biological assumptions.

### Roblox integration references

- Roblox Creator Docs — In-game HTTP requests / HttpService: https://create.roblox.com/docs/cloud-services/http-service
- Roblox Creator Docs — HttpService RequestAsync: https://create.roblox.com/docs/reference/engine/classes/HttpService/RequestAsync
- Roblox Creator Docs — Remote events and callbacks: https://create.roblox.com/docs/scripting/events/remote
- Roblox Creator Docs — Client-server runtime: https://create.roblox.com/docs/projects/client-server
- Roblox Creator Docs — DataStoreService: https://create.roblox.com/docs/reference/engine/classes/DataStoreService
- Roblox Creator Docs — MemoryStoreService: https://create.roblox.com/docs/reference/engine/classes/MemoryStoreService
- Roblox Creator Docs — MessagingService: https://create.roblox.com/docs/reference/engine/classes/MessagingService
- Roblox Creator Docs — Cross-server messaging: https://create.roblox.com/docs/cloud-services/cross-server-messaging
- Roblox Creator Docs — Secrets: https://create.roblox.com/docs/cloud-services/secrets
- Roblox Creator Docs — Security and access-control guidance: https://create.roblox.com/docs/scripting/security/security-tactics

### OpenAI API / Codex references

- OpenAI API — Responses overview: https://developers.openai.com/api/reference/responses/overview
- OpenAI API — Conversation state: https://developers.openai.com/api/docs/guides/conversation-state
- OpenAI API — Function calling: https://developers.openai.com/api/docs/guides/function-calling
- OpenAI API — Structured outputs: https://developers.openai.com/api/docs/guides/structured-outputs
- OpenAI API — Latency optimization: https://developers.openai.com/api/docs/guides/latency-optimization
- OpenAI API — Production best practices: https://developers.openai.com/api/docs/guides/production-best-practices
- OpenAI Codex — AGENTS.md guidance: https://developers.openai.com/codex/guides/agents-md
- OpenAI Codex — Prompting guide: https://developers.openai.com/cookbook/examples/gpt-5/codex_prompting_guide

### Biology references

- NCBI Bookshelf — The Nucleus: https://www.ncbi.nlm.nih.gov/books/NBK9845/
- NCBI Bookshelf — From RNA to Protein: https://www.ncbi.nlm.nih.gov/books/NBK26829/
- NCBI Bookshelf — The Endoplasmic Reticulum: https://www.ncbi.nlm.nih.gov/books/NBK26841/
- NCBI Bookshelf — The Golgi Apparatus: https://www.ncbi.nlm.nih.gov/books/NBK9838/
- NCBI Bookshelf — Lysosomes: https://www.ncbi.nlm.nih.gov/books/NBK9953/
- NCBI Bookshelf — Mitochondria, Chloroplasts, and Peroxisomes: https://www.ncbi.nlm.nih.gov/books/NBK9911/
- NCBI Bookshelf — Peroxisomes: https://www.ncbi.nlm.nih.gov/books/NBK9930/
- NCBI Bookshelf — Cell Membranes: https://www.ncbi.nlm.nih.gov/books/NBK9928/
- NCBI Bookshelf — The Compartmentalization of Cells: https://www.ncbi.nlm.nih.gov/books/NBK26907/
- NCBI Bookshelf — The Eukaryotic Cell Cycle: https://www.ncbi.nlm.nih.gov/books/NBK9876/
- NCBI Bookshelf — Components of the Cell-Cycle Control System: https://www.ncbi.nlm.nih.gov/books/NBK26824/
