from __future__ import annotations

from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field

from app.dependencies import Services, get_services
from app.security.auth import require_backend_auth
from app.sim.scenarios import apply_scenario

router = APIRouter(tags=["admin"])


class ForcePhaseRequest(BaseModel):
    session_id: str
    phase: Literal["G0", "G1", "S", "G2", "M_PROPHASE", "M_PROMETAPHASE", "M_METAPHASE", "M_ANAPHASE", "M_TELOPHASE", "CYTOKINESIS"]


class StressRequest(BaseModel):
    session_id: str
    stress_type: Literal["ros", "waste", "dna_damage", "toxins"]
    amount: float = Field(gt=0.0, le=10.0)


def _ensure_dev_enabled(services: Services) -> None:
    if not services.settings.dev_endpoints_enabled:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dev endpoints are disabled")


@router.get("/admin/metrics", dependencies=[Depends(require_backend_auth)])
def metrics(services: Services = Depends(get_services)) -> dict[str, int]:
    _ensure_dev_enabled(services)
    return services.metrics.snapshot()


@router.post("/dev/scenarios/{scenario_name}", dependencies=[Depends(require_backend_auth)])
def run_scenario(
    scenario_name: str,
    cell_id: str = Query(...),
    session_id: str = Query(...),
    services: Services = Depends(get_services),
) -> dict[str, object]:
    _ensure_dev_enabled(services)
    services.store.ensure_session_cell(session_id, cell_id)
    cell = services.store.get_cell(cell_id)
    if not cell:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Cell not found")
    updated = apply_scenario(cell, scenario_name)
    updated.version += 1
    services.store.save_cell(updated)
    services.metrics.incr("scenarios_applied")
    return {"ok": True, "cell_id": cell_id, "scenario": scenario_name}


@router.post("/dev/cells/{cell_id}/force_phase", dependencies=[Depends(require_backend_auth)])
def force_phase(
    cell_id: str,
    request: ForcePhaseRequest,
    services: Services = Depends(get_services),
) -> dict[str, object]:
    _ensure_dev_enabled(services)
    services.store.ensure_session_cell(request.session_id, cell_id)
    cell = services.store.get_cell(cell_id)
    if not cell:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Cell not found")
    cell.cycle.phase = request.phase
    cell.cycle_phase = request.phase
    cell.version += 1
    services.store.save_cell(cell)
    return {"ok": True, "cell_id": cell_id, "phase": request.phase}


@router.post("/dev/cells/{cell_id}/stress", dependencies=[Depends(require_backend_auth)])
def add_stress(
    cell_id: str,
    request: StressRequest,
    services: Services = Depends(get_services),
) -> dict[str, object]:
    _ensure_dev_enabled(services)
    services.store.ensure_session_cell(request.session_id, cell_id)
    cell = services.store.get_cell(cell_id)
    if not cell:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Cell not found")
    if request.stress_type == "ros":
        cell.resources.ros += request.amount
    elif request.stress_type == "waste":
        cell.resources.waste += request.amount
    elif request.stress_type == "dna_damage":
        cell.cycle.dna_damage = min(1.0, cell.cycle.dna_damage + request.amount / 10.0)
    else:
        cell.environment.toxins += request.amount
    cell.version += 1
    services.store.save_cell(cell)
    return {"ok": True, "cell_id": cell_id, "stress_type": request.stress_type, "amount": request.amount}
