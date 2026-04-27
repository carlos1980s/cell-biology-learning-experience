from __future__ import annotations

import asyncio
from datetime import datetime, timezone
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.dependencies import Services, get_services
from app.schemas.api import CellInputRequest, CellInputResponse, TickRequest, TickResponse
from app.schemas.cell_state import CellState
from app.schemas.events import CellEvent
from app.security.auth import require_backend_auth
from app.sim.cell_cycle import update_mode_and_health
from app.sim.resources import RESOURCE_FIELDS

router = APIRouter(prefix="/cells", tags=["cells"])


def _load_cell(services: Services, session_id: str, cell_id: str) -> CellState:
    services.store.ensure_session_cell(session_id, cell_id)
    cell = services.store.get_cell(cell_id)
    if not cell:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Cell not found")
    return cell


def _player_event(cell: CellState, input_type: str, payload: dict[str, object]) -> CellEvent:
    return CellEvent(
        event_id=f"evt-{uuid4().hex[:10]}",
        seq=0,
        tick=cell.tick,
        source="player",
        type=input_type,
        payload=payload,
        created_at=datetime.now(timezone.utc),
    )


def _apply_input(cell: CellState, request: CellInputRequest) -> tuple[CellState, str]:
    payload = request.payload
    if request.input_type == "add_resource":
        resource = str(payload.get("resource", ""))
        amount = max(0.0, float(payload.get("amount", 0.0)))
        if not resource or amount <= 0.0:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid add_resource payload")
        available_name = f"available_{resource}"
        if hasattr(cell.environment, available_name):
            current = float(getattr(cell.environment, available_name))
            setattr(cell.environment, available_name, current + amount)
            message = f"Environment now has more {resource} available for import."
        elif resource in RESOURCE_FIELDS:
            setattr(cell.resources, resource, float(getattr(cell.resources, resource)) + amount)
            message = f"Internal {resource} pool increased."
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Unknown resource name")
    elif request.input_type == "stress_event":
        stressor = str(payload.get("stressor", payload.get("type", "")))
        amount = max(0.0, float(payload.get("amount", 0.0)))
        if stressor == "dna_damage":
            cell.cycle.dna_damage = min(1.0, cell.cycle.dna_damage + amount)
        elif stressor == "ros":
            cell.resources.ros += amount
        elif stressor == "waste":
            cell.resources.waste += amount
        elif stressor == "membrane_damage":
            cell.environment.membrane_damage = min(1.0, cell.environment.membrane_damage + amount)
        elif stressor == "toxins":
            cell.environment.toxins += amount
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Unknown stressor")
        message = f"Applied stress event: {stressor}."
    elif request.input_type == "player_command":
        command = str(payload.get("command", ""))
        if command == "growth_signal":
            cell.environment.growth_signal = min(1.0, cell.environment.growth_signal + 0.2)
        elif command == "mitosis_focus":
            cell.environment.growth_signal = min(1.0, cell.environment.growth_signal + 0.3)
            cell.resources.nucleotides += 1.0
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Unknown player command")
        message = f"Applied player command: {command}."
    elif request.input_type == "environment_change":
        allowed = {
            "available_glucose",
            "available_oxygen",
            "available_amino_acids",
            "available_lipids",
            "toxins",
            "osmotic_stress",
            "membrane_damage",
            "growth_signal",
            "player_pressure",
        }
        changed = 0
        for key, value in payload.items():
            if key not in allowed:
                continue
            setattr(cell.environment, key, float(value))
            changed += 1
        if not changed:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No valid environment fields provided")
        message = "Environment state updated."
    elif request.input_type == "inspect_organelle":
        message = "Inspect request recorded."
    else:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Unsupported input type")

    update_mode_and_health(cell)
    cell.version += 1
    return cell, message


@router.post(
    "/{cell_id}/input",
    response_model=CellInputResponse,
    dependencies=[Depends(require_backend_auth)],
)
def submit_input(
    cell_id: str,
    request: CellInputRequest,
    services: Services = Depends(get_services),
) -> CellInputResponse:
    services.limiter.check(request.session_id)
    cell = _load_cell(services, request.session_id, cell_id)
    cell, message = _apply_input(cell, request)
    services.store.save_cell(cell)
    events = services.store.append_events(cell_id, [_player_event(cell, request.input_type, request.payload)])
    services.metrics.incr("inputs_received")
    return CellInputResponse(
        accepted=True,
        message=message,
        queued_event_seq=events[-1].seq if events else None,
    )


@router.post(
    "/{cell_id}/tick",
    response_model=TickResponse,
    dependencies=[Depends(require_backend_auth)],
)
async def tick_cell(
    cell_id: str,
    request: TickRequest,
    services: Services = Depends(get_services),
) -> TickResponse:
    services.limiter.check(request.session_id)
    _load_cell(services, request.session_id, cell_id)
    delta = await services.engine.step(
        cell_id=cell_id,
        dt=request.dt,
        last_seen_version=request.last_seen_version,
        max_events=request.max_events,
    )
    return TickResponse(
        delta=delta,
        server_time=services.engine.now(),
        recommended_next_poll_ms=max(500, int(1000 / max(1, services.settings.tick_rate_hz))),
    )


@router.get(
    "/{cell_id}",
    response_model=CellState,
    dependencies=[Depends(require_backend_auth)],
)
def get_full_state(
    cell_id: str,
    session_id: str = Query(...),
    services: Services = Depends(get_services),
) -> CellState:
    services.limiter.check(session_id)
    return _load_cell(services, session_id, cell_id)


@router.get(
    "/{cell_id}/events",
    dependencies=[Depends(require_backend_auth)],
)
async def long_poll_events(
    cell_id: str,
    session_id: str = Query(...),
    after_seq: int = Query(default=0, ge=0),
    timeout_ms: int = Query(default=15000, ge=100, le=30000),
    services: Services = Depends(get_services),
) -> dict[str, object]:
    services.limiter.check(session_id)
    _load_cell(services, session_id, cell_id)
    deadline = asyncio.get_running_loop().time() + timeout_ms / 1000.0
    while True:
        events = services.store.list_events(cell_id, after_seq=after_seq, limit=100)
        if events:
            return {"events": [event.model_dump(mode="json") for event in events], "timed_out": False}
        if asyncio.get_running_loop().time() >= deadline:
            return {"events": [], "timed_out": True}
        await asyncio.sleep(services.settings.long_poll_sleep_ms / 1000.0)
