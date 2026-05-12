# Organelle Scale-Up Process Changes

These changes come from the Phase 07R nucleus Blender-to-Roblox import cycle.
Use them before starting the next production organelle.

For the full phase diagram, validation gates, and fallback flow, see
`docs/ORGANELLE_PRODUCTION_PROCESS_FLOW.md`.

## What Failed

- Upload success was mistaken for production readiness.
- Roblox package uploads returned model/package asset IDs, not stable child
  `MeshId` references.
- Raw imported packages and assembled clones were visible at the same time,
  making the scene look scattered.
- Edit-time Workspace and Play/Test Workspace diverged during validation.
- Blender material intent collapsed into coarse Roblox materials, causing
  excessive transparency and poor color editability.
- Group placement relied on imported pivots instead of a deterministic assembly
  pass.

## New Required Loop

1. Build and review the Blender source organelle.
2. Export logical biological subsystem groups.
3. Upload each group as one Roblox package/model asset.
4. Record package asset IDs in the organelle export manifest.
5. Stop Play/Test mode before editing Studio assembly.
6. Run a rerunnable Studio assembler.
7. Preserve raw packages under `Workspace.MeshLibrary` and hide them.
8. Build only one visible scoped model under `Workspace.<Organelle>_Model`.
9. Apply deterministic scale, pivot, offsets, materials, collision behavior, and
   hidden anchor behavior.
10. Validate edit mode.
11. Validate play mode from the player camera.
12. Write a JSON QA report with screenshots and measurement buckets.

## Scale-Up Gate

The next organelle is not production-ready until it has:

- complete export manifest
- package IDs
- hidden raw package library
- visible scoped assembled model
- no top-level duplicate packages or stale assembled groups
- deterministic layout/material assembly script
- edit-mode validation
- play-mode screenshot
- bounds, material bucket, and transparency bucket report

Use the nucleus Phase 07R import as the reference pattern, but do not copy its
manual offsets blindly. Each organelle needs its own tuned assembly pass.

## Next Organelle Recommendation

Start only one next organelle in production. Recommended order:

1. mitochondrion
2. rough ER
3. Golgi
4. lysosome

Mitochondrion is the best next candidate because it has a clear bounded shape,
strong biological function, and fewer transparent nested layers than the
nucleus. This makes it a good test for whether the improved Roblox package
pipeline scales.
