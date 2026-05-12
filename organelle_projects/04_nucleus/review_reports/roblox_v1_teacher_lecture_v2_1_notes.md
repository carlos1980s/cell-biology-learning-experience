# Roblox V1 Teacher Lecture V2.1 Notes

This pass keeps the teacher-led lecture but changes the experience from a component-selection style to a player-first guided lecture. The teacher starts near the player, introduces herself, then moves between the nucleus structures.

The lecture uses a speech bubble near the teacher plus one short focused organ caption. Whole-object `Highlight` adorners are removed because they made the cell look selected. Focus is now a local glow, a teacher pointer beam, and low-intensity topic lights under `Workspace.V1TeacherLecture.FocusOverlays`.

Lighting is rebuilt as a neutral underwater lecture rig: lower global brightness, reduced bloom, dimmed old scene lights, and soft fill lights around the nucleus and teacher route.

Audio files are generated locally from ElevenLabs where possible and recorded in `audio/nucleus_lecture/nucleus_lecture_manifest.json`. Roblox `SoundId` fields intentionally remain blank until the audio is uploaded and moderated, so the installed experience falls back to subtitles.

Next review pass: press Play in Studio and step through the greeting, nucleus overview, envelope, pores, chromatin, nucleolus, and export/translation segments, checking that the teacher feels like the guide and that the scene is softly lit rather than overbright.
