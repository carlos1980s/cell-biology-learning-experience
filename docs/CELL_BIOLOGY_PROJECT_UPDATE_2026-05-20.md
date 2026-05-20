# Cell Biology Project Update - 2026-05-20

## Summary

The cell biology learning experience is now organized around a nucleus-first
production loop. The repo should prove one complete Blender-to-Roblox organelle
pipeline before scaling to additional organelles.

The current playable classroom source of truth is **Cell Classroom V3**. Restore
it with:

```bash
python3 tools/restore_cell_classroom_v3.py --install --timeout 360
```

## Current Production Focus

- Active organelle: nucleus.
- Active production workspace: `organelles/nucleus/`.
- Required model root: `Nucleus_RootRig`.
- Required component names are tracked in
  `organelles/nucleus/component_manifest.json`.
- Part-level work is split under `organelles/nucleus/parts/`.
- Integration evidence is tracked under `organelles/nucleus/integration/`.

## Latest Nucleus Status

Latest recorded phase: **08R**.

Status: `exported_dry_run_validated_upload_blocked`.

The Phase 08R gene-dynamics export packages exist and passed dry-run export
checks, but the nucleus is not approved for the next phase yet. Real Roblox
upload, Studio assembly, and play-mode validation are still blocked because
package asset IDs are missing.

Remaining blockers:

- `ROBLOX_OPEN_CLOUD_API_KEY` is not present in the shell environment.
- `ROBLOX_GROUP_ID` is not present in the shell environment.
- Phase 08R package asset IDs have not been recorded in the manifest.
- Studio assembly and play-mode validation cannot be accepted until uploaded
  packages are visible, scoped, inspectable, and reproducible from the assembly
  script.

## Repo Update Included

This update adds GitHub-ready tracking material for the cell biology project:

- root production rules and review constraints
- nucleus-first project pipeline docs
- nucleus component manifests and part-agent briefs
- text review reports for visual, biology, animation, Roblox export, and
  integration checks
- recoverable classroom baseline documentation
- Roblox scene safety and scale-up process notes

Large generated binary assets remain local unless deliberately selected for a
release or asset-storage workflow.

## GitHub Project Cards

Use these as initial GitHub Project items:

1. Upload Phase 08R nucleus gene-dynamics packages to Roblox.
2. Record package asset IDs in
   `organelles/nucleus/exports/nucleus_phase_08r_roblox_asset_manifest.json`.
3. Assemble Phase 08R packages in Studio under the approved scoped model root.
4. Run edit-mode and play-mode Studio validation separately.
5. Capture final Phase 08R QA report with bounds, visibility, materials,
   collision behavior, and runtime interaction status.
6. Decide whether Phase 08R supersedes the current V3 classroom baseline.
7. Create a new named recovery bundle before continuing beyond V3.
8. Only after nucleus passes the complete loop, select the next production
   organelle.

## Pass/Fail Gate

Current gate result: **fail, blocked by Roblox upload and Studio validation**.

Do not scale production to additional organelles until the nucleus has:

- approved Blender source and review renders
- matching export groups and manifests
- Roblox package IDs
- hidden raw packages under `Workspace.MeshLibrary`
- one visible scoped assembled model
- deterministic assembly script
- edit-mode validation
- play-mode validation
- final QA report

## Next Recommended Phase

Set the required Roblox upload environment, upload Phase 08R packages, record
the asset IDs, assemble the scoped Studio model, and run the separate edit-mode
and play-mode validations. If the result supersedes V3, create a new recovery
bundle before further classroom changes.
