# Nucleolus Scale And Chromatin Decongestion Pass

- Enlarged `Nucleolus_SubregionBody` from radius `0.72` to `1.04` in Blender source.
- Added shared nucleolus center/scale/clearance constants and chromatin repulsion helpers.
- Pushed chromatin clusters outward, reduced bulky DNA masses, and kept magenta/cyan strand language.
- Regenerated `.blend` and all FBX exports; affected groups are `nucleoplasm_volume`, `chromatin_threads`, and `nucleolus_body`.
- Roblox Studio currently still needs logged-in reimport of the three affected FBXs to produce replacement mesh asset IDs.

## Roblox Studio Reimport

- Reimported affected groups through logged-in Roblox Studio importer after user confirmation.
- New MeshIds: `nucleoplasm_volume` `rbxassetid://122310423005158`, `chromatin_threads` `rbxassetid://83312476274506`, `nucleolus_body` `rbxassetid://123744975944825`.
- Reassembled `Workspace.Nucleus_Model`; visible clone sizes confirm the larger nucleolus is active in Studio.
- The importer queue unexpectedly processed all 12 FBXs; extra direct workspace imports were hidden and moved to the orphan import folder, and only the three requested groups were wired into manifests.
