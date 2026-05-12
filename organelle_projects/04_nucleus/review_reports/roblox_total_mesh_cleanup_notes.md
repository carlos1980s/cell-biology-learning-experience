# Roblox Total Mesh Cleanup Notes

The temporary cell entrance system has been removed from the source builder. This includes the invisible pore gate collision, the visible pore guide, the beacon beads, the bubble trail, and the pore light/mist.

The builder now calls `workspace.Terrain:Clear()` during rebuild and does not recreate Terrain water. The live Studio probe confirmed `Terrain:CountCells()` is `0`.

Next recommended phase: let the imported total mesh provide the cell boundary, collision, and any intentional openings, then add only mesh-owned interaction markers if needed.
