# REVIEW CONTROLS AND PASS CRITERIA

## Suggested Blender review controls

Create these controls as custom properties on `Nucleus_RootRig` or as named empties:

```text
CTRL_Show_Cell_Context
CTRL_Show_Nucleus_Cutaway
CTRL_Show_Envelope_Only
CTRL_Show_Pores
CTRL_Show_Lamina
CTRL_Show_Chromatin
CTRL_Show_Nucleolus
CTRL_Show_Transport_Import
CTRL_Show_Transport_Export
CTRL_Play_Mitosis_Breakdown
CTRL_Play_Reassembly
CTRL_Show_Labels
CTRL_Show_Hotspots
CTRL_Show_Exploded_View
CTRL_Show_LOD0
CTRL_Show_LOD1
CTRL_Show_LOD2
```

## Review camera controls

Create these cameras:

```text
CAM_Main_3D_Cell_Context
CAM_Nucleus_Cutaway_Hero
CAM_NPC_Transport_Closeup
CAM_Envelope_DoubleMembrane_Closeup
CAM_Mitosis_Breakdown_Sequence
CAM_Exploded_Component_View
```

## Pass/fail inspection process

1. Open `CAM_Main_3D_Cell_Context`.
   - Pass if the cell reads as a cohesive 3D animal cell and the nucleus is clearly socketed inside.

2. Open `CAM_Nucleus_Cutaway_Hero`.
   - Pass if the model has the same premium 3D quality as the earlier nucleus image: shadows, depth, texture, visible internal volume, and a clear cutaway.

3. Toggle `CTRL_Show_Envelope_Only`.
   - Pass if the double membrane and perinuclear space are obvious.

4. Toggle `CTRL_Show_Pores`.
   - Pass if NPCs appear as protein complexes with gate cores.

5. Toggle `CTRL_Show_Lamina`.
   - Pass if the gold lamina is beneath the inner membrane, not on the outside.

6. Toggle `CTRL_Show_Chromatin`.
   - Pass if chromatin is distributed inside the nucleoplasm and never exits the nucleus.

7. Play frames 130-300.
   - Pass if protein import and RNA export move in opposite directions through NPCs.

8. Play frames 400-720.
   - Pass if mitosis breakdown and reassembly are understandable without labels.

9. Check object names.
   - Pass if names match the manifest so Roblox scripting can target them.

10. Check Roblox readiness.
   - Pass if functional parts are separate, origins are sensible, surfaces have thickness, and triangle budget is acceptable.