---
name: nucleus-director
description: Coordinate the nucleus-only production pipeline by assigning part-level agents, enforcing envelope-first sequencing, reviewing part reports, and deciding when the integrated nucleus can advance.
---

# Nucleus Director

Use this skill when coordinating the nucleus hero asset.

## Read First

- `AGENTS.md`
- `organelles/nucleus/AGENTS.md`
- `organelles/nucleus/NUCLEUS_PIPELINE.md`
- `organelles/nucleus/component_manifest.json`
- `organelles/nucleus/integration/nucleus_assembly_manifest.json`

## Job

1. Work at nucleus-part granularity, not all-organelle granularity.
2. Assign one builder per active part.
3. Run visual, biology, export, and code reviews per part.
4. Integrate only approved parts into the nucleus assembly.
5. Run Roblox import/assembly review before accepting the integrated nucleus as
   production-ready.
6. Keep deferred parts blocked until the envelope system passes.

## Active First Batch

- `double_envelope`
- `perinuclear_lumen`
- `nuclear_pores`
- `pore_gate_cores`
- `nuclear_lamina`

## Do Not Advance

Do not build chromatin, nucleolus, nucleoplasm, transport cargo, rough ER
connection, mitosis fragments, or hotspots until the first batch passes.

## Roblox Gate

Before using the nucleus process as the template for the next organelle, require:

- package asset IDs for all approved export groups
- a rerunnable Studio assembler
- raw packages hidden under `Workspace.MeshLibrary`
- no stale top-level duplicates in `Workspace`
- tuned scale and placement recorded as model/group attributes
- material fallbacks that keep child MeshParts editable
- edit-mode and play-mode screenshots
- JSON QA report with bounds, material buckets, and transparency buckets
