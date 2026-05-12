# Roblox Open Scene V1 Water Notes

This pass treats the currently open Studio scene as the V1 baseline. It does not run the full importer and does not replace the existing organelle assembly.

The live tool selected `Workspace.CellEnvironment_Main` as the main object and measured its bounds from `2114` parts. Terrain was cleared and replaced with one deterministic water volume centered on that object:

- Center: `81.064, 211.358, 11.337`
- Size: `680.000, 520.000, 920.000`

The first V1 pass found a spawn conflict: `Workspace.CellEnvironment_Main.MainCellSwimSpawn` was still enabled and sat outside the original water edge. The current V1 pass disables all previous `SpawnLocation` objects and creates one authoritative hidden spawn:

- Enabled spawn: `Workspace.V1_WaterSpawn`
- Spawn position: `-18.040, 240.793, 70.504`
- Disabled spawns: `Workspace.CellEnvironment_Main.MainCellSwimSpawn`, `Workspace.SpawnLocation`
- Spawn water checks: center `Water=8`, plus4 `Water=8`, plus8 `Water=8`

The current pass also installs `ServerScriptService.V1WaterSpawnController`. That server script listens for `CharacterAdded` and pivots each character to `Workspace.V1_WaterSpawn` with a small upward lift. This avoids Roblox choosing an old spawn/checkpoint or keeping a character that was already created before the V1 spawn was corrected.

The V1 spawn is now nucleus-relative. It is positioned near `Workspace.Nucleus_Model`, about `273.310` studs from the nucleus center horizontally, which is approximately `95` studs outside the broad nucleus surface. Live bridge samples confirmed the new spawn point, plus `4` and `8` studs above it, are all water.

The previous vibration/drift layer has been reverted. `StarterPlayer.StarterPlayerScripts.V1OrganicMotionController` is disabled, and `ServerScriptService.V1OrganicMotionServerController` is removed.

The scene now uses `ServerScriptService.V1BriefOrganicPulseController`. In Play mode, it stores each organelle model's base pivot and applies a brief oscillation around that exact 3D point, using independent X/Y/Z offsets and tiny rotations. There is no slow drift and no accumulated displacement, so every object continuously returns to its home point.

The pulse profile is now `VisibleBriefPulseV3`. It is stronger than the earlier profile because the first amplitudes were too small for the whole-cell scale. A live bridge probe moved `Workspace.CellEnvironment_Main.ImportedOrganelles.VesiclesEndosomes.VesiclesEndosomes` by `8.2106` studs during an active pulse, proving the motion logic is capable of moving the model when code is running.

The current motion profile is `VisibleBriefPulseV4_BoundedDrift`. It keeps the brief pulse, then adds a slow bounded drift around each organelle's home pivot. The drift is leashed to the nucleus: every organelle stores `V1OrganicMaxNucleusDistance`, and `clampAroundNucleus` prevents the model from exceeding its starting distance from `Workspace.Nucleus_Model` plus a small slack.

The scene is marked in Workspace:

- `SceneVersion = V1`
- `SceneVersionLabel = OpenScene_Water_V1`
- `V1WaterCenter = 81.064, 211.358, 11.337`
- `V1WaterSize = 680.000, 520.000, 920.000`

The water height is now nucleus-aware. Bridge samples confirmed the nucleus bottom, center, top, and `40` studs above the top all return `Water=8`.

`Workspace.V1_SceneMarker` stores the same metadata. `Workspace.V1_SceneWaterVolume` exists only as a hidden non-colliding bounds marker with `Transparency=1`, so it should not show up as a visible box.

Bridge verification confirmed Water material at both the water center and the current spawn. Computer Use and official Roblox MCP were not usable for viewport review in this pass, so the final V1 confirmation should be a direct manual Studio play-mode check.
