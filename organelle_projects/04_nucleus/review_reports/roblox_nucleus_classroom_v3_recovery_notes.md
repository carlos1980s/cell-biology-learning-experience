# Roblox Nucleus Classroom V3 Recovery Notes

This pass resumed from `roblox_nucleus_classroom_v3_report.json` after the prior chat and Roblox Studio bridge hung.

The official Roblox MCP path was still unhealthy: Studio logs had repeated `423 Locked` responses on `localhost:44755`, `get_studio_mode` previously timed out, and a new `start_stop_play` attempt also timed out. I killed only the stale `rbx-studio-mcp` helper process and used the repo compatibility bridge instead.

Before the Studio cloud session disconnected, the legacy bridge confirmed that the target Cell V1 experience had the V3 classroom installed:

- `Workspace.NucleusClassroom_V3` existed at version `NucleusClassroom_V3_2`.
- The runtime contained 25 waypoints, 25 target anchors, 25 class data entries, the lighting rig, audio folder, and `TeacherGuide`.
- `ServerScriptService.NucleusClassroomV3Controller` existed and was enabled.
- `StarterPlayer.StarterPlayerScripts.NucleusClassroomV3Client` existed and was enabled.
- `ReplicatedStorage.NucleusClassroomV3Remotes` contained `ClassState` and `ClassAction`.
- The old V1 teacher lesson scripts were disabled.
- The runtime had 25 sound objects, with one Roblox `SoundId` filled and 24 still pending upload/moderation.

Play-mode review is blocked. Roblox Studio showed `Unable to Connect to Server`, error code `RCC-277`, for place ID `78330326549565`. The error dialog offered a local-copy recovery path, and logs/search briefly showed `/Users/carlosmarinronco/Library/Application Support/Roblox/RobloxStudio/AutoSaves/78330326549565_AutoRecovery_0.rbxl`, but the autosave folder was empty by the time it could be opened.

The only remaining local `.rbxl` file found was `/Users/carlosmarinronco/Documents/Scene1.rbxl`. It opened successfully, but it is a sheep-herding scene, not the cell/nucleus experience. I did not install or modify nucleus classroom content there.

Next recommended phase: reopen the correct Cell V1 experience when Studio/cloud connectivity is stable, or restore a valid local cell `.rbxl` copy. Then rerun `tools/install_v3_nucleus_classroom.py` if V3 is missing and complete Play-mode review for teacher movement, follow gate, questions, subtitles/audio fallback, and mobile-safe UI.
