# Roblox Export Rules

## Naming

- Major components must use exact names from `component_manifest.json`.
- Exported object names should be stable and descriptive.
- Avoid generated random suffixes unless they are recorded in the manifest.

## Geometry

- Keep meshes watertight where possible.
- Apply transforms before export.
- Use sensible origins and pivots for animation.
- Split dense models into meaningful components rather than one opaque blob.
- Prefer reusable materials and shared texture recipes.
- Export logical biological subsystems as package groups, not as hundreds of
  unrelated MeshParts. Preserve internal names where useful, but make runtime
  code target stable group/package names.
- Record expected Roblox scale, pivot, group offset, and visibility behavior in
  the manifest or assembly report. Do not assume Roblox will preserve Blender
  package pivots correctly.

## Performance

- Track triangle counts, material count, texture count, and object count.
- Avoid dense invisible geometry.
- Use lower-detail export variants when repeated many times.
- Document any animation risks before Roblox import.

## Package Import

- Open Cloud or Blender plugin uploads of FBX/glTF models produce Roblox
  Model/package asset IDs, not reliable per-child `MeshId` outputs.
- Treat each export group as one package asset. Record `package_asset_id`,
  upload operation ID/path, owner/creator used, source file, object count,
  triangle count, material count, and import status.
- Keep raw imported packages under `Workspace.MeshLibrary/<organelle>_RawPackages`.
  Raw packages must be preserved for inspection and re-cloning, but all raw
  BaseParts must be transparent and non-colliding in normal review scenes.
- Visible gameplay models must be clones under a scoped model such as
  `Workspace.Nucleus_Model` or `Workspace.<Organelle>_Model`.
- Quarantine stale top-level `EXPORT_*` packages or old assembled group models
  into a hidden folder instead of leaving duplicates visible in `Workspace`.

## Materials

- Blender procedural materials are not accepted as final Roblox material truth.
  Each package needs an explicit Roblox material fallback.
- Prefer editable colors for production packages. Use opaque SmoothPlastic/Metal
  for most visible MeshParts; reserve transparency for biological structures that
  need it, such as lumen, gel volumes, glassy membranes, or hidden proxies.
- For components that users may recolor in Studio, ensure child MeshParts are
  not locked and are not fully transparent.
- Record material/transparency buckets during review so accidental all-transparent
  or all-one-color imports are caught.

## Studio Assembly

- Stop play mode before changing edit-time `Workspace`.
- Assembly scripts must be idempotent: rebuild the visible model, reuse or load
  raw packages, hide raw packages, quarantine duplicates, apply deterministic
  transforms/materials, and print validation facts.
- Validate edit mode first, then enter play mode and validate the player-camera
  view separately.
- Store assembly pass metadata as attributes on the assembled model and groups:
  layout pass name, material pass name, package asset ID, tuned scale, tuned
  position, and known caveats.

## Review

Every export must include a JSON report listing:

- exported files
- component names
- missing manifest components
- estimated Roblox risks
- manual setup notes

Every Studio import/assembly review must also list:

- raw package count and visible raw part count
- top-level duplicate package/model count
- assembled child count and expected group names
- bounds/center/size for each group
- material and transparency buckets for each group
- edit-mode and play-mode screenshot paths
