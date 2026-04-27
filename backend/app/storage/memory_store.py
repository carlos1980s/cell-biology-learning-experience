from __future__ import annotations

from collections import defaultdict
from copy import deepcopy
from threading import RLock

from fastapi import HTTPException, status

from app.config import Settings
from app.schemas.cell_state import CellState
from app.schemas.events import CellEvent
from app.storage.base import SessionRecord
from app.storage.sqlite_store import SQLiteStore


class MemoryStore:
    def __init__(self, settings: Settings, sqlite_store: SQLiteStore | None = None) -> None:
        self.settings = settings
        self.sqlite_store = sqlite_store
        self._sessions: dict[str, SessionRecord] = {}
        self._cells: dict[str, CellState] = {}
        self._events: dict[str, list[CellEvent]] = defaultdict(list)
        self._event_seq: dict[str, int] = defaultdict(int)
        self._lock = RLock()

    def save_session(self, session: SessionRecord, cell: CellState) -> None:
        with self._lock:
            self._sessions[session.session_id] = session
            self._cells[cell.cell_id] = cell.model_copy(deep=True)
            self._events.setdefault(cell.cell_id, [])
            if self.sqlite_store:
                self.sqlite_store.save_session(session)
                self.sqlite_store.save_snapshot(cell)

    def get_session(self, session_id: str) -> SessionRecord | None:
        with self._lock:
            session = self._sessions.get(session_id)
            return session.model_copy(deep=True) if session else None

    def get_cell(self, cell_id: str) -> CellState | None:
        with self._lock:
            cell = self._cells.get(cell_id)
            if cell:
                return cell.model_copy(deep=True)
        if self.sqlite_store:
            snapshot = self.sqlite_store.load_latest_snapshot(cell_id)
            if snapshot:
                with self._lock:
                    self._cells[cell_id] = snapshot.model_copy(deep=True)
                return snapshot
        return None

    def save_cell(self, cell: CellState) -> None:
        with self._lock:
            self._cells[cell.cell_id] = cell.model_copy(deep=True)
            if self.sqlite_store:
                self.sqlite_store.save_snapshot(cell)

    def ensure_session_cell(self, session_id: str, cell_id: str) -> SessionRecord:
        with self._lock:
            session = self._sessions.get(session_id)
            if not session or session.cell_id != cell_id:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Unknown session/cell combination",
                )
            return session.model_copy(deep=True)

    def append_events(self, cell_id: str, events: list[CellEvent]) -> list[CellEvent]:
        with self._lock:
            finalized: list[CellEvent] = []
            for event in events:
                self._event_seq[cell_id] += 1
                finalized.append(
                    event.model_copy(
                        update={"seq": self._event_seq[cell_id]},
                        deep=True,
                    )
                )
            self._events[cell_id].extend(finalized)
            if len(self._events[cell_id]) > self.settings.max_event_history:
                self._events[cell_id] = self._events[cell_id][-self.settings.max_event_history :]
            return deepcopy(finalized)

    def list_events(self, cell_id: str, after_seq: int, limit: int) -> list[CellEvent]:
        with self._lock:
            return [
                event.model_copy(deep=True)
                for event in self._events.get(cell_id, [])
                if event.seq > after_seq
            ][:limit]

