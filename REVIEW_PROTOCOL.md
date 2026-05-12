# Review Protocol

## Required Review Passes

Every organelle production unit requires:

- visual organic quality review
- biology accuracy review
- animation functionality review
- Roblox export readiness review
- whole-cell integration review

Visual reviews should use available reference images as baselines. If reference
images are missing, the report must say so and treat the review as limited. See
`REFERENCE_IMAGE_DESIGN_PRINCIPLES.md`.

## Decision Values

Use one of:

- `approved`
- `approved_with_notes`
- `changes_required`
- `blocked`

## JSON Report Shape

```json
{
  "reviewer": "visual_quality",
  "decision": "changes_required",
  "reference_images_used": [],
  "reference_alignment": {
    "silhouette": "pass/fail",
    "color_language": "pass/fail",
    "component_relationships": "pass/fail",
    "organic_3d_translation": "pass/fail",
    "biology_conflicts": []
  },
  "findings": [
    {
      "severity": "blocking",
      "component": "outer_membrane",
      "issue": "The mesh reads as a plain sphere.",
      "required_fix": "Add organic thickness, asymmetric contour, material variation, and membrane detail.",
      "evidence": "review_renders/phase_01_wide.png"
    }
  ],
  "passed_checks": [],
  "open_questions": [],
  "next_recommended_phase": "Revise Blender script and rerender."
}
```

Blocking findings must be fixed before the next phase.

## Roblox Import Review

For any organelle that reaches Roblox, run a separate Roblox import/assembly
review. A Blender render is not enough.

Required checks:

- Studio is in edit mode before assembly changes are made.
- All expected package asset IDs are present in the export manifest.
- Raw packages exist under `Workspace.MeshLibrary` and have zero visible
  BaseParts during normal review.
- No top-level `EXPORT_*` models or stale assembled group duplicates remain in
  `Workspace`.
- The visible assembled model has every expected group.
- Group bounds, scale, placement, material buckets, and transparency buckets are
  recorded.
- Edit-mode and play-mode screenshots exist.
- Play-mode view is inspected from the player camera, not only through script
  counts.
- User-editable components have selectable child MeshParts with non-hidden,
  non-locked colors/materials.

Use this additional report shape:

```json
{
  "reviewer": "roblox_import_assembly",
  "decision": "changes_required",
  "studio_mode_before_changes": "stop",
  "package_asset_ids_present": true,
  "raw_package_container": "Workspace.MeshLibrary/Organelle_RawPackages",
  "visible_raw_part_count": 0,
  "top_level_duplicate_count": 0,
  "assembled_model": "Workspace.Organelle_Model",
  "expected_groups_present": [],
  "group_bounds": {},
  "material_buckets": {},
  "transparency_buckets": {},
  "edit_mode_screenshot": "",
  "play_mode_screenshot": "",
  "findings": [],
  "required_fixes": [],
  "approved_to_continue": false
}
```

The import review cannot pass if the scene only works in play mode or only works
in edit mode. Both must be validated because Roblox Studio keeps separate state
for edit-time Workspace and running test sessions.
