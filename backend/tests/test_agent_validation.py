from __future__ import annotations

from app.schemas.actions import AgentAction
from app.sim.biological_rules import validate_action
from app.sim.scenarios import build_initial_cell_state


def test_ribosome_cannot_translate_without_inputs() -> None:
    cell = build_initial_cell_state(session_id="session-test")
    cell.resources.mrna = 0.0
    cell.resources.amino_acids = 0.0
    action = AgentAction(
        action_id="a1",
        organelle_id="ribosome-1",
        action_type="translate_mrna",
        consumes={"mrna": 0.5, "amino_acids": 0.5, "atp": 0.2},
        produces={"proteins": 0.5},
    )
    result = validate_action(cell, action)
    assert not result.accepted
    assert any("mrna" in reason.lower() or "amino" in reason.lower() for reason in result.reasons)


def test_mitochondria_require_fuel_for_atp() -> None:
    cell = build_initial_cell_state(session_id="session-test")
    cell.resources.glucose = 0.0
    cell.resources.oxygen = 0.0
    action = AgentAction(
        action_id="a2",
        organelle_id="mitochondrion-1",
        action_type="produce_atp",
        consumes={"glucose": 0.5, "oxygen": 0.5, "adp": 0.5},
        produces={"atp": 1.0},
    )
    result = validate_action(cell, action)
    assert not result.accepted
    assert any("glucose" in reason.lower() or "oxygen" in reason.lower() for reason in result.reasons)


def test_golgi_cannot_dispatch_without_cargo() -> None:
    cell = build_initial_cell_state(session_id="session-test")
    cell.queues.vesicle_jobs = 0.0
    action = AgentAction(
        action_id="a3",
        organelle_id="golgi-1",
        action_type="dispatch_vesicle",
        consumes={"vesicle_jobs": 0.3},
    )
    result = validate_action(cell, action)
    assert not result.accepted
    assert any("vesicle_jobs" in reason.lower() for reason in result.reasons)


def test_invalid_external_action_is_rejected() -> None:
    cell = build_initial_cell_state(session_id="session-test")
    action = AgentAction(
        action_id="a4",
        organelle_id="nucleus-1",
        action_type="produce_atp",
        consumes={"glucose": 0.5, "oxygen": 0.5, "adp": 0.5},
        produces={"atp": 1.0},
    )
    result = validate_action(cell, action)
    assert not result.accepted
    assert "cannot perform" in result.reasons[0]

