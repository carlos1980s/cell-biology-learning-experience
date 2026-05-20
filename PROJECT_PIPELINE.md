# Project Pipeline

This pipeline now treats one organelle as the production unit and uses
part-level agents inside that organelle. The current hero production target is
`organelles/nucleus`.

The reviewable process diagram is in
`docs/ORGANELLE_PRODUCTION_PROCESS_FLOW.md`.

The previous broad multi-organelle pass remains useful as exploratory work, but
it is not the quality path. Do not advance all organelles in parallel until the
nucleus pipeline proves the standard.

## Current Production Target

```text
organelles/nucleus/
+-- NUCLEUS_PIPELINE.md
+-- PART_AGENT_TEMPLATE.md
+-- parts/
|   +-- double_envelope/
|   +-- perinuclear_lumen/
|   +-- nuclear_pores/
|   +-- pore_gate_cores/
|   +-- nuclear_lamina/
|   +-- nucleoplasm/
|   +-- chromatin/
|   +-- nucleolus/
|   +-- transport_cargo/
|   +-- rough_er_connection/
|   +-- mitosis_fragments/
|   +-- interaction_hotspots/
+-- integration/
```

Nucleus part agents work in one `parts/<part_slug>/` folder only. The nucleus
integration pass then assembles approved parts into `build_nucleus.py` and the
full nucleus `.blend`.

## Phases

1. Brief and manifest
   - Confirm the nucleus part's biological function, required components, and
     exact component names.
   - Update the part `brief.md`, `component_manifest.json`, and local
     `AGENTS.md`.

2. Blender build
   - Implement or revise `build_<organelle>.py`.
   - Generate meshes with rounded, organic, asymmetric, textured detail.
   - Avoid default primitives unless they receive a clear finishing pass.

3. Review renders
   - Render at least one wide view, one close component view, and one export
     inspection view.
   - Save renders under `review_renders/`.

4. Specialist review
   - Run visual quality, biology accuracy, animation function, and Roblox export
     checks.
   - Save JSON reports under `review_reports/`.

5. Revision gate
   - Fix all blocking findings before proceeding.
   - Record pass/fail checklist results and next recommended phase.

6. Export
   - Export Roblox-ready assets under `exports/`.
   - Record export risks and any manual Roblox setup required.

7. Roblox package import and assembly
   - Upload only approved export groups as Roblox package/model assets.
   - Record package asset IDs in the export manifest; do not rely on memory,
     Toolbox names, or screenshots as the source of truth.
   - In Studio, keep raw imported packages under `Workspace.MeshLibrary` and
     make them invisible/non-colliding. Only clones under the assembled model
     should be visible.
   - Validate edit mode and play mode separately. Stop play mode before
     changing the edit-time assembly, then re-enter play mode for final visual
     acceptance.
   - Add an explicit assembly pass for each organelle: scale, pivot, group
     offsets, material fallbacks, hidden collision proxies, and inspectable
     anchors must be deterministic and rerunnable.

8. Whole-cell integration
   - For the nucleus, first update `organelles/nucleus/integration/` manifests,
     socket maps, scale maps, and review reports.
   - Update whole-cell integration only after the nucleus passes as a complete
     organelle.
   - Produce final integration renders and reports.

## Scale-Up Rule

Do not start the next organelle as production work until the current organelle
has passed the full Blender-to-Roblox loop:

- Blender source scene exists and passes visual/biology review.
- Export groups exist and match the manifest.
- Roblox package asset IDs are recorded.
- Studio assembly is reproducible from scripts.
- Raw imports are preserved but hidden.
- Visible assembly works in edit mode and play mode.
- A QA report records bounds, material/transparency buckets, screenshots, and
  remaining risks.

The next organelle may reuse the pipeline only after this evidence exists.
Otherwise it remains exploratory.

## Required Evidence

Every completed phase must leave:

- updated script path
- render paths
- review report paths
- checklist path
- change notes
- next recommended phase

Every completed Roblox import/assembly phase must also leave:

- package asset IDs
- Studio assembly script path
- edit-mode validation output
- play-mode screenshot
- material/transparency bucket summary
- duplicate/raw-import visibility check
