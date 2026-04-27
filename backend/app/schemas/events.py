from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from pydantic import BaseModel, Field

from app.schemas.common import CellCyclePhase, CellMode, OrganelleType, VisualCue


class CellEvent(BaseModel):
    event_id: str
    seq: int
    tick: int
    source: str
    type: str
    payload: dict[str, Any] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class OrganelleVisualUpdate(BaseModel):
    organelle_id: str
    type: OrganelleType
    display_name: str
    health: float
    activity: float
    stress: float
    current_task: str
    task_progress: float
    visual_cue: VisualCue = Field(default_factory=VisualCue)
    speech: str = ""
    alerts: list[str] = Field(default_factory=list)


class StateDelta(BaseModel):
    cell_id: str
    from_version: int
    to_version: int
    tick: int
    organelle_updates: list[OrganelleVisualUpdate] = Field(default_factory=list)
    resource_updates: dict[str, float] = Field(default_factory=dict)
    cell_mode: CellMode
    cycle_phase: CellCyclePhase
    alerts: list[str] = Field(default_factory=list)
    events: list[CellEvent] = Field(default_factory=list)

