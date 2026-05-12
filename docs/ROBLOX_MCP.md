# Roblox Studio MCP Notes

## Server

Command:

```bash
/Applications/RobloxStudioMCP.app/Contents/MacOS/rbx-studio-mcp --stdio
```

The installed `rbx-studio-mcp` version tested here is `0.2.365`.

## Transport

This version uses newline-delimited JSON-RPC on stdio. It does not accept `Content-Length` framed messages.

## Verified Tools

- `get_studio_mode`: no arguments. Returns one of `start_play`, `run_server`, or `stop`.
- `run_code`: argument is `command`, not `code`. Returns printed output from Studio.
- `insert_model`: argument is `query`, not an asset id.
- `start_stop_play`: argument is `mode`, with `start_play`, `stop`, or `run_server`.
- `run_script_in_play_mode`: arguments are `code`, `mode`, and optional `timeout`.
- `get_console_output`: listed by the server, but did not respond during the initial smoke test.

## Smoke Test

With Roblox Studio open, run:

```bash
python3 tools/roblox_mcp_smoke.py
```

When running from Codex shell, the Studio proxy call needs unsandboxed local loopback access to `127.0.0.1:44755`.

To also check the current Studio mode:

```bash
python3 tools/roblox_mcp_smoke.py --check-mode
```

The mode and console-output calls can lag or timeout while Studio is busy. The core automation path is `run_code`, which was verified separately and is what we will use to create and modify places.
The smoke script retries `run_code` because the Studio plugin can temporarily stop answering while Studio is settling.

To list MCP tools after the code-execution probe:

```bash
python3 tools/roblox_mcp_smoke.py --list-tools
```

## Current Compatibility Issue

On 2026-04-29, `rbx-studio-mcp 0.2.365` could list tools but every
`tools/call` timed out. Studio still executed the command, so the request path
was working. With `RUST_LOG=trace`, the bridge rejected Studio's `/response`
body with:

```text
missing field `success`
```

The installed Studio plugin posts legacy responses shaped like:

```json
{"id":"...","response":"[OUTPUT] ..."}
```

The bridge binary expects a newer response body containing `success`. Until the
installed plugin and binary are on matching versions, use the compatibility
helper:

```bash
python3 tools/roblox_plugin_bridge.py 'print("compat bridge ok")'
```

This helper talks directly to the existing plugin polling interface on
`127.0.0.1:44755` and accepts the legacy response shape. It leaves the installed
Roblox files unchanged.

## Production Workflow Notes

Before running assembly scripts, stop Play/Test mode. The edit-time Workspace and
the running play session can diverge; a model visible in play mode may not exist
in the edit-time Workspace that production scripts need to repair.

Recommended order:

1. Stop play mode in Studio.
2. Probe the bridge:

   ```bash
   python3 tools/roblox_plugin_bridge.py 'print("compat bridge ok")'
   ```

3. Run the assembler in edit mode.
4. Run the Studio assembly validator.
5. Inspect with Computer Use.
6. Enter play mode and capture a player-camera screenshot.
7. Stop play mode again before making further edit-time changes.

If `tools/roblox_plugin_bridge.py` fails with `OSError: [Errno 48] Address
already in use`, check the listener:

```bash
lsof -nP -iTCP:44755 -sTCP:LISTEN
```

If the listener is `/Applications/RobloxStudioMCP.app/.../rbx-studio-mcp
--stdio`, it may be a stale helper holding the legacy bridge port. Kill only that
helper process, not Roblox Studio, then retry the legacy bridge.

Do not leave visible raw package imports in `Workspace`. Production assemblers
must keep raw packages under `Workspace.MeshLibrary`, hide them, and clone only
the visible reviewed assembly into the scoped organelle model.
