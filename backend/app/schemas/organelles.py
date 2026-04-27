from __future__ import annotations

from pydantic import BaseModel, Field

from app.schemas.common import OrganelleType, Signal, Vector3Like, VisualState


class OrganelleMemory(BaseModel):
    summary: str = ""
    recent_observations: list[str] = Field(default_factory=list)
    recent_actions: list[str] = Field(default_factory=list)
    known_dependencies: list[str] = Field(default_factory=list)
    known_outputs: list[str] = Field(default_factory=list)


class OrganelleState(BaseModel):
    organelle_id: str
    type: OrganelleType
    display_name: str
    location: Vector3Like
    health: float = Field(default=1.0, ge=0.0, le=1.0)
    activity: float = Field(default=0.0, ge=0.0, le=1.0)
    stress: float = Field(default=0.0, ge=0.0, le=1.0)
    energy_budget: float = Field(default=0.5, ge=0.0, le=1.0)
    current_task: str = "Idle"
    task_progress: float = Field(default=0.0, ge=0.0, le=1.0)
    local_resources: dict[str, float] = Field(default_factory=dict)
    inbox: list[Signal] = Field(default_factory=list)
    outbox: list[Signal] = Field(default_factory=list)
    memory: OrganelleMemory = Field(default_factory=OrganelleMemory)
    cooldowns: dict[str, float] = Field(default_factory=dict)
    visual_state: VisualState = Field(default_factory=VisualState)

