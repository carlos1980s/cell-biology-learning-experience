# 15 Proteasomes

Purpose: represent selective protein degradation, ubiquitin tagging, ATP-driven
unfolding, and peptide recycling in a non-membrane protein machine.

Recommended Roblox object: one parent `Model` named `Proteasomes` containing
several small 26S proteasome machines in cytosol and optional nuclear copies.

First build target: barrel-shaped 20S core with one or two 19S regulatory caps,
ubiquitin-tagged protein substrates, and an ATP-driven threading animation.

## Biological Overview

Proteasomes are large protein complexes that degrade many unwanted, damaged, or
short-lived intracellular proteins. They are not membrane-bound organelles.
Instead, they are molecular machines found mainly in the cytosol and nucleus.
The best-known eukaryotic form is the 26S proteasome, which contains a 20S
proteolytic core and one or two 19S regulatory particles.

Proteasomal degradation is closely linked to ubiquitin, a small protein tag.
Cells attach ubiquitin chains to selected target proteins through an enzyme
cascade involving E1 activating enzymes, E2 conjugating enzymes, and E3 ligases.
The proteasome recognizes many ubiquitin-tagged substrates, removes or recycles
ubiquitin, unfolds the substrate using ATP-dependent machinery, and threads it
into the core particle for cleavage into peptides.

Core sources:

- [NCBI Bookshelf, Biochemistry: Ubiquitination](https://www.ncbi.nlm.nih.gov/books/NBK556052/)
- [LibreTexts Biology, The Proteasome](https://bio.libretexts.org/Bookshelves/Introductory_and_General_Biology/Book%3A_Biology_%28Kimball%29/03%3A_The_Cellular_Basis_of_Life/3.10%3A_The_Proteasome)
- [PMC review, Structure and Function of the 26S Proteasome](https://pmc.ncbi.nlm.nih.gov/articles/PMC6422034/)
- [PMC review, Proteasome in action: substrate degradation by the 26S proteasome](https://pmc.ncbi.nlm.nih.gov/articles/PMC8106498/)

## Detailed Structure

- 20S core particle: barrel-like protease chamber built from four stacked rings.
  The two outer rings are alpha subunits; the two inner rings are beta subunits.
- Proteolytic chamber: active sites face inward, protecting the cell from
  uncontrolled protein cleavage.
- Gate: the alpha rings control substrate entry into the core particle.
- 19S regulatory particle: cap complex that recognizes substrates, processes
  ubiquitin chains, unfolds proteins, and feeds them into the 20S core.
- ATPase motor: six AAA+ ATPase subunits in the 19S base use ATP to unfold and
  translocate substrates.
- Ubiquitin receptors: regulatory cap subunits and shuttle factors bind
  ubiquitin chains on selected substrates.
- Deubiquitinating enzymes: remove or edit ubiquitin chains so ubiquitin can be
  reused before or during degradation.
- 26S proteasome forms: one 19S cap on one end or two caps on both ends of the
  20S core.

## Chemistry And Composition

- Proteasomes are protein complexes, not lipid-bounded compartments.
- Ubiquitin is a conserved 76-amino-acid protein that can be attached to lysine
  residues on target proteins or linked to other ubiquitin molecules.
- Many proteasome-directed substrates carry polyubiquitin chains, often including
  Lys48-linked chains in common textbook examples.
- Ubiquitination uses ATP at the E1 activation step, and proteasomal unfolding
  uses ATP hydrolysis in the 19S ATPase motor.
- The 20S beta subunits contain protease active sites that cleave peptide bonds
  after substrates enter the core.
- Released peptide fragments can be further degraded to amino acids or, in
  vertebrate immune cells, contribute to antigen presentation through MHC class I.
- Proteasome inhibitors such as bortezomib show the pathway's medical relevance,
  especially in some cancers.

## Functions

- Remove misfolded, damaged, or oxidized intracellular proteins.
- Regulate levels of short-lived proteins such as cyclins and transcription
  factors.
- Support cell-cycle progression by timed destruction of regulatory proteins.
- Maintain protein homeostasis alongside chaperones, lysosomes, and autophagy.
- Help cells respond to stress by clearing defective proteins.
- Generate peptide fragments for antigen presentation by MHC class I in
  vertebrates.
- Recycle amino acids and ubiquitin for future cellular use.
- Regulate signaling pathways by degrading specific pathway components.

## Dynamic Processes

- Substrate selection: E3 ligases recognize particular degradation signals and
  help attach ubiquitin to target proteins.
- Polyubiquitin chain building: repeated ubiquitin addition creates a signal
  that can recruit proteasome receptors.
- Recognition and docking: ubiquitin receptors on the proteasome or shuttle
  proteins bring the substrate to the 19S cap.
- Deubiquitination: ubiquitin is removed or trimmed and recycled.
- Unfolding: ATPase subunits pull on an unstructured region of the substrate and
  unfold the protein.
- Translocation: the unfolded polypeptide is threaded through the gate into the
  20S core.
- Proteolysis: active sites inside the core cleave the substrate into short
  peptides.
- Product release: peptides exit the proteasome and can be further processed in
  the cytosol.

## Learning Misconceptions

- "Proteasomes are lysosomes": lysosomes are membrane-bound acidic organelles;
  proteasomes are non-membrane protein machines.
- "Ubiquitin is always a destruction signal": ubiquitin can also regulate
  trafficking, signaling, DNA repair, and other processes depending on linkage
  and context.
- "The proteasome chews up every nearby protein": substrates are selected by
  tagging, receptors, unfolding requirements, and regulatory control.
- "Proteasomes only clean up mistakes": they also degrade normal regulatory
  proteins at precise times.
- "ATP is used only to tag proteins": ATP is also used by the proteasome motor
  to unfold and translocate substrates.
- "Protein degradation is wasteful": degradation is essential for recycling,
  quality control, and rapid control of cell state.
- "Proteasomes degrade whole organelles": large organelles are usually handled
  by autophagy and lysosomes, not threaded through proteasome cores.

## Roblox Design Concept

Represent proteasomes as small barrel-shaped recycling machines rather than as
vesicles. A target protein should be selected, tagged with a chain of ubiquitin
beads, docked at a cap, unfolded like a thread, pulled through the barrel, and
released as small peptide fragments.

Recommended experience:

- Quality-control view: misfolded protein tokens are ubiquitinated and delivered
  to proteasomes.
- Cell-cycle view: cyclin tokens disappear at the correct phase to show timed
  regulation.
- Machine view: players inspect 19S caps, 20S core, ATPase ring, gate, and
  internal active sites.
- Immune extension: optional MHC class I path shows some peptides moving toward
  ER processing for antigen presentation.

## Model Hierarchy

```text
Proteasomes (Model)
  Proteasome_26S_01 (Model)
    Core20S (Model)
      AlphaRing_Top
      BetaRing_Top
      BetaRing_Bottom
      AlphaRing_Bottom
      ProteaseActiveSites
      EntryGate
    RegulatoryCap19S_Top (Model)
      UbiquitinReceptors
      DeubiquitinaseSite
      ATPaseRing
      SubstrateChannel
    RegulatoryCap19S_Bottom (Model)
    Hotspots
      Hotspot_UbiquitinTagging
      Hotspot_ATPaseUnfolding
      Hotspot_CoreProteolysis
      Hotspot_UbiquitinRecycling
      Hotspot_ProteasomeVsLysosome
  Substrates (Folder)
    MisfoldedProtein
    CyclinToken
    UbiquitinChain
    PeptideFragments
  OptionalImmuneRoute (Folder)
    PeptidesToER
    MHCClassIHint
```

## Materials, Colors, And Effects

- 20S core: stacked blue and steel-gray rings with a hollow central channel.
- 19S cap: gold or teal cap on one or both ends, visibly different from the core.
- ATPase ring: six small moving nodes around the entry channel with subtle pulse
  effects.
- Ubiquitin: bright red or magenta beads attached in a chain to target proteins.
- Substrate protein: flexible ribbon or bead chain that changes from folded to
  extended during unfolding.
- Peptides: short pale fragments released from the opposite side of the barrel.
- ATP use: small yellow energy flashes at the ATPase ring, kept brief and local.
- Proteasome copies: simplified gray/blue barrels in the background for
  abundance without overloading the scene.

## Interactions And Hotspots

- `Hotspot_UbiquitinTagging`: demonstrates E1, E2, and E3 roles at a simplified
  level and builds a ubiquitin chain.
- `Hotspot_SubstrateRecognition`: docks a ubiquitin-tagged protein to receptor
  nodes on the cap.
- `Hotspot_UbiquitinRecycling`: removes ubiquitin beads before degradation and
  returns them to a reusable pool.
- `Hotspot_ATPaseUnfolding`: uses pulsing ATPase nodes to unfold the substrate.
- `Hotspot_CoreProteolysis`: threads the substrate into the core and releases
  peptide fragments.
- `Hotspot_CellCycleCyclin`: timed degradation example for cell-cycle control.
- `Hotspot_ProteasomeVsLysosome`: compares soluble intracellular protein
  degradation with membrane-bound lysosomal digestion.

## Performance Notes

- Use one detailed proteasome for inspection and low-poly copies for background
  cytosolic/nuclear distribution.
- Animate a single substrate through the machine at a time to keep the process
  understandable and performant.
- Use scale/tween effects for unfolding rather than many physics-linked parts.
- Keep ubiquitin chains short but clear; labels can explain polyubiquitin without
  rendering dozens of beads.
- Do not use particle bursts for proteolysis; simple fragments and fade effects
  make the pathway easier to read.
- If nuclear proteasomes are shown, keep them subtle so they do not distract
  from the nucleus model.

## Sources Used

- [NCBI Bookshelf: Biochemistry, Ubiquitination](https://www.ncbi.nlm.nih.gov/books/NBK556052/)
- [LibreTexts Biology: The Proteasome](https://bio.libretexts.org/Bookshelves/Introductory_and_General_Biology/Book%3A_Biology_%28Kimball%29/03%3A_The_Cellular_Basis_of_Life/3.10%3A_The_Proteasome)
- [PMC review: Structure and Function of the 26S Proteasome](https://pmc.ncbi.nlm.nih.gov/articles/PMC6422034/)
- [PMC review: Proteasome in action](https://pmc.ncbi.nlm.nih.gov/articles/PMC8106498/)

