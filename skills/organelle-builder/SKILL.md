---
name: organelle-builder
description: Build one Blender organelle production phase inside a single organelles/<slug>/ folder, updating only that organelle's build script, review renders, and builder report while respecting global and local biological/visual rules.
---

# Organelle Builder

Use this skill when acting as a Builder Agent for one organelle.

## Boundaries

Work only in:

```text
organelles/[organelle_slug]/
```

Do not modify other organelle folders or integration files unless the user
explicitly asks.

## Read First

- `AGENTS.md`
- `organelles/[organelle_slug]/AGENTS.md`
- `organelles/[organelle_slug]/brief.md`
- `organelles/[organelle_slug]/component_manifest.json`
- `organelles/[organelle_slug]/visual_addendum.md`
- `shared/materials/organic_material_recipes.md`
- `shared/review_checklists/visual_quality_checklist.csv`
- `shared/review_checklists/roblox_export_checklist.csv`

## Task

Build Phase `[X]` only.

## Deliverables

1. Update `build_[organelle_slug].py`.
2. Generate or update review renders in `review_renders/`.
3. Write `review_reports/phase_[X]_builder_report.json`.
4. List which manifest components were created.
5. List which components remain incomplete.
6. Do not continue to the next phase.

For Roblox-facing phases, also deliver:

1. Export groups that match meaningful biological subsystems.
2. A Roblox asset manifest with source files, object counts, triangle counts,
   material names, package asset IDs when available, and placement targets.
3. A Studio assembly script or organelle-specific assembler entrypoint.
4. Edit-mode and play-mode validation evidence after import.
5. Notes on material fallbacks, transparency risks, collision proxies, and
   selectable/editable child MeshParts.

## Critical Rule

Do not create geometric placeholder-looking biology. Every visible biological
component must have organic material treatment: rounded form, asymmetry,
surface variation, and biologically meaningful detail.

## Builder Report Shape

```json
{
  "organelle": "nucleus",
  "phase": 1,
  "script_updated": "organelles/nucleus/build_nucleus.py",
  "review_renders": [],
  "manifest_components_created": [],
  "manifest_components_incomplete": [],
  "organic_treatment_applied": [],
  "roblox_export_risks": [],
  "roblox_package_groups": [],
  "roblox_package_manifest": "",
  "studio_assembly_script": "",
  "edit_mode_validation": "",
  "play_mode_validation": "",
  "notes": "",
  "next_recommended_phase": ""
}
```

## Roblox Build Constraints

- Do not rely on Blender procedural materials to survive Roblox import.
- Keep most visible child MeshParts opaque and editable unless transparency is
  biologically required.
- Preserve raw imported packages but never leave them visible in the review
  scene.
- Treat package/model asset IDs as group-level IDs, not individual `MeshId`s.
- Do not call a Roblox import done until the assembled model is visible and
  correctly scaled in play mode.
