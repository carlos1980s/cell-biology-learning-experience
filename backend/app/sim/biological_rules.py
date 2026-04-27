from __future__ import annotations

from collections.abc import Iterable

from app.schemas.actions import AgentAction, ValidationResult
from app.schemas.cell_state import CellState
from app.sim.cell_cycle import can_advance_phase
from app.sim.resources import QUEUE_FIELDS, RESOURCE_FIELDS

ACTION_ALLOWED_TYPES: dict[str, set[str]] = {
    "transcribe_gene": {"nucleus"},
    "export_mrna": {"nucleus"},
    "replicate_dna": {"nucleus"},
    "repair_dna": {"nucleus"},
    "translate_mrna": {"ribosome"},
    "fold_protein": {"rough_er"},
    "package_cargo": {"rough_er", "golgi"},
    "dispatch_vesicle": {"golgi", "endosome"},
    "produce_atp": {"mitochondrion"},
    "import_resource": {"plasma_membrane"},
    "export_waste": {"plasma_membrane"},
    "recycle_waste": {"lysosome", "endosome"},
    "reduce_stress": {"smooth_er", "mitochondrion", "plasma_membrane", "lysosome", "peroxisome"},
    "move_cargo": {"cytoplasm", "cytoskeleton"},
    "prepare_spindle": {"cytoskeleton", "centrosome"},
    "advance_cell_cycle": {"nucleus"},
    "send_signal": {
        "nucleus",
        "nucleolus",
        "ribosome",
        "rough_er",
        "smooth_er",
        "golgi",
        "mitochondrion",
        "plasma_membrane",
        "cytoplasm",
        "cytoskeleton",
        "lysosome",
        "endosome",
        "peroxisome",
        "centrosome",
    },
    "request_resource": {"nucleolus", "ribosome", "rough_er", "smooth_er", "mitochondrion", "peroxisome"},
    "idle": set(),
    "explain_state": set(),
}

DEFAULT_REQUIREMENTS: dict[str, dict[str, float]] = {
    "transcribe_gene": {"atp": 0.4, "nucleotides": 0.4},
    "replicate_dna": {"atp": 0.8, "nucleotides": 1.0},
    "repair_dna": {"atp": 0.4, "nucleotides": 0.2},
    "translate_mrna": {"mrna": 0.5, "amino_acids": 0.7, "atp": 0.3},
    "fold_protein": {"unfolded_proteins": 0.4, "atp": 0.2},
    "package_cargo": {"folded_proteins": 0.4},
    "dispatch_vesicle": {"vesicle_jobs": 0.3},
    "produce_atp": {"glucose": 0.5, "oxygen": 0.5, "adp": 0.5},
    "import_resource": {"atp": 0.1},
    "export_waste": {"waste": 0.2},
    "recycle_waste": {"waste": 0.5, "damaged_components": 0.2, "atp": 0.1},
    "reduce_stress": {"ros": 0.2},
    "move_cargo": {"vesicle_jobs": 0.2, "atp": 0.1},
    "prepare_spindle": {"atp": 0.2},
}


def _available(cell: CellState, pool_name: str) -> float:
    if pool_name in RESOURCE_FIELDS:
        return float(getattr(cell.resources, pool_name))
    if pool_name in QUEUE_FIELDS:
        return float(getattr(cell.queues, pool_name))
    return 0.0


def _scale_named_values(values: dict[str, float], scale: float) -> dict[str, float]:
    return {name: round(amount * scale, 6) for name, amount in values.items()}


def _reasons_from_requirements(cell: CellState, requirements: Iterable[tuple[str, float]]) -> list[str]:
    reasons: list[str] = []
    for name, amount in requirements:
        if _available(cell, name) < amount:
            reasons.append(f"Insufficient {name}")
    return reasons


def validate_action(cell: CellState, action: AgentAction) -> ValidationResult:
    organelle = cell.organelles.get(action.organelle_id)
    if not organelle:
        return ValidationResult(accepted=False, reasons=["Unknown organelle"])

    allowed_types = ACTION_ALLOWED_TYPES.get(action.action_type, set())
    if allowed_types and organelle.type not in allowed_types:
        return ValidationResult(
            accepted=False,
            reasons=[f"{organelle.type} cannot perform {action.action_type}"],
        )

    requirements = dict(DEFAULT_REQUIREMENTS.get(action.action_type, {}))
    for name, amount in action.consumes.items():
        requirements[name] = max(requirements.get(name, 0.0), amount)

    reasons = _reasons_from_requirements(cell, requirements.items())
    if action.action_type == "advance_cell_cycle":
        allowed, checkpoint_reasons, _ = can_advance_phase(cell)
        if not allowed:
            return ValidationResult(accepted=False, reasons=checkpoint_reasons)
    if action.action_type == "prepare_spindle" and cell.cycle.phase not in {
        "G2",
        "M_PROPHASE",
        "M_PROMETAPHASE",
        "M_METAPHASE",
    }:
        return ValidationResult(accepted=False, reasons=["Spindle can only be prepared in G2/M"])
    if reasons:
        return ValidationResult(accepted=False, reasons=reasons)

    scale = 1.0
    all_consumes = action.consumes or requirements
    for name, amount in all_consumes.items():
        if amount <= 0:
            continue
        available = _available(cell, name)
        if available <= 0:
            return ValidationResult(accepted=False, reasons=[f"Insufficient {name}"])
        scale = min(scale, available / amount)

    adjusted = action.model_copy(deep=True)
    if scale < 1.0:
        if scale < 0.15:
            return ValidationResult(
                accepted=False,
                reasons=["Action downgraded below useful threshold"],
            )
        adjusted.magnitude = round(adjusted.magnitude * scale, 6)
        adjusted.consumes = _scale_named_values(adjusted.consumes, scale)
        adjusted.produces = _scale_named_values(adjusted.produces, scale)
        return ValidationResult(
            accepted=True,
            adjusted_action=adjusted,
            reasons=["Action magnitude downgraded to fit available resources"],
        )

    return ValidationResult(accepted=True, adjusted_action=adjusted)

