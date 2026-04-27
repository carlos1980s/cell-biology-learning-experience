# 10 Golgi Apparatus

Purpose: model stacked cisternae, receiving/shipping faces, and vesicle sorting.

Recommended Roblox object: one `Model` named `GolgiApparatus` with stacked curved
plates and vesicle markers.

First build target: a recognizable stacked structure that can be placed between
ER and vesicle pathways.

## Biological Overview

The Golgi apparatus is a polarized endomembrane organelle that receives proteins
and lipids from the ER, modifies them, sorts them, and dispatches them to
destinations such as the plasma membrane, secretion, lysosomes, or plant-cell
wall pathways ([OpenStax Biology 2e](https://openstax.org/books/biology-2e/pages/4-4-the-endomembrane-system-and-proteins),
[NCBI Bookshelf: The Golgi Apparatus](https://www.ncbi.nlm.nih.gov/books/NBK9838/)).

For A-level / first-year university learners, the essential concept is polarity.
Cargo usually enters near the cis face, passes through cis/medial/trans Golgi
regions where enzymes modify it, then exits from the trans-Golgi network (TGN)
in sorted vesicles. The Golgi is not just a passive stack of bags; it is a
processing and distribution system with chemically distinct compartments
([NCBI Bookshelf: Transport from the ER through the Golgi](https://www.ncbi.nlm.nih.gov/books/NBK26941/)).

## Detailed Structure

- Stack of flattened, membrane-bound sacs called cisternae, with associated
  vesicles and tubules.
- Cis face: entry side, generally oriented toward ER-derived vesicle traffic.
- Medial cisternae: middle processing region where many glycan modifications
  continue.
- Trans face and TGN: exit/sorting side where cargo is packaged for different
  destinations.
- Animal cells often have linked Golgi stacks near the nucleus and centrosome;
  many plant cells have multiple dispersed Golgi stacks.
- Vesicles around the stack represent incoming ER-Golgi traffic, recycling
  traffic, and outgoing secretory/lysosomal/plasma-membrane traffic.

## Chemistry And Composition

- Membranes: phospholipid bilayers with compartment-specific resident enzymes
  and trafficking proteins.
- Cargo: proteins, lipids, glycoproteins, glycolipids, and polysaccharides
  moving through the secretory pathway.
- Glycosylation enzymes: glycosyltransferases and glycosidases modify N-linked
  glycans and build O-linked glycans in ordered compartmental steps.
- Sugar-nucleotide transporters supply activated sugars to the Golgi lumen for
  glycosylation reactions.
- Sorting chemistry: oligosaccharide tags and other molecular signals help
  direct cargo. A classic example is mannose-6-phosphate tagging of many
  lysosomal enzymes.
- Plant-specific chemistry: the Golgi synthesizes many hemicelluloses and
  pectins for the cell wall
  ([NCBI Bookshelf: The Golgi Apparatus](https://www.ncbi.nlm.nih.gov/books/NBK9838/)).

## Core Functions

- Receives ER-derived cargo at the cis side.
- Modifies proteins and lipids, especially by glycosylation and glycan trimming.
- Sorts cargo for secretion, plasma membrane insertion, lysosomes/vacuoles, or
  return to earlier compartments.
- Packages cargo into transport vesicles at the TGN.
- Maintains resident Golgi enzymes in correct regions while cargo moves through.
- In plant cells, synthesizes and exports important non-cellulose wall
  polysaccharides.

## Dynamic Processes To Represent

- ER-to-Golgi delivery: incoming vesicles fuse with the cis side.
- Ordered modification: cargo gains or changes sugar tags as it moves from cis
  through medial to trans regions.
- Sorting at the TGN: different tagged cargo exits in different vesicle classes.
- Retrieval/recycling: some escaped ER or Golgi resident proteins are returned
  rather than sent onward.
- Cisternal maturation concept: cisternae can be represented as changing
  identity over time while cargo progresses, with recycling vesicles carrying
  resident enzymes backward. This is more advanced but appropriate as an
  optional first-year extension.

## Learning Misconceptions To Avoid

- "The Golgi makes proteins." Proteins are synthesized by ribosomes; the Golgi
  modifies, sorts, and packages many proteins after ER entry.
- "The Golgi has no direction." Cis and trans faces are functionally different.
- "All cargo leaves in the same vesicles." Cargo is sorted into distinct
  pathways based on molecular signals and destination.
- "Glycosylation only happens in the Golgi." Initial N-linked glycosylation
  begins in the ER; further modification often occurs in the Golgi.
- "Golgi vesicles only move outward." Retrieval traffic returns selected
  proteins and membranes to earlier compartments.

## Roblox Design Concept

Build the Golgi as a stack of curved, flattened plates with a clear receiving
face and shipping face. Incoming ER vesicles should approach the cis side,
change color/tag state as they pass through the stack, then leave the TGN along
separate destination lanes: secretion/plasma membrane, lysosome/vacuole, and
recycling/return.

## Model Hierarchy

```text
GolgiApparatus (Model)
  PivotAnchor (Part, transparent, PrimaryPart)
  CisternaeStack (Folder)
    CisCisterna_01 (MeshPart)
    MedialCisterna_02
    MedialCisterna_03
    TransCisterna_04
  Faces (Folder)
    CisFaceMarker (Attachment or translucent Part)
    TransFaceMarker (Attachment or translucent Part)
    TGNZone (Part + ProximityPrompt)
  Vesicles (Folder)
    IncomingERVesicle_###
    SecretoryVesicle_###
    LysosomeBoundVesicle_###
    RetrievalVesicle_###
  CargoMarkers (Folder)
    ProteinCargo_###
    LipidCargo_###
    SugarTag_###
  Pathways (Folder)
    FromERPath
    ToMembranePath
    ToLysosomePath
    ReturnToERPath
  Hotspots (Folder)
    CisEntryHotspot
    GlycosylationHotspot
    SortingHotspot
```

Use the model `PrimaryPart` for placement and prompt management. Roblox
`ProximityPrompt` can be attached to parts, attachments, or a model with a
`PrimaryPart`, which fits the hotspot plan
([Roblox ProximityPrompt](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt)).

## Materials, Colors, And Effects

- Cisternae: warm gold/orange membranes (`#E0A32E`) with slightly darker rims to
  make each flattened sac readable.
- Cis face: green-blue receiving highlight to connect visually to ER traffic.
- Trans/TGN face: magenta or coral shipping highlight to signal sorting.
- Incoming ER vesicles: teal spheres/capsules.
- Secretory vesicles: bright yellow/white; lysosome-bound vesicles: purple;
  retrieval vesicles: blue-gray returning toward ER.
- Cargo tags: small colored bands or icons added to cargo, not text-heavy
  labels on every object.
- Effects: short Beam arrows or Tweened vesicles for traffic. Use particles only
  for active sorting moments and keep counts low
  ([Roblox Particle Emitters](https://create.roblox.com/docs/effects/particle-emitters)).

## Interactions And Hotspots

- Cis entry hotspot: player sends ER cargo into the cis face and identifies the
  direction of movement.
- Glycosylation hotspot: player adds or modifies sugar tags across cis, medial,
  and trans stations.
- Sorting hotspot: player chooses cargo destinations based on tags such as
  secretion, membrane insertion, lysosome/vacuole delivery, or retrieval.
- Plant-cell extension hotspot: toggles a plant mode showing pectin/hemicellulose
  cargo leaving for the cell wall.
- Advanced pathway hotspot: demonstrates that forward and backward vesicle
  traffic operate together to maintain compartment identity.

## Performance Notes

- Use 4-6 cisternae meshes, not dozens of thin parts. The visual stack matters
  more than microscopic accuracy at Roblox scale.
- Keep vesicles as simple spheres or capsules with shared materials and pooled
  animation instances.
- Prefer Beam path indicators over many always-moving particles.
- Disable collisions on all decorative cargo and vesicle markers unless a lesson
  requires touch interaction.
- Anchor static Golgi plates and animate vesicles/cargo only.
- Manage part counts and particle/shadow settings carefully; Roblox performance
  guidance specifically highlights dense models, particle changes, and shadow
  costs as optimization concerns
  ([Roblox Performance Optimization](https://create.roblox.com/docs/performance-optimization/improve)).

## Sources Used

- [OpenStax Biology 2e: The Endomembrane System and Proteins](https://openstax.org/books/biology-2e/pages/4-4-the-endomembrane-system-and-proteins)
- [NCBI Bookshelf: The Golgi Apparatus - The Cell](https://www.ncbi.nlm.nih.gov/books/NBK9838/)
- [NCBI Bookshelf: Transport from the ER through the Golgi Apparatus](https://www.ncbi.nlm.nih.gov/books/NBK26941/)
- [NCBI Bookshelf: Cellular Organization of Glycosylation](https://www.ncbi.nlm.nih.gov/books/NBK453052/)
- [Khan Academy: The Endomembrane System](https://www.khanacademy.org/science/ap-biology/cell-structure-and-function/cell-compartmentalization-and-its-origins/a/the-endomembrane-system)
- [Roblox Creator Hub: ProximityPrompt](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt)
- [Roblox Creator Hub: Particle Emitters](https://create.roblox.com/docs/effects/particle-emitters)
- [Roblox Creator Hub: Improve Performance](https://create.roblox.com/docs/performance-optimization/improve)
