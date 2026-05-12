# AGENTS.md - Nucleus

You are working only on the animal eukaryotic nucleus.

## Production Granularity

The nucleus is built by part-level agents under `organelles/nucleus/parts/`.
Do not assign one agent to build the entire nucleus unless the task is the final
nucleus integration pass.

Active first-pass parts:

- `double_envelope`
- `perinuclear_lumen`
- `nuclear_pores`
- `pore_gate_cores`
- `nuclear_lamina`

Deferred parts:

- `nucleoplasm`
- `chromatin`
- `nucleolus`
- `transport_cargo`
- `rough_er_connection`
- `mitosis_fragments`
- `interaction_hotspots`

## Functional Target

The nucleus must support:

- DNA storage
- chromatin organization
- transcription
- RNA export
- protein import
- nucleolus/ribosomal subunit production
- double nuclear envelope structure
- nuclear pore selectivity
- nuclear lamina support
- nuclear envelope breakdown and reassembly during mitosis

## Required Major Systems

Create these as separate Blender object groups:

- whole-cell context socket
- `Nucleus_RootRig`
- outer nuclear membrane panels
- inner nuclear membrane panels
- perinuclear lumen segments
- nuclear pore complexes
- nuclear pore gate cores
- nuclear lamina lattice
- nucleoplasm volume
- chromatin threads
- condensed chromosomes
- nucleolus subregions
- transport cargo
- rough ER connection
- mitosis fragments
- interaction hotspots

## Non-Negotiable Look

The nucleus must visually match the reference images:

- thick purple double membrane
- raised violet pore complexes
- glowing perinuclear lumen
- gold lamina mesh
- transparent blue nucleoplasm
- tangled magenta/cyan chromatin
- dense bumpy dark-violet nucleolus
- folded rough ER connection

Reject if it looks like a smooth purple ball or clean geometry.

## Biology Failure Cases

Reject the build if it implies:

- DNA leaving the nucleus
- nuclear pores as simple open holes with no selective gate structure
- nucleolus surrounded by a membrane
- a single nuclear membrane instead of a double nuclear envelope
- lamina outside the nuclear envelope
