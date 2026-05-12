# Organelle Subcharts

These charts split the cell structures into smaller review groups before Roblox
implementation. Each node maps to one project brief in `organelle_projects/`.

## Whole-Cell Review Map

```mermaid
flowchart TD
    cell["Human / Animal Eukaryotic Cell"]

    cell --> boundary["Boundary + Interior"]
    cell --> genome["Genome + Information Flow"]
    cell --> secretion["Endomembrane + Trafficking"]
    cell --> metabolism["Energy + Recycling"]
    cell --> structure["Structure + Motility"]
    cell --> surface["Cell Surface + Environment"]

    boundary --> membrane["01 Membrane"]
    boundary --> cytoplasm["02 Cytoplasm"]

    genome --> nucleus["04 Nucleus"]
    genome --> nucleolus["05 Nucleolus + Chromatin"]
    genome --> ribosomes["08 Ribosomes"]

    secretion --> roughER["06 Rough ER"]
    secretion --> smoothER["07 Smooth ER"]
    secretion --> golgi["10 Golgi Apparatus"]
    secretion --> vesicles["12 Vesicles + Vacuoles"]
    secretion --> endosomes["16 Endosomes"]

    metabolism --> mitochondria["09 Mitochondria"]
    metabolism --> lysosomes["11 Lysosomes"]
    metabolism --> peroxisomes["13 Peroxisomes"]
    metabolism --> proteasomes["15 Proteasomes"]

    structure --> cytoskeleton["03 Cytoskeleton"]
    structure --> centrosome["14 Centrosome + Centrioles"]
    structure --> cilia["18 Cilia + Flagella"]

    surface --> ecm["17 Extracellular Matrix"]
    surface --> membrane
```

## Boundary + Interior

```mermaid
flowchart LR
    membrane["01 Membrane<br/>phospholipid bilayer, proteins, receptors"]
    cytoplasm["02 Cytoplasm<br/>cytosol, ions, crowding, suspended structures"]
    cytoskeleton["03 Cytoskeleton<br/>orientation, support, intracellular routes"]

    membrane <--> cytoplasm
    cytoplasm <--> cytoskeleton
    cytoskeleton --> membraneAnchors["membrane anchors / cortex"]
```

Roblox review focus:

- The membrane defines the playable boundary and scale.
- Cytoplasm should make the interior readable without blocking movement.
- Cytoskeleton should create navigation routes and spatial orientation.

## Genome + Information Flow

```mermaid
flowchart TD
    nucleus["04 Nucleus<br/>double envelope, pores, lamina"]
    chromatin["05 Chromatin<br/>DNA packaging, gene accessibility"]
    nucleolus["05 Nucleolus<br/>rRNA production, subunit assembly"]
    ribosomes["08 Ribosomes<br/>translation in cytoplasm / rough ER"]
    mrna["mRNA export"]
    subunits["ribosomal subunit export"]

    nucleus --> chromatin
    nucleus --> nucleolus
    chromatin --> mrna
    mrna --> ribosomes
    nucleolus --> subunits
    subunits --> ribosomes
```

Roblox review focus:

- Keep DNA inside the nucleus.
- Show nuclear pores as selective gates, not open holes.
- Keep the nucleolus non-membrane-bound.
- Use the ribosome model as the handoff point from nuclear information to
  cytoplasmic protein synthesis.

## Endomembrane + Trafficking

```mermaid
flowchart LR
    roughER["06 Rough ER<br/>secretory/membrane protein entry"]
    smoothER["07 Smooth ER<br/>lipids, detox, calcium"]
    golgi["10 Golgi<br/>modify, sort, package"]
    vesicles["12 Vesicles<br/>transport carriers"]
    endosomes["16 Endosomes<br/>sorting and recycling"]
    lysosomes["11 Lysosomes<br/>degradation endpoint"]
    membrane["01 Membrane<br/>secretion/endocytosis surface"]

    roughER --> golgi
    smoothER --> golgi
    golgi --> vesicles
    vesicles --> membrane
    membrane --> endosomes
    endosomes --> membrane
    endosomes --> lysosomes
    golgi --> lysosomes
```

Roblox review focus:

- Protein path: rough ER -> Golgi -> vesicles -> membrane or lysosome.
- Lipid/detox path: smooth ER should look related to ER but visually distinct.
- Endosomes deserve a separate sorting chart even though they overlap with
  vesicles.
- Vesicle animation should use paths and pooling rather than physics clutter.

## Energy + Recycling

```mermaid
flowchart TD
    mitochondria["09 Mitochondria<br/>ATP, cristae, proton gradient"]
    peroxisomes["13 Peroxisomes<br/>fatty-acid oxidation, H2O2 detox"]
    lysosomes["11 Lysosomes<br/>macromolecule digestion"]
    proteasomes["15 Proteasomes<br/>ubiquitin-tagged protein degradation"]
    cytoplasm["02 Cytoplasm<br/>metabolites and recycled products"]

    cytoplasm --> mitochondria
    mitochondria --> atp["ATP supply"]
    cytoplasm --> peroxisomes
    peroxisomes --> detox["detoxified products"]
    cytoplasm --> proteasomes
    proteasomes --> aminoAcids["amino-acid recycling"]
    lysosomes --> monomers["monomer recycling"]
    monomers --> cytoplasm
    aminoAcids --> cytoplasm
```

Roblox review focus:

- Mitochondria should show inner membrane/cristae, not just a bean shape.
- Peroxisomes should be visually distinct from lysosomes.
- Lysosomes digest vesicle/autophagy cargo; proteasomes degrade tagged proteins
  in the cytosol/nucleus.

## Structure + Motility

```mermaid
flowchart TD
    cytoskeleton["03 Cytoskeleton<br/>actin, microtubules, intermediate filaments"]
    centrosome["14 Centrosome + Centrioles<br/>microtubule organizing center"]
    cilia["18 Cilia + Flagella<br/>9+2 or 9+0 microtubule structures"]
    vesicleTraffic["vesicle transport paths"]
    nucleusPosition["nucleus positioning"]

    centrosome --> cytoskeleton
    cytoskeleton --> vesicleTraffic
    cytoskeleton --> nucleusPosition
    cytoskeleton --> cilia
```

Roblox review focus:

- Cytoskeleton should support gameplay navigation and biological transport.
- Centrosome/centrioles can serve as a visual hub for microtubules.
- Cilia/flagella are optional depending on the cell type, but useful for
  showing microtubule-based movement.

## Cell Surface + Environment

```mermaid
flowchart LR
    membrane["01 Membrane<br/>receptors, channels, transport"]
    ecm["17 Extracellular Matrix<br/>collagen, proteoglycans, adhesion"]
    cytoskeleton["03 Cytoskeleton<br/>internal mechanical link"]
    signals["external signals"]
    adhesion["integrin-style adhesion"]

    ecm --> adhesion
    adhesion --> membrane
    membrane --> cytoskeleton
    signals --> membrane
```

Roblox review focus:

- The extracellular matrix belongs outside the cell and should not be confused
  with cytoplasm.
- Membrane receptors should connect outside signals to internal responses.
- Surface design matters if later builds include tissues or multiple cells.

