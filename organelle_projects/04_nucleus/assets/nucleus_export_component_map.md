# Nucleus Export Component Map

Generated from `tools/create_nucleus_roblox_functional_model.py`.

## Scale Contract

- Pivot: `Nucleus_RootRig` at `[0.0, 0.0, 0.2]`
- Source diameter: `6.4` Blender units
- Recommended Roblox scale: `35.0` studs per Blender unit
- Target Roblox outer diameter: `224.0` studs

## Export Groups

| # | Export group | Blender collection | Roblox target | Role | Objects | Mesh | Curve | Export file |
|---:|---|---|---|---|---:|---:|---:|---|
| 01 | `outer_membrane_panels` | `EXPORT_01_OuterMembranePanels` | `NucleusModel/MeshVisuals/OuterEnvelope` | `visual` | 365 | 260 | 105 | `nucleus_01_outer_membrane_panels_lod0.fbx` |
| 02 | `npc_assemblies` | `EXPORT_02_NPCAssemblies` | `NucleusModel/MeshVisuals/NPCAssemblies` | `visual_scriptable` | 706 | 658 | 48 | `nucleus_02_npc_assemblies_lod0.fbx` |
| 03 | `inner_membrane_panels` | `EXPORT_03_InnerMembranePanels` | `NucleusModel/MeshVisuals/InnerMembrane` | `visual` | 17 | 16 | 1 | `nucleus_03_inner_membrane_panels_lod0.fbx` |
| 04 | `perinuclear_lumen` | `EXPORT_04_PerinuclearLumen` | `NucleusModel/MeshVisuals/PerinuclearLumen` | `visual` | 17 | 16 | 1 | `nucleus_04_perinuclear_lumen_lod0.fbx` |
| 05 | `lamina_web` | `EXPORT_05_LaminaWeb` | `NucleusModel/MeshVisuals/LaminaWeb` | `visual` | 82 | 34 | 47 | `nucleus_05_lamina_web_lod0.fbx` |
| 06 | `nucleoplasm_volume` | `EXPORT_06_NucleoplasmVolume` | `NucleusModel/MeshVisuals/Nucleoplasm` | `visual_transparent` | 96 | 82 | 14 | `nucleus_06_nucleoplasm_volume_lod0.fbx` |
| 07 | `chromatin_threads` | `EXPORT_07_ChromatinThreads` | `NucleusModel/MeshVisuals/Chromatin` | `visual_animated` | 184 | 39 | 135 | `nucleus_07_chromatin_threads_lod0.fbx` |
| 08 | `nucleolus_body` | `EXPORT_08_NucleolusBody` | `NucleusModel/MeshVisuals/Nucleolus` | `visual_hotspot` | 223 | 179 | 44 | `nucleus_08_nucleolus_body_lod0.fbx` |
| 09 | `er_connection` | `EXPORT_09_ERConnectionSheets` | `NucleusModel/MeshVisuals/ERConnection` | `visual_context` | 24 | 24 | 0 | `nucleus_09_er_connection_sheets_lod0.fbx` |
| 10 | `transport_cargo` | `EXPORT_10_TransportCargo` | `NucleusModel/AnimationControllers/TransportCargo` | `animated_instances` | 21 | 15 | 5 | `nucleus_10_transport_cargo_reference_lod0.fbx` |
| 11 | `mitosis_fragments` | `EXPORT_11_MitosisFragments` | `NucleusModel/AnimationControllers/MitosisFragments` | `animated_visual` | 28 | 28 | 0 | `nucleus_11_mitosis_fragments_lod0.fbx` |
| 12 | `interaction_hotspots_collision` | `EXPORT_12_InteractionHotspotsCollision` | `NucleusModel/InteractionAnchors` | `nonvisual_gameplay` | 24 | 22 | 0 | `nucleus_12_interaction_hotspots_collision_guide.fbx` |

## Notes

- These collections are export-facing groups linked from the detailed master scene.
- The source `.blend` remains the editable art file; Roblox should receive combined/LOD export chunks, not every tiny source object.
- Collision, hotspots, cargo animation, and script anchors should remain separate from dense visual mesh exports.
