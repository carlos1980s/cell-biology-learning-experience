# Roblox V1 Gene Expression Lesson Notes

This pass adds a separate V1 lesson layer without disturbing the water, spawn, or imported organelle meshes.

Installed runtime:

- `Workspace.V1LessonRuntime`
- `ReplicatedStorage.V1LessonRemotes.LessonState`
- `ReplicatedStorage.V1LessonRemotes.LessonAction`
- `ServerScriptService.V1GeneExpressionLessonController`
- `StarterPlayer.StarterPlayerScripts.V1TeacherLessonClient`

The guided mission has seven stations: teacher briefing, DNA/chromatin, transcription, mRNA export, translation, protein handoff, and recap. Each station is non-colliding, has a `LessonPrompt`, and samples as water in the current V1 Terrain volume.

The server owns lesson state and overlay animations. The client owns the teacher HUD, answer buttons, Continue control, and local guide marker/beam. The lesson is self-contained in Roblox for V1 and uses action IDs compatible with the existing biology vocabulary: `transcribe_gene`, `export_mrna`, `translate_mrna`, and `protein_handoff`.

Important: the HUD and progression scripts run in Play mode. Edit mode will show the station markers, but not the full player HUD/interaction loop. The next review should press Play and test the full sequence from `Workspace.V1_WaterSpawn`.
