from __future__ import annotations

from app.sim.cell_cycle import update_mode_and_health
from app.sim.scenarios import apply_scenario, build_initial_cell_state


def test_energy_crisis_scenario_reaches_expected_mode() -> None:
    cell = build_initial_cell_state(session_id="session-scenarios")
    apply_scenario(cell, "energy_crisis")
    update_mode_and_health(cell)
    assert cell.mode == "energy_crisis"


def test_dna_damage_checkpoint_scenario_reaches_expected_mode() -> None:
    cell = build_initial_cell_state(session_id="session-scenarios")
    apply_scenario(cell, "dna_damage_checkpoint")
    update_mode_and_health(cell)
    assert cell.mode == "dna_repair"
