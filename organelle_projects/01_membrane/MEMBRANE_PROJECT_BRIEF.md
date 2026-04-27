# 01 Membrane

Purpose: define the playable cell boundary, phospholipid bilayer, membrane
proteins, receptors, and inside/outside relationship.

Recommended Roblox object: one `Model` named `CellMembrane` with a stable pivot,
visual subfolders for bilayer/proteins/receptors, and interaction markers for
transport and permeability lessons.

First build target: a movable translucent membrane shell that can be assembled
around the rest of the cell without owning any interior organelle logic.

## Biological Overview

The plasma membrane is the selectively permeable boundary between the cytoplasm
and the extracellular environment. It is not a rigid wall: the accepted
fluid-mosaic model describes a thin, fluid lipid bilayer containing proteins,
cholesterol, and carbohydrate-bearing lipids/proteins. OpenStax gives a typical
plasma membrane thickness of about 5 to 10 nm and identifies phospholipids,
cholesterol, proteins, and carbohydrates as the main components
([OpenStax Biology 2e 5.1](https://openstax.org/books/biology-2e/pages/5-1-components-and-structure)).

For A-level and first-year biology, the key idea is selective exchange. Small
nonpolar molecules can cross the hydrophobic core more easily, while ions,
larger polar solutes, and many metabolites require membrane proteins or vesicle
traffic. The membrane also provides cell recognition, signalling, adhesion, and
mechanical linkage to the cytoskeleton.

## Detailed Structure

- **Phospholipid bilayer:** two leaflets of amphipathic phospholipids with
  hydrophilic heads facing water and hydrophobic fatty-acid tails facing inward.
- **Leaflet asymmetry:** the outer and inner leaflets can differ in lipid
  composition. Molecular Biology of the Cell notes that, in human red blood
  cell membranes, choline-containing lipids are concentrated in the outer
  leaflet while phosphatidylethanolamine and phosphatidylserine are mostly in
  the inner leaflet
  ([NCBI Bookshelf, The Lipid Bilayer](https://www.ncbi.nlm.nih.gov/books/NBK26871/)).
- **Integral membrane proteins:** embedded permanently in the bilayer; many span
  the membrane as channels, carriers, receptors, pumps, or adhesion proteins.
- **Peripheral membrane proteins:** attached to membrane surfaces or to integral
  proteins; often involved in signalling, cytoskeletal anchoring, or enzymes.
- **Carbohydrate layer:** glycoproteins and glycolipids project mainly from the
  extracellular surface, contributing to recognition, adhesion, and protection.
- **Cholesterol in animal membranes:** positioned among phospholipid tails; it
  buffers fluidity and permeability rather than simply "making membranes solid."
- **Cytoskeletal attachment:** actin and adaptor proteins can tether membrane
  proteins and help maintain shape, polarity, and localized receptor domains.

## Chemistry and Composition

- Phospholipids contain a glycerol backbone, two hydrophobic fatty-acid chains,
  and a phosphate-containing hydrophilic head group
  ([OpenStax Concepts of Biology 3.3](https://openstax.org/books/concepts-biology/pages/3-3-eukaryotic-cells)).
- Fatty-acid tail length and saturation affect fluidity: shorter and more
  unsaturated tails generally increase fluidity, while longer and saturated
  tails pack more tightly.
- Cholesterol is a sterol with four fused carbon rings; it restricts excessive
  phospholipid movement at higher temperatures and reduces tight packing at
  lower temperatures.
- Membrane proteins are made from amino-acid chains. Their hydrophobic regions
  interact with lipid tails, while hydrophilic regions face cytosol or
  extracellular fluid.
- Membrane carbohydrates occur as oligosaccharides attached to proteins or
  lipids. Glycolipids are exposed on the noncytosolic leaflet and are involved
  in interactions with the cell surroundings
  ([NCBI Bookshelf, The Lipid Bilayer](https://www.ncbi.nlm.nih.gov/books/NBK26871/)).
- The exact protein:lipid:carbohydrate ratio varies by cell type. OpenStax
  describes a typical human plasma membrane by mass as roughly 50 percent
  protein, 40 percent lipid, and 10 percent carbohydrate, while stressing that
  this varies among membranes
  ([OpenStax Biology 2e 5.1](https://openstax.org/books/biology-2e/pages/5-1-components-and-structure)).

## Functions

- **Compartment boundary:** separates cytoplasm from extracellular fluid and
  allows the cell to maintain internal conditions.
- **Selective permeability:** permits or blocks substances according to size,
  polarity, charge, lipid solubility, and the presence of transport proteins.
- **Passive transport:** diffusion moves substances down concentration
  gradients; osmosis is water movement through a semipermeable membrane
  ([OpenStax Biology 2e 5.2](https://openstax.org/books/biology-2e/pages/5-2-passive-transport)).
- **Facilitated diffusion:** channels and carriers allow polar molecules or ions
  to cross down gradients without direct ATP use.
- **Active transport:** pumps use energy, often ATP, to move substances against
  concentration or electrochemical gradients
  ([OpenStax Concepts of Biology 3.6](https://openstax.org/books/concepts-biology/pages/3-6-active-transport)).
- **Bulk transport:** endocytosis brings large materials into the cell, and
  exocytosis releases materials by vesicle fusion
  ([OpenStax Biology 2e 5.4](https://openstax.org/books/biology-2e/pages/5-4-bulk-transport)).
- **Signal reception:** receptors bind external ligands such as hormones or
  growth factors and activate intracellular response pathways.
- **Cell identity and adhesion:** carbohydrate-bearing molecules contribute to
  self/non-self recognition and cell-cell interaction.

## Dynamic Processes to Teach

- **Lateral diffusion:** lipids and some proteins move sideways within a leaflet.
- **Rare flip-flop:** spontaneous movement of phospholipids between leaflets is
  uncommon; enzymes such as flippases, floppases, and scramblases can control
  lipid distribution.
- **Membrane fluidity regulation:** temperature, fatty-acid saturation, and
  cholesterol all affect how freely components move. Molecular Biology of the
  Cell stresses that membrane fluidity must be regulated for transport and
  enzyme activities to work properly
  ([NCBI Bookshelf, The Lipid Bilayer](https://www.ncbi.nlm.nih.gov/books/NBK26871/)).
- **Channel gating:** ion channels can open or close in response to voltage,
  ligand binding, or mechanical stress.
- **Carrier conformational change:** carrier proteins bind a solute, change
  shape, and release it on the other side.
- **Osmotic change:** water influx can swell animal cells, while water loss can
  shrink them; plant cells use a cell wall and central vacuole to resist lysis.
- **Endocytosis/exocytosis:** membrane is removed from or added to the cell
  surface by vesicle budding and fusion.
- **Receptor clustering:** signalling proteins can gather in local membrane
  domains, allowing one region of membrane to behave differently from another.

## Learning Misconceptions

- **"The membrane is a solid wall."** It is a fluid bilayer with mobile lipids
  and proteins, not a fixed shell.
- **"Everything small passes freely."** Charge and polarity matter. Ions and
  many polar molecules require channels or carriers even if they are small.
- **"Active transport always means endocytosis."** Pumps, coupled transporters,
  endocytosis, and exocytosis are different mechanisms that can all require
  energy.
- **"Osmosis moves solute."** Osmosis refers to water movement; solutes create
  the water potential gradient.
- **"Proteins only float randomly."** Many membrane proteins are constrained by
  cytoskeletal links, extracellular matrix links, lipid domains, or cell
  junctions.
- **"Cholesterol always stiffens membranes."** It buffers fluidity: it limits
  excessive movement but can also prevent tight packing.

## Roblox Design Concept

Build the membrane as a semi-transparent boundary that players can approach,
inspect, and pass through only at appropriate transport hotspots. The experience
should make the membrane feel selectively permeable: small nonpolar particles
can fade through general lipid regions, ions wait at channels, glucose uses a
carrier, and cargo vesicles dock at endocytosis/exocytosis zones.

Keep the membrane visually thin but not invisible. The player should read it as
two surfaces with embedded components, not as a thick plastic sphere.

## Model Hierarchy

```text
CellMembrane
  BilayerShell
    OuterLeaflet
    InnerLeaflet
    HydrophobicCoreCue
  Lipids
    PhospholipidHeads_Outer
    PhospholipidHeads_Inner
    FattyAcidTails
    CholesterolMarkers
  Proteins
    Channels
    Carriers
    Pumps
    Receptors
    AdhesionProteins
  Carbohydrates
    GlycoproteinChains
    GlycolipidChains
  InteractionHotspots
    DiffusionGate
    OsmosisGate
    IonChannelGate
    GlucoseCarrierGate
    ATPPumpGate
    EndocytosisDock
    ExocytosisDock
    ReceptorSignalDock
  Labels
  Effects
    MembraneRipple
    TransportParticles
    SignalPulse
```

## Materials, Colors, and Effects

- Use a pale cyan or blue transparent shell for the aqueous-facing leaflet
  surfaces.
- Use a muted amber or pale yellow band for the hydrophobic core cue so learners
  can see why polar molecules struggle to cross.
- Phospholipid heads: small blue or teal spheres/discs.
- Fatty-acid tails: paired thin flexible-looking strands or short rods in
  yellow-orange tones.
- Cholesterol: small flat purple or silver inserts between tails, sparse enough
  that they do not imply cholesterol is the whole membrane.
- Channel proteins: larger green transmembrane pores.
- Carrier proteins: two-state hinged models, perhaps green/blue, with a
  labelled binding pocket.
- Pumps: red or magenta proteins with an ATP icon marker.
- Receptors: exterior-facing proteins with a matching ligand key shape.
- Carbohydrates: branching chains on the outside only, in light pink/white, to
  reinforce membrane asymmetry.
- Add subtle ripple or shimmer effects for fluidity. Avoid a constant heavy
  particle field around the shell.

## Interactions and Hotspots

- **Selective permeability sorter:** spawn oxygen/carbon dioxide, sodium ions,
  water, and glucose tokens. The correct route changes by molecule type.
- **Osmosis slider:** change outside solute concentration and show net water
  particle direction. Include hypotonic, isotonic, and hypertonic states.
- **Ion channel gate:** player toggles a gate open/closed and sees ions move
  only when the channel is open.
- **Carrier cycle:** glucose binds to one side, the carrier changes shape, and
  glucose appears on the other side.
- **ATP pump:** player spends ATP tokens to move ions against the displayed
  gradient.
- **Receptor signalling:** ligand binding triggers an intracellular signal pulse
  without moving the ligand through the membrane.
- **Endocytosis dock:** cargo binds, membrane invaginates visually, and a vesicle
  appears inside.
- **Exocytosis dock:** vesicle approaches from inside, fuses, and releases cargo
  outside.

## Performance Notes

- Use a small number of repeated lipid/protein meshes or parts rather than
  thousands of separate visible phospholipids.
- Make most components non-colliding; use dedicated invisible trigger parts for
  hotspots.
- Keep transparency layers limited. Roblox notes that overlapping transparent
  objects can cause expensive overdraw
  ([Roblox Creator Hub, Improve Performance](https://create.roblox.com/docs/performance-optimization/improve)).
- Prefer `Beam` or mesh-based strands for tails and carbohydrate chains where
  repeated thin parts become expensive
  ([Roblox Creator Hub, Beam](https://create.roblox.com/docs/reference/engine/classes/Beam)).
- Use `ParticleEmitter` sparingly for transport particles; particle count and
  overdraw can affect performance
  ([Roblox Creator Hub, Particle Emitters](https://create.roblox.com/docs/effects/particle-emitters)).
- Animate only nearby hotspots. The full shell can use a subtle shader/material
  change or slow tween rather than many independent moving objects.
- Keep the model pivot centered so later scripts can scale, rotate, or position
  the whole membrane around the cell scene.

## Research Sources

- [OpenStax Biology 2e: 5.1 Components and Structure](https://openstax.org/books/biology-2e/pages/5-1-components-and-structure)
- [OpenStax Biology 2e: 5.2 Passive Transport](https://openstax.org/books/biology-2e/pages/5-2-passive-transport)
- [OpenStax Biology 2e: 5.4 Bulk Transport](https://openstax.org/books/biology-2e/pages/5-4-bulk-transport)
- [OpenStax Concepts of Biology: 3.6 Active Transport](https://openstax.org/books/concepts-biology/pages/3-6-active-transport)
- [NCBI Bookshelf: Molecular Biology of the Cell, The Lipid Bilayer](https://www.ncbi.nlm.nih.gov/books/NBK26871/)
- [Roblox Creator Hub: Improve Performance](https://create.roblox.com/docs/performance-optimization/improve)
- [Roblox Creator Hub: Particle Emitters](https://create.roblox.com/docs/effects/particle-emitters)
- [Roblox Creator Hub: Beam](https://create.roblox.com/docs/reference/engine/classes/Beam)
