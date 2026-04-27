# 02 Cytoplasm

Purpose: create the navigable intracellular medium that gives the cell volume,
depth cues, suspended particles, and learner movement context.

Recommended Roblox object: one `Model` named `Cytoplasm` containing translucent
volumetric parts, particles, ambient lighting helpers, and optional slow-flow
motion effects.

First build target: a low-cost interior atmosphere that does not block movement
but makes scale and location readable.

## Biological Overview

In a eukaryotic cell, the cytoplasm is the material between the plasma membrane
and the nuclear envelope. It includes the cytosol, organelles, cytoskeleton, and
dissolved or suspended chemicals. OpenStax describes cytoplasm as organelles
suspended in gel-like cytosol, with cytoskeleton and various chemicals, and
states that it is about 70 to 80 percent water while still having a semi-solid
consistency because of its proteins
([OpenStax Concepts of Biology 3.3](https://openstax.org/books/concepts-biology/pages/3-3-eukaryotic-cells)).

The cytoplasm is not empty "cell fluid." It is a crowded, organized, reactive
environment where many metabolic reactions occur, ribosomes translate proteins,
vesicles and organelles move, and chemical gradients can be maintained locally.
For the Roblox cell, cytoplasm should act as the readable interior medium rather
than as a separate membrane-bound organelle.

## Detailed Structure

- **Cytosol:** the aqueous, gel-like fluid phase containing water, ions,
  metabolites, soluble proteins, RNA, enzymes, and small complexes.
- **Organelles:** membrane-bound structures such as mitochondria, ER, Golgi,
  lysosomes, peroxisomes, vesicles, and vacuoles are suspended within the
  cytoplasm but are not themselves part of the cytosol.
- **Cytoskeleton:** a network of microfilaments, intermediate filaments, and
  microtubules that gives the cytoplasm spatial organization and mechanical
  support
  ([OpenStax Biology 2e 4.5](https://openstax.org/books/biology-2e/pages/4-5-the-cytoskeleton)).
- **Inclusions and particles:** glycogen granules, lipid droplets, ribosomes,
  proteasomes, transport vesicles, and other non-membrane or membrane structures
  may occupy the cytoplasm depending on cell type.
- **Local microenvironments:** the cytoplasm can have localized ion
  concentrations, pH differences near organelles, and clustered enzymes, so it is
  not perfectly uniform at every point.
- **Boundary relationships:** the cytoplasm contacts the inner leaflet of the
  plasma membrane and surrounds the nuclear envelope, ER, Golgi, mitochondria,
  and other organelles.

## Chemistry and Composition

- Water is the major component, but cytoplasm is crowded with macromolecules and
  cannot be treated as pure water.
- Dissolved ions include potassium, sodium, calcium, chloride, phosphate,
  magnesium, and hydrogen ions. These contribute to osmotic balance, enzyme
  function, electrical gradients, and signalling.
- Organic molecules include glucose and other sugars, amino acids, nucleotides,
  fatty-acid derivatives, glycerol derivatives, RNA, and many soluble proteins
  ([OpenStax Concepts of Biology 3.3](https://openstax.org/books/concepts-biology/pages/3-3-eukaryotic-cells)).
- Enzymes in the cytosol support metabolic pathways such as glycolysis and
  parts of nucleotide, amino-acid, lipid, and carbohydrate metabolism. Some
  pathways also require organelles, so avoid implying that all metabolism is
  cytosolic.
- Macromolecular crowding changes diffusion, enzyme encounters, and protein
  interactions. A PubMed-indexed systematic review describes molecular crowding
  as a high-concentration macromolecular environment that affects protein
  folding, enzyme activity, cytoskeleton organization, and metabolic regulation
  ([Macromolecular Crowding in Cytoplasm and Cellular Organelles](https://pubmed.ncbi.nlm.nih.gov/41004002/)).
- Many lysosomal enzymes are separated from the cytoplasm because they work best
  at low pH; OpenStax notes that many cytoplasmic reactions could not occur at
  the acidic pH used inside lysosomes
  ([OpenStax Concepts of Biology 3.3](https://openstax.org/books/concepts-biology/pages/3-3-eukaryotic-cells)).

## Functions

- **Reaction medium:** provides an aqueous but crowded environment for enzymes
  and metabolites.
- **Spatial support:** gives organelles a medium to be suspended in and a
  scaffold context through the cytoskeleton.
- **Transport space:** allows diffusion of small molecules and directed
  transport of vesicles and organelles along cytoskeletal tracks.
- **Protein synthesis context:** free ribosomes translate cytosolic proteins in
  the cytoplasm, while ER-bound ribosomes make many secreted and membrane
  proteins.
- **Cell shape and volume:** contributes to internal pressure and volume; in
  plant cells, cytoplasmic contents and the central vacuole contribute to turgor
  against the cell wall.
- **Signal integration:** local changes in calcium, phosphorylation, second
  messengers, and protein localization help coordinate responses.
- **Organelle coordination:** cytoplasm is the shared environment through which
  mitochondria, ER, Golgi, vesicles, and the membrane exchange materials and
  signals.

## Dynamic Processes to Teach

- **Diffusion:** small molecules move through cytosol down concentration
  gradients, but diffusion in cytoplasm is affected by crowding and barriers.
  OpenStax explicitly notes that materials move within cytosol by diffusion
  ([OpenStax Biology 2e 5.2](https://openstax.org/books/biology-2e/pages/5-2-passive-transport)).
- **Cytoplasmic streaming:** in many plant cells, actin-dependent flow moves
  cytoplasm and helps distribute materials. OpenStax identifies cytoplasmic
  streaming as circular movement of the cytoplasm in plant cells
  ([OpenStax Biology 2e 4.5](https://openstax.org/books/biology-2e/pages/4-5-the-cytoskeleton)).
- **Vesicle traffic:** vesicles bud, travel through cytoplasm, and fuse with
  target membranes in the endomembrane system.
- **Organelle positioning:** microtubules and actin help move and position
  organelles; this is not random floating.
- **Osmotic response:** water movement across the plasma membrane changes cell
  volume and cytoplasmic concentration.
- **Local signalling pulses:** calcium or other second messengers can rise in
  localized regions rather than everywhere at once.
- **Phase separation and condensates:** some cytoplasmic components can form
  membraneless bodies such as stress granules or P-bodies; for this project, use
  only as an advanced optional note, not a required A-level concept.

## Learning Misconceptions

- **"Cytoplasm and cytosol are the same."** Cytosol is the fluid phase;
  cytoplasm includes cytosol plus organelles, cytoskeleton, and inclusions
  outside the nucleus.
- **"Cytoplasm is just water."** It is mostly water but crowded with proteins,
  ions, metabolites, ribosomes, vesicles, and filaments.
- **"Organelles float randomly."** Many organelles are positioned or moved by
  cytoskeletal tracks and motor proteins.
- **"All reactions happen in organelles."** Many reactions occur in cytosol, but
  organelles compartmentalize reactions that need different conditions.
- **"The cytoplasm is uniform everywhere."** Local gradients and subcellular
  organization matter, especially for signalling and transport.
- **"Cytoplasm is an organelle."** It is a cellular compartment/region, not a
  membrane-bound organelle.

## Roblox Design Concept

Build the cytoplasm as the ambient navigable interior of the cell. It should
make scale and depth legible without behaving like water that blocks movement.
The player should feel inside a crowded biochemical workspace: slow drifting
particles, faint suspended ribosome dots, vesicles moving along routes, and
localized signal pulses should create an organized medium.

The cytoplasm model should not own the logic of other organelles. It should
provide shared visual context, movement volume, and optional environmental
signals that later organelle models can reference.

## Model Hierarchy

```text
Cytoplasm
  Volume
    InteriorHaze
    DepthCueShells
    BoundaryGradient
  SuspendedParticles
    SmallMetabolites
    Ions
    FreeRibosomeDots
    VesicleProxies
    InclusionGranules
  FlowFields
    SlowCytosolDrift
    PlantStreamingLoop_Optional
    LocalSignalPulseZones
  Navigation
    NonCollidingSwimVolume
    ScaleMarkers
    OrganelleClearanceZones
  InteractionHotspots
    DiffusionDemo
    CrowdingDemo
    RibosomeTranslationZone
    VesicleTrafficRoute
    CalciumSignalPulse
    OsmosisConcentrationMeter
  Labels
  Effects
    AmbientParticles
    SoftLightScatter
    LocalPulseRings
```

## Materials, Colors, and Effects

- Use very light teal/blue-green transparent volumes for cytosol, with low
  opacity so other organelles remain readable.
- Add faint depth cue shells or fog-like layers, but keep them sparse to avoid
  hiding the cell interior.
- Small metabolites: tiny white or pale yellow dots moving slowly.
- Ions: slightly brighter colored particles, for example potassium purple,
  sodium blue, calcium orange. Use labels only at hotspots.
- Free ribosomes: small darker dots or bead clusters, more visible near protein
  synthesis zones.
- Vesicle proxies: larger translucent spheres that can travel on named routes
  toward ER/Golgi/membrane areas.
- Crowding cue: local regions with higher density particles and slower movement,
  not a solid wall.
- Signal pulses: short-lived rings or light flashes, especially for calcium
  waves.
- Avoid thick opaque liquid surfaces; cytoplasm should read as an intracellular
  medium, not a swimming pool.

## Interactions and Hotspots

- **Cytosol vs cytoplasm sorter:** player classifies items as cytosol,
  organelle, cytoskeleton, or inclusion.
- **Diffusion demo:** release a small molecule cloud and show it spreading from
  high to low concentration.
- **Crowding demo:** compare particle speed in dilute and crowded zones to show
  why cytoplasm is not pure water.
- **Free ribosome zone:** amino-acid tokens enter a ribosome cluster and produce
  a simple cytosolic protein token.
- **Vesicle route:** vesicle proxies move through cytoplasm between ER, Golgi,
  and membrane docking markers.
- **Calcium pulse:** trigger a local pulse that expands and fades, showing
  signalling without moving every molecule in the whole cell.
- **Osmosis concentration meter:** changing external tonicity changes cytoplasm
  particle density or volume cue.
- **Plant streaming optional mode:** circular flow path moves cytoplasmic
  particles around a large vacuole-like obstacle.

## Performance Notes

- Use bounded particle systems rather than thousands of individual moving parts.
  Roblox particle emitters can emit from attachments or parts, but particle
  count and overlapping transparency affect performance
  ([Roblox Creator Hub, Particle Emitters](https://create.roblox.com/docs/effects/particle-emitters)).
- Keep ambient haze low opacity and avoid stacking many large transparent
  volumes; transparent overdraw is a known performance cost
  ([Roblox Creator Hub, Improve Performance](https://create.roblox.com/docs/performance-optimization/improve)).
- Represent metabolite variety with color, scale, and motion parameters rather
  than unique meshes for every molecule.
- Use local emitters near the player or near active hotspots instead of filling
  the entire cell with live particles.
- Keep collision disabled for haze, particles, and decorative inclusions.
- Use simple looping tweens or path-following only for a limited number of
  vesicle proxies; background particles can be visual-only.
- Provide clear organelle clearance zones so cytoplasm effects do not overlap
  or visually obscure nucleus, ER, Golgi, mitochondria, or membrane lessons.

## Research Sources

- [OpenStax Concepts of Biology: 3.3 Eukaryotic Cells](https://openstax.org/books/concepts-biology/pages/3-3-eukaryotic-cells)
- [OpenStax Anatomy and Physiology: 3.2 The Cytoplasm and Cellular Organelles](https://openstax.org/books/anatomy-and-physiology/pages/3-2-the-cytoplasm-and-cellular-organelles)
- [OpenStax Biology 2e: 4.5 The Cytoskeleton](https://openstax.org/books/biology-2e/pages/4-5-the-cytoskeleton)
- [OpenStax Biology 2e: 5.2 Passive Transport](https://openstax.org/books/biology-2e/pages/5-2-passive-transport)
- [PubMed: Macromolecular Crowding in Cytoplasm and Cellular Organelles](https://pubmed.ncbi.nlm.nih.gov/41004002/)
- [Roblox Creator Hub: Improve Performance](https://create.roblox.com/docs/performance-optimization/improve)
- [Roblox Creator Hub: Particle Emitters](https://create.roblox.com/docs/effects/particle-emitters)
