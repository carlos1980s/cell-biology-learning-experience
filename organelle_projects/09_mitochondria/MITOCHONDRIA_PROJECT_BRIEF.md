# 09 Mitochondria

Purpose: build energy-producing organelles with an outer membrane, inner
membrane, cristae, matrix, and ATP-related learning hooks.

Recommended Roblox object: one or more `Model` instances named `Mitochondrion`
under a parent `Mitochondria` model.

First build target: movable bean-shaped organelles with visible cristae and
optional gentle motion.

## Biological Overview

Mitochondria are double-membrane organelles found in most eukaryotic cells. Their
best-known role is aerobic respiration: pyruvate and fatty-acid breakdown feed
reduced electron carriers into the citric acid cycle and electron transport
chain, allowing oxidative phosphorylation to make ATP. At A-level and first-year
university depth, the key idea is structure-function coupling: the inner
membrane is folded into cristae, which increases membrane area for electron
transport chain complexes and ATP synthase.

Mitochondria also have their own circular DNA and bacterial-type ribosomes, but
most mitochondrial proteins are encoded by nuclear genes, translated in the
cytosol, and imported through mitochondrial translocases. This supports
endosymbiotic theory while also showing that modern mitochondria depend heavily
on the nucleus and cytosol.

Core sources:

- [NCBI Bookshelf, The Cell: Mitochondria](https://www.ncbi.nlm.nih.gov/books/NBK9896/)
- [NCBI Bookshelf, The Cell: The Mechanism of Oxidative Phosphorylation](https://www.ncbi.nlm.nih.gov/books/NBK9885/)
- [OpenStax Biology 2e, Eukaryotic Cells](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)
- [OpenStax Biology 2e, Oxidative Phosphorylation](https://openstax.org/books/biology-2e/pages/7-4-oxidative-phosphorylation)

## Detailed Structure

- Outer mitochondrial membrane: smooth enclosing membrane with porins that make
  it relatively permeable to small molecules. It defines the organelle boundary
  and contains import machinery for nuclear-encoded proteins.
- Intermembrane space: narrow compartment between the two membranes. During
  respiration, protons are pumped from the matrix into this space, giving it a
  higher H+ concentration than the matrix.
- Inner mitochondrial membrane: highly selective membrane that contains electron
  transport chain complexes, ATP synthase, transporters for ADP/ATP and
  phosphate, and the folds called cristae.
- Cristae: folds of inner membrane projecting into the matrix. They increase
  membrane area and create local spaces where proton gradients and respiratory
  complexes can be organized.
- Matrix: enzyme-rich internal fluid containing mitochondrial DNA, ribosomes,
  tRNAs, citric acid cycle enzymes, beta-oxidation enzymes, and soluble
  metabolic intermediates.
- Mitochondrial genome: small circular DNA encoding a limited set of respiratory
  chain components plus rRNAs and tRNAs; the majority of mitochondrial proteins
  come from nuclear genes.

## Chemistry And Composition

- Membranes are phospholipid bilayers with embedded proteins. The inner membrane
  is especially protein-rich because it hosts oxidative phosphorylation.
- Cardiolipin is a distinctive four-fatty-acid phospholipid enriched in the
  inner mitochondrial membrane; it helps support membrane curvature and
  respiratory-complex organization.
- Electron carriers include NADH and FADH2, which donate high-energy electrons,
  and mobile carriers such as coenzyme Q and cytochrome c.
- ATP synthase uses ADP and inorganic phosphate (Pi) to synthesize ATP as H+
  flows back into the matrix.
- Oxygen is the final electron acceptor in aerobic respiration, producing water
  at complex IV.
- The matrix has a different chemical environment from the cytosol: during
  active respiration it is relatively alkaline compared with the intermembrane
  space because protons have been pumped outward.

## Functions

- ATP production by oxidative phosphorylation.
- Citric acid cycle reactions in the matrix, generating NADH and FADH2.
- Fatty-acid beta-oxidation in many cell types.
- Control of metabolic balance by exporting ATP and importing ADP, Pi, pyruvate,
  and other metabolites.
- Calcium buffering and signaling in many eukaryotic cells.
- Programmed cell death signaling, including release of cytochrome c in
  apoptosis.
- Heat generation in specialized tissues when proton gradients are uncoupled
  from ATP synthesis.

## Dynamic Processes

- Electron transport: electrons move through inner-membrane complexes. Complexes
  I, III, and IV are associated with proton movement from the matrix to the
  intermembrane space.
- Chemiosmosis: the proton gradient and membrane potential form a proton-motive
  force. H+ returns to the matrix through ATP synthase, driving ATP production.
- Protein import: most mitochondrial proteins are imported after translation in
  the cytosol. Targeting sequences and TOM/TIM translocase systems direct them
  to the correct subcompartment.
- Fusion and fission: mitochondria are dynamic, not static beans. They can join
  and divide, changing shape and distribution with energy demand and cell state.
- Cristae remodeling: cristae shape and density can change with metabolic state,
  affecting respiratory capacity.
- Mitophagy: damaged mitochondria can be selectively enclosed and delivered to
  lysosomes for degradation.

## Learning Misconceptions

- "Mitochondria make energy": they convert energy from nutrients into ATP; they
  do not create energy from nothing.
- "All ATP is made in mitochondria": glycolysis also makes ATP in the cytosol,
  and some cells rely more heavily on glycolysis.
- "The outer membrane does respiration": the electron transport chain and ATP
  synthase are in the inner membrane, especially the cristae.
- "Cristae are separate compartments": cristae are folds of the inner membrane,
  not independent organelles.
- "Mitochondrial DNA means independence": mitochondria retain DNA but depend on
  many nuclear-encoded proteins.
- "More mitochondria always means more ATP": activity depends on oxygen,
  substrate supply, ADP availability, membrane integrity, and regulation.

## Roblox Design Concept

Create a cluster of 3 to 7 bean-shaped mitochondria floating near high-energy
areas of the cell. Each mitochondrion should look like a translucent outer shell
with a visible folded inner membrane. The learning goal is for players to read
the organelle spatially: outside membrane, inner cristae, matrix, proton
gradient, ATP synthase, and export of ATP.

Recommended experience:

- Exterior view: players see a smooth oval/bean boundary and glowing inner folds.
- Cutaway view: one mitochondrion has a partial opening so cristae and matrix
  are visible without needing camera clipping.
- Process view: animated H+ particles accumulate in the intermembrane space,
  then flow through ATP synthase hotspots to release ATP tokens into cytoplasm.

## Model Hierarchy

```text
Mitochondria (Model)
  Mitochondrion_01 (Model)
    OuterMembrane (MeshPart or scaled Part group)
    IntermembraneSpaceGlow (ParticleEmitter/Beam container)
    InnerMembrane (Model)
      Crista_01 (MeshPart)
      Crista_02 (MeshPart)
      Crista_03 (MeshPart)
      ATP_SYNTHASE_01 (Attachment + small cylinder/sphere parts)
      ETC_COMPLEX_MARKERS (Folder)
    Matrix (Part or MeshPart, translucent fill)
    MatrixDNA (Curve/Beam or small loop mesh)
    MatrixRibosomes (Folder of small spheres)
    Hotspots (Folder)
      Hotspot_Cristae
      Hotspot_ProtonGradient
      Hotspot_ATPSynthase
      Hotspot_MitochondrialDNA
  Mitochondrion_02 (Model)
  Mitochondrion_03 (Model)
```

## Materials, Colors, And Effects

- Outer membrane: semi-transparent warm coral or amber shell, `SmoothPlastic` or
  low-reflectance `Glass`; keep transparency moderate so internal folds remain
  readable.
- Inner membrane/cristae: brighter orange-gold folded ribbons with subtle
  emission or point lights at ATP synthase sites.
- Matrix: muted peach or soft yellow translucent volume.
- H+ particles: small magenta or electric-blue particles constrained near the
  intermembrane space; avoid too many particles.
- ATP tokens: small yellow glowing spheres or hexagonal coins emitted from ATP
  synthase and drifting into cytoplasm.
- Mitochondrial DNA: thin teal loop in the matrix, visually distinct from
  nuclear DNA.
- Motion: slow bobbing and gentle rotation; cristae can pulse subtly during
  "high respiration" states.

## Interactions And Hotspots

- `Hotspot_Cristae`: explains that cristae increase inner-membrane surface area
  for oxidative phosphorylation.
- `Hotspot_ProtonGradient`: toggles H+ particle accumulation in the
  intermembrane space and shows the matrix/intermembrane difference.
- `Hotspot_ATPSynthase`: starts a short sequence where protons pass through the
  enzyme and ATP tokens appear on the matrix side before export.
- `Hotspot_MitochondrialDNA`: highlights circular DNA and explains that only a
  small fraction of mitochondrial proteins are encoded there.
- `Hotspot_ADP_ATP_Exchange`: optional advanced hotspot showing ADP entering and
  ATP leaving through inner-membrane transporters.
- `Hotspot_Mitophagy`: optional link to lysosome content, showing a damaged
  mitochondrion tagged for recycling.

## Performance Notes

- Use a small number of mitochondria with shared meshes where possible; vary
  scale and rotation instead of creating unique high-poly shapes.
- Build cristae from a limited set of reusable ribbon meshes or curved segments.
- Keep particle counts low and use distance-based enabling for H+ and ATP
  effects.
- Prefer one cutaway mitochondrion with rich internal detail; background
  mitochondria can be simpler shells.
- Use anchored parts unless gameplay requires physical motion. Animate with
  TweenService or lightweight scripted transforms rather than physics
  simulation.
- Keep hotspot hitboxes simple invisible parts so players can select biological
  features without needing to click thin cristae geometry.

## Sources Used

- [NCBI Bookshelf: Mitochondria](https://www.ncbi.nlm.nih.gov/books/NBK9896/)
- [NCBI Bookshelf: The Mechanism of Oxidative Phosphorylation](https://www.ncbi.nlm.nih.gov/books/NBK9885/)
- [OpenStax Biology 2e: Eukaryotic Cells](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)
- [OpenStax Biology 2e: Oxidative Phosphorylation](https://openstax.org/books/biology-2e/pages/7-4-oxidative-phosphorylation)
