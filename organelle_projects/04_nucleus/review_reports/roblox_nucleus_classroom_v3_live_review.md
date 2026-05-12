# Roblox Nucleus Classroom V3 Live Review

Date: 2026-05-09

## Studio Deployment

- Installed `Workspace.NucleusClassroom_V3` into the logged-in `Cell V1 experience` Studio scene.
- Saved the place to Roblox after the play-mode validation.
- Runtime contains 25 class segments, 4 checks, 25 `Sound` objects, 0 `ProximityPrompt` hubs, and 0 whole-object `Highlight` adorners.
- New near-nucleus spawn is `Workspace.V3_ClassStartSpawn`.

## Play-Mode Checks

- Player starts close to the nucleus instead of far outside the scene.
- Teacher-led UI appears immediately with greeting segment `Meet Dr. Rivera (1/25)`.
- Added a fixed readable teacher panel because the in-world teacher speech bubble can be partially occluded by the player camera.
- `Continue` advances to segment 2 and teacher movement/focus beam/organ caption appear.
- Follow gate works: when the teacher moves ahead, the lesson blocks advancement with "Swim closer to Dr. Rivera so the class can continue together."
- Neutral lighting is active: brightness about `0.62`, exposure about `-0.28`.

## Audio State

- ElevenLabs generated 25 local MP3 narration segments with voice `yhFUAoS32gPDJFQHbH68`.
- Manifest: `audio/nucleus_classroom_v3/nucleus_classroom_manifest.json`.
- Roblox `SoundId` fields are still pending upload/moderation, so the tested in-game path currently uses subtitles.
- Added `tools/upload_nucleus_classroom_audio_oauth.py` for the next upload pass through Roblox Open Cloud OAuth.

## Known External Scene Errors

The Output panel still shows unrelated free-model script errors:

- `Workspace.Working Submarine V2.HoverSeat`, line 3: `Position is not a valid member of Model`.
- `Workspace.Submarine.Baby Yoda Carriage (ungroup me).PUT ME IN SERVER SCRIPT SERVICE`, line 3: infinite yield on `Workspace:WaitForChild("FollowingBrick")`.

These are not from the V3 classroom runtime, but they should be cleaned later because they add noise to Play mode.
