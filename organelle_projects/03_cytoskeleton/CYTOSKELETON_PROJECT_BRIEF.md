# 03 Cytoskeleton

Purpose: add microtubules, actin-like strands, structural support, and spatial
routes through the cell.

Recommended Roblox object: one `Model` named `Cytoskeleton` using beams, thin
parts, attachments, and color-coded strand families.

First build target: non-colliding orientation strands that help players navigate
between membrane, nucleus, ER, and Golgi.

## Biological Overview

The cytoskeleton is a dynamic network of protein filaments extending through the
cytoplasm. It gives cells shape, organizes internal space, links organelles and
the plasma membrane, supports cell movement, and provides tracks for internal
transport. NCBI Bookshelf describes it as a protein-filament network that
determines cell shape and the general organization of the cytoplasm, while also
being responsible for cell movements and internal transport
([The Cell: A Molecular Approach, The Cytoskeleton and Cell Movement](https://www.ncbi.nlm.nih.gov/books/NBK9893/)).

For A-level and first-year learners, the main filament systems are
microfilaments, intermediate filaments, and microtubules. The cytoskeleton is
not a static "bone structure." It is constantly assembled, disassembled, linked,
cut, stabilized, and moved by motor proteins.

## Detailed Structure

- **Microfilaments / actin filaments:** the thinnest major cytoskeletal fibers,
  about 7 nm diameter, made from actin subunits in two intertwined strands
  ([OpenStax Biology 2e 4.5](https://openstax.org/books/biology-2e/pages/4-5-the-cytoskeleton)).
- **Intermediate filaments:** rope-like fibers about 8 to 10 nm diameter,
  assembled from fibrous proteins. Different cell types use different
  intermediate filament proteins, such as keratins in many epithelial cells.
- **Microtubules:** hollow tubes about 25 nm diameter, built from alpha-tubulin
  and beta-tubulin dimers. OpenStax notes that microtubule walls are commonly
  shown as 13 polymerized tubulin dimers around a hollow tube
  ([OpenStax Biology 2e 4.5](https://openstax.org/books/biology-2e/pages/4-5-the-cytoskeleton)).
- **Centrosome / MTOC:** in many animal cells, the centrosome near the nucleus
  acts as a microtubule-organizing center.
- **Cell cortex:** actin-rich region just under the plasma membrane; important
  for cell shape, tension, movement, and endocytosis.
- **Motor proteins:** myosins move on actin; kinesins and dyneins move along
  microtubules, carrying vesicles, organelles, and other cargo.
- **Accessory proteins:** crosslinkers, nucleators, capping proteins, severing
  proteins, and membrane anchors control filament location and behavior.

## Chemistry and Composition

- Actin and tubulin are globular proteins that bind nucleotides. Actin dynamics
  are linked to ATP binding and hydrolysis; tubulin dynamics are linked to GTP
  binding and hydrolysis.
- Microfilaments are polar, meaning the two ends differ in growth behavior and
  motor direction.
- Microtubules are also polar, with plus and minus ends. In many animal cells,
  minus ends are anchored near the centrosome while plus ends extend outward.
- Intermediate filaments are less polar and generally provide high tensile
  strength, helping cells resist stretching.
- Cytoskeletal filaments interact with membranes through adaptor proteins and
  can be connected to cell junctions, the nuclear envelope, and extracellular
  matrix attachments.
- The filaments are proteins, not membranes. They do not have phospholipid
  bilayers and should not be represented as tubes filled with cytoplasm unless
  specifically modelling microtubule hollowness.

## Functions

- **Mechanical support:** maintains cell shape and resists deformation.
- **Organelle positioning:** anchors or positions nucleus, ER, Golgi,
  mitochondria, and other structures.
- **Intracellular transport:** microtubules act as tracks for vesicles and
  organelles; OpenStax states that microtubules provide tracks along which
  vesicles move
  ([OpenStax Biology 2e 4.5](https://openstax.org/books/biology-2e/pages/4-5-the-cytoskeleton)).
- **Cell movement:** actin polymerization and actin-myosin contraction support
  cell crawling, muscle contraction, and changes in cell shape.
- **Cell division:** microtubules form the mitotic spindle that separates
  chromosomes; actin and myosin help form the cleavage furrow in animal cells.
- **Membrane organization:** cortical actin supports the plasma membrane and can
  help localize membrane proteins.
- **Cilia and flagella:** eukaryotic cilia and flagella have microtubule-based
  structures, commonly the 9 + 2 arrangement for motile forms
  ([OpenStax Biology 2e 4.5](https://openstax.org/books/biology-2e/pages/4-5-the-cytoskeleton)).
- **Cytoplasmic movement:** actin contributes to cytoplasmic streaming in plant
  cells and other directed cytoplasmic flows.

## Dynamic Processes to Teach

- **Polymerization and depolymerization:** actin filaments and microtubules can
  grow and shrink rapidly by adding or losing protein subunits.
- **Dynamic instability:** microtubules switch between growth and rapid shrinkage
  depending partly on the GTP state of tubulin subunits.
- **Treadmilling:** actin filaments can add subunits at one end and lose them at
  the other, creating apparent motion without moving the entire filament.
- **Motor-based transport:** kinesin and dynein carry cargo in opposite
  directions on microtubules; myosin carries cargo or generates contraction on
  actin.
- **Cortical remodeling:** actin under the membrane reorganizes during
  endocytosis, cell migration, cytokinesis, and cell shape change.
- **Spindle assembly:** microtubules reorganize dramatically during mitosis to
  capture and separate chromosomes.
- **Filament cross-talk:** actin, microtubules, and intermediate filaments
  interact through shared adaptor proteins and mechanical coupling.

## Learning Misconceptions

- **"The cytoskeleton is rigid and permanent."** It is dynamic and continually
  reorganized, especially during movement and cell division
  ([NCBI Bookshelf](https://www.ncbi.nlm.nih.gov/books/NBK9893/)).
- **"All cytoskeletal fibers do the same job."** Actin, intermediate filaments,
  and microtubules differ in structure, chemistry, diameter, and function.
- **"Microtubules are the same as microfilaments."** Microtubules are hollow
  tubulin tubes; microfilaments are actin strands.
- **"Intermediate filaments are unimportant because they are less involved in
  movement."** They are crucial for tensile strength, organelle anchoring, and
  tissue resilience.
- **"Vesicles float randomly to destinations."** Many vesicles are transported
  directionally by motor proteins along cytoskeletal tracks.
- **"The cytoskeleton exists only in animal cells."** Eukaryotic plant cells
  also have cytoskeletal systems, though their organization differs.

## Roblox Design Concept

Build the cytoskeleton as the cell's color-coded internal route and support
system. It should help the player navigate while teaching that different fiber
families have different jobs. Use prominent microtubule highways radiating from
a centrosome-like hub, a denser actin cortex near the membrane, and a more
rope-like intermediate filament support web around the nucleus and organelles.

The first version should be non-colliding orientation geometry. Later scripts
can attach vesicle movement, spindle animation, actin remodeling, and hotspot
lessons.

## Model Hierarchy

```text
Cytoskeleton
  Microtubules
    CentrosomeHub
    RadialTracks
    VesicleTrafficTracks
    SpindleDemo_Optional
  ActinNetwork
    CellCortex
    MicrovilliSupport_Optional
    CleavageFurrowDemo_Optional
    StreamingLoops_Optional
  IntermediateFilaments
    PerinuclearCage
    OrganelleAnchorWeb
    MembraneLinkers
  Motors
    KinesinCargoMarkers
    DyneinCargoMarkers
    MyosinMarkers
  InteractionHotspots
    TrackTransportDemo
    DynamicInstabilityDemo
    ActinTreadmillingDemo
    SpindleCheckpointDemo
    TensionSupportDemo
  Labels
  Effects
    GrowthTipGlow
    CargoMotionTrails
    CortexPulse
```

## Materials, Colors, and Effects

- Microtubules: bright cyan or blue hollow-looking beams/tubes, thicker than
  actin, radiating from a centrosome hub near the nucleus.
- Actin: magenta or red thin strands concentrated under the membrane, with a few
  branching regions to show cortex remodeling.
- Intermediate filaments: warm yellow or orange rope-like strands around the
  nucleus and across organelle anchor points.
- Centrosome hub: small paired cylinder marker near the nucleus, clearly marked
  as a microtubule-organizing center for animal-cell mode.
- Motor proteins: small moving icons or beads on tracks, color coded by motor:
  kinesin outward, dynein inward, myosin on actin.
- Vesicle cargo: small translucent spheres attached to motor markers.
- Growth tips: short glowing caps on selected microtubule plus ends to show
  polymerization.
- Use `Beam` objects with attachments for long, curved strands where possible.
  Roblox documents beams as effects connecting two attachments
  ([Roblox Creator Hub, Beam](https://create.roblox.com/docs/reference/engine/classes/Beam)).

## Interactions and Hotspots

- **Fiber identification challenge:** player labels actin, intermediate
  filament, and microtubule based on diameter, position, and function.
- **Cargo transport route:** activate a vesicle and watch it move along a
  microtubule from Golgi region toward membrane, then switch to dynein for
  inward movement.
- **Dynamic instability demo:** one microtubule grows, loses its cap, then
  shrinks rapidly; player stabilizes it with a "GTP cap" marker.
- **Actin treadmilling demo:** beads add at one end and leave at the other while
  the filament's position appears to shift.
- **Cortex support hotspot:** push/deform a membrane region and show actin
  cortex resisting and recovering shape.
- **Intermediate filament tension demo:** stretch a region and show rope-like
  filaments distributing tension across anchor points.
- **Cell division optional scene:** microtubules form a spindle, attach to
  chromosome proxies, and pull sister-chromatid models apart.
- **Cilia/flagella optional scene:** show a simplified 9 + 2 cross-section as a
  separate inspectable panel, not as the default cell-wide cytoskeleton.

## Performance Notes

- Use beams or low-poly cylinders for long strands; avoid hundreds of separate
  tiny parts per filament.
- Disable collision for all decorative filaments. Use invisible trigger volumes
  only at hotspots.
- Keep live animations limited to selected demo strands. Most of the network can
  be static orientation geometry.
- Use shared colors/materials for each filament family to reduce visual noise and
  help batching.
- Avoid heavy transparency stacking inside the cytoplasm; overlapping
  transparent visuals can be costly
  ([Roblox Creator Hub, Improve Performance](https://create.roblox.com/docs/performance-optimization/improve)).
- For cargo movement, animate a small set of bead/vesicle proxies rather than
  simulating all intracellular transport.
- Use level-of-detail groups: show fewer strands on low graphics settings or
  when the player is far from the cell interior.
- Keep the centrosome hub and main tracks stable so other organelle models can
  later reference attachment points without relying on constantly changing
  geometry.

## Research Sources

- [OpenStax Biology 2e: 4.5 The Cytoskeleton](https://openstax.org/books/biology-2e/pages/4-5-the-cytoskeleton)
- [OpenStax Anatomy and Physiology: 3.2 The Cytoplasm and Cellular Organelles](https://openstax.org/books/anatomy-and-physiology/pages/3-2-the-cytoplasm-and-cellular-organelles)
- [NCBI Bookshelf: The Cell, The Cytoskeleton and Cell Movement](https://www.ncbi.nlm.nih.gov/books/NBK9893/)
- [HHMI Beautiful Biology: Scroll and Explore](https://www.hhmi.org/beautifulbiology/scroll-and-explore)
- [Roblox Creator Hub: Improve Performance](https://create.roblox.com/docs/performance-optimization/improve)
- [Roblox Creator Hub: Beam](https://create.roblox.com/docs/reference/engine/classes/Beam)
