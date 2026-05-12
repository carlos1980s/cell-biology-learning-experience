# Roblox Nucleus Classroom V4 Guided Class Notes

V4 replaces the button-driven classroom with an autoplay lesson. The client UI has no Continue button; Dr Riviera walks to each station, points to the target, and the lesson advances by audio/subtitle timing.

Audio state after install: Roblox SoundId playback is primary. The classroom has 18 ready Sound objects and 0 pending objects. Client TTS remains as a fallback only, using voice `3` (United States male #1).

Local ElevenLabs files are present for 18 segments and use voice ids ['NFG5qt843uXKj4pFvR7C']. Their matching Roblox SoundIds are written into the manifest and loaded into `Workspace.NucleusClassroom_V4.Audio.TeacherVoiceEmitter`.

The added `Workspace.Scientist Dr Riviera` model is cloned into the runtime as `DrRiviera_Teacher`; the source model is hidden but preserved in place with original transparency attributes.

Camera behavior was changed from a hard target lock to a guided camera that frames Dr Riviera and the active structure, then releases to normal player camera control when the player looks or moves the camera. The first segment gets a short intro framing pass so the player starts with Dr Riviera visible.

Teacher movement was tightened around each target. Dr Riviera now uses closer target-relative waypoints, waits when the player is far away, faces the player while waiting, and shows a locator/guide beam so the class can rejoin her.

Lesson text is duplicated into a BillboardGui speech bubble attached to Dr Riviera so subtitles feel teacher-originated instead of only being a detached bottom panel.

Embedded sounds on the teacher model were disabled for the class clone (1) and source model (1) so old inaccessible assets do not compete with classroom narration.

Lighting was changed to a single restrained nucleus-center glow near the nucleolus/nucleus center, while older nucleus portal/key lights and bright emissive nucleus entry/perinuclear parts were capped. Adjusted parts: 7.
