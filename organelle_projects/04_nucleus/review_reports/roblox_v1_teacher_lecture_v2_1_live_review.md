# Roblox V1 Teacher Lecture V2.1 Live Review

Date: 2026-05-09

## Studio Deployment

- Deployed `TeacherLecture_V2_1` into the open `Cell V1 experience` Studio place.
- Saved updated place to Roblox twice:
  - first after the V2.1 lecture/lighting deployment
  - second after wiring the first uploaded audio asset
- Studio output confirmed: `Saved new changes in "Cell V1 experience" to Roblox.`

## Runtime State

- Runtime: `Workspace.V1TeacherLecture`
- Segments: `13`
- Active teacher: `Workspace.V1TeacherLecture.TeacherGuide`
- Old station runtime removed: yes
- Whole-object highlights: `0`
- Lecture prompts/hub markers: `0`
- Global lighting: brightness `0.78`, exposure `-0.18`

## Audio Test

- Imported `01_teacher_greeting.mp3` through Studio Asset Manager.
- Studio account quota after import: `1999 of 2000 audio uploads left until Jun 8`.
- Uploaded Roblox audio id: `rbxassetid://110289914696450`
- Wired the uploaded id into `audio/nucleus_lecture/nucleus_lecture_manifest.json`.
- Reinstalled runtime; `Voice_teacher_greeting` now uses `rbxassetid://110289914696450`.
- Remaining 12 lecture segments still use subtitle fallback until uploaded and added to the manifest.

## Play-Mode Visual Check

- Player starts near the teacher/nucleus.
- Greeting segment appears first: `Meet Your Guide`.
- Teacher UI shows Replay / Next / Restart.
- No selection-style component outlines appear.
- The scene is less overbright than the previous lecture pass.

## Known Issues

- Current open place still contains unrelated submarine scripts that produce output errors:
  - `Workspace.Working Submarine V2.HoverSeat`
  - `Workspace.Submarine.Baby Yoda Carriage...`
- Those scripts are outside the teacher lecture layer and were not modified in this pass.
- Remaining narration audio segments need upload IDs before full voice playback can work end to end.
