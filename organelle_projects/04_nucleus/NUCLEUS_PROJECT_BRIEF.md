# 04 Nucleus

Purpose: represent the nucleus as the command center and DNA storage area.

Recommended Roblox object: one `Model` named `Nucleus` with submodels for nuclear
envelope, pores, internal volume, and interaction markers.

First build target: a movable, walkable nucleus chamber with solid irregular
walls, readable nuclear pore gates, four educational levels, and a clear pivot
so it can be repositioned inside the cell.

## Biological overview

The nucleus is the membrane-bounded genetic compartment of a eukaryotic cell. It
contains most of the cell's DNA as chromatin, provides the site for DNA
replication and transcription, and separates genome management from cytoplasmic
translation. OpenStax describes the nucleus as housing DNA and directing
ribosome and protein synthesis through gene expression and nucleolar activity
([OpenStax Biology 2e, 4.3](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)).

For A-level and first-year university teaching, model the nucleus as an active
regulated compartment rather than a static "brain." Its key learning point is
selective access: DNA remains inside, while RNA, ribosomal subunits, proteins,
and small solutes move through nuclear pore complexes.

## Detailed structure

- Nuclear envelope: two phospholipid bilayers, an inner nuclear membrane and an
  outer nuclear membrane. The outer membrane is continuous with the endoplasmic
  reticulum, so it can be shown as visually related to rough ER.
- Perinuclear space: a narrow lumen between the inner and outer membranes,
  continuous with the ER lumen.
- Nuclear pore complexes: large protein assemblies that perforate both membranes
  and regulate exchange between nucleoplasm and cytoplasm. Small water-soluble
  molecules can diffuse more freely; larger proteins and RNAs need selective
  import or export pathways ([NCBI Bookshelf, nuclear transport](https://www.ncbi.nlm.nih.gov/books/NBK26932/)).
- Nuclear lamina: a supportive protein meshwork lining the inner nuclear
  membrane. It helps maintain nuclear shape and provides attachment sites for
  chromatin.
- Nucleoplasm: the semi-fluid internal phase containing chromatin, nucleolus,
  enzymes, nucleotides, transcription factors, and RNA-processing machinery.
- Chromatin and nucleolus: visible internal features should be built by the
  `NucleolusAndChromatin` model, but the nucleus shell must provide anchors and
  viewports for them.

## Chemistry and composition

- Membranes: phospholipid bilayers with embedded membrane proteins. Cholesterol
  may be represented implicitly as part of membrane stability in animal cells.
- Nuclear pore complexes: nucleoporins, including proteins that form scaffold
  rings and selective transport regions.
- Lamina: intermediate-filament proteins called lamins.
- Nucleoplasm: water, ions, nucleotides, ATP/GTP, soluble proteins, RNA, and
  chromatin-associated factors.
- Genetic material: DNA packaged with histones and non-histone proteins; this is
  mostly visualized in the chromatin brief.

## Functions

- Store and protect the nuclear genome.
- Provide the site of DNA replication during S phase.
- Provide the site of transcription, where DNA sequence information is copied
  into RNA.
- Support RNA processing before export, including capping, splicing, and
  polyadenylation for many mRNAs.
- Regulate nucleocytoplasmic traffic through nuclear pores. Nuclear proteins are
  imported from the cytoplasm, while mRNA, tRNA, some snRNA, and ribosomal
  subunits are exported.
- Organize gene expression by positioning chromatin, regulatory proteins, and
  nuclear bodies in the nucleoplasm.

## Dynamic processes to represent

- Import: proteins made in the cytoplasm enter through pores when they carry
  nuclear localization signals. The NCBI Bookshelf nuclear transport chapter
  notes that proteins can enter through pores while folded, unlike many proteins
  imported into other organelles ([NCBI Bookshelf](https://www.ncbi.nlm.nih.gov/books/NBK26932/)).
- Export: processed RNAs and ribosomal subunits exit through pores using export
  signals and transport receptors.
- Gene expression flow: DNA is transcribed to RNA in the nucleus; mRNA leaves
  for ribosomes in the cytoplasm.
- Cell-cycle change: in many animal cells, the nuclear envelope breaks down
  during mitosis and reassembles afterward. For this first model, show this as a
  hotspot or optional animation rather than core geometry.
- Mechanical support: the lamina and chromatin attachments help maintain nuclear
  shape and genome organization.

## Learning misconceptions to address

- "The nucleus controls everything directly." Better: it stores genetic
  information and regulates expression, but cytoplasmic systems, signaling, and
  organelles also make autonomous contributions.
- "DNA leaves the nucleus to make proteins." Better: DNA stays in the nucleus;
  RNA copies carry information to ribosomes.
- "Nuclear pores are open holes." Better: they are selective protein complexes,
  not simple gaps.
- "The nuclear membrane is one membrane." Better: the nuclear envelope has two
  membranes with a perinuclear space.
- "The nucleolus is a separate membrane-bound organelle." Better: it is a dense,
  non-membrane nuclear region associated with ribosome biogenesis.

## Roblox design concept

Build the nucleus as a functional organic building rather than a realistic
transparent blob. The priority is gameplay readability: players should be able
to walk around and through a protected genome chamber with solid walls, obvious
gateways, interior floors, and strong color-coded learning zones.

This is an educational scale model, not literal microscopic scale. The
relationships should remain biologically accurate, but the spatial design is
expanded into a 3-4 storey explorable structure so students can understand the
nucleus as a protected information compartment.

The preferred art path is mesh-first: use authored or generated OBJ meshes for
the organic shell, pore ring, and nucleolus core, then keep simple Roblox parts
for floors, ramps, collision, hotspots, and transport effects. If mesh asset IDs
are not available yet, the builder falls back to a procedural blockout.

Suggested experience: the player approaches a warm orange-red irregular wall,
enters through one enlarged nuclear pore gate, walks through chromatin galleries
and a nucleolus production core, then reaches a transport overlook where mRNA
and ribosomal subunit paths visibly exit through pore gates.

## Model hierarchy

```text
Nucleus
  PivotCore
  NavigationCollision
    Floors
    Ramps
    InvisibleWallGuides
  OrganicEnvelope
    MeshVisuals
      OrganicShellMesh
      OrganicSurfaceAccents
    LaminaBands
  PoreGates
    WalkablePoreGate
      GateRingMesh
      GateRing
      GateTunnel
      SelectiveGate
    VisualPores
  InteriorLevels
    Level1_EnvelopeEntry
    Level2_ChromatinGallery
    Level3_NucleolusCore
    Level4_TransportOverlook
  GenomeRoutes
    ChromatinCables
    GeneActivationMarkers
  NucleolusCore
    RibosomeBiogenesisHubMesh
    PreRRNAParticles
    SubunitAssemblyMarkers
  TransportPaths
    MRNAExportPath
    RibosomalSubunitExportPath
  Hotspots
    EnvelopeHotspot
    PoreGateHotspot
    ChromatinGalleryHotspot
    NucleolusCoreHotspot
    TransportOverlookHotspot
```

## Materials, colors, and effects

- Outer wall: solid warm orange/red SmoothPlastic or Slate-like material, with
  darker red-purple patches and irregular lobes to avoid a perfect sphere. Use
  `nucleus_organic_shell_v1.obj` once imported into Roblox.
- Inner wall and lamina: darker magenta/violet bands that read as structural
  support, like a biological wall lining rather than a transparent membrane.
- Pores: dark graphite or deep violet ringed gates with bright yellow/cyan cargo
  paths. One pore is enlarged as a walkable entrance; the rest are visual
  selective gates.
- Interior floors: muted amber, red-brown, or purple platforms. They are
  functional navigation surfaces first and biological metaphor second.
- Chromatin galleries: thick blue/purple cable routes attached to walls and
  platforms, grouped as genome districts rather than random spaghetti.
- Nucleolus core: dense irregular purple/blue central tower or production hub.
  Use `nucleolus_core_v1.obj` once imported into Roblox.
- Cargo particles: color-code imported nuclear proteins, exported mRNA, and
  exported ribosomal subunits. Use short trails only near pores.

## Interactions and hotspots

- Nuclear envelope hotspot: explains the wall metaphor and clarifies that the
  real envelope is a double membrane, even though the game shows it as a
  walkable protective chamber.
- Pore gate hotspot: lets the player compare small solute movement with larger
  signal-tagged protein/RNA transport through selective gates.
- Chromatin gallery hotspot: lights one cable route to show DNA packaging and
  regulated access to genes.
- Nucleolus core hotspot: shows rRNA production and early ribosomal subunit
  assembly inside a dense non-membrane nuclear region.
- Transport overlook hotspot: starts a simplified sequence: chromatin region
  lights up, RNA particle forms, RNA exits through a pore, and a ribosome
  hotspot receives it.
- Cell-cycle hotspot: optional timed overlay showing envelope disassembly and
  reassembly during mitosis, clearly marked as a process in many eukaryotic
  cells rather than the normal interphase state.
- Rough ER link: highlights the outer nuclear membrane continuity with nearby ER
  sheets without forcing a hard-coded attachment.

## Performance notes

- Use one enlarged walkable pore and 18 to 30 smaller visible pores. Do not
  build hundreds of detailed pore assemblies.
- Make detailed pore rings reusable components cloned from one template.
- Prefer low-poly rings, cylinders, and sphere clusters with bevel-like visual
  treatment over many small parts.
- Keep visual wall geometry separate from simple invisible collision floors,
  ramps, and guide walls. The player should walk smoothly even if the organic
  wall silhouette is irregular.
- Store imported mesh IDs in `src/CellExperience/Data/NucleusMeshAssets.lua`.
  Blank IDs intentionally keep the part-based fallback active.
- Animate cargo particles with pooled instances and short paths; avoid spawning
  new parts continuously.
- Keep the nucleus pivot central and expose placement handles so downstream
  builders can reposition it without recalculating chromatin or ER geometry.
- Ensure the envelope remains readable on low graphics settings by relying on
  silhouette, solid color contrast, pore placement, and architectural levels
  rather than transparency.

## Sources

- [OpenStax Biology 2e: Eukaryotic Cells](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)
- [NCBI Bookshelf: The Transport of Molecules between the Nucleus and the Cytosol](https://www.ncbi.nlm.nih.gov/books/NBK26932/)
- [Khan Academy: Nucleus and Ribosomes](https://www.khanacademy.org/science/biology/structure-of-a-cell/prokaryotic-and-eukaryotic-cells/a/nucleus-and-ribosomes)
