from __future__ import annotations

from typing import Protocol

from pydantic import BaseModel, Field

from app.schemas.actions import ActionType, AgentAction
from app.schemas.cell_state import CellState
from app.schemas.common import CellCyclePhase, CellMode, OrganelleType
from app.schemas.organelles import OrganelleState


class AgentObservation(BaseModel):
    cell_id: str
    tick: int
    mode: CellMode
    cycle_phase: CellCyclePhase
    resources: dict[str, float]
    queues: dict[str, float]
    environment: dict[str, float]
    organelle_id: str
    organelle_type: OrganelleType
    organelle_health: float
    organelle_stress: float
    current_task: str
    inbox_messages: list[str] = Field(default_factory=list)
    recent_actions: list[str] = Field(default_factory=list)


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


class OrganelleAgent(Protocol):
    organelle_type: OrganelleType

    def build_observation(
        self,
        cell: CellState,
        self_state: OrganelleState,
    ) -> AgentObservation: ...

    async def decide(self, observation: AgentObservation) -> list[AgentAction]: ...

