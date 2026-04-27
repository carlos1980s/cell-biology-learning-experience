# Roblox Bridge Example

These Luau scripts show one safe integration shape between the existing Roblox frontend and the new FastAPI backend.

## Files

- `CellRemotes.lua`: creates or returns the required `RemoteEvent`s in `ReplicatedStorage`.
- `CellBackendBridge.server.lua`: server-authoritative HTTP bridge to the backend.
- `CellClientExample.client.lua`: minimal client listener and inspect example.

## Expected RemoteEvents

- `CellStateDelta`
- `CellInputRequest`
- `OrganelleInspectResult`
- `CellBackendStatus`

## Wiring Notes

1. Put `CellBackendBridge.server.lua` in `ServerScriptService`.
2. Put `CellRemotes.lua` where the server bridge can `require()` it.
3. Keep `BACKEND_TOKEN` server-side only.
4. Replace `BACKEND_BASE_URL` with your running backend URL.
5. Forward player interactions through `CellInputRequest`; do not let the client talk to the backend directly.

## Current Assumptions

- One backend-backed cell per Roblox game server.
- Polling transport only for the MVP.
- The existing 3D cell in `src/CellExperience` remains the visual frontend.

## Recommended Next Step

Map `delta.organelle_updates[*].visual_cue` and `current_task` onto your existing organelle models and UI labels in `src/CellExperience`.

