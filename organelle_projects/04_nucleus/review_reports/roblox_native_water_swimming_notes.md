# Native Water Swimming Pass

This pass removes the custom player swim physics from the main cell experience so the avatar can rely on Roblox's native water swimming. The old direct-dive/cytoplasm controller is no longer installed by `BuildMainCellExperience.build()`.

What changed:

- `CellEnvironment_Main.MovementMode` is now `NativeWaterSwimming`.
- `MainCellPlayerCustomPhysicsEnabled` is set to `false`.
- `Workspace.Gravity` is restored to `196.2`.
- Existing player artifacts are cleaned up:
  - `MainCellCytoplasmBuoyancy`
  - `MainCellSwimVelocity`
  - `MainCellSwimOrientation`
  - `MainCellSwimAttachment`
  - `CytoplasmBuoyancy`
  - `CytoplasmVelocity`
  - `CytoplasmOrientation`
  - custom touch swim GUIs
- The old player control LocalScripts are removed from `StarterPlayerScripts` and active `PlayerScripts`.

Studio result:

- Build ran and returned `CellEnvironment_Main`.
- Movement mode probe returned `NativeWaterSwimming`.
- Player custom physics probe returned no active custom player scripts or forces.

Important note for the nucleus water test:

`Workspace.Nucleus_Model` is currently fully anchored and non-colliding: `12` anchored parts, `0` unanchored parts, `0` collidable parts. That means it will stay fixed in the water and will not show true float/sink behavior yet. To test nucleus floatability, the next pass should convert the visual nucleus into a welded unanchored assembly or add a single invisible physical proxy that carries the nucleus.
