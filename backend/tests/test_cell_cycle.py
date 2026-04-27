from __future__ import annotations

from app.schemas.actions import AgentAction
from app.sim.biological_rules import validate_action
from app.sim.scenarios import build_initial_cell_state


def test_nucleus_cannot_advance_to_m_before_replication_complete() -> None:
    cell = build_initial_cell_state(session_id="session-cycle")
    cell.cycle.phase = "G2"
    cell.cycle_phase = "G2"
    cell.cycle.dna_replicated = 0.5
    action = AgentAction(
        action_id="advance-1",
        organelle_id="nucleus-1",
        action_type="advance_cell_cycle",
        explanation="Attempting to enter mitosis.",
    )
    result = validate_action(cell, action)
    assert not result.accepted
    assert any("replication" in reason.lower() for reason in result.reasons)

