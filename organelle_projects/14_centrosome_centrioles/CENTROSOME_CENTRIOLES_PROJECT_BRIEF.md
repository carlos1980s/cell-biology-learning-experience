# 14 Centrosome And Centrioles

Purpose: represent the animal-cell microtubule-organizing center, paired
centrioles, pericentriolar material, spindle organization, and cilium/basal-body
connections.

Recommended Roblox object: one parent `Model` named `CentrosomeCentrioles`
positioned near the nucleus with radial microtubule routes.

First build target: two perpendicular barrel-shaped centrioles surrounded by a
soft pericentriolar material cloud and radial microtubules.

## Biological Overview

The centrosome is a non-membrane-bound organelle that acts as a major
microtubule-organizing center in many animal cells. A typical animal centrosome
contains a pair of centrioles surrounded by pericentriolar material, often
abbreviated PCM. The PCM contains proteins that help nucleate and organize
microtubules, including gamma-tubulin complexes.

Centrioles are cylindrical microtubule-based structures with ninefold symmetry.
In many cells, the older mother centriole can also become a basal body that
templates a cilium or flagellum. Centrosomes are duplicated once per cell cycle
so that two centrosomes can help organize the mitotic spindle during cell
division.

Core sources:

- [OpenStax Biology 2e, The Centrosome](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)
- [PubMed Central, Building the centriole](https://pmc.ncbi.nlm.nih.gov/articles/PMC2956124/)
- [PubMed, The centrosome cycle](https://pubmed.ncbi.nlm.nih.gov/21968988/)
- [PMC review, Choreography of the centrosome](https://pmc.ncbi.nlm.nih.gov/articles/PMC6970175/)

## Detailed Structure

- Centriole pair: two centrioles usually arranged approximately at right angles
  to each other.
- Centriole wall: each centriole is commonly modeled as a cylinder of nine
  microtubule triplets. The A-tubule is complete; B- and C-tubules are partial.
- Cartwheel: early procentrioles form around a ninefold symmetric cartwheel that
  helps establish centriole geometry.
- Mother centriole: older centriole with distal and subdistal appendages in
  vertebrate cells. These appendages help dock a basal body for ciliogenesis and
  anchor microtubules.
- Daughter centriole: newer centriole that matures over more than one cell
  cycle before gaining full appendage features.
- Pericentriolar material: protein-rich matrix around the centrioles containing
  microtubule nucleation and anchoring factors.
- Microtubule array: microtubules extend with minus ends near the centrosome and
  plus ends growing outward into the cytoplasm.

## Chemistry And Composition

- Centrioles are built mainly from alpha- and beta-tubulin assembled into
  microtubules.
- The PCM contains many scaffold and regulatory proteins, including pericentrin,
  CEP-family proteins, and gamma-tubulin ring complexes.
- Gamma-tubulin complexes help nucleate new microtubules.
- Centrin and other centriole-associated proteins contribute to centriole
  structure and duplication control.
- Regulatory kinases such as PLK4 help control centriole duplication; this
  prevents extra centrioles from forming each cycle.
- Centrosomes are not membrane-bound and do not have a lumen, genome, or
  phospholipid boundary.

## Functions

- Organize interphase microtubules in many animal cells.
- Help establish cell polarity by positioning microtubule arrays.
- Contribute to intracellular transport routes because motor proteins move
  cargo along microtubules.
- Duplicate once per cell cycle and separate to help organize the mitotic
  spindle.
- Support chromosome segregation indirectly by forming spindle poles and
  organizing spindle microtubules.
- Provide centrioles that can become basal bodies for cilia and flagella.
- Coordinate local signaling at centrosome, spindle, and cilium-related sites.

## Dynamic Processes

- Centriole duplication: a procentriole forms next to each existing centriole
  around the G1/S transition and elongates during S and G2 phases.
- Centrosome maturation: PCM expands and recruits more microtubule nucleation
  factors before mitosis.
- Centrosome separation: duplicated centrosomes move apart to define spindle
  poles.
- Microtubule nucleation: gamma-tubulin complexes seed new microtubules from the
  PCM.
- Microtubule dynamic instability: microtubules grow and shrink as tubulin
  subunits are added or lost at plus ends.
- Ciliogenesis: in non-dividing or quiescent cells, the mother centriole can
  dock at the plasma membrane and act as a basal body.
- Disassembly or remodeling: centrosome and cilium states change as cells enter
  or exit division.

## Learning Misconceptions

- "Centrioles and centrosomes are the same thing": centrioles are the barrel
  structures; the centrosome includes centrioles plus surrounding PCM.
- "Centrioles pull chromosomes directly": spindle microtubules and motor
  proteins do the mechanical work; centrosomes organize spindle poles.
- "All eukaryotes have centrioles": many plant cells and some fungi lack
  centrioles but still organize microtubules.
- "Centrosomes are membrane-bound organelles": centrosomes are protein-rich,
  non-membrane-bound structures.
- "Microtubules are static beams": microtubules are dynamic polymers that grow,
  shrink, and reorganize.
- "Centrioles are only for mitosis": centrioles also support cilia and flagella
  as basal bodies in many cell types.
- "The centrosome is the centromere": a centrosome organizes microtubules;
  a centromere is a chromosome region where kinetochores form.

## Roblox Design Concept

Build the centrosome as a compact command hub near the nucleus. The center
should show the two perpendicular centrioles as unmistakable nine-triplet
barrels, while the surrounding PCM launches microtubule tracks into the cell.
During the cell-division mode, the hub duplicates and separates into two spindle
poles.

Recommended experience:

- Interphase view: radial microtubule tracks extend from one centrosome near the
  nucleus.
- Structure view: player zooms in to inspect nine microtubule triplets,
  cartwheel geometry, mother/daughter labels, and PCM.
- Mitosis view: duplicated centrosomes move apart and organize spindle fibers.
- Cilium view: the mother centriole docks at the membrane as a basal body and
  grows a cilium.

## Model Hierarchy

```text
CentrosomeCentrioles (Model)
  Centrosome_Interphase (Model)
    MotherCentriole (Model)
      TripletMicrotubules_01_to_09
      DistalAppendages
      SubdistalAppendages
      CartwheelHint
    DaughterCentriole (Model)
      TripletMicrotubules_01_to_09
      CartwheelHint
    PericentriolarMaterial
    GammaTubulinMarkers
    MicrotubuleAsters
    Hotspots
      Hotspot_CentrioleStructure
      Hotspot_PCM
      Hotspot_MicrotubuleNucleation
      Hotspot_CentrosomeDuplication
      Hotspot_BasalBodyCilium
  MitosisMode (Folder)
    Centrosome_Pole_A
    Centrosome_Pole_B
    SpindleMicrotubules
    ChromosomeAttachmentMarkers
```

## Materials, Colors, And Effects

- Centrioles: firm white or light gray microtubule barrels with dark grooves so
  the ninefold triplet pattern is visible.
- Mother centriole appendages: blue or teal fins/rays at one end to distinguish
  maturity.
- Daughter centriole: slightly smaller or less saturated gray to signal its
  younger state.
- PCM: translucent pale gold or soft green cloud, using low-opacity parts rather
  than dense particles.
- Gamma-tubulin markers: small yellow nodes embedded in PCM.
- Microtubules: thin cyan/green rods or Beams extending outward, with brighter
  growing plus-end tips.
- Mitosis spindle: use two centrosome poles with microtubules in distinct
  spindle arcs; keep chromosome models separate from the centrosome brief.

## Interactions And Hotspots

- `Hotspot_CentrioleStructure`: highlights nine triplets and the right-angle
  centriole arrangement.
- `Hotspot_PCM`: fades the centrioles slightly and emphasizes the surrounding
  protein matrix.
- `Hotspot_MicrotubuleNucleation`: grows microtubules from gamma-tubulin marker
  nodes.
- `Hotspot_CentrosomeDuplication`: shows one procentriole forming beside each
  parental centriole.
- `Hotspot_MitosisSpindle`: switches to two centrosomes organizing spindle
  microtubules.
- `Hotspot_BasalBodyCilium`: moves the mother centriole to the membrane and
  grows a cilium from it.
- `Hotspot_CentrosomeVsCentromere`: quick misconception check comparing the cell
  organelle with a chromosome region.

## Performance Notes

- Model only one high-detail centriole pair; use simplified versions for mitotic
  pole duplicates or distant views.
- Use Beams or cylinders for microtubules and cap their number so the cytoplasm
  remains readable.
- Animate microtubule growth by scaling or tweening, not by spawning many tiny
  tubulin parts.
- Keep PCM as a few translucent shapes; avoid heavy particle clouds around the
  nucleus.
- In mitosis mode, disable interphase radial microtubules before showing spindle
  fibers.
- Use labels and hotspot outlines to clarify mother versus daughter centriole
  without adding excessive geometry.

## Sources Used

- [OpenStax Biology 2e: Eukaryotic Cells, The Centrosome](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)
- [PubMed Central: Building the centriole](https://pmc.ncbi.nlm.nih.gov/articles/PMC2956124/)
- [PubMed: The centrosome cycle: Centriole biogenesis, duplication and inherent asymmetries](https://pubmed.ncbi.nlm.nih.gov/21968988/)
- [PMC review: Choreography of the centrosome](https://pmc.ncbi.nlm.nih.gov/articles/PMC6970175/)

