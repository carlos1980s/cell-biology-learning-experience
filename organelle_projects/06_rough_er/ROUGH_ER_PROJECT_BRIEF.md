# 06 Rough ER

Purpose: model folded membrane sheets around the nucleus with ribosomes attached
for protein synthesis lessons.

Recommended Roblox object: one `Model` named `RoughER` with sheet/tube geometry,
ribosome attachment markers, and hotspots about protein folding and transport.

First build target: movable ER sheets that visually connect to, but do not
hard-code against, the nucleus position.

## Biological Overview

The rough endoplasmic reticulum (rough ER or RER) is part of the eukaryotic
endomembrane system. It is continuous with the outer nuclear membrane and with
other ER regions, but it is visually distinctive because ribosomes bind to its
cytosolic surface during synthesis of proteins entering the secretory pathway
([OpenStax Biology 2e](https://openstax.org/books/biology-2e/pages/4-4-the-endomembrane-system-and-proteins),
[NCBI Bookshelf: The Cell](https://www.ncbi.nlm.nih.gov/books/NBK9889/)).

At A-level / first-year university depth, the key point is specificity: the RER
does not synthesize every protein. It handles proteins destined for secretion,
the ER lumen, the Golgi apparatus, lysosomes, the plasma membrane, and other
endomembrane compartments. Cytosolic, nuclear, mitochondrial, chloroplast, and
peroxisomal proteins are usually made on free ribosomes and targeted elsewhere
([NCBI Bookshelf: The Cell](https://www.ncbi.nlm.nih.gov/books/NBK9889/)).

## Detailed Structure

- Continuous membrane network of flattened sacs, called cisternae, with a
  shared internal lumen or cisternal space.
- The ER membrane is a phospholipid bilayer with embedded proteins and is
  continuous with the nuclear envelope, so the RER often appears wrapped around
  the nucleus in cell diagrams.
- Ribosomes sit on the cytosolic face, not inside the lumen. They are attached
  transiently when translating mRNA for proteins with an ER signal sequence.
- RER is commonly sheet-like because flat cisternae give many ribosomes access
  to a broad membrane surface. Smooth ER is more tubular by comparison.
- Transport vesicles bud from ER exit sites and carry correctly folded cargo
  toward the Golgi apparatus.

## Chemistry And Composition

- Membrane: phospholipid bilayer with integral and peripheral membrane proteins.
  The ER also synthesizes many membrane lipids used in the endomembrane system.
- Ribosomes: rRNA-protein complexes. Membrane-bound and free ribosomes are
  structurally the same; their location depends on the protein being translated
  ([NCBI Bookshelf: Molecular Biology of the Cell](https://www.ncbi.nlm.nih.gov/books/NBK26841/)).
- Targeting machinery: signal recognition particle (SRP), SRP receptor, Sec61
  translocon, signal peptidase, and start/stop-transfer sequences for membrane
  proteins.
- Lumen chemistry: an oxidizing environment supports disulfide bond formation.
  Chaperones such as BiP and enzymes such as protein disulfide isomerase help
  proteins fold and assemble ([NCBI Bookshelf: The Cell](https://www.ncbi.nlm.nih.gov/books/NBK9889/)).
- Glycosylation chemistry: many proteins receive an N-linked oligosaccharide in
  the ER before further processing in the Golgi. The initial glycan is assembled
  on a dolichol lipid carrier and transferred to selected asparagine residues.

## Core Functions

- Co-translational import of secreted and many membrane proteins into or across
  the ER membrane.
- Folding and quality control of newly made polypeptides before export.
- Assembly of multisubunit proteins and formation of disulfide bonds.
- Initial N-linked glycosylation and early trimming of carbohydrate groups.
- Synthesis and insertion of membrane proteins and some membrane lipids.
- Packaging of properly folded cargo into transport vesicles for the Golgi.

## Dynamic Processes To Represent

- Signal sequence recognition: a ribosome begins translation in the cytosol, an
  ER signal sequence emerges, SRP targets the ribosome-nascent chain complex to
  the ER, and translation continues through a translocon.
- Ribosome cycling: ribosomes attach and detach; they are not permanent studs.
- Protein quality control: correctly folded cargo exits; misfolded proteins are
  retained for refolding or degradation.
- Vesicle export: cargo leaves in vesicles at ER exit sites and moves toward the
  cis face of the Golgi.
- Topology preservation: protein domains that enter the ER lumen correspond to
  domains later exposed outside the cell after vesicle fusion.

## Learning Misconceptions To Avoid

- "Rough ER makes all proteins." It makes proteins entering the endomembrane
  secretory pathway; free ribosomes make many other proteins.
- "Ribosomes are different on rough ER." Free and bound ribosomes are the same
  type of ribosome; the mRNA/protein signal determines binding.
- "Ribosomes are inside the ER." They are attached to the cytosolic surface.
- "Rough ER and smooth ER are separate organelles." They are regions of one
  continuous ER network with different dominant structures and functions.
- "Proteins go straight from rough ER to the plasma membrane." Most secretory
  pathway cargo is modified and sorted through the Golgi first.

## Roblox Design Concept

Build the RER as layered, folded membrane sheets partly hugging the nucleus, with
small ribosome units dotting only the outside-facing surfaces. Use animated
cargo markers to show nascent polypeptides entering the lumen and export vesicles
leaving toward the Golgi. Keep the structure recognizable at a distance: broad
flattened blue-green sheets, dark ribosome beads, and a few highlighted ER exit
sites.

## Model Hierarchy

```text
RoughER (Model)
  PivotAnchor (Part, transparent, PrimaryPart)
  MembraneSheets (Folder)
    Sheet_01 (MeshPart or Part group)
    Sheet_02
    Sheet_03
  Ribosomes (Folder)
    Ribosome_### (small MeshPart or low-part Model)
  LumenMarkers (Folder)
    FoldingZone_01 (Attachment or small translucent Part)
    GlycosylationZone_01
  ExitSites (Folder)
    ERExitSite_01 (Attachment + ProximityPrompt)
    ERExitSite_02
  VesiclePathMarkers (Folder)
    ToGolgiPath_01 (Beam attachments or Tween target points)
  Hotspots (Folder)
    ProteinImportHotspot (Part + ProximityPrompt)
    FoldingQualityHotspot
    TransportHotspot
```

Use `ProximityPrompt` on hotspot parts or attachments for learner interactions,
consistent with Roblox Creator Hub guidance that prompts can be parented to a
`BasePart`, `Attachment`, or `Model` with a `PrimaryPart`
([Roblox ProximityPrompt](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt)).

## Materials, Colors, And Effects

- Membrane sheets: smooth plastic or custom mesh material, medium teal
  (`#3BA7A0`) with slight transparency only at thin edges.
- Lumen side: lighter cyan inner strip or glow to distinguish inside from
  cytosol-facing surface.
- Ribosomes: dark violet or charcoal beads, repeated at regular but not perfect
  grid spacing.
- Nascent proteins: short yellow or lime chains entering selected translocon
  points.
- Correctly folded cargo: small green spheres or capsules moving to exit sites.
- Misfolded cargo: orange/red curled markers retained near a quality-control
  hotspot.
- Effects: use subtle, low-rate particles only at active exit sites. Roblox
  notes that overlapping particle counts can affect performance
  ([Roblox Particle Emitters](https://create.roblox.com/docs/effects/particle-emitters)).

## Interactions And Hotspots

- Protein import hotspot: explains signal sequence, SRP, ribosome docking, and
  Sec61 translocation. Trigger a short animation of a ribosome attaching and a
  peptide entering the lumen.
- Folding quality hotspot: shows BiP/chaperone assistance, disulfide bond
  formation, and a pass/fail sorting choice.
- Glycosylation hotspot: displays an N-linked sugar tag added before Golgi
  processing.
- ER exit hotspot: launches a transport vesicle toward the Golgi, making clear
  that RER-to-Golgi movement is vesicle mediated rather than direct mixing.
- Misconception checkpoint: ask players to choose whether a cytosolic enzyme
  should be sent to RER or remain on free ribosomes.

## Performance Notes

- Prefer a few reusable low-poly ribosome meshes over hundreds of separate
  multi-part ribosome models.
- Combine static membrane sheet geometry into MeshParts where practical, but
  keep hotspot and exit-site parts separate for interaction.
- Cap visible ribosomes based on camera distance; dense dots can be represented
  by texture/decals on far sheets.
- Disable shadows on tiny ribosomes and invisible prompt anchor parts.
- Avoid constant particle property changes and high overlapping particle counts;
  Roblox flags these as performance-sensitive areas
  ([Roblox Performance Optimization](https://create.roblox.com/docs/performance-optimization/improve)).
- Keep the RER model movable by using a transparent `PivotAnchor`/`PrimaryPart`
  and avoid hard-coded nucleus references. Position it relative to the cell
  layout system when coding begins.

## Sources Used

- [OpenStax Biology 2e: The Endomembrane System and Proteins](https://openstax.org/books/biology-2e/pages/4-4-the-endomembrane-system-and-proteins)
- [NCBI Bookshelf: The Endoplasmic Reticulum - The Cell](https://www.ncbi.nlm.nih.gov/books/NBK9889/)
- [NCBI Bookshelf: The Endoplasmic Reticulum - Molecular Biology of the Cell](https://www.ncbi.nlm.nih.gov/books/NBK26841/)
- [Khan Academy: The Endomembrane System](https://www.khanacademy.org/science/ap-biology/cell-structure-and-function/cell-compartmentalization-and-its-origins/a/the-endomembrane-system)
- [Roblox Creator Hub: ProximityPrompt](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt)
- [Roblox Creator Hub: Particle Emitters](https://create.roblox.com/docs/effects/particle-emitters)
- [Roblox Creator Hub: Improve Performance](https://create.roblox.com/docs/performance-optimization/improve)
