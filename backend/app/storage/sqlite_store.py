from __future__ import annotations

import sqlite3
from pathlib import Path

from app.schemas.cell_state import CellState
from app.storage.base import SessionRecord


class SQLiteStore:
    def __init__(self, database_path: str) -> None:
        self.database_path = Path(database_path).expanduser().resolve()
        self.database_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_db()

    def _connect(self) -> sqlite3.Connection:
        connection = sqlite3.connect(self.database_path)
        connection.row_factory = sqlite3.Row
        return connection

    def _init_db(self) -> None:
        with self._connect() as connection:
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS sessions (
                    session_id TEXT PRIMARY KEY,
                    cell_id TEXT NOT NULL,
                    payload TEXT NOT NULL
                )
                """
            )
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS cell_snapshots (
                    cell_id TEXT NOT NULL,
                    version INTEGER NOT NULL,
                    payload TEXT NOT NULL,
                    PRIMARY KEY (cell_id, version)
                )
                """
            )

    def save_session(self, session: SessionRecord) -> None:
        with self._connect() as connection:
            connection.execute(
                """
                INSERT OR REPLACE INTO sessions(session_id, cell_id, payload)
                VALUES (?, ?, ?)
                """,
                (session.session_id, session.cell_id, session.model_dump_json()),
            )

    def save_snapshot(self, cell: CellState) -> None:
        with self._connect() as connection:
            connection.execute(
                """
                INSERT OR REPLACE INTO cell_snapshots(cell_id, version, payload)
                VALUES (?, ?, ?)
                """,
                (cell.cell_id, cell.version, cell.model_dump_json()),
            )

    def load_latest_snapshot(self, cell_id: str) -> CellState | None:
        with self._connect() as connection:
            row = connection.execute(
                """
                SELECT payload
                FROM cell_snapshots
                WHERE cell_id = ?
                ORDER BY version DESC
                LIMIT 1
                """,
                (cell_id,),
            ).fetchone()
        if not row:
            return None
        return CellState.model_validate_json(row["payload"])

