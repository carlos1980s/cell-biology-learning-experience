# 16 Endosomes

Purpose: represent the cell's endocytic sorting system: early endosomes,
recycling endosomes, late endosomes, and multivesicular bodies.

Recommended Roblox object: one parent `Model` named `Endosomes` containing a
small network of sorting compartments, recycling tubules, cargo tokens, and
traffic routes from the plasma membrane toward lysosomes and Golgi.

First build target: inspectable sorting endosomes that receive internalized
cargo and route it to recycling, degradation, or transcytosis paths.

## Biological Overview

Endosomes are membrane-bound sorting compartments in the endocytic pathway.
Material internalized from the plasma membrane by endocytosis first arrives in
early endosomes. From there, cargo can be recycled back to the plasma membrane,
sent to a different membrane domain, routed toward the Golgi, or passed to late
endosomes and lysosomes for degradation.

Endosomes are not one fixed organelle shape. They form a dynamic system of
interconnected vesicles, vacuolar regions, and tubules. Early endosomes act as
major sorting stations; recycling endosomes store and return selected membrane
proteins; late endosomes are more acidic and receive lysosomal hydrolases before
maturing into lysosomal compartments.

Core sources:

- [NCBI Bookshelf, Endocytosis](https://www.ncbi.nlm.nih.gov/books/NBK9831/)
- [NCBI Bookshelf, Transport into the Cell from the Plasma Membrane: Endocytosis](https://www.ncbi.nlm.nih.gov/books/NBK26870/)
- [NCBI Bookshelf, Transport from the Trans Golgi Network to Lysosomes](https://www.ncbi.nlm.nih.gov/books/NBK26844/)
- [Khan Academy, Bulk Transport](https://www.khanacademy.org/science/shs-biology-1/xca2b82fdfba136b8%3Aunit-1-name/xca2b82fdfba136b8%3Acellular-transport/a/bulk-transport)

## Detailed Structure

- Early endosome: peripheral, mildly acidic sorting compartment with a vacuolar
  body and narrow tubular extensions. The tubules are important for recycling
  membrane proteins back to the cell surface.
- Recycling endosome: intermediate compartment, often represented near the cell
  center or a target membrane domain, that returns receptors, transporters, and
  other membrane proteins to the plasma membrane when needed.
- Late endosome: more acidic compartment located closer to the cell center. It
  receives cargo from early endosomes and hydrolase-bearing traffic from the
  Golgi before progressing toward lysosomes.
- Multivesicular body: late endosomal stage containing internal vesicles formed
  by inward budding of the endosomal membrane. These intraluminal vesicles carry
  membrane proteins selected for degradation.
- Endosomal membrane: single phospholipid bilayer with specific Rab GTPases,
  SNAREs, tethering proteins, pumps, and cargo-sorting complexes.
- Lumen: aqueous interior containing endocytosed fluid, ligands, soluble cargo,
  released receptor ligands, and material headed for degradation.
- Tubules and buds: narrow membrane extensions that concentrate membrane cargo
  for recycling or retrograde transport.
- Acidification machinery: proton pumps lower lumen pH, helping receptors
  release ligands and preparing degradative cargo for lysosomal digestion.

## Chemistry And Composition

- Endosomal membranes are lipid bilayers with membrane proteins that preserve
  topology: extracellular-facing receptor domains become lumen-facing after
  endocytosis.
- Early endosomes are mildly acidic, commonly around pH 6.0 to 6.2, due to
  membrane proton pumps. This helps many receptor-ligand pairs dissociate.
- Late endosomes are more acidic, roughly pH 5.5 to 6.0, and can receive
  lysosomal hydrolases from the trans-Golgi network.
- Rab GTPases help define endosome identity and regulate fusion and trafficking
  steps. Rab5 is commonly associated with early endosomes, while Rab7 is linked
  with late endosomes.
- SNARE proteins and tethering factors support selective membrane fusion between
  incoming endocytic vesicles and endosomal target membranes.
- Clathrin-coated vesicles shed their coats before fusing with early endosomes.
- Recycling tubules are enriched in membrane cargo because tubules have high
  membrane area relative to their small internal volume.
- Intraluminal vesicles inside multivesicular bodies separate selected membrane
  proteins from the cytosol-facing machinery and send them toward degradation.

## Functions

- Sort cargo internalized by endocytosis.
- Recycle receptors and membrane components back to the plasma membrane.
- Deliver nutrients such as iron and cholesterol by separating ligands from
  receptors in acidic endosomal compartments.
- Route some receptors to lysosomes for degradation, helping down-regulate cell
  signaling.
- Move selected cargo across polarized cells by transcytosis.
- Send cargo to late endosomes and lysosomes for digestion.
- Receive hydrolase traffic from the trans-Golgi network and help build the
  degradative endolysosomal system.
- Store regulated pools of some plasma membrane proteins, such as glucose
  transporters in specialized recycling compartments.

## Dynamic Processes

- Endocytosis: plasma membrane invaginates and pinches off, bringing receptors,
  ligands, membrane, and extracellular fluid into the cell.
- Uncoating: many endocytic vesicles lose clathrin coats before fusion.
- Early endosome fusion: incoming vesicles fuse with early endosomes through
  Rab- and SNARE-dependent targeting.
- Acid-dependent sorting: lower pH causes many ligands to dissociate from their
  receptors.
- Recycling: selected receptors and membrane proteins enter endosomal tubules
  and return to the plasma membrane directly or through recycling endosomes.
- Maturation: endosomal compartments move inward along microtubules, become more
  acidic, and transition toward late endosomes.
- Multivesicular body formation: patches of endosomal membrane invaginate and
  pinch into the lumen, packaging membrane proteins for degradation.
- Lysosome delivery: late endosomes receive lysosomal enzymes and can mature or
  fuse into degradative endolysosomal compartments.

## Learning Misconceptions

- "Endosomes are just transport vesicles": endosomes are sorting compartments
  with distinct regions, pH, identity proteins, and routes.
- "Everything taken up by endocytosis is destroyed": much internalized membrane
  and many receptors are recycled back to the cell surface.
- "Early and late endosomes are only different ages": they also differ in
  location, acidity, protein identity, cargo content, and trafficking partners.
- "The endosome lumen is the same as cytosol": endosomes have a separate lumen,
  and extracellular-facing receptor domains become lumen-facing after uptake.
- "Recycling is passive leakage back out": recycling is a selective membrane
  trafficking process.
- "Lysosomes appear suddenly": late endosomes help form lysosomal compartments
  through maturation, acidification, enzyme delivery, and fusion.
- "Endosomes only handle nutrients": they also regulate signaling receptors,
  membrane turnover, polarity, synaptic vesicle recycling, and transcytosis.

## Roblox Design Concept

Build endosomes as a sorting hub near the inside of the plasma membrane. Cargo
tokens enter from coated pits, arrive at an early endosome, then choose one of
several visible exits: fast recycling back to the membrane, slow recycling
through a recycling endosome, delivery to late endosome/lysosome, or optional
transcytosis across a polarized cell layer.

Recommended experience:

- Sorting station view: players watch receptor-ligand pairs split inside a
  mildly acidic early endosome.
- Route choice challenge: players assign cargo to recycle, degrade, transcytose,
  or return toward Golgi.
- Maturation view: early endosome moves inward, gains late-endosome markers, and
  forms internal vesicles.
- Degradation handoff: late endosome receives hydrolase cargo from Golgi traffic
  and links to the lysosome project.

## Model Hierarchy

```text
Endosomes (Model)
  Routes (Folder)
    Route_PM_to_EarlyEndosome
    Route_EarlyEndosome_to_PM_FastRecycle
    Route_EarlyEndosome_to_RecyclingEndosome
    Route_RecyclingEndosome_to_PM
    Route_EarlyEndosome_to_LateEndosome
    Route_LateEndosome_to_Lysosome
    Route_LateEndosome_to_Golgi_Optional
  Compartments (Folder)
    EarlyEndosome_01 (Model)
      VacuolarBody
      RecyclingTubules
      AcidicLumen
      CargoTokens
      Rab5Markers
      Hotspots
    RecyclingEndosome_01 (Model)
      StorageLumen
      ReturnTubules
      Rab11Markers
    LateEndosome_01 (Model)
      AcidicLumen
      IntraluminalVesicles
      Rab7Markers
      HydrolaseCargo
    MultivesicularBody_01 (Model)
      OuterMembrane
      InternalVesicles
  CargoExamples (Folder)
    LDL_ReceptorPair
    Transferrin_ReceptorPair
    GrowthFactor_ReceptorPair
    GenericFluidCargo
  Hotspots (Folder)
    Hotspot_EarlySorting
    Hotspot_ReceptorRecycling
    Hotspot_EndosomeAcidification
    Hotspot_MultivesicularBody
    Hotspot_LateEndosomeLysosome
```

## Materials, Colors, And Effects

- Early endosome: translucent teal-green membrane with pale yellow/green lumen
  glow to signal mild acidity.
- Recycling tubules: thin blue or cyan curved tubes extending from the early
  endosome and recycling endosome.
- Late endosome: deeper violet/red tint with stronger acidic glow.
- Multivesicular body: transparent shell containing a small number of internal
  vesicle spheres; keep the count readable rather than anatomically crowded.
- Cargo tokens: paired shapes for receptor and ligand so players can see
  dissociation after acidification.
- Rab markers: small colored studs or bands on membranes; use labels in UI
  rather than trying to model proteins at molecular scale.
- Routes: Beams or dotted path markers with arrowheads; use patterns and labels
  as well as colors.
- Acidification effect: small inward-moving `H+` particles or pulsing glow,
  kept subtle so the model remains readable.

## Interactions And Hotspots

- `Hotspot_EarlySorting`: shows incoming clathrin-derived vesicles uncoating and
  fusing with an early endosome.
- `Hotspot_ReceptorLigandSplit`: lowers the pH indicator and separates ligand
  from receptor.
- `Hotspot_ReceptorRecycling`: sends receptor tokens through tubules back to the
  plasma membrane.
- `Hotspot_DegradationRoute`: sends soluble cargo and down-regulated receptors
  toward late endosome and lysosome.
- `Hotspot_MultivesicularBody`: demonstrates inward budding into intraluminal
  vesicles.
- `Hotspot_Transcytosis`: optional polarized-cell challenge that moves cargo
  from one membrane domain to another.
- `Hotspot_GolgiHydrolaseDelivery`: connects late endosome function to
  lysosomal enzyme delivery from the Golgi.

## Performance Notes

- Use only one highly detailed early endosome and one late endosome; represent
  the rest as simplified spheres or route markers.
- Limit internal vesicles in multivesicular bodies to 8 to 16 visible spheres.
- Animate cargo along spline-like paths with TweenService or scripted
  interpolation rather than physics simulation.
- Pool cargo tokens and recycle them during sorting loops.
- Keep proton particles low-count and local to selected compartments.
- Use simple transparent shells with outline rings; many transparent objects can
  become expensive and visually confusing.
- Disable nonessential route beams when a player focuses on one pathway.

## Sources Used

- [NCBI Bookshelf: Endocytosis](https://www.ncbi.nlm.nih.gov/books/NBK9831/)
- [NCBI Bookshelf: Transport into the Cell from the Plasma Membrane: Endocytosis](https://www.ncbi.nlm.nih.gov/books/NBK26870/)
- [NCBI Bookshelf: Transport from the Trans Golgi Network to Lysosomes](https://www.ncbi.nlm.nih.gov/books/NBK26844/)
- [Khan Academy: Bulk Transport](https://www.khanacademy.org/science/shs-biology-1/xca2b82fdfba136b8%3Aunit-1-name/xca2b82fdfba136b8%3Acellular-transport/a/bulk-transport)
