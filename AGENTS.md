# AGENTS.md - Cell Blender to Roblox Project

You are working on a stylized-realistic eukaryotic animal cell model for
Blender and Roblox.

## Global Goal

Build organelles as separate Blender Python-generated assets that can later be
imported into Roblox as functional, animation-ready educational models.

## Current Production Focus

The active production target is the nucleus. Use part-level agents inside
`organelles/nucleus/parts/` instead of trying to build every organelle at once.

Other organelles may remain as exploratory work, but the quality bar should be
proven on the nucleus first.

## Non-Negotiable Visual Rule

Do not create geometric toy-like models.

Every organelle must look:

- organic
- biological
- layered
- textured
- rounded
- colorful but scientifically readable
- premium 3D educational infographic quality
- optimized enough for Roblox

Every biological component needs an organic finishing pass:

- bevels or rounded geometry
- procedural bump or displacement
- color variation
- asymmetry
- material response
- thickness where relevant
- camera-readable 3D detail

Reject default-looking primitives.

## Biological Rule

Every mesh must be designed around biological function. Do not create decorative
pieces unless they support:

- transport
- structure
- storage
- synthesis
- metabolism
- digestion
- movement
- cell cycle change
- interaction or teaching

## Workflow Rule

Work in phases.

Each phase must produce:

1. Updated Blender script.
2. Review renders.
3. JSON review report.
4. Pass/fail checklist.
5. Notes on what changed.
6. Next recommended phase.

Do not proceed to the next phase if the current phase fails visual, biological,
or Roblox-readiness criteria.

## Roblox Production Rule

Roblox import is a production phase, not a final manual cleanup step.

For every organelle that reaches Roblox:

- export meaningful biological subsystem groups
- prefer the logged-in Roblox Studio session for package upload/import when
  available; check Studio/Asset Manager/plugin upload routes before treating
  missing Open Cloud environment variables as a blocker
- upload each group as a package/model asset
- record package asset IDs in a manifest
- assemble visible clones under one scoped `Workspace.<Organelle>_Model`
- preserve raw packages under `Workspace.MeshLibrary`
- hide raw packages and stale duplicate imports
- apply deterministic scale, pivot, offsets, material fallbacks, and collision
  behavior
- validate edit mode and play mode separately

Do not mark an organelle Roblox-ready just because files uploaded. Done means
the grouped packages are visible, correctly placed, inspectable, and reproducible
from the assembly script.

## Roblox Scene Safety Rule

Golden source assets are read-only. Do not mutate, hide, recolor, rename, move,
scale, delete, or overwrite source art under `Workspace.MeshLibrary`, imported
Blender source folders, or an existing production model such as
`Workspace.Nucleus_Model` unless the user explicitly asks for that exact source
asset to be changed.

Classroom, camera, telemetry, and lesson experiments must use scoped clones
under a versioned runtime root such as `Workspace.CellClassroom_V6`. Runtime
scripts may modify only their own scoped clone and temporary runtime objects.

Before any Studio mutation, capture an audit of exact object paths, mesh counts,
visible counts, bounding boxes, scripts, and active play state. After mutation,
capture the same audit and compare it. Avoid broad name-matching mutations like
“all descendants containing nucleus”; use explicit whitelisted paths.

Do not save or publish after visual scene changes until the user explicitly
approves the verified result.

## Playability Rule

Player movement must be playable without a keyboard.

For cytoplasm swimming and any core navigation mode:

- support desktop keyboard/mouse
- support Android/iOS touch controls with on-screen movement and vertical
  controls
- support VR/gamepad controls with thumbsticks and controller buttons
- validate that controls are usable in play mode, not only that the scripts
  exist

Do not treat W/A/S/D as the only control path.

## Scale-Up Rule

Do not scale the multi-agent system to many organelles until one organelle has
passed the complete loop from Blender source through Roblox play-mode review.
For the next organelle, reuse the proven loop and keep the same evidence
requirements instead of improvising a new import process.

## Review Requirement

After building, run specialist review passes:

- visual organic quality
- biology accuracy
- animation functionality
- Roblox export readiness
- whole-cell integration

## Done Means

A task is not done until:

- the script runs
- review renders exist
- review reports exist
- major components use exact names from the manifest
- visual quality is organic and premium
- biology rules are respected
- Roblox export risks are listed
