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
