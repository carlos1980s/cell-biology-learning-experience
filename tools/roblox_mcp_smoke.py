#!/usr/bin/env python3
"""Smoke test the installed Roblox Studio MCP server.

This script talks directly to rbx-studio-mcp over newline-delimited JSON-RPC.
It is intentionally dependency-free so it can run from a fresh workspace.
"""

from __future__ import annotations

import argparse
import json
import select
import subprocess
import sys
import time
from typing import Any


DEFAULT_SERVER = "/Applications/RobloxStudioMCP.app/Contents/MacOS/rbx-studio-mcp"


class RobloxMCPClient:
    def __init__(self, server_path: str, timeout: float) -> None:
        self.server_path = server_path
        self.timeout = timeout
        self.next_id = 0
        self.process: subprocess.Popen[str] | None = None

    def __enter__(self) -> "RobloxMCPClient":
        self.process = subprocess.Popen(
            [self.server_path, "--stdio"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
        )
        self.request(
            "initialize",
            {
                "protocolVersion": "2024-11-05",
                "capabilities": {},
                "clientInfo": {"name": "codex-roblox-smoke", "version": "0.1.0"},
            },
        )
        self.notify("notifications/initialized", {})
        return self

    def __exit__(self, exc_type: object, exc: object, tb: object) -> None:
        if not self.process:
            return

        try:
            self.process.terminate()
            self.process.wait(timeout=5)
        except Exception:
            self.process.kill()
            self.process.wait(timeout=5)

        stderr = self.process.stderr.read() if self.process.stderr else ""
        if stderr.strip():
            print("stderr:", file=sys.stderr)
            print(stderr.strip(), file=sys.stderr)

    def request(self, method: str, params: dict[str, Any] | None = None) -> dict[str, Any]:
        self.next_id += 1
        message: dict[str, Any] = {
            "jsonrpc": "2.0",
            "id": self.next_id,
            "method": method,
        }
        if params is not None:
            message["params"] = params

        self._write_message(message)
        response = self._read_message()
        if response is None:
            raise TimeoutError(f"No MCP response for {method}")
        return response

    def notify(self, method: str, params: dict[str, Any] | None = None) -> None:
        message: dict[str, Any] = {"jsonrpc": "2.0", "method": method}
        if params is not None:
            message["params"] = params
        self._write_message(message)

    def call_tool(self, name: str, arguments: dict[str, Any] | None = None) -> dict[str, Any]:
        return self.request("tools/call", {"name": name, "arguments": arguments or {}})

    def _write_message(self, message: dict[str, Any]) -> None:
        if not self.process or not self.process.stdin:
            raise RuntimeError("MCP process is not running")
        self.process.stdin.write(json.dumps(message) + "\n")
        self.process.stdin.flush()

    def _read_message(self) -> dict[str, Any] | None:
        if not self.process or not self.process.stdout:
            raise RuntimeError("MCP process is not running")

        deadline = time.time() + self.timeout
        while time.time() < deadline:
            ready, _, _ = select.select(
                [self.process.stdout], [], [], max(0, deadline - time.time())
            )
            if not ready:
                return None

            line = self.process.stdout.readline()
            if not line:
                return None

            line = line.strip()
            if line:
                return json.loads(line)

        return None


def text_content(response: dict[str, Any]) -> str:
    if "error" in response:
        return json.dumps(response["error"], indent=2)

    content = response.get("result", {}).get("content", [])
    return "".join(item.get("text", "") for item in content if item.get("type") == "text")


def main() -> int:
    parser = argparse.ArgumentParser(description="Smoke test Roblox Studio MCP.")
    parser.add_argument("--server", default=DEFAULT_SERVER, help="Path to rbx-studio-mcp")
    parser.add_argument("--timeout", type=float, default=30.0, help="Response timeout in seconds")
    parser.add_argument("--retries", type=int, default=2, help="Retry count for the run_code probe")
    parser.add_argument(
        "--check-mode",
        action="store_true",
        help="Also call get_studio_mode. This can be slower than run_code.",
    )
    parser.add_argument(
        "--list-tools",
        action="store_true",
        help="Also list the MCP tools exposed by the stdio server.",
    )
    args = parser.parse_args()

    last_error: Exception | None = None
    for attempt in range(1, args.retries + 2):
        try:
            with RobloxMCPClient(args.server, args.timeout) as client:
                if attempt > 1:
                    print(f"retry_attempt: {attempt}")

                # Keep the required probe to one Studio call. The plugin can lag
                # while Studio is busy, so nonessential diagnostics run after it.
                ping = client.call_tool(
                    "run_code",
                    {"command": 'print("ping from codex smoke test")'},
                )
                print("run_code:", text_content(ping).strip())

                if args.check_mode:
                    try:
                        mode = client.call_tool("get_studio_mode")
                        print("studio_mode:", text_content(mode).strip())
                    except Exception as error:
                        print(f"studio_mode_warning: {error}", file=sys.stderr)

                if args.list_tools:
                    try:
                        tools = client.request("tools/list")
                        names = [
                            tool["name"] for tool in tools.get("result", {}).get("tools", [])
                        ]
                        print("tools:", ", ".join(sorted(names)))
                    except Exception as error:
                        print(f"tools_warning: {error}", file=sys.stderr)

            return 0
        except Exception as error:
            last_error = error
            if attempt <= args.retries:
                time.sleep(2)
                continue
            break

    print(f"smoke test failed: {last_error}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
