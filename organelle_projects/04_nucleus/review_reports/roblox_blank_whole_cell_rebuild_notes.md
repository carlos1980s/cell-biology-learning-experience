# Roblox Blank Whole-Cell Rebuild Notes

This phase rebuilt the blank Roblox place from the package manifests instead of relying on manually imported Workspace objects. The builder now owns the scene reset: it removes the default `Baseplate` and default `SpawnLocation`, clears Terrain, fills one large calm water volume, creates a near-cell spawn, loads raw organelle packages into `Workspace.MeshLibrary`, and assembles visible clones under `Workspace.CellEnvironment_Main.ImportedOrganelles`.

The generated water volume is centered at `Vector3.new(0, 90, 0)` with size `Vector3.new(760, 240, 900)`. The spawn is `Vector3.new(0, 90, -385.691)`, inside water and facing the cell center. Movement is intentionally native Roblox water swimming; the previous custom buoyancy and direct-dive systems are not used for this reset.

The organelle map now spreads the 12 families across the water volume: nucleus, ER, ribosomes, Golgi, vesicles/endosomes, lysosome, mitochondria, peroxisomes, proteasomes, cytoskeleton/centrosome, membrane, and cytoplasm. Raw package parts are hidden, while visible clones are assembled in the scoped cell environment.

The nucleus is exposed as `Workspace.Nucleus_Model`. Its entry portal is still attached to the nucleus itself, with `NucleusMembraneCollisionMode=PortalControlledProxy`. The old outer-cell entry guide and old cell-wall gate are removed.

Studio bridge verification passed, including water material sampling at spawn, cell center, and nucleus. Computer Use could not access the Studio viewport during this pass, so the visual inspection remains a manual follow-up rather than completed evidence.

Next recommended phase: press Play in the open Studio place and confirm the character spawns in water, can swim, and sees the proportional whole-cell layout. If the scene looks too cramped or too spread out from the player view, tune only `WholeCellOrganelleMap.lua` placements/scales and rebuild.
