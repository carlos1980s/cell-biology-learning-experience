# 04 Nucleus

Purpose: represent the nucleus as the command center and DNA storage area.

Recommended Roblox object: one `Model` named `Nucleus` with submodels for nuclear
envelope, pores, internal volume, and interaction markers.

First build target: a movable nucleus shell with readable nuclear pores and a
clear pivot so it can be repositioned inside the cell.

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

Build a large translucent nucleus that reads clearly from outside the cell and
also works as a visitable learning zone. The shell should communicate
"protected but connected": a double envelope, visible pores, a faint lamina
grid, and animated cargo particles crossing only at pore sites.

Suggested experience: the player approaches the nucleus, sees pulses of mRNA
leaving pores and nuclear proteins entering, then activates hotspots for DNA
storage, nuclear envelope, pore selectivity, and gene expression.

## Model hierarchy

```text
Nucleus
  PivotCore
  NuclearEnvelope
    OuterMembrane
    InnerMembrane
    PerinuclearSpaceHint
    NuclearLamina
  NuclearPores
    Pore_001
      RingOuter
      RingInner
      SelectiveGate
      ImportExportPath
    Pore_...
  Nucleoplasm
    InteriorVolume
    AmbientParticles
  CargoAnimation
    ImportProteinParticles
    ExportMRNAParticles
    ExportRibosomalSubunitParticles
  AttachmentPoints
    ChromatinAnchors
    NucleolusAnchor
    RoughERConnectionHints
  Hotspots
    EnvelopeHotspot
    PoreHotspot
    NucleoplasmHotspot
    GeneExpressionHotspot
```

## Materials, colors, and effects

- Outer and inner membranes: translucent blue-violet or cool cyan material with
  low opacity; use slightly different tints so the double membrane is readable.
- Perinuclear space: thin pale glow between the membranes.
- Pores: darker teal or graphite rings with a brighter central gate; keep high
  contrast against the envelope.
- Lamina: subtle inner mesh in desaturated green or pale gold, using low
  transparency so it does not compete with chromatin.
- Nucleoplasm: faint fog or soft particles, not dense enough to hide internal
  features.
- Cargo particles: color-code imported nuclear proteins, exported mRNA, and
  exported ribosomal subunits. Use short trails only near pores.

## Interactions and hotspots

- Nuclear envelope hotspot: toggles a cutaway showing inner membrane, outer
  membrane, and perinuclear space.
- Pore selectivity hotspot: lets the player send small solutes through quickly,
  then requires a "signal tag" for a larger protein or RNA cargo.
- Gene expression hotspot: starts a simplified sequence: chromatin region lights
  up, RNA particle forms, RNA exits through a pore, ribosome hotspot receives
  it.
- Cell-cycle hotspot: optional timed overlay showing envelope disassembly and
  reassembly during mitosis, clearly marked as a process in many eukaryotic
  cells rather than the normal interphase state.
- Rough ER link: highlights the outer nuclear membrane continuity with nearby ER
  sheets without forcing a hard-coded attachment.

## Performance notes

- Use 24 to 40 visible pores, then imply additional pores with texture or small
  decals. Do not build hundreds of detailed pore assemblies.
- Make detailed pore rings reusable components cloned from one template.
- Prefer low-poly rings, torus meshes, or cylinders with bevel-like visual
  treatment over many small parts.
- Animate cargo particles with pooled instances and short paths; avoid spawning
  new parts continuously.
- Keep the nucleus pivot central and expose placement handles so downstream
  builders can reposition it without recalculating chromatin or ER geometry.
- Ensure the envelope remains readable on low graphics settings by relying on
  silhouette, color contrast, and pore placement rather than transparency alone.

## Sources

- [OpenStax Biology 2e: Eukaryotic Cells](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)
- [NCBI Bookshelf: The Transport of Molecules between the Nucleus and the Cytosol](https://www.ncbi.nlm.nih.gov/books/NBK26932/)
- [Khan Academy: Nucleus and Ribosomes](https://www.khanacademy.org/science/biology/structure-of-a-cell/prokaryotic-and-eukaryotic-cells/a/nucleus-and-ribosomes)
