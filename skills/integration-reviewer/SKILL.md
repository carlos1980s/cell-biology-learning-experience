---
name: integration-reviewer
description: Assemble approved organelle production units into one cohesive animal-cell model by checking manifests, review status, sockets, scale, materials, spatial conflicts, shared animation logic, and whole-cell review evidence.
---

# Whole Cell Integration Agent

Use this skill when bringing reviewed organelles together into the full animal
cell assembly.

## Read First

- `AGENTS.md`
- `integration/whole_cell_manifest.json`
- `integration/socket_map.json`
- `integration/scale_map.json`
- all `organelles/*/component_manifest.json`
- all `organelles/*/review_reports/latest_status.json`

## Job

1. Assemble approved organelles into one cohesive animal cell model.
2. Align organelles to sockets.
3. Ensure scale consistency.
4. Ensure materials are visually consistent.
5. Ensure no two organelles conflict spatially.
6. Ensure shared animations make sense.
7. Verify Roblox package assemblies are reproducible and clean.
8. Produce whole-cell review renders.
9. Write integration review report.

## Boundaries

Do not modify organelle internals unless required for integration.

If an organelle has no `latest_status.json`, or if its status is not approved,
do not integrate it as production-ready. Record it as blocked or pending.

If an organelle has no Roblox import/assembly report, do not mark it as
Roblox-ready. Record it as pending even if the Blender model looks approved.

Roblox assembly acceptance requires:

- raw packages hidden under `Workspace.MeshLibrary`
- no top-level duplicate `EXPORT_*` or organelle group models
- visible scoped model under `Workspace.<Organelle>_Model`
- deterministic scale, pivot, offsets, and collision behavior
- material/transparency bucket evidence
- edit-mode and play-mode screenshots

## Integration Report Shape

Write reports under:

```text
integration/review_reports/
```

Use this shape:

```json
{
  "integration_pass": false,
  "approved_organelles": [],
  "blocked_organelles": [],
  "socket_alignment_findings": [],
  "scale_findings": [],
  "material_consistency_findings": [],
  "roblox_package_assembly_findings": [],
  "edit_play_mode_findings": [],
  "spatial_conflict_findings": [],
  "animation_findings": [],
  "whole_cell_review_renders": [],
  "required_fixes": [],
  "approved_to_continue": false
}
```
