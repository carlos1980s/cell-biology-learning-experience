#!/usr/bin/env python3
"""Deploy the generated cell biology source modules into Roblox Studio."""

from __future__ import annotations

import json
from pathlib import Path

from roblox_mcp_smoke import DEFAULT_SERVER, RobloxMCPClient, text_content


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "src" / "CellExperience"


def module_name(path: str) -> str:
    return path.removesuffix(".lua")


def luau_string(value: str) -> str:
    return json.dumps(value)


def source_modules() -> list[str]:
    paths = []
    for source_path in sorted(SOURCE_ROOT.rglob("*.lua")):
        relative_path = source_path.relative_to(SOURCE_ROOT).as_posix()
        if relative_path == "Data/Generated/MembraneSpec.lua":
            continue
        paths.append(relative_path)
    return paths


def build_command() -> str:
    files = []
    for path in source_modules():
        source_path = SOURCE_ROOT / path
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        files.append(
            "{ path = %s, source = %s }"
            % (luau_string(module_name(path)), luau_string(source_path.read_text()))
        )

    return """
local ServerScriptService = game:GetService("ServerScriptService")

local existing = ServerScriptService:FindFirstChild("CellExperience")
if existing then
    existing:Destroy()
end

local root = Instance.new("Folder")
root.Name = "CellExperience"
root.Parent = ServerScriptService

local files = {
%s
}

local function ensureFolder(parent, name)
    local child = parent:FindFirstChild(name)
    if child then
        return child
    end

    child = Instance.new("Folder")
    child.Name = name
    child.Parent = parent
    return child
end

for _, file in ipairs(files) do
    local parent = root
    local parts = string.split(file.path, "/")
    for index = 1, #parts - 1 do
        parent = ensureFolder(parent, parts[index])
    end

    local module = Instance.new("ModuleScript")
    module.Name = parts[#parts]
    module.Source = file.source
    module.Parent = parent
end

local builder = require(root:WaitForChild("BuildCellExperience"))
builder.build()
""" % (",\n".join("    " + file for file in files))


def main() -> int:
    command = build_command()
    with RobloxMCPClient(DEFAULT_SERVER, timeout=240.0) as client:
        response = client.call_tool("run_code", {"command": command})
        print(text_content(response).strip())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
