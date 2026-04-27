from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.dependencies import Services, get_services
from app.schemas.api import InspectOrganelleResponse
from app.security.auth import require_backend_auth

router = APIRouter(prefix="/cells", tags=["agents"])


@router.post(
    "/{cell_id}/organelles/{organelle_id}/inspect",
    response_model=InspectOrganelleResponse,
    dependencies=[Depends(require_backend_auth)],
)
def inspect_organelle(
    cell_id: str,
    organelle_id: str,
    session_id: str = Query(...),
    services: Services = Depends(get_services),
) -> InspectOrganelleResponse:
    services.limiter.check(session_id)
    services.store.ensure_session_cell(session_id, cell_id)
    cell = services.store.get_cell(cell_id)
    if not cell:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Cell not found")
    if organelle_id not in cell.organelles:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Organelle not found")
    return services.engine.inspect_organelle(cell, organelle_id)
