# MASTER REVERSE-COMPONENTIZATION PROMPT — Nucleus Organelle

You are an expert Blender Python developer and technical biology artist. Build a stylized-realistic, Roblox-ready 3D model of an animal eukaryotic nucleus by starting from the final cohesive organelle and reverse-breaking it into individually designed Blender components.

The goal is not to produce one merged object. The goal is a complete organelle system made of separate named pieces, each designed around biological functionality and animation.

## Required output

Generate a complete Blender Python script that:
1. Clears the scene.
2. Creates all required collections.
3. Creates all materials listed below.
4. Creates the whole-cell context and nucleus socket first.
5. Creates the final nucleus as one cohesive organelle.
6. Breaks it into component groups and individual mesh parts.
7. Uses exact object names from the manifest.
8. Adds pivots, origins, and parenting rules for Roblox animation.
9. Adds animation frame ranges for transport, transcription, mitosis breakdown, and reassembly.
10. Adds review controls, cameras, labels, and checkpoints.
11. Keeps topology optimized for Roblox export.

## Style target

High-quality 3D educational infographic style: stylized realistic, colorful, simplified but biologically correct, textured with procedural bumps and material contrast, readable from a distance, functional at close inspection, suitable for Roblox import and scripted educational animations.

## Scale

- 1 Blender unit = 1 micrometer conceptual scale.
- Animal cell context: ellipsoid about X=20, Y=14, Z=9.
- Nucleus outer radius: about 3.2 BU.
- Inner membrane radius: about 2.95 BU.
- Nucleolus radius: about 0.65 BU.
- Nucleus center: `(0, 0, 0.2)`.

## Biological non-negotiables

1. The nuclear envelope has two membranes.
2. The perinuclear space is visible between the membranes.
3. Nuclear pores are selective protein complexes, not simple holes.
4. DNA/chromatin stays inside the nucleus.
5. RNA and protein cargo move through nuclear pore complexes.
6. The nucleolus is not membrane-bound.
7. The nuclear lamina supports the inner nuclear membrane.
8. The outer nuclear membrane is continuous with rough ER.
9. During mitosis in animal cells, the nuclear envelope can break down and reassemble.

## Materials

```json
{
  "MAT_CellMembrane_ClearBlue": {
    "color_hex": "#8CCBFF",
    "alpha": 0.2,
    "texture": "transparent glass-like membrane, soft rim highlight, very faint procedural noise"
  },
  "MAT_Cytoplasm_BlueGlass": {
    "color_hex": "#4DA7FF",
    "alpha": 0.12,
    "texture": "transparent volume with faint suspended specks and soft volumetric feel"
  },
  "MAT_OuterMembrane_Purple": {
    "color_hex": "#8B55D7",
    "alpha": 1.0,
    "texture": "satin membrane, procedural fine bump, subtle color variation, rounded bevels"
  },
  "MAT_InnerMembrane_DeepPurple": {
    "color_hex": "#5E36A6",
    "alpha": 1.0,
    "texture": "darker satin membrane, smoother than outer membrane, light bump"
  },
  "MAT_PerinuclearLumen_AmberGlow": {
    "color_hex": "#F4A03A",
    "alpha": 0.35,
    "texture": "transparent amber additive glow to reveal the space between membranes"
  },
  "MAT_NPC_Protein_Violet": {
    "color_hex": "#6E35B9",
    "alpha": 1.0,
    "texture": "smooth rounded protein lobes with bevels and slight roughness"
  },
  "MAT_NPC_Gate_LilacGlass": {
    "color_hex": "#C07BFF",
    "alpha": 0.45,
    "texture": "translucent gel-like selective gate, soft emission pulse"
  },
  "MAT_Lamina_Gold": {
    "color_hex": "#DFA03A",
    "alpha": 1.0,
    "texture": "warm gold tube lattice, clean bevels, low roughness"
  },
  "MAT_Nucleoplasm_BlueTransparent": {
    "color_hex": "#2F78D8",
    "alpha": 0.22,
    "texture": "glass-like internal sphere with light fog, low visual opacity"
  },
  "MAT_Chromatin_Purple": {
    "color_hex": "#C65BFF",
    "alpha": 1.0,
    "texture": "beveled DNA/chromatin curves, slight emission, varied thickness"
  },
  "MAT_Chromatin_CyanHighlight": {
    "color_hex": "#1E9CFF",
    "alpha": 1.0,
    "texture": "secondary highlighted chromatin strands for active regions"
  },
  "MAT_Chromosome_Magenta": {
    "color_hex": "#B246FF",
    "alpha": 1.0,
    "texture": "smooth condensed chromosome surface with broad rounded grooves"
  },
  "MAT_Nucleolus_DeepViolet": {
    "color_hex": "#5A176A",
    "alpha": 1.0,
    "texture": "dense bumpy spheroid with procedural noise displacement"
  },
  "MAT_Nucleolus_MagentaSpeckles": {
    "color_hex": "#E15BD8",
    "alpha": 1.0,
    "texture": "small surface speckles and mottled subregion patches"
  },
  "MAT_Cargo_Protein_Green": {
    "color_hex": "#56C96F",
    "alpha": 1.0,
    "texture": "glossy green cargo spheres with small NLS tag bead"
  },
  "MAT_Cargo_RNA_Pink": {
    "color_hex": "#F05FA6",
    "alpha": 1.0,
    "texture": "pink squiggle curves with emissive direction dots"
  },
  "MAT_Cargo_Ribosome_Magenta": {
    "color_hex": "#C94EC8",
    "alpha": 1.0,
    "texture": "paired rounded subunit particles, glossy, slightly different sizes"
  },
  "MAT_RoughER_BluePurple": {
    "color_hex": "#625BD6",
    "alpha": 1.0,
    "texture": "folded ER sheet membrane, satin, ribosome dots on cytoplasmic surface"
  },
  "MAT_Ribosome_Orange": {
    "color_hex": "#F06A2B",
    "alpha": 1.0,
    "texture": "tiny orange dots with simple glossy material"
  },
  "MAT_MembraneFragment_Purple": {
    "color_hex": "#9B5BE0",
    "alpha": 1.0,
    "texture": "broken curved membrane pieces with bevels"
  },
  "MAT_Hotspot_GoldEmission": {
    "color_hex": "#F4C542",
    "alpha": 1.0,
    "texture": "gold icon plaques with mild emission and pulsing rim"
  },
  "MAT_Label_White": {
    "color_hex": "#FFFFFF",
    "alpha": 1.0,
    "texture": "flat readable text labels, camera-facing"
  }
}
```

## Component group summary


## G00 — WholeCell_Context_Integration / `00_CELL_CONTEXT`
Goal: Make the nucleus feel assembled into a single animal eukaryotic cell, with cytoplasm, ER side, and socketed placement.
- `Cell_Context_RootRig` (CXT_001): Empty + light guide shell; material `MAT_CellMembrane_ClearBlue`; pass: Cell boundary is visible but does not obscure the nucleus.
- `Cytoplasm_Volume` (CXT_002): Transparent ellipsoid mesh; material `MAT_Cytoplasm_BlueGlass`; pass: Cytoplasm is visible from main camera but not visually dominant.
- `NucleusSocket_Center` (CXT_003): Socket empty + visible ring; material `MAT_Label_White`; pass: Nucleus rotates and scales around this socket correctly.
- `Cell_Context_Organelle_Silhouettes` (CXT_004): Low-detail context meshes; material `MAT_Cytoplasm_BlueGlass`; pass: Secondary organelles do not compete with the nucleus.

## G01 — RootRig_Pivots_LOD / `01_NUCLEUS_ROOT`
Goal: Create master pivot, axes, LOD switches, cutaway controller, and global parent relationships.
- `Nucleus_RootRig` (ROOT_001): Master empty; material `MAT_Label_White`; pass: Every nucleus component is under this root and rotates around the center.
- `Nucleus_Cutaway_Controller` (ROOT_002): Boolean guide / empty; material `MAT_Label_White`; pass: Cutaway reveals inside but keeps the nucleus recognizable as a sphere.
- `Nucleus_LOD_Controller` (ROOT_003): Empty + custom properties; material `MAT_Label_White`; pass: Reviewer can toggle LOD levels cleanly.
- `Nucleus_ExplodedView_Controller` (ROOT_004): Empty + offset targets; material `MAT_Label_White`; pass: Exploded view separates groups without losing relationships.

## G02 — NuclearEnvelope_DoubleMembrane / `02_NUCLEAR_ENVELOPE`
Goal: Build the animation-ready outer membrane, inner membrane, perinuclear lumen, seams, and cutaway rims as separate pieces.
- `NE_OuterMembrane_Panel_01` (ENV_OUT_01): Curved thick spherical shell panel; material `MAT_OuterMembrane_Purple`; pass: Panel has thickness, bevels, pore sockets, and does not merge with other panels.
- `NE_OuterMembrane_Panel_02` (ENV_OUT_02): Curved thick spherical shell panel; material `MAT_OuterMembrane_Purple`; pass: Panel has thickness, bevels, pore sockets, and does not merge with other panels.
- `NE_OuterMembrane_Panel_03` (ENV_OUT_03): Curved thick spherical shell panel; material `MAT_OuterMembrane_Purple`; pass: Panel has thickness, bevels, pore sockets, and does not merge with other panels.
- `NE_OuterMembrane_Panel_04` (ENV_OUT_04): Curved thick spherical shell panel; material `MAT_OuterMembrane_Purple`; pass: Panel has thickness, bevels, pore sockets, and does not merge with other panels.
- `NE_OuterMembrane_Panel_05` (ENV_OUT_05): Curved thick spherical shell panel; material `MAT_OuterMembrane_Purple`; pass: Panel has thickness, bevels, pore sockets, and does not merge with other panels.
- `NE_OuterMembrane_Panel_06` (ENV_OUT_06): Curved thick spherical shell panel; material `MAT_OuterMembrane_Purple`; pass: Panel has thickness, bevels, pore sockets, and does not merge with other panels.
- `NE_OuterMembrane_Panel_07` (ENV_OUT_07): Curved thick spherical shell panel; material `MAT_OuterMembrane_Purple`; pass: Panel has thickness, bevels, pore sockets, and does not merge with other panels.
- `NE_OuterMembrane_Panel_08` (ENV_OUT_08): Curved thick spherical shell panel; material `MAT_OuterMembrane_Purple`; pass: Panel has thickness, bevels, pore sockets, and does not merge with other panels.
- `NE_InnerMembrane_Panel_01` (ENV_IN_01): Curved thick inner spherical shell panel; material `MAT_InnerMembrane_DeepPurple`; pass: Inner panel is visually separate from outer panel and preserves the lumen gap.
- `NE_InnerMembrane_Panel_02` (ENV_IN_02): Curved thick inner spherical shell panel; material `MAT_InnerMembrane_DeepPurple`; pass: Inner panel is visually separate from outer panel and preserves the lumen gap.
- `NE_InnerMembrane_Panel_03` (ENV_IN_03): Curved thick inner spherical shell panel; material `MAT_InnerMembrane_DeepPurple`; pass: Inner panel is visually separate from outer panel and preserves the lumen gap.
- `NE_InnerMembrane_Panel_04` (ENV_IN_04): Curved thick inner spherical shell panel; material `MAT_InnerMembrane_DeepPurple`; pass: Inner panel is visually separate from outer panel and preserves the lumen gap.
- `NE_InnerMembrane_Panel_05` (ENV_IN_05): Curved thick inner spherical shell panel; material `MAT_InnerMembrane_DeepPurple`; pass: Inner panel is visually separate from outer panel and preserves the lumen gap.
- `NE_InnerMembrane_Panel_06` (ENV_IN_06): Curved thick inner spherical shell panel; material `MAT_InnerMembrane_DeepPurple`; pass: Inner panel is visually separate from outer panel and preserves the lumen gap.
- `NE_InnerMembrane_Panel_07` (ENV_IN_07): Curved thick inner spherical shell panel; material `MAT_InnerMembrane_DeepPurple`; pass: Inner panel is visually separate from outer panel and preserves the lumen gap.
- `NE_InnerMembrane_Panel_08` (ENV_IN_08): Curved thick inner spherical shell panel; material `MAT_InnerMembrane_DeepPurple`; pass: Inner panel is visually separate from outer panel and preserves the lumen gap.
- `NE_PerinuclearLumen_Segment_01` (ENV_LUMEN_01): Transparent curved lumen segment; material `MAT_PerinuclearLumen_AmberGlow`; pass: The gap reads as a space, not a solid extra membrane.
- `NE_PerinuclearLumen_Segment_02` (ENV_LUMEN_02): Transparent curved lumen segment; material `MAT_PerinuclearLumen_AmberGlow`; pass: The gap reads as a space, not a solid extra membrane.
- `NE_PerinuclearLumen_Segment_03` (ENV_LUMEN_03): Transparent curved lumen segment; material `MAT_PerinuclearLumen_AmberGlow`; pass: The gap reads as a space, not a solid extra membrane.
- `NE_PerinuclearLumen_Segment_04` (ENV_LUMEN_04): Transparent curved lumen segment; material `MAT_PerinuclearLumen_AmberGlow`; pass: The gap reads as a space, not a solid extra membrane.
- `NE_PerinuclearLumen_Segment_05` (ENV_LUMEN_05): Transparent curved lumen segment; material `MAT_PerinuclearLumen_AmberGlow`; pass: The gap reads as a space, not a solid extra membrane.
- `NE_PerinuclearLumen_Segment_06` (ENV_LUMEN_06): Transparent curved lumen segment; material `MAT_PerinuclearLumen_AmberGlow`; pass: The gap reads as a space, not a solid extra membrane.
- `NE_PerinuclearLumen_Segment_07` (ENV_LUMEN_07): Transparent curved lumen segment; material `MAT_PerinuclearLumen_AmberGlow`; pass: The gap reads as a space, not a solid extra membrane.
- `NE_PerinuclearLumen_Segment_08` (ENV_LUMEN_08): Transparent curved lumen segment; material `MAT_PerinuclearLumen_AmberGlow`; pass: The gap reads as a space, not a solid extra membrane.
- `NE_Cutaway_OuterEdge_Rim` (ENV_TRIM_01): Rim/seam mesh; material `MAT_OuterMembrane_Purple`; pass: Cutaway edge looks intentional, not broken geometry.
- `NE_Cutaway_InnerEdge_Rim` (ENV_TRIM_02): Rim/seam mesh; material `MAT_InnerMembrane_DeepPurple`; pass: Inner rim is separate and darker than outer rim.
- `NE_Cutaway_Lumen_EdgeGlow` (ENV_TRIM_03): Rim/seam mesh; material `MAT_PerinuclearLumen_AmberGlow`; pass: The double membrane gap is obvious at cutaway edge.
- `NE_PanelSeam_Bevels` (ENV_SEAM_01): Rim/seam mesh; material `MAT_InnerMembrane_DeepPurple`; pass: Seams are visible but not distracting.

## G03 — NuclearPoreComplex_System / `03_NUCLEAR_PORE_SYSTEM`
Goal: Build NPCs as selective protein machines made of rings, lobes, gate cores, filaments, and baskets.
- `NPC_Master_Root` (NPC_M_001): Empty; material `MAT_NPC_Protein_Violet`; pass: One NPC module can be duplicated without breaking subpart alignment.
- `NPC_Cytoplasmic_Ring` (NPC_M_002): Torus/ring mesh; material `MAT_NPC_Protein_Violet`; pass: Ring is torus-like and clearly protein-based.
- `NPC_Nuclear_Ring` (NPC_M_003): Torus/ring mesh; material `MAT_NPC_Protein_Violet`; pass: Nuclear ring is aligned with cytoplasmic ring across the envelope.
- `NPC_Scaffold_Lobes_8` (NPC_M_004): Eight rounded protein lobes; material `MAT_NPC_Protein_Violet`; pass: Eight lobes are visible from close camera.
- `NPC_CentralGate_GelPlug` (NPC_M_005): Transparent gate plug/fibers; material `MAT_NPC_Gate_LilacGlass`; pass: Gate is visible but still suggests permeability.
- `NPC_Cytoplasmic_Filaments` (NPC_M_006): Curved filament set; material `MAT_NPC_Protein_Violet`; pass: Filaments are visible on selected close-up NPCs.
- `NPC_Nuclear_Basket` (NPC_M_007): Basket filament set; material `MAT_NPC_Protein_Violet`; pass: Basket shape is readable in close-up/cutaway.
- `NPC_Membrane_Collar` (NPC_M_008): Short cylinder/collar mesh; material `MAT_NPC_Protein_Violet`; pass: Collar helps explain the NPC perforates both membranes.
- `NPC_Instance_001` (NPC_I_001): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_002` (NPC_I_002): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_003` (NPC_I_003): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_004` (NPC_I_004): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_005` (NPC_I_005): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_006` (NPC_I_006): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_007` (NPC_I_007): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_008` (NPC_I_008): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_009` (NPC_I_009): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_010` (NPC_I_010): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_011` (NPC_I_011): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_012` (NPC_I_012): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_013` (NPC_I_013): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_014` (NPC_I_014): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_015` (NPC_I_015): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_016` (NPC_I_016): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_017` (NPC_I_017): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_018` (NPC_I_018): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_019` (NPC_I_019): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_020` (NPC_I_020): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_021` (NPC_I_021): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_022` (NPC_I_022): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_023` (NPC_I_023): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_024` (NPC_I_024): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_025` (NPC_I_025): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_026` (NPC_I_026): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_027` (NPC_I_027): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_028` (NPC_I_028): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_029` (NPC_I_029): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_030` (NPC_I_030): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_031` (NPC_I_031): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.
- `NPC_Instance_032` (NPC_I_032): Duplicated NPC module; material `MAT_NPC_Protein_Violet`; pass: NPC is flush with membrane and not floating above or buried inside.

## G04 — NuclearLamina_SupportMesh / `04_LAMINA`
Goal: Build a gold lamin lattice under the inner membrane with detachable mitosis fragments and chromatin anchor nodes.
- `Lamina_Geodesic_BaseNet` (LAM_001): Bevelled curve lattice; material `MAT_Lamina_Gold`; pass: Lamina is inside the envelope and follows the inner membrane curvature.
- `Lamina_Tile_01` (LAM_TILE_01): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_02` (LAM_TILE_02): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_03` (LAM_TILE_03): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_04` (LAM_TILE_04): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_05` (LAM_TILE_05): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_06` (LAM_TILE_06): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_07` (LAM_TILE_07): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_08` (LAM_TILE_08): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_09` (LAM_TILE_09): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_10` (LAM_TILE_10): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_11` (LAM_TILE_11): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_Tile_12` (LAM_TILE_12): Lattice tile segment; material `MAT_Lamina_Gold`; pass: Tile reads as part of one continuous mesh but can animate independently.
- `Lamina_ChromatinAnchor_Nodes` (LAM_013): Anchor bead mesh; material `MAT_Lamina_Gold`; pass: Anchor nodes touch lamina and point toward chromatin.
- `Lamina_Disassembly_Fragments` (LAM_014): Hidden fragment mesh; material `MAT_Lamina_Gold`; pass: Fragments clearly come from lamina lattice.

## G05 — Nucleoplasm_InternalMedium / `05_NUCLEOPLASM`
Goal: Build the inner semi-fluid volume, particle field, and flow curves without obscuring chromatin.
- `Nucleoplasm_GlassVolume` (NUCPL_001): Transparent inner ellipsoid; material `MAT_Nucleoplasm_BlueTransparent`; pass: Nucleoplasm is visible but does not hide genome structures.
- `Nucleoplasm_ParticleField` (NUCPL_002): Instanced tiny particles; material `MAT_Nucleoplasm_BlueTransparent`; pass: Particles remain inside nuclear boundary and are not too dense.
- `Nucleoplasm_FlowCurves` (NUCPL_003): Very faint curved paths; material `MAT_Cytoplasm_BlueGlass`; pass: Flow curves add depth without implying bulk leakage.

## G06 — GenomeSystem_Chromatin_Chromosomes / `06_GENOME_SYSTEM`
Goal: Build interphase chromatin, active transcription regions, heterochromatin, and hidden condensed chromosomes for mitosis.
- `Euchromatin_LooseLoop_Set_A` (GEN_CHR_001): Bevelled chromatin curve set; material `MAT_Chromatin_CyanHighlight`; pass: All chromatin remains inside the nucleus and reads as DNA/protein packaging.
- `Euchromatin_LooseLoop_Set_B` (GEN_CHR_002): Bevelled chromatin curve set; material `MAT_Chromatin_CyanHighlight`; pass: All chromatin remains inside the nucleus and reads as DNA/protein packaging.
- `Heterochromatin_PeripheralBand_Set_A` (GEN_CHR_003): Bevelled chromatin curve set; material `MAT_Chromatin_Purple`; pass: All chromatin remains inside the nucleus and reads as DNA/protein packaging.
- `Heterochromatin_PeripheralBand_Set_B` (GEN_CHR_004): Bevelled chromatin curve set; material `MAT_Chromatin_Purple`; pass: All chromatin remains inside the nucleus and reads as DNA/protein packaging.
- `Chromatin_BackgroundThread_Set` (GEN_CHR_005): Bevelled chromatin curve set; material `MAT_Chromatin_Purple`; pass: All chromatin remains inside the nucleus and reads as DNA/protein packaging.
- `TranscriptionHotspot_01` (GEN_TX_01): Highlighted chromatin segment + RNA spawn; material `MAT_Chromatin_CyanHighlight`; pass: RNA appears from chromatin, but DNA strand remains inside nucleus.
- `TranscriptionHotspot_02` (GEN_TX_02): Highlighted chromatin segment + RNA spawn; material `MAT_Chromatin_CyanHighlight`; pass: RNA appears from chromatin, but DNA strand remains inside nucleus.
- `TranscriptionHotspot_03` (GEN_TX_03): Highlighted chromatin segment + RNA spawn; material `MAT_Chromatin_CyanHighlight`; pass: RNA appears from chromatin, but DNA strand remains inside nucleus.
- `CondensedChromosome_01` (GEN_CHROMO_01): Stylized X/rod chromosome mesh; material `MAT_Chromosome_Magenta`; pass: Chromosome is recognizable as condensed DNA and distinct from loose chromatin.
- `CondensedChromosome_02` (GEN_CHROMO_02): Stylized X/rod chromosome mesh; material `MAT_Chromosome_Magenta`; pass: Chromosome is recognizable as condensed DNA and distinct from loose chromatin.
- `CondensedChromosome_03` (GEN_CHROMO_03): Stylized X/rod chromosome mesh; material `MAT_Chromosome_Magenta`; pass: Chromosome is recognizable as condensed DNA and distinct from loose chromatin.
- `CondensedChromosome_04` (GEN_CHROMO_04): Stylized X/rod chromosome mesh; material `MAT_Chromosome_Magenta`; pass: Chromosome is recognizable as condensed DNA and distinct from loose chromatin.
- `CondensedChromosome_05` (GEN_CHROMO_05): Stylized X/rod chromosome mesh; material `MAT_Chromosome_Magenta`; pass: Chromosome is recognizable as condensed DNA and distinct from loose chromatin.
- `CondensedChromosome_06` (GEN_CHROMO_06): Stylized X/rod chromosome mesh; material `MAT_Chromosome_Magenta`; pass: Chromosome is recognizable as condensed DNA and distinct from loose chromatin.
- `CondensedChromosome_07` (GEN_CHROMO_07): Stylized X/rod chromosome mesh; material `MAT_Chromosome_Magenta`; pass: Chromosome is recognizable as condensed DNA and distinct from loose chromatin.
- `CondensedChromosome_08` (GEN_CHROMO_08): Stylized X/rod chromosome mesh; material `MAT_Chromosome_Magenta`; pass: Chromosome is recognizable as condensed DNA and distinct from loose chromatin.
- `Chromatin_Condensation_PathCurves` (GEN_MORPH_001): Guide curve set; material `MAT_Chromatin_CyanHighlight`; pass: Paths do not imply DNA leaves nucleus.
- `RNA_Product_SpawnMarkers` (GEN_RNA_001): Small marker mesh; material `MAT_Cargo_RNA_Pink`; pass: RNA spawn points are clearly inside nucleus.

## G07 — Nucleolus_Subregions / `07_NUCLEOLUS`
Goal: Build the nucleolus as a non-membrane body with subregions and rRNA/ribosome biogenesis markers.
- `Nucleolus_Root` (NOL_001): Empty; material `MAT_Nucleolus_DeepViolet`; pass: Nucleolus has no surrounding membrane shell.
- `Nucleolus_FibrillarCenter` (NOL_002): Small internal bumpy spheroid; material `MAT_Nucleolus_DeepViolet`; pass: Reads as internal region, not a separate organelle.
- `Nucleolus_DenseFibrillar_Component` (NOL_003): Irregular ring/shell patch; material `MAT_Nucleolus_MagentaSpeckles`; pass: Subregion boundary is texture/color, not membrane.
- `Nucleolus_GranularOuterRegion` (NOL_004): Main bumpy outer spheroid; material `MAT_Nucleolus_DeepViolet`; pass: Outer nucleolus is dense and bumpy with no membrane envelope.
- `Nucleolus_rRNA_RibosomeMarkers` (NOL_005): Small pink/magenta particle markers; material `MAT_Nucleolus_MagentaSpeckles`; pass: Particles travel outward as ribosomal cargo, not DNA.
- `Nucleolus_Mitosis_DissolveParticles` (NOL_006): Hidden fading particle cloud; material `MAT_Nucleolus_MagentaSpeckles`; pass: Dissolve reads as non-membrane reorganization, not membrane rupture.

## G08 — NucleocytoplasmicTransport_CargoPaths / `08_TRANSPORT_CARGO`
Goal: Build animated import/export cargo, path curves, arrows, and gate-linked transport cues.
- `ProteinImport_PathCurve_01` (TRN_001): Curve path; material `MAT_Cargo_Protein_Green`; pass: Path crosses envelope only at NPC, not through membrane wall.
- `ProteinCargo_NLS_Set` (TRN_002): Green cargo spheres + tag beads; material `MAT_Cargo_Protein_Green`; pass: Cargo direction is clearly outside-to-inside.
- `RNAExport_PathCurve_01` (TRN_003): Curve path; material `MAT_Cargo_RNA_Pink`; pass: RNA goes out; DNA remains inside.
- `mRNA_Cargo_Squiggle_Set` (TRN_004): Pink bevelled RNA curves; material `MAT_Cargo_RNA_Pink`; pass: mRNA exits but chromatin does not.
- `RibosomalSubunit_Export_Cargo` (TRN_005): Paired magenta particles; material `MAT_Cargo_Ribosome_Magenta`; pass: Ribosomal cargo exits as particles/subunits, not as DNA.
- `SmallSolute_DiffusionDots` (TRN_006): Tiny neutral dots; material `MAT_NPC_Gate_LilacGlass`; pass: Dots are subtle and do not confuse cargo categories.
- `Transport_DirectionArrows` (TRN_007): Arrow meshes/curves; material `MAT_Hotspot_GoldEmission`; pass: Arrows are readable but can be hidden for realistic mode.
- `NPC_GatePulse_Controller` (TRN_008): Empty/controller; material `MAT_NPC_Gate_LilacGlass`; pass: Gate pulse happens only when cargo crosses.

## G09 — RoughER_ContinuityConnection / `09_CELL_CONNECTIONS`
Goal: Build the rough ER connection to the outer nuclear membrane and preserve the ER lumen/perinuclear continuity cue.
- `OuterEnvelope_ER_Bridge` (ER_001): Curved membrane bridge; material `MAT_RoughER_BluePurple`; pass: Bridge is physically connected to outer membrane, not just nearby.
- `RoughER_Sheet_Upper` (ER_002): Folded membrane sheet; material `MAT_RoughER_BluePurple`; pass: Rough ER sheet has ribosome dots and folded surface.
- `RoughER_Sheet_Lower` (ER_003): Folded membrane sheet; material `MAT_RoughER_BluePurple`; pass: Supports context but does not block nucleus.
- `ER_Lumen_Continuity_Band` (ER_004): Transparent lumen strip; material `MAT_PerinuclearLumen_AmberGlow`; pass: Lumen continuity is visually clear at the connection.
- `Ribosome_Dot_Set_ER` (ER_005): Instanced orange spheres; material `MAT_Ribosome_Orange`; pass: Orange dots look attached to ER surface.
- `ER_Mitosis_Disconnect_Seam` (ER_006): Hidden seam marker; material `MAT_RoughER_BluePurple`; pass: Seam appears only during mitosis/review mode.

## G10 — MitosisBreakdown_ReassemblyParts / `10_MITOSIS_FRAGMENTS`
Goal: Create envelope fragments, detached NPC pieces, lamina fragments, and reassembly target sockets.
- `Envelope_Fragment_Shards_Set` (MITO_001): Hidden curved membrane shards; material `MAT_MembraneFragment_Purple`; pass: Fragments match envelope material and motion direction.
- `Envelope_Vesicle_Bubbles_Set` (MITO_002): Hidden vesicle spheres; material `MAT_MembraneFragment_Purple`; pass: Vesicles are distinct from cargo particles.
- `NPC_Fragment_Detached_Set` (MITO_003): Hidden pore fragments; material `MAT_NPC_Protein_Violet`; pass: Pore fragments are violet and linked to NPC locations.
- `Lamina_Fragment_Set` (MITO_004): Hidden gold tube fragments; material `MAT_Lamina_Gold`; pass: Fragments match lamina color and originate under inner membrane.
- `Reassembly_Target_Sockets` (MITO_005): Hidden target empties; material `MAT_Label_White`; pass: Reassembly returns pieces to exact interphase positions.
- `Mitosis_Stage_Cards` (MITO_006): Optional 3D labels/cards; material `MAT_Label_White`; pass: Labels are optional and can be hidden.

## G11 — Hotspots_Labels_ReviewUI / `11_INTERACTION_HOTSPOTS`
Goal: Create Roblox interaction hotspots, optional labels, review icons, and animation triggers.
- `Hotspot_Transport` (HOT_001): Gold emissive icon/ring; material `MAT_Hotspot_GoldEmission`; pass: Hotspot is readable and can be hidden.
- `Hotspot_Transcription` (HOT_002): Gold emissive icon/ring; material `MAT_Hotspot_GoldEmission`; pass: Hotspot is readable and can be hidden.
- `Hotspot_Mitosis` (HOT_003): Gold emissive icon/ring; material `MAT_Hotspot_GoldEmission`; pass: Hotspot is readable and can be hidden.
- `Hotspot_Envelope` (HOT_004): Gold emissive icon/ring; material `MAT_Hotspot_GoldEmission`; pass: Hotspot is readable and can be hidden.
- `Hotspot_Nucleolus` (HOT_005): Gold emissive icon/ring; material `MAT_Hotspot_GoldEmission`; pass: Hotspot is readable and can be hidden.
- `Hotspot_Chromatin` (HOT_006): Gold emissive icon/ring; material `MAT_Hotspot_GoldEmission`; pass: Hotspot is readable and can be hidden.
- `Label_Set_MajorAnatomy` (HOT_007): 3D text labels; material `MAT_Label_White`; pass: Labels help but do not become required to understand the 3D shapes.

## G12 — Cameras_Lights_Checkpoints / `99_REVIEW_CHECKPOINTS`
Goal: Create cameras, lighting, labels, review checkpoints, and pass/fail controls.
- `CAM_Main_3D_Cell_Context` (CAM_001): Camera; material `MAT_Label_White`; pass: Camera shows full 3D quality and cohesive assembly.
- `CAM_Nucleus_Cutaway_Hero` (CAM_002): Camera; material `MAT_Label_White`; pass: Camera reveals internal anatomy and envelope surface details.
- `CAM_NPC_Transport_Closeup` (CAM_003): Camera; material `MAT_Label_White`; pass: NPC reads as selective complex and cargo path passes through it.
- `CAM_Envelope_DoubleMembrane_Closeup` (CAM_004): Camera; material `MAT_Label_White`; pass: Double membrane and perinuclear space are unmistakable.
- `CAM_Mitosis_Breakdown_Sequence` (CAM_005): Camera; material `MAT_Label_White`; pass: Breakdown and reassembly are understandable without labels.
- `CAM_Exploded_Component_View` (CAM_006): Camera; material `MAT_Label_White`; pass: Exploded view preserves assembly relationships.
- `Review_Checkpoint_Board` (CHK_001): 3D checklist board; material `MAT_Label_White`; pass: Board is readable from review camera or can be hidden.

## Animation ranges

```json
[
  {
    "range": "001-120",
    "name": "A01_Interphase_Idle",
    "objects": [
      "Nucleoplasm_ParticleField",
      "Chromatin_BackgroundThread_Set",
      "Nucleolus_GranularOuterRegion",
      "NPC_CentralGate_GelPlug"
    ],
    "pass": "Subtle motion only; nucleus remains intact."
  },
  {
    "range": "130-210",
    "name": "A02_Protein_Import_NLS",
    "objects": [
      "ProteinCargo_NLS_Set",
      "ProteinImport_PathCurve_01",
      "NPC_GatePulse_Controller"
    ],
    "pass": "Green cargo moves cytoplasm to nucleus through NPC."
  },
  {
    "range": "220-300",
    "name": "A03_RNA_Export",
    "objects": [
      "mRNA_Cargo_Squiggle_Set",
      "RNAExport_PathCurve_01",
      "RibosomalSubunit_Export_Cargo"
    ],
    "pass": "RNA/ribosomal cargo exits; chromatin stays inside."
  },
  {
    "range": "310-390",
    "name": "A04_Transcription_Hotspot",
    "objects": [
      "TranscriptionHotspot_01",
      "RNA_Product_SpawnMarkers"
    ],
    "pass": "RNA appears from chromatin hotspot without moving DNA."
  },
  {
    "range": "400-560",
    "name": "A05_Mitosis_Breakdown",
    "objects": [
      "CondensedChromosome_*",
      "NE_OuterMembrane_Panel_*",
      "NE_InnerMembrane_Panel_*",
      "Lamina_Tile_*",
      "NPC_Instance_*",
      "Envelope_Fragment_Shards_Set"
    ],
    "pass": "Chromatin condenses, nucleolus fades, lamina fragments, envelope panels split, NPCs detach."
  },
  {
    "range": "570-720",
    "name": "A06_Nuclear_Reassembly",
    "objects": [
      "Reassembly_Target_Sockets",
      "NE_*",
      "NPC_Instance_*",
      "Lamina_*",
      "Nucleolus_*"
    ],
    "pass": "Envelope reforms, pores reinsert, lamina returns, nucleolus and chromatin return to interphase state."
  }
]
```

## Review controls

```text
CTRL_Show_Cell_Context
CTRL_Show_Nucleus_Only
CTRL_Show_Cutaway
CTRL_Show_Envelope_Outer
CTRL_Show_Envelope_Inner
CTRL_Show_Perinuclear_Lumen
CTRL_Show_NPC_Master_Closeup
CTRL_Show_All_NPCs
CTRL_Show_Lamina
CTRL_Show_Nucleoplasm
CTRL_Show_Chromatin_Interphase
CTRL_Show_Chromosomes_Mitosis
CTRL_Show_Nucleolus_Subregions
CTRL_Show_Import_Path
CTRL_Show_Export_Path
CTRL_Show_ER_Connection
CTRL_Play_Interphase_Idle
CTRL_Play_Protein_Import
CTRL_Play_RNA_Export
CTRL_Play_Transcription
CTRL_Play_Mitosis_Breakdown
CTRL_Play_Reassembly
CTRL_Show_Exploded_View
CTRL_Show_Labels
CTRL_Show_Hotspots
CTRL_Switch_LOD0_Hero
CTRL_Switch_LOD1_Gameplay
CTRL_Switch_LOD2_Distant
```

## Checkpoints

```json
[
  {
    "id": "CP0",
    "name": "Scene setup and naming",
    "pass_criteria": "All collections and object names follow manifest exactly. No stray nucleus objects outside hierarchy."
  },
  {
    "id": "CP1",
    "name": "Whole organelle cohesion",
    "pass_criteria": "Nucleus sits in cytoplasm with clear socket and ER contact side; whole cell context reads in 3D."
  },
  {
    "id": "CP2",
    "name": "Double nuclear envelope",
    "pass_criteria": "Outer membrane, inner membrane, perinuclear lumen, and cutaway rims are all visible."
  },
  {
    "id": "CP3",
    "name": "Envelope panelization",
    "pass_criteria": "Outer/inner/lumen segments are separate and can split for mitosis without gaps/overlap errors."
  },
  {
    "id": "CP4",
    "name": "NPC biological readability",
    "pass_criteria": "NPCs are protein complexes with rings, lobes, gates, filaments/baskets on hero pores."
  },
  {
    "id": "CP5",
    "name": "Lamina support",
    "pass_criteria": "Gold lamina lies beneath inner membrane and anchors peripheral chromatin."
  },
  {
    "id": "CP6",
    "name": "Internal volume",
    "pass_criteria": "Nucleoplasm is transparent, textured, and does not obscure chromatin/nucleolus."
  },
  {
    "id": "CP7",
    "name": "Genome system",
    "pass_criteria": "Interphase chromatin and condensed chromosomes are separate states; DNA never exits the nucleus."
  },
  {
    "id": "CP8",
    "name": "Nucleolus",
    "pass_criteria": "Nucleolus is non-membrane, bumpy, subregioned, and able to fade/reform in mitosis."
  },
  {
    "id": "CP9",
    "name": "Transport",
    "pass_criteria": "Protein import and RNA/ribosomal export use NPC paths in opposite directions."
  },
  {
    "id": "CP10",
    "name": "ER continuity",
    "pass_criteria": "Outer membrane visibly connects to rough ER and perinuclear lumen continuity is shown."
  },
  {
    "id": "CP11",
    "name": "Mitosis animation",
    "pass_criteria": "Breakdown and reassembly can be understood using panels, fragments, chromosomes, and target sockets."
  },
  {
    "id": "CP12",
    "name": "Roblox export readiness",
    "pass_criteria": "Meshes are separate, origins sensible, surfaces thick enough, triangle budget recorded, materials portable."
  },
  {
    "id": "CP13",
    "name": "Final 3D quality",
    "pass_criteria": "Model has high-quality depth, texture, shadows, bevels, and readable stylized realism."
  }
]
```

## Detailed component manifest

Use the detailed manifest file `nucleus_reverse_component_manifest_deep.json` for exact component descriptions. Create components as separate objects unless explicitly marked optional or helper-only.

## Final output quality

The resulting Blender scene must pass the checkpoint review. It should look like a premium 3D educational nucleus model while remaining structurally organized for Roblox animation.
