#!/usr/bin/env python3
"""Deploy a clean standalone nucleus mesh experience into Roblox Studio."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TOOLS_DIR = ROOT / "tools"
if str(TOOLS_DIR) not in sys.path:
    sys.path.insert(0, str(TOOLS_DIR))

from roblox_mcp_smoke import DEFAULT_SERVER, RobloxMCPClient, text_content

EXPERIENCE_SOURCE = (
    ROOT
    / "roblox_experiences"
    / "nucleus_mesh_experience"
    / "src"
    / "NucleusMeshExperience.server.lua"
)
MESH_DIR = ROOT / "organelle_projects" / "04_nucleus" / "assets" / "mesh"


def parse_obj(path: Path) -> dict[str, list[list[float]] | list[list[int]]]:
    vertices: list[list[float]] = []
    faces: list[list[int]] = []

    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("v "):
            _, x, y, z = line.split()[:4]
            vertices.append([round(float(x), 4), round(float(y), 4), round(float(z), 4)])
        elif line.startswith("f "):
            indices = []
            for token in line.split()[1:]:
                indices.append(int(token.split("/")[0]))
            if len(indices) == 3:
                faces.append(indices)
            elif len(indices) > 3:
                first = indices[0]
                for i in range(1, len(indices) - 1):
                    faces.append([first, indices[i], indices[i + 1]])

    if not vertices or not faces:
        raise ValueError(f"OBJ did not contain vertices and faces: {path}")

    return {"vertices": vertices, "faces": faces}


def lua_expression(value: object) -> str:
    if isinstance(value, dict):
        return "{%s}" % ",".join(f"{key}={lua_expression(item)}" for key, item in value.items())
    if isinstance(value, list):
        return "{%s}" % ",".join(lua_expression(item) for item in value)
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, (int, float)):
        return repr(value)
    raise TypeError(type(value))


def patch_source(source: str, mesh_data: dict[str, object]) -> str:
    source = re.sub(r"^return buildExperience\s*$", "", source, flags=re.MULTILINE).strip()
    return source + "\n\nbuildExperience(" + lua_expression(mesh_data) + ", {clearScene = false})\n"


def build_command() -> str:
    mesh_data = {
        "shell": parse_obj(MESH_DIR / "nucleus_organic_shell_v1.obj"),
        "inner": parse_obj(MESH_DIR / "nucleus_inner_lining_v1.obj"),
        "nucleolus": parse_obj(MESH_DIR / "nucleolus_core_v1.obj"),
        "pore": parse_obj(MESH_DIR / "nuclear_pore_gate_ring_v1.obj"),
    }

    source = patch_source(EXPERIENCE_SOURCE.read_text(encoding="utf-8"), mesh_data)
    return source


def main() -> int:
    command = build_command()
    print(f"Deploying clean nucleus mesh experience ({len(command):,} Luau chars)")
    with RobloxMCPClient(DEFAULT_SERVER, timeout=240.0) as client:
        response = client.call_tool("run_code", {"command": command})
        print(text_content(response).strip())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
