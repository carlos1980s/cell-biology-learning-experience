from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field


OrganelleType = Literal[
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
    "vesicle",
    "chloroplast",
    "vacuole",
    "cell_wall",
]

CellCyclePhase = Literal[
    "G0",
    "G1",
    "S",
    "G2",
    "M_PROPHASE",
    "M_PROMETAPHASE",
    "M_METAPHASE",
    "M_ANAPHASE",
    "M_TELOPHASE",
    "CYTOKINESIS",
]

CellMode = Literal[
    "homeostasis",
    "growth",
    "stress_response",
    "energy_crisis",
    "dna_repair",
    "protein_production_surge",
    "mitosis_preparation",
    "mitosis",
    "recovery",
]

ResourceName = Literal[
    "atp",
    "adp",
    "glucose",
    "oxygen",
    "amino_acids",
    "nucleotides",
    "lipids",
    "water",
    "ions",
    "mrna",
    "proteins",
    "folded_proteins",
    "membrane_proteins",
    "secretory_cargo",
    "waste",
    "damaged_components",
    "ros",
    "calcium",
]


class Vector3Like(BaseModel):
    x: float = 0.0
    y: float = 0.0
    z: float = 0.0


class Signal(BaseModel):
    source_id: str
    target_id: str | None = None
    target_type: OrganelleType | None = None
    message: str
    priority: int = Field(default=5, ge=0, le=10)


class VisualCue(BaseModel):
    animation: str | None = None
    color_hint: str | None = None
    intensity: float = Field(default=0.0, ge=0.0, le=1.0)
    particles: list[str] = Field(default_factory=list)


class VisualState(BaseModel):
    cue: VisualCue = Field(default_factory=VisualCue)
    status_label: str = "Idle"
    speech: str = ""
    alerts: list[str] = Field(default_factory=list)


class EnvironmentState(BaseModel):
    available_glucose: float = 30.0
    available_oxygen: float = 30.0
    available_amino_acids: float = 20.0
    available_lipids: float = 10.0
    toxins: float = 0.0
    osmotic_stress: float = 0.0
    membrane_damage: float = 0.0
    growth_signal: float = 0.3
    player_pressure: float = 0.0

