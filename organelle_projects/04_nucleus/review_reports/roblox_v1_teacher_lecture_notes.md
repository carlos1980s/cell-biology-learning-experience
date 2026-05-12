# Roblox V1 Teacher Lecture Notes

This pass replaces the station/hub lesson with a teacher-led lecture. The active teacher is installed under `Workspace.V1TeacherLecture.TeacherGuide`; raw `Workspace.Teacher` models are preserved under `Workspace.V1TeacherRawSources` and hidden.

The lecture uses a speech bubble near the teacher plus a single focused organ caption. Per-topic lighting and overlays are created under `Workspace.V1TeacherLecture.FocusOverlays`. Old V1 lesson station parts, labels, prompts, and guide markers are removed or disabled.

Audio files are generated locally from ElevenLabs where possible and recorded in `audio/nucleus_lecture/nucleus_lecture_manifest.json`. Roblox `SoundId` fields intentionally remain blank until the audio is uploaded and moderated, so the installed experience falls back to subtitles.

Computer Use play-mode smoke review showed the teacher near the nucleus, speech bubble visible, focused caption visible, and Replay/Next/Restart controls visible.

Next review pass: step through all lecture segments on desktop, Android, and VR, then add Roblox `SoundId` values after audio upload/moderation and verify voice playback.
