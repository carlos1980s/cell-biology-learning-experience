---
name: roblox-import-assembly
description: Drive the Blender-to-Roblox package import, Studio assembly, material fallback, edit/play validation, and QA report loop for one organelle.
---

# Roblox Import Assembly

Use this skill when an organelle has approved Blender export groups and needs to
be uploaded, assembled, inspected, or repaired in Roblox Studio.

## Read First

- `AGENTS.md`
- `ROBLOX_EXPORT_RULES.md`
- `REVIEW_PROTOCOL.md`
- `docs/ROBLOX_MCP.md`
- `organelles/[organelle_slug]/exports/*manifest*.json`
- organelle-specific Roblox import README or assembly script, if present

## Workflow

1. Confirm all expected export groups exist.
2. Prefer the logged-in Roblox Studio session for uploads/imports. Check
   Studio, Asset Manager, and plugin-driven upload/import routes before falling
   back to Open Cloud environment variables.
3. If Studio cannot upload the files programmatically, use Open Cloud only as
   the automation fallback and record the credential blocker clearly.
4. Confirm package asset IDs are recorded before assembly.
5. Stop Play/Test mode before editing the Studio scene.
6. Probe automation:
   - try the official MCP once if available
   - use `tools/roblox_plugin_bridge.py` if the official MCP times out
   - if port `44755` is held by `rbx-studio-mcp --stdio`, kill only that helper
     and retry the legacy bridge
7. Run the organelle Studio assembler.
8. Preserve raw packages under `Workspace.MeshLibrary/<Organelle>_RawPackages`.
9. Hide raw packages and stale duplicates; do not delete them unless explicitly
   requested.
10. Build the visible model under `Workspace.<Organelle>_Model`.
11. Apply deterministic layout:
   - final model scale
   - model pivot
   - per-group offsets
   - per-group scale overrides
   - collision proxy visibility
   - anchor socket visibility
12. Apply Roblox material fallbacks:
   - mostly opaque, editable MeshParts by default
   - limited transparency only where biology requires it
   - group-specific color/material passes for functionally different subparts
13. Validate edit mode, then enter play mode and validate the player-camera
    view.

## Required Checks

- No top-level `EXPORT_*` models remain visible in `Workspace`.
- No stale top-level organelle group models remain outside the scoped model.
- `Workspace.MeshLibrary` has zero visible raw BaseParts.
- `Workspace.<Organelle>_Model` contains every expected group.
- Child MeshParts that users may recolor are not locked and not fully
  transparent.
- Bounds, material buckets, transparency buckets, package IDs, and screenshot
  paths are written to a JSON report.

## Report Shape

```json
{
  "reviewer": "roblox_import_assembly",
  "decision": "approved_with_notes",
  "organelle": "nucleus",
  "assembled_model": "Workspace.Nucleus_Model",
  "raw_package_container": "Workspace.MeshLibrary/Nucleus_RawPackages",
  "package_asset_ids_present": true,
  "top_level_duplicate_count": 0,
  "visible_raw_part_count": 0,
  "expected_groups_present": [],
  "group_bounds": {},
  "material_buckets": {},
  "transparency_buckets": {},
  "edit_mode_screenshot": "",
  "play_mode_screenshot": "",
  "required_fixes": [],
  "approved_to_continue": true
}
```

## Failure Rules

Do not approve if:

- only Blender renders were reviewed
- only upload succeeded but Studio assembly was not validated
- only play mode works while edit-time Workspace is missing the model
- raw packages or stale duplicates are visible in Workspace
- transparent defaults prevent practical Studio recoloring
- group placement is tuned manually but not recorded in a rerunnable script
