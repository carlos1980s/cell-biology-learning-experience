from __future__ import annotations

from app.schemas.cell_state import CellQueues, ResourcePools

RESOURCE_FIELDS = tuple(ResourcePools.model_fields.keys())
QUEUE_FIELDS = tuple(
    name
    for name, field in CellQueues.model_fields.items()
    if field.annotation in (float, int)
)


def resource_snapshot(resources: ResourcePools) -> dict[str, float]:
    return {name: float(getattr(resources, name)) for name in RESOURCE_FIELDS}


def queue_snapshot(queues: CellQueues) -> dict[str, float]:
    return {name: float(getattr(queues, name)) for name in QUEUE_FIELDS}


def apply_named_delta(resources: ResourcePools, queues: CellQueues, changes: dict[str, float]) -> None:
    for name, delta in changes.items():
        if name in RESOURCE_FIELDS:
            current = float(getattr(resources, name))
            setattr(resources, name, max(0.0, current + delta))
        elif name in QUEUE_FIELDS:
            current = float(getattr(queues, name))
            setattr(queues, name, max(0.0, current + delta))

