# Nucleus Production Pipeline

The nucleus is now the hero production unit. Do not run the full multi-organelle
pipeline until this nucleus reaches the quality bar.

## Strategy

Build the nucleus through part-level specialist agents. Each part agent owns a
small biological structure, produces review evidence, and hands off to the
nucleus integration pass.

The goal is one excellent nucleus, not five acceptable organelles.

## Reference Image Baseline

Nucleus visual reviews must use available reference images as baselines. The
references define recognizability, color language, layer relationships, and
quality bar. They do not define flat geometry to trace.

Read:

- `REFERENCE_IMAGE_DESIGN_PRINCIPLES.md`
- `reference_images/reference_manifest.json`

If reference images are missing, reviewers must record that limitation and still
judge against the written visual rules in `AGENTS.md` and `visual_addendum.md`.

## Part Order

1. `double_envelope`
   - outer nuclear membrane panels
   - inner nuclear membrane panels
   - visible thickness and organic purple shell language
2. `perinuclear_lumen`
   - glowing structured gap between membranes
   - segmented, not a flat uniform band
3. `nuclear_pores`
   - raised violet nuclear pore complexes
   - distributed across the envelope with organic spacing
4. `pore_gate_cores`
   - selective gate cores inside pores
   - must prevent the visual misconception that pores are open holes
5. `nuclear_lamina`
   - gold lattice inside the inner envelope
   - must not appear outside the nuclear envelope
6. `nucleoplasm`
   - transparent blue interior volume
   - must preserve readability of chromatin and nucleolus
7. `chromatin`
   - tangled magenta/cyan chromatin threads
   - condensed chromosomes as separate later-state structures
8. `nucleolus`
   - dense bumpy dark-violet subregions
   - no surrounding membrane
9. `transport_cargo`
   - RNA export and protein import cues
   - DNA must never appear to leave the nucleus
10. `rough_er_connection`
    - folded rough ER connection outside envelope
    - must read as adjacent endomembrane continuity, not nuclear interior
11. `mitosis_fragments`
    - envelope breakdown/reassembly fragments
    - future state layer, not part of the default intact nucleus
12. `interaction_hotspots`
    - teaching anchors and inspection points

## Phase Gates

Each part must produce:

- `parts/<part_slug>/brief.md`
- `parts/<part_slug>/AGENTS.md`
- `parts/<part_slug>/component_manifest.json`
- `parts/<part_slug>/review_reports/latest_status.json`
- one or more review renders when geometry exists
- a JSON builder report for the phase

The nucleus integration pass must then update:

- `integration/nucleus_assembly_manifest.json`
- `integration/socket_map.json`
- `integration/scale_map.json`
- `integration/review_reports/`

## Phase 3 Target

The next build phase should focus only on the nucleus envelope system:

- improve `OuterNuclearMembrane_Panels`
- improve `InnerNuclearMembrane_Panels`
- improve `PerinuclearLumen_Segments`
- improve `NuclearPore_Complexes`
- improve `NuclearPore_GateCores`
- improve `NuclearLamina_Lattice`

Do not add chromatin, nucleolus, transport cargo, rough ER connection, mitosis
fragments, or hotspots until the envelope system passes review.
