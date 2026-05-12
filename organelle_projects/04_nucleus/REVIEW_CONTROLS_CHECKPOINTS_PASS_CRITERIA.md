# Review Controls, Checkpoints, and Pass Criteria

## Controls

- `CTRL_Show_Cell_Context`
- `CTRL_Show_Nucleus_Only`
- `CTRL_Show_Cutaway`
- `CTRL_Show_Envelope_Outer`
- `CTRL_Show_Envelope_Inner`
- `CTRL_Show_Perinuclear_Lumen`
- `CTRL_Show_NPC_Master_Closeup`
- `CTRL_Show_All_NPCs`
- `CTRL_Show_Lamina`
- `CTRL_Show_Nucleoplasm`
- `CTRL_Show_Chromatin_Interphase`
- `CTRL_Show_Chromosomes_Mitosis`
- `CTRL_Show_Nucleolus_Subregions`
- `CTRL_Show_Import_Path`
- `CTRL_Show_Export_Path`
- `CTRL_Show_ER_Connection`
- `CTRL_Play_Interphase_Idle`
- `CTRL_Play_Protein_Import`
- `CTRL_Play_RNA_Export`
- `CTRL_Play_Transcription`
- `CTRL_Play_Mitosis_Breakdown`
- `CTRL_Play_Reassembly`
- `CTRL_Show_Exploded_View`
- `CTRL_Show_Labels`
- `CTRL_Show_Hotspots`
- `CTRL_Switch_LOD0_Hero`
- `CTRL_Switch_LOD1_Gameplay`
- `CTRL_Switch_LOD2_Distant`

## Animation Plan

### A01_Interphase_Idle — Frames 001-120
- **Objects:** Nucleoplasm_ParticleField, Chromatin_BackgroundThread_Set, Nucleolus_GranularOuterRegion, NPC_CentralGate_GelPlug
- **Pass:** Subtle motion only; nucleus remains intact.

### A02_Protein_Import_NLS — Frames 130-210
- **Objects:** ProteinCargo_NLS_Set, ProteinImport_PathCurve_01, NPC_GatePulse_Controller
- **Pass:** Green cargo moves cytoplasm to nucleus through NPC.

### A03_RNA_Export — Frames 220-300
- **Objects:** mRNA_Cargo_Squiggle_Set, RNAExport_PathCurve_01, RibosomalSubunit_Export_Cargo
- **Pass:** RNA/ribosomal cargo exits; chromatin stays inside.

### A04_Transcription_Hotspot — Frames 310-390
- **Objects:** TranscriptionHotspot_01, RNA_Product_SpawnMarkers
- **Pass:** RNA appears from chromatin hotspot without moving DNA.

### A05_Mitosis_Breakdown — Frames 400-560
- **Objects:** CondensedChromosome_*, NE_OuterMembrane_Panel_*, NE_InnerMembrane_Panel_*, Lamina_Tile_*, NPC_Instance_*, Envelope_Fragment_Shards_Set
- **Pass:** Chromatin condenses, nucleolus fades, lamina fragments, envelope panels split, NPCs detach.

### A06_Nuclear_Reassembly — Frames 570-720
- **Objects:** Reassembly_Target_Sockets, NE_*, NPC_Instance_*, Lamina_*, Nucleolus_*
- **Pass:** Envelope reforms, pores reinsert, lamina returns, nucleolus and chromatin return to interphase state.


## Checkpoints

### CP0 — Scene setup and naming
**Pass criteria:** All collections and object names follow manifest exactly. No stray nucleus objects outside hierarchy.

### CP1 — Whole organelle cohesion
**Pass criteria:** Nucleus sits in cytoplasm with clear socket and ER contact side; whole cell context reads in 3D.

### CP2 — Double nuclear envelope
**Pass criteria:** Outer membrane, inner membrane, perinuclear lumen, and cutaway rims are all visible.

### CP3 — Envelope panelization
**Pass criteria:** Outer/inner/lumen segments are separate and can split for mitosis without gaps/overlap errors.

### CP4 — NPC biological readability
**Pass criteria:** NPCs are protein complexes with rings, lobes, gates, filaments/baskets on hero pores.

### CP5 — Lamina support
**Pass criteria:** Gold lamina lies beneath inner membrane and anchors peripheral chromatin.

### CP6 — Internal volume
**Pass criteria:** Nucleoplasm is transparent, textured, and does not obscure chromatin/nucleolus.

### CP7 — Genome system
**Pass criteria:** Interphase chromatin and condensed chromosomes are separate states; DNA never exits the nucleus.

### CP8 — Nucleolus
**Pass criteria:** Nucleolus is non-membrane, bumpy, subregioned, and able to fade/reform in mitosis.

### CP9 — Transport
**Pass criteria:** Protein import and RNA/ribosomal export use NPC paths in opposite directions.

### CP10 — ER continuity
**Pass criteria:** Outer membrane visibly connects to rough ER and perinuclear lumen continuity is shown.

### CP11 — Mitosis animation
**Pass criteria:** Breakdown and reassembly can be understood using panels, fragments, chromosomes, and target sockets.

### CP12 — Roblox export readiness
**Pass criteria:** Meshes are separate, origins sensible, surfaces thick enough, triangle budget recorded, materials portable.

### CP13 — Final 3D quality
**Pass criteria:** Model has high-quality depth, texture, shadows, bevels, and readable stylized realism.

