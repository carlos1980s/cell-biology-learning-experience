from __future__ import annotations

from datetime import timedelta
from uuid import uuid4

from fastapi import APIRouter, Depends

from app.dependencies import Services, get_services
from app.schemas.api import SessionStartRequest, SessionStartResponse
from app.security.auth import require_backend_auth
from app.sim.scenarios import build_initial_cell_state
from app.storage.base import SessionRecord

router = APIRouter(prefix="/sessions", tags=["sessions"])


@router.post("", response_model=SessionStartResponse, dependencies=[Depends(require_backend_auth)])
def start_session(
    request: SessionStartRequest,
    services: Services = Depends(get_services),
) -> SessionStartResponse:
    session_id = f"session-{uuid4().hex[:10]}"
    cell_id = f"cell-{uuid4().hex[:10]}"
    now = services.engine.now()
    session = SessionRecord(
        session_id=session_id,
        cell_id=cell_id,
        roblox_server_id=request.roblox_server_id,
        universe_id=request.universe_id,
        place_id=request.place_id,
        player_id_hash=request.player_id_hash,
        cell_type=request.cell_type,
        frontend_version=request.frontend_version,
        created_at=now,
        auth_expires_at=now + timedelta(hours=8),
    )
    cell = build_initial_cell_state(session_id=session_id, cell_id=cell_id, cell_type=request.cell_type)
    services.store.save_session(session, cell)
    services.metrics.incr("sessions_started")
    initial_delta = services.engine.build_delta(cell, from_version=0, events_limit=50)
    return SessionStartResponse(
        session_id=session_id,
        cell_id=cell_id,
        auth_expires_at=session.auth_expires_at,
        initial_state=cell,
        initial_delta=initial_delta,
    )
