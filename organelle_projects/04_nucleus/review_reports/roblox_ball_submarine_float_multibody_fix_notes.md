# Roblox Ball Submarine Float Multibody Fix

The ball was dropping because it is not a single rigid physical object. It has an exterior collision shell, glass/ring meshes, interior pieces, a seat, and constraints. The previous float pass only gave the main exterior part a reliable lift force, so the rest of the ball could still behave like dead weight.

This pass changes the float behavior to treat the ball as a small submarine assembly:

- Every physical ball part gets its own `MainCellSubmarineBuoyancy` `VectorForce`.
- Lift is calculated from the part's own mass, not from a shared assembly mass.
- A builder-owned `RunService.Heartbeat` keeps the forces updated in runtime without needing to write `Script.Source`.
- Optional generated script creation is guarded with `pcall` for plugin/edit contexts.
- Telemetry attributes on `Workspace.Ball` expose active body count, mass, and force.

Studio probe after deployment:

- `SubmarineFloatForceVersion`: `multi_part_v2`
- active float bodies: `7`
- total part mass: `3096.48`
- neutral gravity force: `130052.16`
- active upward force while below target: `273463.78`
- lift ratio: `2.10x`

Next recommended phase: replace the old rolling-ball package controls with submarine-style thrust controls if the ball should become a drivable vehicle. The old angular rolling controller remains disabled because it fights the floating behavior.
