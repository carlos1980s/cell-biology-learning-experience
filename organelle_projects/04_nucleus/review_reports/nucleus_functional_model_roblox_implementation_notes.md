# Nucleus Functional Model Roblox Implementation Notes

## What changed
- Added a functional-model FBX exporter for the regenerated Blender scene.
- Exported 12 biological groups: outer membrane, NPCs, inner membrane, lumen, lamina, nucleoplasm, chromatin, nucleolus, ER connection, cargo, mitosis fragments, and interaction/collision guide.
- Updated the Open Cloud upload script so it accepts both the old Phase07R manifest and the new functional manifest.
- Added a functional Studio assembler that preserves raw packages in `Workspace.MeshLibrary.Nucleus_FunctionalModel_RawPackages` and clones visible groups under `Workspace.Nucleus_Model` once package asset IDs exist.
- Added the functional group manifest skeleton to `NucleusMeshAssets.lua`.

## Current blocker
The new FBX exports are ready, but they are not uploaded to Roblox because `ROBLOX_OPEN_CLOUD_API_KEY` and `ROBLOX_GROUP_ID` are not set. The current Studio viewport still shows the older Phase07R package assembly, not the newly exported functional meshes.

## How to finish the Roblox import
1. Set `ROBLOX_OPEN_CLOUD_API_KEY` and `ROBLOX_GROUP_ID` in the shell that runs Codex/tools.
2. Run `python3 tools/upload_nucleus_phase07r_open_cloud_assets.py --manifest organelle_projects/04_nucleus/assets/exports/nucleus_functional_model/nucleus_functional_model_roblox_asset_manifest.json --timeout 300`.
3. Confirm the manifest receives `package_asset_id` values.
4. Run `python3 tools/assemble_nucleus_functional_model_in_studio.py --legacy-bridge`.
5. Review edit mode and play mode in Studio for the larger scale, smaller irregular entrance, and full-surface pore distribution.

## Next recommended phase
After upload succeeds, perform a Studio-only visual pass. The specific target is to confirm the organic membrane rugosity and pore holes survive Roblox import and that no raw package/helper objects are visible in the playable model.
