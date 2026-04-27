# 08 Ribosomes

Purpose: create free and attached ribosomes for protein synthesis activities.

Recommended Roblox object: one `Model` named `Ribosomes` for free-floating
ribosomes, plus reusable ribosome components that rough ER can instantiate.

First build target: small repeated units with a strict part-count budget and
clear educational highlighting.

## Biological overview

Ribosomes are ribonucleoprotein machines that translate messenger RNA into
polypeptides. They are not membrane-bound organelles. In eukaryotic cells, many
ribosomes are free in the cytosol, while others are temporarily bound to the
rough endoplasmic reticulum or the outer nuclear membrane during synthesis of
secreted, membrane, or endomembrane-system proteins. OpenStax describes
ribosomes as RNA-protein complexes made of large and small subunits that read
mRNA instructions and assemble amino acids into proteins
([OpenStax Biology 2e, 4.3](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)).

At first-year level, the most important distinction is that ribosomes are
assembled from rRNA and proteins but function as dynamic translation machines:
the small subunit helps decode mRNA codons, the large subunit catalyzes peptide
bond formation, and tRNAs bring amino acids matched by anticodons.

## Detailed structure

- Eukaryotic cytosolic ribosome: 80S complete ribosome, made from a 40S small
  subunit and 60S large subunit. The S values are sedimentation coefficients and
  do not add arithmetically.
- Small subunit: binds mRNA and helps match codons with tRNA anticodons.
- Large subunit: contains the peptidyl transferase center that catalyzes peptide
  bond formation and a tunnel through which the growing polypeptide exits.
- Binding sites: model A, P, and E tRNA sites conceptually. The A site receives
  incoming aminoacyl-tRNA, the P site holds the growing peptide-tRNA, and the E
  site releases deacylated tRNA.
- mRNA channel: the strand passes through the ribosome and is read in codons.
- Exit tunnel: the nascent polypeptide emerges from the large subunit.
- Polyribosome: multiple ribosomes translating the same mRNA at once. Nature
  Education notes that ribosomes can be visible as clusters called
  polyribosomes ([Nature Education/Scitable](https://www.nature.com/scitable/topicpage/ribosomes-transcription-and-translation-14120660/)).
- ER-bound ribosomes: structurally the same ribosomes as free ribosomes, but
  attached during translation because the growing protein carries an ER-targeting
  signal.

## Chemistry and composition

- Ribosomes are complexes of ribosomal RNA and ribosomal proteins. Nature
  Education summarizes that rRNA makes up about half of ribosomal mass and
  carries out catalytic steps of protein synthesis
  ([Nature Education/Scitable](https://www.nature.com/scitable/topicpage/ribosomes-transcription-and-translation-14120660/)).
- Eukaryotic ribosomes include 18S rRNA in the 40S subunit and 28S, 5.8S, and 5S
  rRNAs in the 60S subunit. The nucleolus brief covers how most rRNAs are
  transcribed and processed.
- Ribosomal proteins are synthesized in the cytoplasm, imported into the nucleus
  for ribosomal subunit assembly, then exported as part of pre-ribosomal
  subunits.
- Translation consumes energy: ATP is used to charge tRNAs with amino acids;
  GTP is used during initiation, elongation, translocation, and termination
  steps.
- Peptide bond formation is catalyzed by the large ribosomal subunit's peptidyl
  transferase activity; NCBI Bookshelf emphasizes that protein synthesis is
  performed by a catalytic machine made from many proteins and rRNAs
  ([NCBI Bookshelf: From RNA to Protein](https://www.ncbi.nlm.nih.gov/books/NBK26829/)).

## Functions

- Translate mRNA codon sequences into amino acid sequences.
- Maintain reading frame so codons are read in groups of three.
- Coordinate tRNA selection, peptide bond formation, and ribosome translocation.
- Produce cytosolic, nuclear, mitochondrial-imported, peroxisomal, and many
  other proteins on free ribosomes.
- Produce secreted proteins, lysosomal proteins, ER/Golgi/plasma membrane
  proteins, and many endomembrane proteins on ribosomes bound to rough ER after
  signal recognition.
- Enable high protein output through polyribosomes, where many ribosomes
  translate one mRNA simultaneously.

## Dynamic processes to represent

- Initiation: small subunit binds mRNA, start codon is recognized, initiator
  tRNA binds, and the large subunit joins.
- Elongation: aminoacyl-tRNA enters the A site, peptide bond forms, the
  ribosome translocates, and empty tRNA exits from the E site.
- Termination: a stop codon recruits release factors, the completed polypeptide
  is released, and ribosomal subunits separate. NCBI Bookshelf notes that stop
  codons are recognized by release factors rather than tRNAs
  ([NCBI Bookshelf: From RNA to Protein](https://www.ncbi.nlm.nih.gov/books/NBK26829/)).
- Targeting to rough ER: translation begins on a free ribosome; if an ER signal
  peptide emerges, signal recognition particle can pause translation and target
  the ribosome to the ER translocon.
- Polyribosome activity: several ribosomes move along the same mRNA, each
  producing a separate polypeptide chain.
- Ribosomal subunit reuse: subunits detach after translation and can be reused
  for another mRNA.

## Learning misconceptions to address

- "Ribosomes are membrane-bound organelles." Better: ribosomes are
  ribonucleoprotein particles without a surrounding membrane.
- "Free and bound ribosomes are different types." Better: the same ribosome can
  be free or bound depending on the mRNA/protein signal being translated.
- "Ribosomes make amino acids." Better: ribosomes link amino acids delivered by
  tRNAs into polypeptides.
- "Translation happens in the nucleus in eukaryotes." Better: transcription and
  RNA processing happen in the nucleus; translation happens on ribosomes in the
  cytoplasm or on rough ER.
- "The nucleolus makes proteins." Better: it produces rRNA and assembles
  ribosomal subunits; protein synthesis occurs later at ribosomes.
- "80S equals 40S plus 60S by arithmetic." Better: Svedberg units measure
  sedimentation behavior, so they are not additive.

## Roblox design concept

Create ribosomes as small reusable machines that can appear in two contexts:
free in the cytosol and attached to rough ER surfaces. The model should be
simple enough for many copies but clear enough that one "teaching ribosome" can
zoom in to show mRNA, tRNAs, A/P/E sites, and the growing polypeptide.

Suggested experience: players collect an mRNA exported from the nucleus, feed it
through a ribosome, match tRNA anticodons to codons, and watch a polypeptide
chain grow. A second interaction routes a signal-peptide-containing mRNA/ribosome
to the rough ER.

## Model hierarchy

```text
Ribosomes
  RibosomeTemplates
    RibosomeSimple
      SmallSubunit
      LargeSubunit
      MRNAChannelHint
    RibosomeTeaching
      SmallSubunit
      LargeSubunit
      ASiteMarker
      PSiteMarker
      ESiteMarker
      ExitTunnel
      MRNAstrand
      TRNAParticles
      PolypeptideChain
  FreeRibosomes
    RibosomeFree_001
    RibosomeFree_...
  Polyribosomes
    PolyMRNA_001
      RibosomeOnMRNA_001
      RibosomeOnMRNA_...
  BoundRibosomeAdapters
    RoughERAttachmentPoints
    TransloconAlignmentMarker
  Hotspots
    TranslationHotspot
    FreeVsBoundHotspot
    PolyribosomeHotspot
    CodonMatchingHotspot
```

## Materials, colors, and effects

- Small subunit: light teal or blue-green.
- Large subunit: warmer purple, magenta, or blue-violet, large enough to
  visually dominate the small subunit.
- mRNA: thin bright yellow or lime strand with codon tick marks grouped in
  threes.
- tRNA: small L- or T-shaped tokens in distinct colors, with anticodon end
  facing the mRNA.
- Amino acids/polypeptide: bead chain emerging from the large subunit. Use a
  different color from mRNA so students do not confuse nucleic acid with
  protein.
- ER-bound state: add a docking glow or translocon socket on rough ER rather
  than changing ribosome color, reinforcing that bound ribosomes are not a
  separate ribosome species.
- Use minimal particle trails; ribosomes should feel like dense molecular
  machines, not magic emitters.

## Interactions and hotspots

- Translation hotspot: steps through initiation, elongation, translocation, and
  termination with one highlighted ribosome.
- Codon matching hotspot: player selects a tRNA with a complementary anticodon
  for the displayed mRNA codon.
- A/P/E site hotspot: pauses elongation and highlights where incoming tRNA,
  peptidyl-tRNA, and exiting tRNA sit.
- Polyribosome hotspot: toggles multiple ribosomes on a single mRNA and shows
  several growing chains at different lengths.
- Free versus bound hotspot: asks the player to route proteins based on signal
  peptide presence: cytosolic protein remains free; secreted/membrane pathway
  docks to rough ER.
- Stop codon hotspot: shows release factor binding and subunit recycling instead
  of another tRNA arriving.

## Performance notes

- Keep ordinary ribosomes to 2 to 4 parts each: large subunit, small subunit,
  optional mRNA bit, optional chain bit.
- Use one higher-detail `RibosomeTeaching` instance for close-up interactions.
- Pool tRNA and amino acid bead objects for the translation minigame.
- For free ribosome fields, use clustered placement and level of detail: nearby
  ribosomes use simple subunit geometry; distant ones can be small dots or
  decals.
- Bound ribosomes on rough ER should be instanced from the same template and
  snapped to attachment markers supplied by the rough ER model.
- Avoid physics simulation for individual ribosomes; use anchored parts and
  scripted tweens.
- Keep polyribosome counts modest, such as 3 to 6 ribosomes per mRNA, so the
  concept remains readable and part counts stay controlled.

## Sources

- [OpenStax Biology 2e: Eukaryotic Cells](https://openstax.org/books/biology-2e/pages/4-3-eukaryotic-cells)
- [NCBI Bookshelf: From RNA to Protein](https://www.ncbi.nlm.nih.gov/books/NBK26829/)
- [NCBI Bookshelf: Eukaryotic Ribosome Assembly and Nucleocytoplasmic Transport](https://www.ncbi.nlm.nih.gov/books/NBK586897/)
- [Nature Education/Scitable: Ribosomes, Transcription, and Translation](https://www.nature.com/scitable/topicpage/ribosomes-transcription-and-translation-14120660/)
- [Khan Academy: Nucleus and Ribosomes](https://www.khanacademy.org/science/biology/structure-of-a-cell/prokaryotic-and-eukaryotic-cells/a/nucleus-and-ribosomes)
