from __future__ import annotations

from datetime import datetime, timezone
from typing import Protocol

from pydantic import BaseModel, Field

from app.schemas.cell_state import CellState
from app.schemas.events import CellEvent


class SessionRecord(BaseModel):
    session_id: str
    cell_id: str
    roblox_server_id: str
    universe_id: str
    place_id: str
    player_id_hash: str
    cell_type: str
    frontend_version: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    auth_expires_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class ActiveCellStore(Protocol):
    def save_session(self, session: SessionRecord, cell: CellState) -> None: ...
    def get_session(self, session_id: str) -> SessionRecord | None: ...
    def get_cell(self, cell_id: str) -> CellState | None: ...
    def save_cell(self, cell: CellState) -> None: ...
    def ensure_session_cell(self, session_id: str, cell_id: str) -> SessionRecord: ...
    def append_events(self, cell_id: str, events: list[CellEvent]) -> list[CellEvent]: ...
    def list_events(self, cell_id: str, after_seq: int, limit: int) -> list[CellEvent]: ...

