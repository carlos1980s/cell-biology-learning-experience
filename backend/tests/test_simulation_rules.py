from __future__ import annotations

from app.schemas.actions import AgentAction
from app.schemas.cell_state import ResourcePools
from app.sim.biological_rules import validate_action
from app.sim.reducer import apply_action
from app.sim.scenarios import build_initial_cell_state


def test_resources_never_go_negative_after_validated_actions() -> None:
    cell = build_initial_cell_state(session_id="session-sim")
    cell.resources = ResourcePools(
        atp=1.0,
        adp=1.0,
        glucose=2.0,
        oxygen=2.0,
        amino_acids=1.0,
        nucleotides=1.0,
        lipids=1.0,
        water=5.0,
        ions=5.0,
        mrna=1.0,
        proteins=0.0,
        folded_proteins=0.0,
        membrane_proteins=0.0,
        secretory_cargo=0.0,
        waste=0.5,
        damaged_components=0.2,
        ros=0.2,
        calcium=1.0,
    )
    actions = [
        AgentAction(
            action_id="translate-1",
            organelle_id="ribosome-1",
            action_type="translate_mrna",
            consumes={"mrna": 0.5, "amino_acids": 0.5, "atp": 0.2},
            produces={"proteins": 0.4},
        ),
        AgentAction(
            action_id="atp-1",
            organelle_id="mitochondrion-1",
            action_type="produce_atp",
            consumes={"glucose": 0.5, "oxygen": 0.5, "adp": 0.3},
            produces={"atp": 0.7},
        ),
    ]

    for action in actions:
        result = validate_action(cell, action)
        assert result.accepted
        assert result.adjusted_action is not None
        cell, _ = apply_action(cell, result.adjusted_action)

    for field_name in type(cell.resources).model_fields:
        assert getattr(cell.resources, field_name) >= 0.0


def test_lysosome_recycling_reduces_waste() -> None:
    cell = build_initial_cell_state(session_id="session-sim")
    cell.resources.waste = 3.0
    cell.resources.damaged_components = 1.0
    action = AgentAction(
        action_id="recycle-1",
        organelle_id="lysosome-1",
        action_type="recycle_waste",
        consumes={"waste": 0.8, "damaged_components": 0.2, "atp": 0.1},
        produces={"amino_acids": 0.3, "lipids": 0.2},
    )
    result = validate_action(cell, action)
    assert result.accepted
    assert result.adjusted_action is not None

    before_waste = cell.resources.waste
    before_amino_acids = cell.resources.amino_acids
    updated_cell, _ = apply_action(cell, result.adjusted_action)
    assert updated_cell.resources.waste < before_waste
    assert updated_cell.resources.amino_acids > before_amino_acids
