# Roblox Nucleus Classroom V3 Notes

V3 replaces the station-style lesson with a teacher-led class. The teacher starts near the player, explains the class goals, moves through the nucleus, and uses follow checks so the player cannot advance while too far away.

The class is designed to last 10-15 minutes including swimming, short checks, and replay time. The narration is split into short audio segments so each one can be uploaded to Roblox audio separately.

The runtime avoids hub prompts and whole-object selection highlights. Topic focus comes from the teacher position, the speech bubble, a subtle pointer beam, local lighting, a short organ caption, and functional overlay animations.

Audio files are generated locally with ElevenLabs when `ELEVENLABS_API_KEY` is available. Roblox `SoundId` values remain blank until the MP3s are uploaded and moderated, so subtitles remain the fallback path.
