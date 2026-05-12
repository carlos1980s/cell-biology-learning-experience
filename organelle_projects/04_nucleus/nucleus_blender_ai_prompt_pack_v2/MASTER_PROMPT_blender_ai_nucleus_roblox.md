# MASTER PROMPT — Blender AI Code Generation
## Project: Stylized-Realistic Animal Cell Nucleus for Roblox

You are an expert Blender technical artist and Python developer. Generate a complete Blender Python script using `bpy` that creates a stylized-realistic, colorful, biologically accurate, Roblox-friendly 3D model of an animal eukaryotic nucleus inside a simplified whole-cell context.

The model must be animation-ready and composed of named functional mesh objects. The purpose is not just to make a pretty nucleus: the asset must support Roblox educational interactions and biological animations, especially selective nuclear transport, chromatin behavior, nucleolus activity, and nuclear envelope breakdown/reassembly during mitosis.

## Output requirements for the AI coder

Return a complete Blender Python script only. The script must:
1. Clear the scene.
2. Create all collections, objects, materials, labels, pivots, and camera/lights.
3. Use exact object and collection names listed below.
4. Build objects as separate mesh/curve components, not as one merged mesh.
5. Add procedural materials and visible 3D texture/bump details.
6. Add frame ranges and named actions or keyframes for the animation plan.
7. Add empties and path curves for animation control.
8. Add review markers/checkpoint labels.
9. Keep topology simple enough for Roblox export.
10. Save the Blender file to `nucleus_roblox_functional_model.blend` if the execution environment allows saving.

## Global style

- Style: stylized-realistic educational 3D, colorful, high readability, simplified but biologically accurate.
- Use rounded forms, bevels, clean silhouettes, and strong material separation.
- Use a dark neutral background plane/grid only if helpful for preview.
- Main viewing camera: isometric 3/4 cutaway view.
- Include a second camera for close-up nuclear pore transport.
- Include a third camera for exploded component overview if possible.
- Do not create photorealistic microscopic noise that makes the asset hard to read.
- Use readable mesh names and collection names exactly.

## Scale and coordinate system

Use 1 Blender unit = 1 micrometer for conceptual scale.

- Whole cell context: ellipsoid approximately X=20, Y=14, Z=9.
- Nucleus center: `(0, 0, 0.2)`.
- Nucleus outer radius: approximately `3.2`.
- Inner membrane radius: approximately `2.95`.
- Perinuclear space: visible gap between outer and inner membranes.
- Nucleolus radius: approximately `0.65`, offset slightly from center.
- ER connection: attach to one side of outer nuclear envelope, preferably right/back side.
- Pivots: every functional object must have a centered, sensible origin. The whole nucleus must rotate around `Nucleus_RootRig`.

## Required hierarchy

Create this hierarchy:

```text
Cell_RootRig
├── Cell_Context_RootRig
├── Cytoplasm_Volume
├── NucleusSocket_Center
└── Nucleus_RootRig
    ├── NuclearEnvelope
    │   ├── NE_OuterMembrane_Panels
    │   ├── NE_InnerMembrane_Panels
    │   ├── NE_PerinuclearSpace_LumenBand
    │   └── NE_BreakdownFragments_Vesicles
    ├── NuclearPoreSystem
    │   ├── NPC_RingAssemblies
    │   └── NPC_GateCore_Selectivity
    ├── NuclearLamina_LatticeTiles
    ├── Nucleoplasm_Volume
    ├── GenomeSystem
    │   ├── Chromatin_DiffuseThreads
    │   └── Chromosomes_Condensed_MitosisSet
    ├── Nucleolus_SubregionBody
    ├── TransportCargo_Markers
    ├── OuterEnvelope_ERConnectionPort
    └── Nucleus_InteractionHotspots
```

Use Blender collections matching these groups:
- `00_CELL_CONTEXT`
- `01_NUCLEUS_ROOT`
- `02_NUCLEAR_ENVELOPE`
- `03_NUCLEAR_PORE_SYSTEM`
- `04_LAMINA`
- `05_NUCLEOPLASM`
- `06_GENOME_SYSTEM`
- `07_NUCLEOLUS`
- `08_TRANSPORT_CARGO`
- `09_CELL_CONNECTIONS`
- `10_MITOSIS_FRAGMENTS`
- `11_INTERACTION_HOTSPOTS`
- `99_REVIEW_CHECKPOINTS`

## Component specifications

[
  {
    "id": "C00",
    "name": "Cell_Context_RootRig",
    "collection": "00_CELL_CONTEXT",
    "type": "empty + optional transparent cell boundary",
    "purpose": "Defines the whole animal cell coordinate system so the nucleus is cohesive with the larger Roblox cell.",
    "geometry": "Create a transparent flattened ovoid cell shell and a central origin/pivot marker. Keep it lightweight.",
    "materials": [
      "CellMembrane_ClearBlue",
      "Cytoplasm_TransparentBlue"
    ],
    "animation": "Cell-level parent; no biological animation required except optional subtle cytoplasm drift.",
    "pass": "Whole cell silhouette is visible and nucleus sits inside it, not as a floating unrelated model."
  },
  {
    "id": "C01",
    "name": "Cytoplasm_Volume",
    "collection": "00_CELL_CONTEXT",
    "type": "semi-transparent volume mesh",
    "purpose": "Shows that the nucleus is embedded in cytoplasm and that cargo moves between nucleus and cytoplasm.",
    "geometry": "Low-poly transparent ovoid volume with faint particle dots and flowing curves.",
    "materials": [
      "Cytoplasm_TransparentBlue",
      "Cytoplasm_ParticleSpecks"
    ],
    "animation": "Subtle slow drift of internal particles and cytoplasmic paths.",
    "pass": "Does not obscure the nucleus; should be readable from isometric and side camera views."
  },
  {
    "id": "C02",
    "name": "NucleusSocket_Center",
    "collection": "00_CELL_CONTEXT",
    "type": "empty/socket marker",
    "purpose": "Roblox assembly anchor for placing, repositioning, or replacing the nucleus model inside the cell.",
    "geometry": "Small non-render or optional visible ring at nucleus center; add XYZ arrow axes.",
    "materials": [
      "Socket_White",
      "Axis_RedGreenBlue"
    ],
    "animation": "Parent point for the whole nucleus. All nucleus objects should ultimately track this pivot.",
    "pass": "Origin is at the center of nucleus mass; rotations preserve envelope alignment."
  },
  {
    "id": "N01",
    "name": "Nucleus_RootRig",
    "collection": "01_NUCLEUS_ROOT",
    "type": "empty/root",
    "purpose": "Parent object for all nucleus assets; controls placement, scaling, and high-level animation.",
    "geometry": "Visible pivot gizmo plus optional faint sphere radius guide.",
    "materials": [
      "Pivot_White",
      "Guide_Transparent"
    ],
    "animation": "Master parent for interphase, transport, and mitosis actions.",
    "pass": "Every nucleus component is parented under this root; no stray unparented nucleus objects."
  },
  {
    "id": "N02",
    "name": "NE_OuterMembrane_Panels",
    "collection": "02_NUCLEAR_ENVELOPE",
    "type": "segmented spherical shell mesh",
    "purpose": "Outer nuclear membrane; continuous with rough ER; splits during mitosis.",
    "geometry": "Create 8-12 curved shell panels forming outer sphere. Leave circular holes or socket depressions for NPCs. Add small surface bumps.",
    "materials": [
      "Membrane_Outer_Purple",
      "Membrane_Roughness_Bump"
    ],
    "animation": "Panels separate outward during nuclear envelope breakdown; reassemble during telophase.",
    "pass": "Double membrane is clear; outer layer is distinct from inner membrane; panel seams are visible but not distracting."
  },
  {
    "id": "N03",
    "name": "NE_InnerMembrane_Panels",
    "collection": "02_NUCLEAR_ENVELOPE",
    "type": "inner segmented spherical shell mesh",
    "purpose": "Inner nuclear membrane lining nucleoplasm; supports lamina attachment.",
    "geometry": "Create matching inner shell panels with slightly smaller radius and darker purple color. Align with outer panels but keep gap visible.",
    "materials": [
      "Membrane_Inner_DeepPurple"
    ],
    "animation": "Splits with envelope but slightly delayed behind the outer membrane.",
    "pass": "Perinuclear space visibly separates inner and outer membranes throughout the shell."
  },
  {
    "id": "N04",
    "name": "NE_PerinuclearSpace_LumenBand",
    "collection": "02_NUCLEAR_ENVELOPE",
    "type": "transparent gap/lumen band",
    "purpose": "Narrow lumen between inner and outer membranes, continuous with ER lumen.",
    "geometry": "Thin amber/cyan translucent spherical band between the two membranes. Use additive material.",
    "materials": [
      "Lumen_AmberGlow_Transparent"
    ],
    "animation": "Glows subtly; splits with envelope panels during mitosis.",
    "pass": "Learner can see there are two membranes rather than one thick wall."
  },
  {
    "id": "N05",
    "name": "NPC_RingAssemblies",
    "collection": "03_NUCLEAR_PORE_SYSTEM",
    "type": "instanced torus/ring protein complexes",
    "purpose": "Nuclear pore complexes that regulate transport; not simple holes.",
    "geometry": "Place 24-36 pores across envelope. Each pore is a torus-like ring with 8 radial protein lobes, cytoplasmic rim, nuclear rim, and central opening.",
    "materials": [
      "NPC_Protein_Violet",
      "NPC_Rim_DarkPurple"
    ],
    "animation": "NPC rings remain aligned to membrane; can detach/scatter in mitosis; pulse during transport.",
    "pass": "NPCs read as protein assemblies with ring/lobes, not blank circular holes."
  },
  {
    "id": "N06",
    "name": "NPC_GateCore_Selectivity",
    "collection": "03_NUCLEAR_PORE_SYSTEM",
    "type": "semi-transparent central gate meshes",
    "purpose": "Shows selective barrier inside each NPC.",
    "geometry": "For major visible NPCs, add translucent gel-like plug or star/funnel fibers in the pore center.",
    "materials": [
      "NPC_Gate_Lilac_Transparent"
    ],
    "animation": "Gate opens/pulses for import/export cargo; small solutes can pass freely while large cargo uses marked transport.",
    "pass": "At least six visible NPCs show gate cores clearly from the main camera."
  },
  {
    "id": "N07",
    "name": "NuclearLamina_LatticeTiles",
    "collection": "04_LAMINA",
    "type": "inner lattice mesh/curves",
    "purpose": "Supportive lamin network under inner membrane; maintains nuclear shape and anchors chromatin.",
    "geometry": "Gold/orange geodesic net just inside inner membrane. Use curves or low-poly tubes.",
    "materials": [
      "Lamina_Gold"
    ],
    "animation": "Disassembles into short fragments before envelope breakdown; reassembles in telophase.",
    "pass": "Lamina is visually under the inner membrane, not floating in the nucleoplasm center."
  },
  {
    "id": "N08",
    "name": "Nucleoplasm_Volume",
    "collection": "05_NUCLEOPLASM",
    "type": "transparent inner volume",
    "purpose": "Semi-fluid internal matrix containing enzymes, nucleotides, proteins, RNA, chromatin, and nucleolus.",
    "geometry": "Transparent bluish sphere/ellipsoid inside inner membrane with tiny floating particles.",
    "materials": [
      "Nucleoplasm_BlueGlass",
      "Nucleoplasm_Particles"
    ],
    "animation": "Slow fluid-like movement and gentle particle drift.",
    "pass": "Readable as internal volume; does not hide chromatin or nucleolus."
  },
  {
    "id": "N09",
    "name": "Chromatin_DiffuseThreads",
    "collection": "06_GENOME_SYSTEM",
    "type": "beveled curves/threads",
    "purpose": "DNA packaged with histones during interphase; source of transcription.",
    "geometry": "Create layered irregular purple/cyan thread network distributed inside nucleoplasm, with denser regions near lamina and around nucleolus.",
    "materials": [
      "Chromatin_Purple",
      "Chromatin_CyanHighlights"
    ],
    "animation": "Idle drifting; selected regions glow for transcription; condense toward chromosome meshes during mitosis.",
    "pass": "Chromatin remains inside nucleus. It should never be animated leaving through NPCs."
  },
  {
    "id": "N10",
    "name": "Chromosomes_Condensed_MitosisSet",
    "collection": "06_GENOME_SYSTEM",
    "type": "hidden/optional chromosome meshes",
    "purpose": "Condensed DNA state for mitosis animation.",
    "geometry": "Create 6-10 stylized X/rod chromosome meshes for educational display, initially hidden inside nucleus.",
    "materials": [
      "Chromosome_MagentaPurple"
    ],
    "animation": "Fade/scale in during prophase as diffuse chromatin fades; align for metaphase demo if requested.",
    "pass": "Chromosomes have clear condensed forms and are separate from interphase chromatin meshes."
  },
  {
    "id": "N11",
    "name": "Nucleolus_SubregionBody",
    "collection": "07_NUCLEOLUS",
    "type": "bumpy non-membrane spheroid with subregions",
    "purpose": "Dense non-membrane nuclear region for rRNA synthesis and ribosomal subunit assembly.",
    "geometry": "Create one large irregular purple spheroid with three subtle subregion textures: fibrillar center, dense fibrillar component, granular component.",
    "materials": [
      "Nucleolus_DeepViolet",
      "Nucleolus_MagentaSpeckles"
    ],
    "animation": "Pulses during rRNA production; fades/disassembles during mitosis; reforms after envelope reassembly.",
    "pass": "No membrane is drawn around it; label/material should communicate it is a dense region, not a separate organelle membrane."
  },
  {
    "id": "N12",
    "name": "TransportCargo_Markers",
    "collection": "08_TRANSPORT_CARGO",
    "type": "animated markers/curves",
    "purpose": "Shows protein import and RNA/ribosomal export pathways through NPCs.",
    "geometry": "Green protein cargo spheres with NLS tags move inward; pink RNA squiggle curves and magenta ribosomal subunit particles move outward.",
    "materials": [
      "Cargo_Protein_Green",
      "Cargo_RNA_Pink",
      "Cargo_Ribosome_Magenta"
    ],
    "animation": "Create path curves through selected NPCs. Protein moves cytoplasm->nucleoplasm; RNA moves nucleoplasm->cytoplasm.",
    "pass": "DNA never exits; only RNA/protein/ribosomal cargo crosses NPCs."
  },
  {
    "id": "N13",
    "name": "OuterEnvelope_ERConnectionPort",
    "collection": "09_CELL_CONNECTIONS",
    "type": "curved membrane bridge",
    "purpose": "Shows outer nuclear membrane continuity with rough ER.",
    "geometry": "Add 2-3 ribosome-dotted ER sheet/tube segments attached to one side of outer membrane.",
    "materials": [
      "RoughER_BluePurple",
      "Ribosome_OrangeDots"
    ],
    "animation": "Optional subtle ER sway; remains attached to outer membrane in interphase; separates during envelope breakdown.",
    "pass": "Connection side is visible and clear without overwhelming nucleus."
  },
  {
    "id": "N14",
    "name": "NE_BreakdownFragments_Vesicles",
    "collection": "10_MITOSIS_FRAGMENTS",
    "type": "hidden fragment meshes",
    "purpose": "Represents nuclear envelope breakdown into vesicles/fragments during mitosis.",
    "geometry": "Small purple membrane shards and vesicle spheres, initially hidden around envelope.",
    "materials": [
      "Membrane_Fragment_Purple",
      "NPC_Fragment_Violet"
    ],
    "animation": "Appear as outer/inner membrane panels fade/split; scatter outward, then hide/reverse for reassembly.",
    "pass": "Fragment motion is organized enough to teach breakdown, not random visual noise."
  },
  {
    "id": "N15",
    "name": "Nucleus_InteractionHotspots",
    "collection": "11_INTERACTION_HOTSPOTS",
    "type": "click/tap hotspot markers",
    "purpose": "Roblox interactions for learning, inspection, and triggering animations.",
    "geometry": "Small low-poly icon plaques/rings: Transport, Transcription, Mitosis, Envelope, Nucleolus, Chromatin.",
    "materials": [
      "Hotspot_Gold",
      "Hotspot_Emission"
    ],
    "animation": "Pulse gently; each hotspot triggers one educational animation group.",
    "pass": "Hotspots are visible but do not block scientific structures."
  }
]

## Material specifications

Create named materials with the following color and texture intent:

{
  "CellMembrane_ClearBlue": {
    "hex": "#8CCBFF",
    "alpha": 0.22,
    "finish": "transparent glass, soft rim highlight"
  },
  "Cytoplasm_TransparentBlue": {
    "hex": "#4DA7FF",
    "alpha": 0.12,
    "finish": "transparent volume, very low roughness"
  },
  "Membrane_Outer_Purple": {
    "hex": "#8B55D7",
    "alpha": 1.0,
    "finish": "stylized membrane, satin, procedural fine bump"
  },
  "Membrane_Inner_DeepPurple": {
    "hex": "#5E36A6",
    "alpha": 1.0,
    "finish": "slightly darker satin membrane"
  },
  "Lumen_AmberGlow_Transparent": {
    "hex": "#F4A03A",
    "alpha": 0.35,
    "finish": "transparent additive glow"
  },
  "NPC_Protein_Violet": {
    "hex": "#6E35B9",
    "alpha": 1.0,
    "finish": "rounded protein lobes, soft bevels"
  },
  "NPC_Gate_Lilac_Transparent": {
    "hex": "#C07BFF",
    "alpha": 0.45,
    "finish": "gel-like selective barrier"
  },
  "Lamina_Gold": {
    "hex": "#DFA03A",
    "alpha": 1.0,
    "finish": "thin tube lattice, warm gold"
  },
  "Nucleoplasm_BlueGlass": {
    "hex": "#2F78D8",
    "alpha": 0.23,
    "finish": "glass-like internal matrix"
  },
  "Chromatin_Purple": {
    "hex": "#C65BFF",
    "alpha": 1.0,
    "finish": "beveled threads with slight emission"
  },
  "Chromatin_CyanHighlights": {
    "hex": "#1E9CFF",
    "alpha": 1.0,
    "finish": "secondary thread highlights"
  },
  "Chromosome_MagentaPurple": {
    "hex": "#B246FF",
    "alpha": 1.0,
    "finish": "smooth condensed chromosome surface"
  },
  "Nucleolus_DeepViolet": {
    "hex": "#5A176A",
    "alpha": 1.0,
    "finish": "bumpy dense spheroid, high roughness"
  },
  "Nucleolus_MagentaSpeckles": {
    "hex": "#E15BD8",
    "alpha": 1.0,
    "finish": "tiny speckles and bumps"
  },
  "Cargo_Protein_Green": {
    "hex": "#56C96F",
    "alpha": 1.0,
    "finish": "small glossy spheres"
  },
  "Cargo_RNA_Pink": {
    "hex": "#F05FA6",
    "alpha": 1.0,
    "finish": "pink RNA squiggle curves"
  },
  "Cargo_Ribosome_Magenta": {
    "hex": "#C94EC8",
    "alpha": 1.0,
    "finish": "paired rounded subunit particles"
  },
  "RoughER_BluePurple": {
    "hex": "#625BD6",
    "alpha": 1.0,
    "finish": "folded membrane sheets with ribosome dots"
  },
  "Ribosome_OrangeDots": {
    "hex": "#F06A2B",
    "alpha": 1.0,
    "finish": "tiny orange dots"
  },
  "Membrane_Fragment_Purple": {
    "hex": "#9B5BE0",
    "alpha": 1.0,
    "finish": "small broken curved membrane pieces"
  },
  "Hotspot_Gold": {
    "hex": "#F4C542",
    "alpha": 1.0,
    "finish": "emissive rim icon markers"
  }
}

Use Blender procedural nodes where possible:
- Membranes: Principled BSDF, satin finish, procedural noise bump, subtle color variation.
- Nucleoplasm and cytoplasm: transparent glass-like material with low alpha.
- Perinuclear lumen: translucent amber glow with emission.
- Lamina: gold tube lattice with clean bevels.
- Chromatin: beveled curves with purple/cyan alternating strands and slight emission.
- Nucleolus: rough bumpy spheroid with procedural noise displacement/normal.
- NPCs: smooth violet protein lobes, central lilac transparent gate.
- Cargo: glossy green protein spheres, pink RNA squiggle curves, magenta ribosomal subunits.
- Hotspots: gold/emissive icons or rings.

## Geometry instructions by component

### Whole-cell context
Create a transparent ovoid cell boundary and faint cytoplasm volume. Add a `NucleusSocket_Center` empty/ring at the nucleus position. Add simplified surrounding organelles only as contextual shapes if helpful: rough ER sheets around the nucleus, a few mitochondria, Golgi arcs, lysosome spheres, peroxisome spheres, and cytoskeleton fibers. Keep these secondary and low-detail so the nucleus remains the hero.

### Nucleus root
Create `Nucleus_RootRig` as an Empty at `(0,0,0.2)`. Parent all nucleus objects to it. Add a visible pivot marker: small white sphere at center plus X/Y/Z arrows.

### Outer nuclear membrane panels
Build `NE_OuterMembrane_Panels` as 8-12 curved shell panels, not one solid sphere. Use UV sphere segments or generated parametric mesh patches. Add a cutaway window on the front-left side so internal structures are visible. The outer membrane should have rounded bevels and visible pores distributed across it.

### Inner nuclear membrane panels
Build `NE_InnerMembrane_Panels` as a smaller segmented inner shell. Align with the outer panels and preserve a visible perinuclear space. Use darker purple. Include a cutaway matching the outer membrane.

### Perinuclear space
Create `NE_PerinuclearSpace_LumenBand` as a thin transparent amber/cyan band between the membranes. It must visually prove that the nuclear envelope is a double membrane.

### Nuclear pore complexes
Create `NPC_RingAssemblies` using instanced or duplicated pore complexes:
- Place 24-36 NPCs on visible and partially hidden membrane areas.
- Each NPC should have:
  - outer torus/ring,
  - 8 radial protein lobes,
  - central opening,
  - optional cytoplasmic and nuclear rim rings.
- Align each NPC normal to the membrane surface.
- Avoid making them simple holes.

### NPC selective gate core
Create `NPC_GateCore_Selectivity` as translucent plugs/fibers inside selected visible pores. Gate cores should be most visible on 6-10 pores, especially on the cutaway/front side.

### Nuclear lamina
Create `NuclearLamina_LatticeTiles` as a gold/orange network just beneath the inner membrane. It can be made of bevelled curves, geodesic arcs, or a triangulated net. It should hug the inside of the inner envelope.

### Nucleoplasm
Create `Nucleoplasm_Volume` as a transparent blue inner sphere/ellipsoid. Add small floating particles inside.

### Chromatin
Create `Chromatin_DiffuseThreads` as many irregular beveled curves inside the nucleoplasm. Use purple and cyan strands. Place some threads near the lamina and some around the nucleolus. Add 2-3 highlighted transcription hotspot strands.

### Condensed chromosomes
Create `Chromosomes_Condensed_MitosisSet` as 6-10 stylized X-shaped or rod-like chromosome meshes, initially hidden or low alpha. They should be visible during the mitosis animation sequence.

### Nucleolus
Create `Nucleolus_SubregionBody` as one dense bumpy spheroid inside the nucleoplasm. It must not have a membrane. Use procedural noise bump and speckles. Add 2-3 subtle internal zones with slightly different purple/magenta tones.

### Transport cargo
Create `TransportCargo_Markers`:
- Green protein cargo spheres with small NLS tag markers moving inward.
- Pink RNA squiggle curves moving outward.
- Magenta ribosomal subunit particles moving outward.
- Add path curves through selected NPCs.
- Ensure DNA/chromatin never leaves the nucleus.

### ER connection
Create `OuterEnvelope_ERConnectionPort` as 2-3 folded rough ER membrane sheets/tubes connected to the outer nuclear membrane. Add small orange ribosome dots on the ER surface. It should visually show the outer nuclear membrane is continuous with rough ER.

### Envelope breakdown fragments
Create `NE_BreakdownFragments_Vesicles` as small membrane shards/vesicles and detached NPC pieces, initially hidden. Use them in mitosis animation.

### Interaction hotspots
Create `Nucleus_InteractionHotspots` as small gold/emissive rings or plaques around the model:
- `Hotspot_Transport`
- `Hotspot_Transcription`
- `Hotspot_Mitosis`
- `Hotspot_Envelope`
- `Hotspot_Nucleolus`
- `Hotspot_Chromatin`

They should be visible from the main camera but not block the anatomy.

## Animation plan

Create these animation ranges and keyframes:

[
  {
    "name": "A01_Interphase_Idle",
    "frames": "1-120",
    "description": "Nucleoplasm particles drift, chromatin gently wiggles, nucleolus pulses, NPC gates breathe lightly."
  },
  {
    "name": "A02_Protein_Import_NLS",
    "frames": "130-210",
    "description": "Green NLS protein cargo moves from cytoplasm through NPC gate into nucleoplasm; gate pulses open during crossing."
  },
  {
    "name": "A03_RNA_Export",
    "frames": "220-300",
    "description": "Pink mRNA squiggle and ribosomal subunit particles move from nucleoplasm through NPC to cytoplasm; DNA/chromatin stays inside."
  },
  {
    "name": "A04_Transcription_Hotspot",
    "frames": "310-390",
    "description": "A chromatin region glows; small RNA curve appears and travels toward an NPC."
  },
  {
    "name": "A05_Mitosis_Envelope_Breakdown",
    "frames": "400-560",
    "description": "Chromatin condenses; nucleolus fades; lamina fragments; NPCs detach; envelope panels separate into membrane fragments."
  },
  {
    "name": "A06_Nuclear_Reassembly",
    "frames": "570-720",
    "description": "Fragments and panels return; lamina re-forms; NPCs reinsert; nucleolus returns; chromatin diffuses."
  }
]

### Animation implementation details

- Use frame 1 as clean interphase default.
- Add keyframes for visibility, scale, material alpha, emission strength, and object position.
- Use path constraints or keyframed positions for cargo markers.
- Add custom properties on `Nucleus_RootRig` if possible:
  - `show_cutaway`
  - `play_transport_import`
  - `play_transport_export`
  - `play_mitosis_breakdown`
  - `show_component_exploded`
- Make sure all animations can be isolated by hiding/showing collections.

## Labels and review overlays

Add simple 3D text labels near major structures:
- Outer nuclear membrane
- Inner nuclear membrane
- Perinuclear space
- Nuclear pore complex
- Nuclear lamina
- Nucleoplasm
- Chromatin
- Nucleolus
- Rough ER connection
- Import cargo
- RNA export cargo
- Pivot / nucleus socket

Labels should face the main camera or be placed on a separate review layer. Keep them optional by placing them in `99_REVIEW_CHECKPOINTS`.

## Roblox optimization rules

- Keep all components separate for animation.
- Use quads where possible, but acceptable triangulation for export.
- Avoid unnecessary high subdivision.
- Use instancing during Blender generation, but make sure final objects can be converted to mesh if Roblox export requires it.
- Avoid thin single-sided surfaces that disappear in Roblox. Add small thickness to membrane panels, ER sheets, and plaques.
- Keep transparent surfaces limited and readable.
- Use simple PBR materials that can be approximated in Roblox.
- Keep total nucleus triangle budget target under 90,000 triangles for the hero asset. Create optional lower LOD duplicates if possible:
  - LOD0: full educational hero model
  - LOD1: reduced pore count and simplified chromatin
  - LOD2: shell + major labels only

## Biological accuracy constraints

The generated model must clearly teach:
1. The nuclear envelope has two membranes, not one.
2. The perinuclear space exists between those membranes.
3. Nuclear pores are selective protein complexes, not simple holes.
4. DNA/chromatin stays inside the nucleus.
5. RNA and proteins move through nuclear pores.
6. The nucleolus is non-membrane-bound.
7. The outer nuclear membrane is continuous with rough ER.
8. The lamina supports the inner nuclear membrane.
9. During mitosis in animal cells, the nuclear envelope can break down and reassemble.

## Quality bar

The final asset should look like a high-quality 3D educational infographic model, similar to a polished stylized biology museum display or Roblox learning experience. It should be readable from a distance and still contain enough detail for close inspection.