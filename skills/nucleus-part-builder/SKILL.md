---
name: nucleus-part-builder
description: Build one nucleus part in organelles/nucleus/parts/<part_slug>/ only, producing part geometry evidence, review renders, and JSON reports without touching unrelated nucleus systems.
---

# Nucleus Part Builder

Use this skill when building one part of the nucleus.

## Boundaries

Work only in:

```text
organelles/nucleus/parts/[part_slug]/
```

Only touch `organelles/nucleus/build_nucleus.py` during an explicit integration
task.

## Read First

- `AGENTS.md`
- `organelles/nucleus/AGENTS.md`
- `organelles/nucleus/NUCLEUS_PIPELINE.md`
- `organelles/nucleus/component_manifest.json`
- `organelles/nucleus/parts/[part_slug]/AGENTS.md`
- `organelles/nucleus/parts/[part_slug]/brief.md`
- `organelles/nucleus/parts/[part_slug]/component_manifest.json`
- `shared/materials/organic_material_recipes.md`
- `shared/scripts/export_validation_helpers.py`

## Deliverables

- part build script or part asset source
- review renders
- `review_reports/phase_[X]_builder_report.json`
- created and incomplete component list
- biology misconceptions avoided
- export candidates and excluded review-only objects
- transform status and scene budget

## Roblox Handoff

Each nucleus part should be designed as a future export subsystem, even when the
current phase is still Blender-only. Report:

- proposed export group/package name
- pivot and socket expectation
- material fallback names for Roblox editability
- transparency intent and which pieces must stay opaque
- collision participation
- known risks for package import or Studio assembly

Do not assume Blender procedural materials, transparency, or collection pivots
will survive Roblox import without a Studio material/layout pass.

## Critical Biology Rules

- DNA never leaves the nucleus.
- Nuclear pores are not open holes.
- Nucleolus has no membrane.
- Lamina stays inside the envelope.
