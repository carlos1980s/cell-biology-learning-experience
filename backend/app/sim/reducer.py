from __future__ import annotations

from datetime import datetime, timezone
from uuid import uuid4

from app.schemas.actions import AgentAction
from app.schemas.cell_state import CellState
from app.schemas.common import Signal, VisualCue
from app.schemas.events import CellEvent
from app.sim.cell_cycle import advance_phase
from app.sim.resources import apply_named_delta


def _event(cell: CellState, action: AgentAction, payload: dict[str, object]) -> CellEvent:
    return CellEvent(
        event_id=f"evt-{uuid4().hex[:10]}",
        seq=0,
        tick=cell.tick,
        source=action.organelle_id,
        type=action.action_type,
        payload=payload,
        created_at=datetime.now(timezone.utc),
    )


def _default_visual_cue(action: AgentAction) -> VisualCue:
    color_hint = {
        "produce_atp": "energy_high",
        "translate_mrna": "protein_synthesis",
        "transcribe_gene": "nucleus_active",
        "fold_protein": "er_active",
        "package_cargo": "golgi_flow",
        "dispatch_vesicle": "vesicle_motion",
        "recycle_waste": "cleanup",
        "prepare_spindle": "mitosis_ready",
        "repair_dna": "repair",
    }.get(action.action_type, "stable")
    return VisualCue(
        animation=action.action_type,
        color_hint=color_hint,
        intensity=min(1.0, max(0.2, action.magnitude)),
    )


def apply_action(cell: CellState, action: AgentAction) -> tuple[CellState, list[CellEvent]]:
    organelle = cell.organelles[action.organelle_id]
    changes: dict[str, float] = {}

    for name, amount in action.consumes.items():
        changes[name] = changes.get(name, 0.0) - amount
    for name, amount in action.produces.items():
        changes[name] = changes.get(name, 0.0) + amount

    apply_named_delta(cell.resources, cell.queues, changes)

    if action.action_type == "replicate_dna":
        cell.cycle.dna_replicated = min(1.0, cell.cycle.dna_replicated + 0.15 * action.magnitude)
    elif action.action_type == "repair_dna":
        cell.cycle.dna_damage = max(0.0, cell.cycle.dna_damage - 0.2 * action.magnitude)
    elif action.action_type == "translate_mrna":
        if action.produces.get("secretory_cargo", 0.0) > 0:
            cell.queues.unfolded_proteins = max(
                0.0,
                cell.queues.unfolded_proteins + action.produces["secretory_cargo"],
            )
        cell.queues.transcript_demand = max(0.0, cell.queues.transcript_demand - 0.3 * action.magnitude)
    elif action.action_type == "fold_protein":
        cell.queues.golgi_cargo = max(
            0.0,
            cell.queues.golgi_cargo + action.produces.get("folded_proteins", 0.0),
        )
    elif action.action_type == "package_cargo" and organelle.type == "golgi":
        cell.queues.vesicle_jobs = max(
            0.0,
            cell.queues.vesicle_jobs + action.produces.get("vesicle_jobs", 0.0),
        )
    elif action.action_type == "dispatch_vesicle":
        cell.queues.vesicle_jobs = max(0.0, cell.queues.vesicle_jobs - 0.2 * action.magnitude)
    elif action.action_type == "reduce_stress":
        cell.resources.ros = max(0.0, cell.resources.ros - 0.25 * action.magnitude)
        cell.environment.toxins = max(0.0, cell.environment.toxins - 0.2 * action.magnitude)
        organelle.stress = max(0.0, organelle.stress - 0.2 * action.magnitude)
    elif action.action_type == "recycle_waste":
        cell.resources.waste = max(0.0, cell.resources.waste - 0.4 * action.magnitude)
        cell.resources.damaged_components = max(0.0, cell.resources.damaged_components - 0.15 * action.magnitude)
    elif action.action_type == "import_resource":
        for resource_name, amount in action.produces.items():
            available_name = f"available_{resource_name}"
            if hasattr(cell.environment, available_name):
                current = float(getattr(cell.environment, available_name))
                setattr(cell.environment, available_name, max(0.0, current - amount))
    elif action.action_type == "export_waste":
        cell.resources.waste = max(0.0, cell.resources.waste - max(0.3, 0.4 * action.magnitude))
    elif action.action_type == "prepare_spindle":
        cell.cycle.spindle_ready = min(1.0, cell.cycle.spindle_ready + 0.2 * action.magnitude)
        if cell.cycle.phase in {"M_PROMETAPHASE", "M_METAPHASE"}:
            cell.cycle.chromosome_alignment = min(1.0, cell.cycle.chromosome_alignment + 0.1 * action.magnitude)
    elif action.action_type == "advance_cell_cycle":
        advance_phase(cell)

    if action.signal:
        cell.global_signals.append(action.signal)
    elif action.action_type in {"send_signal", "request_resource"}:
        cell.global_signals.append(
            Signal(
                source_id=action.organelle_id,
                target_id=action.target_id,
                message=action.explanation or action.action_type,
            )
        )

    organelle.current_task = action.action_type.replace("_", " ").title()
    organelle.activity = min(1.0, max(organelle.activity * 0.4, action.magnitude))
    organelle.task_progress = min(1.0, organelle.task_progress + max(0.1, action.magnitude * 0.5))
    organelle.energy_budget = max(0.0, min(1.0, organelle.energy_budget + 0.05 - 0.1 * action.magnitude))
    organelle.memory.recent_actions = (organelle.memory.recent_actions + [action.action_type])[-5:]
    organelle.visual_state.cue = action.visual_cue or _default_visual_cue(action)
    organelle.visual_state.status_label = organelle.current_task
    organelle.visual_state.speech = action.explanation

    payload = {
        "action_type": action.action_type,
        "organelle_id": action.organelle_id,
        "magnitude": action.magnitude,
        "consumes": action.consumes,
        "produces": action.produces,
        "explanation": action.explanation,
    }
    return cell, [_event(cell, action, payload)]

