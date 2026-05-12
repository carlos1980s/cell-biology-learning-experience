# Nucleus Scale / Entrance / Pore Pass Notes

Implemented the +40% scale pass in the Blender source and updated the Roblox-side assembly/fallback paths to match the new 224-stud target diameter.

Key changes:
- Blender scale contract is now 35 studs per Blender unit.
- The broad cutaway wedge was replaced in source with a smaller irregular portal measuring about 23.8 x 28 studs.
- Pore placement now uses deterministic full-surface distribution instead of concentrating on one area.
- Shell panel seams were overlapped and edge-jittered to reduce straight CAD-like cuts.
- Studio fallback layout was enlarged and its gate/pore visuals were reduced to player scale.
- Phase07R Studio assembler now uses the larger scale and adds distributed pore markers.

Review outcome:
- Blender/source pass is ready for the next export/upload phase.
- Live Studio was assembled and reviewed through the legacy bridge, but the visible package meshes are still older uploaded assets. The smaller source entrance will not fully appear in Studio until the regenerated export groups are uploaded and the package asset IDs are replaced.

Next recommended phase:
- Export the 12 new groups from `nucleus_roblox_functional_model.blend`.
- Upload/import those groups into Roblox as replacement packages.
- Update the Roblox asset manifest with the new package IDs.
- Re-run the Studio assembler and review from player scale.
