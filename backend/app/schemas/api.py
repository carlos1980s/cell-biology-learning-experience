from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Literal

from pydantic import BaseModel, Field

from app.schemas.cell_state import CellState
from app.schemas.events import StateDelta


class HealthResponse(BaseModel):
    ok: bool = True
    version: str


class SessionStartRequest(BaseModel):
    roblox_server_id: str
    universe_id: str
    place_id: str
    player_id_hash: str
    cell_type: Literal["animal", "plant"] = "animal"
    frontend_version: str


class SessionStartResponse(BaseModel):
    session_id: str
    cell_id: str
    auth_expires_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    initial_state: CellState
    initial_delta: StateDelta


class CellInputRequest(BaseModel):
    session_id: str
    seq: int
    input_type: Literal[
        "add_resource",
        "stress_event",
        "inspect_organelle",
        "player_command",
        "environment_change",
    ]
    payload: dict[str, Any] = Field(default_factory=dict)


class CellInputResponse(BaseModel):
    accepted: bool
    message: str
    queued_event_seq: int | None = None


class TickRequest(BaseModel):
    session_id: str
    dt: float = Field(default=1.0, gt=0.0, le=10.0)
    last_seen_version: int = Field(default=0, ge=0)
    max_events: int = Field(default=50, ge=1, le=250)


class TickResponse(BaseModel):
    delta: StateDelta
    server_time: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    recommended_next_poll_ms: int = 1000


class InspectOrganelleResponse(BaseModel):
    organelle_id: str
    display_name: str
    status: str
    health: float
    stress: float
    inputs_needed: list[str] = Field(default_factory=list)
    outputs: list[str] = Field(default_factory=list)
    explanation: str

