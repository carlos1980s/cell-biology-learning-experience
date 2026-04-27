from __future__ import annotations

from app.schemas.cell_state import CellState

MITOSIS_PHASES = {
    "M_PROPHASE",
    "M_PROMETAPHASE",
    "M_METAPHASE",
    "M_ANAPHASE",
    "M_TELOPHASE",
    "CYTOKINESIS",
}

NEXT_PHASE: dict[str, str] = {
    "G0": "G1",
    "G1": "S",
    "S": "G2",
    "G2": "M_PROPHASE",
    "M_PROPHASE": "M_PROMETAPHASE",
    "M_PROMETAPHASE": "M_METAPHASE",
    "M_METAPHASE": "M_ANAPHASE",
    "M_ANAPHASE": "M_TELOPHASE",
    "M_TELOPHASE": "CYTOKINESIS",
    "CYTOKINESIS": "G1",
}


def can_advance_phase(cell: CellState) -> tuple[bool, list[str], str | None]:
    phase = cell.cycle.phase
    reasons: list[str] = []
    next_phase = NEXT_PHASE.get(phase)

    if phase == "G0":
        if cell.environment.growth_signal < 0.2 or cell.resources.atp < 6:
            reasons.append("Growth signal or ATP too low for G1 entry")
    elif phase == "G1":
        if cell.resources.atp < 8:
            reasons.append("ATP too low for S phase")
        if cell.resources.nucleotides < 2:
            reasons.append("Nucleotides too low for S phase")
        if cell.cycle.dna_damage > 0.3:
            reasons.append("DNA damage too high for S phase")
    elif phase == "S":
        if cell.cycle.dna_replicated < 1.0:
            reasons.append("DNA replication incomplete")
    elif phase == "G2":
        if cell.cycle.dna_replicated < 1.0:
            reasons.append("DNA replication incomplete")
        if cell.cycle.dna_damage > 0.2:
            reasons.append("DNA damage checkpoint failed")
        if cell.resources.atp < 8:
            reasons.append("ATP too low for mitosis")
    elif phase == "M_METAPHASE":
        if cell.cycle.spindle_ready < 0.6:
            reasons.append("Spindle not ready")
        if cell.cycle.chromosome_alignment < 0.6:
            reasons.append("Chromosomes not aligned")

    return (not reasons, reasons, next_phase)


def advance_phase(cell: CellState) -> bool:
    allowed, reasons, next_phase = can_advance_phase(cell)
    cell.cycle.checkpoint_failures = reasons
    if not allowed or not next_phase:
        return False

    if cell.cycle.phase == "CYTOKINESIS":
        cell.cycle.dna_replicated = 0.0
        cell.cycle.spindle_ready = 0.0
        cell.cycle.chromosome_alignment = 0.0

    cell.cycle.phase = next_phase
    cell.cycle.phase_progress = 0.0
    cell.cycle_phase = next_phase
    return True


def tick_cycle(cell: CellState, dt: float) -> None:
    phase = cell.cycle.phase
    if phase == "S" and cell.resources.nucleotides > 0.2 and cell.resources.atp > 0.2:
        cell.cycle.dna_replicated = min(1.0, cell.cycle.dna_replicated + 0.08 * dt)
    if phase in {"G2", "M_PROPHASE", "M_PROMETAPHASE", "M_METAPHASE"}:
        cell.cycle.spindle_ready = min(1.0, cell.cycle.spindle_ready + 0.06 * dt)
    if phase in {"M_PROMETAPHASE", "M_METAPHASE"} and cell.cycle.spindle_ready > 0.3:
        cell.cycle.chromosome_alignment = min(
            1.0,
            cell.cycle.chromosome_alignment + 0.08 * dt,
        )
    if phase in MITOSIS_PHASES:
        cell.cycle.phase_progress = min(1.0, cell.cycle.phase_progress + 0.1 * dt)
    else:
        cell.cycle.phase_progress = min(1.0, cell.cycle.phase_progress + 0.03 * dt)

    if cell.cycle.phase_progress >= 1.0:
        advance_phase(cell)


def update_mode_and_health(cell: CellState) -> None:
    if cell.cycle.dna_damage > 0.35:
        cell.mode = "dna_repair"
    elif cell.resources.atp < 5 or cell.resources.glucose < 2 or cell.resources.oxygen < 2:
        cell.mode = "energy_crisis"
    elif cell.cycle.phase in MITOSIS_PHASES:
        cell.mode = "mitosis"
    elif cell.cycle.phase in {"S", "G2"}:
        cell.mode = "mitosis_preparation"
    elif cell.resources.ros > 2.5 or cell.queues.unfolded_proteins > 2.5:
        cell.mode = "stress_response"
    elif cell.resources.mrna > 6 or cell.queues.transcript_demand > 4:
        cell.mode = "protein_production_surge"
    elif cell.resources.waste > 2.5 or cell.resources.damaged_components > 1.5:
        cell.mode = "recovery"
    else:
        cell.mode = "homeostasis"

    energy_penalty = max(0.0, 6.0 - cell.resources.atp) * 0.03
    stress_penalty = min(0.4, cell.resources.ros * 0.03 + cell.cycle.dna_damage * 0.1)
    waste_penalty = min(0.2, cell.resources.waste * 0.02)
    cell.health = max(0.0, min(1.0, 1.0 - energy_penalty - stress_penalty - waste_penalty))

