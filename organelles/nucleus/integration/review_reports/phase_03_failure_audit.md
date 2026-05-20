# Phase 03 Failure Audit - Nucleus Visual Pipeline

Date: 2026-05-02

## Decision

Phase 03 is not a valid visual approval state.

The nucleus should be treated as blocked for further production until the
double-envelope system is rebuilt and reviewed against the baseline images in
Blender with an actual visual inspection loop.

## What Failed

The project principles were present in the repo, but they were not enforced by
the production loop.

The global rules say to reject geometric toy-like models and default-looking
primitives (`AGENTS.md:19-45`). The style rules explicitly reject plain spheres,
cylinders, toruses, and flat diagram translations (`STYLE_BIBLE.md:31-41`).
The reference-image rules require every visual review to compare the latest
render against the reference set (`REFERENCE_IMAGE_DESIGN_PRINCIPLES.md:55-86`).
The review protocol says blocking findings must be fixed before the next phase
(`REVIEW_PROTOCOL.md:55`).

Those rules were bypassed in practice.

## Root Causes

1. The failed Phase 02 visual gate was ignored.

   `phase_02_visual_validation_report.json` explicitly says:

   - `visual_pass: false`
   - `approved_for_phase_3_geometry: false`
   - score `74`
   - required fixes before continuing: improve envelope visual design, strengthen
     lamina, improve pore distribution, and prove the layer relationships

   Evidence:

   - `organelles/nucleus/integration/review_reports/phase_02_visual_validation_report.json:19-21`
   - `organelles/nucleus/integration/review_reports/phase_02_visual_validation_report.json:40-53`

   Phase 03 was created anyway.

2. Conflicting reports were allowed to override the visual failure.

   `phase_02_builder_report.json` marked visual quality as passing and
   recommended Phase 03, even while the independent visual validation report
   failed the phase.

   Evidence:

   - `organelles/nucleus/review_reports/phase_02_builder_report.json:272-314`
   - `organelles/nucleus/integration/review_reports/phase_02_roblox_design_review.json:1-8`
   - `organelles/nucleus/integration/review_reports/phase_02_roblox_design_review.json:105-108`

   The pipeline had no resolver rule saying visual failure beats builder
   optimism.

3. The Phase 03 similarity scores are not measured evidence.

   The report claims high similarity scores, but the scores are hard-coded in
   the generator script rather than produced by a reviewer, metric, or
   documented inspection.

   Evidence:

   - `tools/build_nucleus_phase3_visual_iteration.py:327-367`
   - `tools/build_nucleus_phase3_visual_iteration.py:339-346`
   - `organelles/nucleus/review_reports/phase_03_visual_iteration_report.json:16-23`

   This made the report look like validation even though no reliable validation
   happened.

4. Reference images were displayed, not used as production constraints.

   The Phase 03 script places three reference images into a Blender board, but
   the geometry generation does not derive forms, density, relationship checks,
   or pass/fail decisions from those images.

   Evidence:

   - `tools/build_nucleus_phase3_visual_iteration.py:269-292`
   - `tools/build_nucleus_phase3_visual_iteration.py:347-358`

   The iteration notes show camera and board-layout fixes, not model-quality
   iteration against the references.

5. The generated geometry violated the organic design rules.

   Critical biological components were still built from recognizable procedural
   primitives:

   - torus pore rings
   - UV sphere subunits
   - cylinder gate cores
   - latitude/meridian lamina curves
   - ellipsoid shell panels with minor sine/cosine perturbation

   Evidence:

   - `tools/build_nucleus_phase3_visual_iteration.py:96-150`
   - `tools/build_nucleus_phase3_visual_iteration.py:169-218`
   - `tools/build_nucleus_phase3_visual_iteration.py:221-251`

   These choices explain why the result reads as geometric and toy-like instead
   of organic.

6. The visual loop optimized board framing instead of the model.

   The Phase 03 iteration notes list five iterations, but all five are about
   label overlap, camera framing, axis layout, and moving panels. They do not
   describe changes to the envelope surface, pore anatomy, lamina structure, or
   material biology.

   Evidence:

   - `organelles/nucleus/review_reports/phase_03_visual_iteration_report.json:24-30`

7. The multi-agent structure did not enforce independence.

   The builder report contains its own specialist pass summary instead of
   requiring independent review outputs for Phase 02 and Phase 03. Part-level
   nucleus folders are initialized but not approved for integration, so the
   system looked decomposed while the actual production still operated as a
   broad single-script pass.

   Evidence:

   - `organelles/nucleus/review_reports/phase_02_builder_report.json:283-304`
   - `organelles/nucleus/parts/*/review_reports/latest_status.json`

## Why Blender Visual Inspection Did Not Happen Correctly

The pipeline generated Blender files and PNG renders, but it did not run a
disciplined live-inspection cycle:

- no hard stop after the failed visual validation
- no repeated model edits until the baseline resemblance passed
- no independent reviewer pass for Phase 03
- no required user-visible Blender checkpoint before declaring progress
- no evidence that the score came from inspection rather than from the script

The clean comparison board later made outside Blender is useful as a communication
artifact, but it is not a substitute for validating the actual Blender model in
the scene.

## Corrective Actions

1. Freeze the current Phase 02 and Phase 03 nucleus outputs as failed prototypes.
   Do not build chromatin, nucleoplasm, nucleolus, ER connection, cargo, or
   mitosis systems on top of this geometry.

2. Mark `phase_03_visual_iteration_report.json` as invalid approval evidence.
   It can remain as historical output, but it should not be used to authorize
   the next phase.

3. Restart at a single part: `organelles/nucleus/parts/double_envelope/`.
   Build only the double nuclear envelope and perinuclear lumen against
   `reference_images/nucleus_specs/01_nuclear_envelope.png`.

4. Use this mandatory visual gate before adding pores:

   - Blender scene opens with the reference image and 3D candidate visible as
     separate sections in the same scene.
   - At least three renders exist: wide board, envelope close-up, cutaway/lumen
     inspection.
   - Independent visual review marks organic 3D translation as pass.
   - No similarity score may be written unless the reviewer explains evidence.
   - If the render still looks like a smooth ellipsoid or primitive shell, it
     fails automatically.

5. Add a pipeline validator before any future phase advance:

   - fail if any current visual report has `visual_pass: false`
   - fail if any report says `approved_for_next_phase: false`
   - fail if builder self-review is the only approval source
   - fail if similarity scores are present without reviewer provenance
   - warn on final biological objects made directly from torus, cylinder, cube,
     or default sphere primitives

## Immediate Next Recommended Step

Do not continue Phase 03. The next production task should be:

`Phase 02R - Double Envelope Rebuild`

Scope:

- outer nuclear membrane only
- inner nuclear membrane only
- perinuclear lumen only
- organic cutaway rim
- no pores
- no lamina
- no chromatin
- no nucleolus

The goal is not to finish the nucleus. The goal is to prove that one nucleus
part can match the baseline quality in Blender before expanding the system.
