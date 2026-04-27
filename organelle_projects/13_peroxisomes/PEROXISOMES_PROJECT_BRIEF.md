# 13 Peroxisomes

Purpose: represent oxidative metabolism, detoxification, lipid processing, and
reactive oxygen control in a compact single-membrane organelle.

Recommended Roblox object: one parent `Model` named `Peroxisomes` containing
several small peroxisome submodels distributed through the cytoplasm.

First build target: translucent enzyme-filled spheres with catalase and fatty
acid processing hotspots.

## Biological Overview

Peroxisomes are small, single-membrane organelles found in nearly all eukaryotic
cells. They contain enzymes that carry out oxidation reactions, especially
reactions linked to lipid metabolism and detoxification. Many of these reactions
produce hydrogen peroxide, so peroxisomes also contain catalase, which converts
hydrogen peroxide into less harmful products.

Peroxisomes are not part of the endomembrane traffic pathway in the same way as
ER, Golgi, lysosomes, and vesicles. Most peroxisomal proteins are made on free
ribosomes in the cytosol and imported after translation. Peroxisomes can grow,
divide, and exchange metabolic products with mitochondria, the ER, lipid
droplets, and, in plant cells, chloroplasts.

Core sources:

- [NCBI Bookshelf, The Cell: Peroxisomes](https://www.ncbi.nlm.nih.gov/books/NBK9930/)
- [OpenStax Biology 2e, Eukaryotic Cells](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)
- [LibreTexts Biology, Peroxisomes](https://bio.libretexts.org/Courses/Northwest_University/MKBN211%3A_Introductory_Microbiology_%28Bezuidenhout%29/03%3A_Cell_Structure_of_Bacteria_Archaea_and_Eukaryotes/3.08%3A_Other_Eukaryotic_Components/3.8.01%3A_Peroxisomes)
- [PMC review, Peroxisomes: a Nexus for Lipid Metabolism and Cellular Signaling](https://pmc.ncbi.nlm.nih.gov/articles/PMC3951609/)

## Detailed Structure

- Membrane: one phospholipid bilayer containing peroxisomal membrane proteins
  that import proteins and move metabolites.
- Matrix: enzyme-rich internal space where oxidation reactions, catalase
  activity, and lipid-related reactions occur.
- Catalase-rich zones: some peroxisomes contain dense enzyme regions in electron
  micrographs; a Roblox model can show these as brighter internal enzyme
  clusters.
- Protein import machinery: peroxins recognize peroxisomal targeting signals on
  folded or completed proteins and help import them into the organelle.
- Variable size and number: peroxisomes can be small and numerous, and their
  abundance changes with cell type and metabolic state.
- Contacts with other organelles: peroxisomes often work near mitochondria, ER,
  lipid droplets, and chloroplasts because their metabolites are shared.

## Chemistry And Composition

- Peroxisomes contain oxidases that transfer hydrogen from substrates to oxygen,
  producing hydrogen peroxide as a by-product.
- Catalase breaks down hydrogen peroxide or uses it to oxidize other compounds,
  limiting oxidative damage to the rest of the cell.
- In animal cells, peroxisomes help shorten very-long-chain and some branched
  fatty acids. Products can be passed to mitochondria for further metabolism.
- Peroxisomes participate in synthesis of ether phospholipids called
  plasmalogens, which are important in tissues such as brain and heart.
- In liver cells, peroxisomes contribute to bile acid synthesis from cholesterol
  derivatives.
- In plants, specialized peroxisomes participate in the glyoxylate cycle during
  seed germination and in photorespiration in leaves.
- Peroxisomes do not contain their own DNA; their proteins are encoded in the
  nucleus and imported from the cytosol.

## Functions

- Detoxify reactive hydrogen peroxide using catalase.
- Oxidize fatty acids, especially very-long-chain fatty acids that mitochondria
  handle poorly.
- Support lipid biosynthesis, including plasmalogen synthesis.
- Contribute to bile acid synthesis in animal liver cells.
- Metabolize certain amino acids, uric acid, and other small molecules depending
  on species and tissue.
- Cooperate with mitochondria in redox balance and fatty acid metabolism.
- In plant cells, support conversion of stored fats to carbohydrates during seed
  germination and participate in photorespiration.

## Dynamic Processes

- Protein import: enzymes made on free ribosomes are targeted to peroxisomes by
  peroxisomal targeting signals and imported after translation.
- Growth: membrane and matrix proteins are added as the organelle expands.
- Division: peroxisomes can replicate by elongation, constriction, and fission.
- Metabolic exchange: fatty acid products and redox-related molecules move
  between peroxisomes and partner organelles.
- Oxidative detoxification: hydrogen peroxide generated inside the peroxisome is
  rapidly processed by catalase.
- Organelle turnover: damaged or excess peroxisomes can be removed by selective
  autophagy, often called pexophagy.
- Environmental response: peroxisome number and enzyme content can change when
  cell metabolism changes.

## Learning Misconceptions

- "Peroxisomes are small lysosomes": lysosomes digest material with acid
  hydrolases; peroxisomes specialize in oxidative metabolism and redox control.
- "Peroxisomes are only for detox": detoxification is important, but lipid
  metabolism and biosynthesis are also central functions.
- "Hydrogen peroxide is stored safely forever": hydrogen peroxide is reactive,
  so peroxisomes generate and break it down in a controlled space.
- "Peroxisomes make ATP like mitochondria": peroxisomal oxidation is metabolic,
  but peroxisomes are not ATP-producing organelles like mitochondria.
- "All fatty acid oxidation is mitochondrial": mitochondria carry out much fatty
  acid beta oxidation, but peroxisomes are important for very-long-chain and
  specialized fatty acids.
- "Peroxisomes have their own genome": unlike mitochondria and chloroplasts,
  peroxisomes do not carry DNA.

## Roblox Design Concept

Represent peroxisomes as small oxidative processing stations scattered through
the cytoplasm. Each station should look enclosed, enzyme-rich, and metabolically
active without resembling a digestive lysosome. The strongest learner signal is
that potentially dangerous chemistry happens inside a controlled organelle.

Recommended experience:

- Redox view: substrate tokens enter, small hydrogen peroxide warning tokens
  appear, and catalase converts them to safe output particles.
- Fatty acid view: a long fatty acid chain enters and exits as shorter fragments
  that can move toward mitochondria.
- Organelle comparison view: toggles labels contrasting lysosome hydrolysis,
  mitochondrial ATP production, and peroxisomal oxidation.
- Plant extension: optional seed/leaf module shows glyoxysome and
  photorespiration roles when the scene includes plant cells.

## Model Hierarchy

```text
Peroxisomes (Model)
  Peroxisome_01 (Model)
    Membrane
    Matrix
    EnzymeClusters
      CatalaseCluster
      OxidaseCluster
    ImportPores
    FattyAcidTrack
    H2O2Markers
    Hotspots
      Hotspot_Catalase
      Hotspot_FattyAcidOxidation
      Hotspot_ProteinImport
      Hotspot_OrganelleCrosstalk
  Peroxisome_02 (Model)
  Peroxisome_03 (Model)
  MetaboliteRoutes (Folder)
    Route_Peroxisome_to_Mitochondrion
    Route_ER_to_PeroxisomeMembrane
    Route_LipidDroplet_to_Peroxisome
  OptionalPlantPeroxisomes (Folder)
    Glyoxysome
    LeafPeroxisome
```

## Materials, Colors, And Effects

- Membrane: translucent pale amber or sea-green shell with a clear outline.
- Matrix: warm yellow-green glow to suggest enzyme activity, distinct from the
  acidic red/purple lysosome palette.
- Catalase cluster: bright blue-white or cyan particles that pulse when hydrogen
  peroxide appears.
- Hydrogen peroxide markers: small red/orange warning sparks that quickly fade
  after catalase activation.
- Fatty acids: flexible bead chains; very-long-chain fatty acids should visibly
  shorten during the interaction.
- Organelle routes: thin green/yellow Beams connecting peroxisomes to
  mitochondria, ER, or lipid droplets only when that view is active.
- Plant extension: glyoxysomes can use green accents; leaf peroxisomes can use a
  chloroplast-adjacent route color.

## Interactions And Hotspots

- `Hotspot_Catalase`: starts a hydrogen peroxide detoxification animation.
- `Hotspot_FattyAcidOxidation`: shows a long fatty acid being shortened inside
  the peroxisome.
- `Hotspot_ProteinImport`: animates cytosolic enzyme proteins entering through
  import machinery after translation.
- `Hotspot_PlasmalogenSynthesis`: highlights lipid biosynthesis for membranes.
- `Hotspot_MitochondriaCrosstalk`: routes shortened fatty acid products toward
  mitochondria.
- `Hotspot_PeroxisomeDivision`: shows elongation and fission into two smaller
  peroxisomes.
- `Hotspot_PlantRoles`: optional comparison of glyoxysome and photorespiration
  roles.

## Performance Notes

- Use a small number of detailed peroxisomes and many low-detail copies if the
  cell scene needs abundance.
- Keep internal enzyme particles low-count and disable them at distance.
- Use scripted token movement rather than physics for fatty acid chains and
  hydrogen peroxide markers.
- Reuse the same peroxisome mesh with scale and tint variations.
- Avoid continuous bright warning particles; trigger them only during hotspot
  interactions so the scene does not look noisy.
- Show plant-specific roles only in a separate mode or optional module to avoid
  confusing animal-cell learners.

## Sources Used

- [NCBI Bookshelf: Peroxisomes](https://www.ncbi.nlm.nih.gov/books/NBK9930/)
- [OpenStax Biology 2e: Eukaryotic Cells](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)
- [LibreTexts Biology: Peroxisomes](https://bio.libretexts.org/Courses/Northwest_University/MKBN211%3A_Introductory_Microbiology_%28Bezuidenhout%29/03%3A_Cell_Structure_of_Bacteria_Archaea_and_Eukaryotes/3.08%3A_Other_Eukaryotic_Components/3.8.01%3A_Peroxisomes)
- [PMC review: Peroxisomes as a Nexus for Lipid Metabolism and Cellular Signaling](https://pmc.ncbi.nlm.nih.gov/articles/PMC3951609/)

