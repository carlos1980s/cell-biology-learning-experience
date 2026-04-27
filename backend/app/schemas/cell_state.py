from __future__ import annotations

from pydantic import BaseModel, Field

from app.schemas.common import CellCyclePhase, CellMode, EnvironmentState, Signal
from app.schemas.events import CellEvent
from app.schemas.organelles import OrganelleState


class ResourcePools(BaseModel):
    atp: float = 20.0
    adp: float = 12.0
    glucose: float = 12.0
    oxygen: float = 12.0
    amino_acids: float = 10.0
    nucleotides: float = 8.0
    lipids: float = 6.0
    water: float = 20.0
    ions: float = 10.0
    mrna: float = 4.0
    proteins: float = 2.0
    folded_proteins: float = 1.0
    membrane_proteins: float = 0.5
    secretory_cargo: float = 0.5
    waste: float = 1.0
    damaged_components: float = 0.5
    ros: float = 0.5
    calcium: float = 4.0


class CellQueues(BaseModel):
    transcript_demand: float = 2.0
    unfolded_proteins: float = 1.0
    golgi_cargo: float = 0.5
    vesicle_jobs: float = 0.5
    recycling_jobs: float = 0.5
    alerts: list[str] = Field(default_factory=list)


class CellCycleState(BaseModel):
    phase: CellCyclePhase = "G1"
    phase_progress: float = Field(default=0.0, ge=0.0, le=1.0)
    dna_replicated: float = Field(default=0.0, ge=0.0, le=1.0)
    dna_damage: float = Field(default=0.0, ge=0.0, le=1.0)
    spindle_ready: float = Field(default=0.0, ge=0.0, le=1.0)
    chromosome_alignment: float = Field(default=0.0, ge=0.0, le=1.0)
    checkpoint_failures: list[str] = Field(default_factory=list)


class CellState(BaseModel):
    cell_id: str
    session_id: str
    tick: int = 0
    sim_time_seconds: float = 0.0
    cell_type: str = "animal"
    cycle_phase: CellCyclePhase = "G1"
    mode: CellMode = "homeostasis"
    health: float = Field(default=1.0, ge=0.0, le=1.0)
    resources: ResourcePools = Field(default_factory=ResourcePools)
    environment: EnvironmentState = Field(default_factory=EnvironmentState)
    organelles: dict[str, OrganelleState] = Field(default_factory=dict)
    queues: CellQueues = Field(default_factory=CellQueues)
    global_signals: list[Signal] = Field(default_factory=list)
    recent_events: list[CellEvent] = Field(default_factory=list)
    version: int = 0
    cycle: CellCycleState = Field(default_factory=CellCycleState)

