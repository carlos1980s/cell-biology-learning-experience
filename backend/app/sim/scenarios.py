from __future__ import annotations

from uuid import uuid4

from app.schemas.cell_state import CellState, ResourcePools
from app.schemas.common import Vector3Like, VisualCue, VisualState
from app.schemas.organelles import OrganelleMemory, OrganelleState


def _organelle(
    organelle_id: str,
    organelle_type: str,
    display_name: str,
    x: float,
    y: float,
    z: float,
) -> OrganelleState:
    return OrganelleState(
        organelle_id=organelle_id,
        type=organelle_type,
        display_name=display_name,
        location=Vector3Like(x=x, y=y, z=z),
        current_task="Monitoring cell state",
        memory=OrganelleMemory(
            summary=f"{display_name} is ready for its normal role.",
            known_dependencies=[],
            known_outputs=[],
        ),
        visual_state=VisualState(
            cue=VisualCue(color_hint="stable", intensity=0.2),
            status_label="Stable",
        ),
    )


def build_initial_cell_state(
    session_id: str,
    cell_id: str | None = None,
    cell_type: str = "animal",
) -> CellState:
    cell_identifier = cell_id or f"cell-{uuid4().hex[:8]}"
    organelles = {
        "nucleus-1": _organelle("nucleus-1", "nucleus", "Nucleus", 0, 0, 0),
        "nucleolus-1": _organelle("nucleolus-1", "nucleolus", "Nucleolus", 0, 4, 0),
        "ribosome-1": _organelle("ribosome-1", "ribosome", "Ribosome Cluster", -22, 5, 14),
        "rough-er-1": _organelle("rough-er-1", "rough_er", "Rough ER", -18, 0, 18),
        "smooth-er-1": _organelle("smooth-er-1", "smooth_er", "Smooth ER", 20, -2, 10),
        "golgi-1": _organelle("golgi-1", "golgi", "Golgi Body", 32, 4, -10),
        "mitochondrion-1": _organelle("mitochondrion-1", "mitochondrion", "Mitochondrion", -35, -8, -14),
        "plasma-membrane-1": _organelle("plasma-membrane-1", "plasma_membrane", "Plasma Membrane", 120, 0, 0),
        "cytoplasm-1": _organelle("cytoplasm-1", "cytoplasm", "Cytoplasm", 5, 0, 28),
        "cytoskeleton-1": _organelle("cytoskeleton-1", "cytoskeleton", "Cytoskeleton", -8, -14, 22),
        "lysosome-1": _organelle("lysosome-1", "lysosome", "Lysosome", 24, -18, -4),
        "endosome-1": _organelle("endosome-1", "endosome", "Endosome", 28, -6, 20),
        "peroxisome-1": _organelle("peroxisome-1", "peroxisome", "Peroxisome", -12, -20, -24),
        "centrosome-1": _organelle("centrosome-1", "centrosome", "Centrosome", 12, 14, 0),
    }
    return CellState(
        cell_id=cell_identifier,
        session_id=session_id,
        cell_type=cell_type,
        resources=ResourcePools(),
        organelles=organelles,
    )


def apply_scenario(cell: CellState, scenario_name: str) -> CellState:
    scenario = scenario_name.lower()
    if scenario == "normal_homeostasis":
        cell.resources = ResourcePools()
        cell.cycle.phase = "G1"
        cell.cycle_phase = "G1"
        cell.cycle.dna_damage = 0.05
    elif scenario == "energy_crisis":
        cell.resources.atp = 3.0
        cell.resources.glucose = 0.8
        cell.resources.oxygen = 0.8
        cell.environment.available_glucose = 8.0
        cell.environment.available_oxygen = 8.0
    elif scenario == "protein_production_surge":
        cell.resources.mrna = 7.5
        cell.queues.transcript_demand = 5.5
        cell.queues.unfolded_proteins = 2.0
    elif scenario == "waste_overload":
        cell.resources.waste = 5.0
        cell.resources.damaged_components = 2.5
        cell.resources.ros = 2.0
    elif scenario == "mitosis_preparation":
        cell.resources.atp = 18.0
        cell.resources.nucleotides = 10.0
        cell.cycle.phase = "S"
        cell.cycle_phase = "S"
        cell.cycle.dna_replicated = 0.4
        cell.cycle.dna_damage = 0.05
        cell.environment.growth_signal = 0.8
    elif scenario == "dna_damage_checkpoint":
        cell.cycle.dna_damage = 0.7
        cell.cycle.phase = "G2"
        cell.cycle_phase = "G2"
    else:
        raise KeyError(f"Unknown scenario: {scenario_name}")
    return cell

