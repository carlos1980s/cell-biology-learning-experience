# Roblox Nucleus Entry Portal Notes

The entrance clarification was for the nucleus, not the outer cell. The outer cell entrance helpers remain removed.

The main nucleus now receives a `NucleusEntryPortal` under `Workspace.Nucleus_Model`. The portal is visible, non-colliding, and positioned at the nucleus surface facing the submarine-side spawn. The closed nucleus collision proxy remains solid by default and is controlled by a runtime portal proximity check.

Next recommended phase: cut a matching organic doorway into the Blender source/exported nucleus mesh so the visual geometry and Roblox collision behavior match exactly.
