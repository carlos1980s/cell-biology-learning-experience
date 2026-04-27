from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

from app.schemas.common import Signal, VisualCue


ActionType = Literal[
    "transcribe_gene",
    "export_mrna",
    "replicate_dna",
    "repair_dna",
    "translate_mrna",
    "fold_protein",
    "package_cargo",
    "dispatch_vesicle",
    "produce_atp",
    "import_resource",
    "export_waste",
    "recycle_waste",
    "reduce_stress",
    "move_cargo",
    "prepare_spindle",
    "advance_cell_cycle",
    "send_signal",
    "request_resource",
    "idle",
    "explain_state",
]


class AgentAction(BaseModel):
    action_id: str
    organelle_id: str
    action_type: ActionType
    target_id: str | None = None
    priority: int = Field(default=5, ge=0, le=10)
    magnitude: float = Field(default=0.5, ge=0.0, le=1.0)
    duration_ticks: int = Field(default=1, ge=1, le=100)
    consumes: dict[str, float] = Field(default_factory=dict)
    produces: dict[str, float] = Field(default_factory=dict)
    signal: Signal | None = None
    visual_cue: VisualCue | None = None
    explanation: str = ""
    confidence: float = Field(default=0.5, ge=0.0, le=1.0)


class ValidationResult(BaseModel):
    accepted: bool
    adjusted_action: AgentAction | None = None
    reasons: list[str] = Field(default_factory=list)

