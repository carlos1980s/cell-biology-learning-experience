# Roblox Scene Safety Runbook

This project treats Blender imports, raw packages, and production organelle
models as source assets. Lesson runtimes must work on scoped clones only.

## Non-Negotiables

- Never mutate `Workspace.MeshLibrary`, imported Blender source folders, or
  existing production models such as `Workspace.Nucleus_Model` during classroom
  iteration.
- Build test experiences under a versioned root, for example
  `Workspace.CellClassroom_V6`.
- Use exact whitelisted paths for every mutation. Do not run broad operations
  such as hiding all objects whose names contain `nucleus`.
- Do not save or publish after visual mutations until the user approves the
  verified result.

## Required Audit Before Mutation

Capture and record:

- Studio mode: edit, play, or run-server.
- Existing classroom roots and scripts.
- Source asset paths and visible/total BasePart counts.
- MeshPart counts and model bounding boxes.
- Active runtime roots and remotes.
- Console errors that may affect movement, camera, or object visibility.

## Required Audit After Mutation

Verify:

- Only the intended scoped runtime changed.
- Source asset counts and bounding boxes are unchanged.
- Runtime clone has nonzero MeshParts and expected group names.
- Play mode telemetry emits JSON samples.
- Duplicate/source models are not visible to the player unless intentionally
  included.
- No save or publish has occurred without approval.

## V6 Policy

`CellClassroom_V6` owns:

- `Workspace.CellClassroom_V6.ActiveScene`
- `Workspace.CellClassroom_V6.ActiveScene.Nucleus_TeachingClone`
- `Workspace.CellClassroom_V6.ActiveScene.DrRiviera_Teacher`
- `Workspace.CellClassroom_V6.Telemetry`
- `ReplicatedStorage.CellClassroomV6Remotes`
- `ServerScriptService.CellClassroomV6Controller`
- `StarterPlayer.StarterPlayerScripts.CellClassroomV6Client`

Anything outside these paths is read-only unless the user explicitly approves a
separate source-asset operation.
