# Cell Biology Learning Experience

Cell Biology Learning Experience is an AI-assisted Roblox learning project that
simulates a human/animal eukaryotic cell. The repository combines a source-built
Roblox place, a FastAPI simulation backend, Roblox bridge scripts, and
organelles documented as independent design projects before implementation.

## Repository Map

- [`src/CellExperience`](src/CellExperience) - source-driven Roblox cell scene.
- [`backend`](backend) - FastAPI simulation authority and organelle agents.
- [`roblox_bridge`](roblox_bridge) - Luau scripts for Roblox/backend
  communication.
- [`organelle_projects`](organelle_projects) - research and Roblox design briefs
  for 18 organelles and cell structures.
- [`docs`](docs) - architecture, project structure, roadmap, and Roblox MCP
  notes.
- [`tools`](tools) - generation, deployment, audit, and validation scripts.

See [`docs/PROJECT_STRUCTURE.md`](docs/PROJECT_STRUCTURE.md) for the full
repository layout.

## Organelle Planning Scope

The project currently has research/design briefs for 18 structures:

1. membrane
2. cytoplasm
3. cytoskeleton
4. nucleus
5. nucleolus and chromatin
6. rough ER
7. smooth ER
8. ribosomes
9. mitochondria
10. Golgi apparatus
11. lysosomes
12. vesicles and vacuoles
13. peroxisomes
14. centrosome and centrioles
15. proteasomes
16. endosomes
17. extracellular matrix
18. cilia and flagella

Start from [`organelle_projects/DOCUMENT_INDEX.md`](organelle_projects/DOCUMENT_INDEX.md).

## Backend MVP

The cell-simulation backend lives in [`backend`](backend).

It adds:

- a FastAPI service for authoritative cell state and organelle simulation
- deterministic rule-based organelle agents plus optional OpenAI hooks
- SQLite-backed snapshots and pytest coverage
- example Luau bridge scripts in [`roblox_bridge`](roblox_bridge)

## Roblox Studio MCP Status

- Roblox Studio is installed at `/Applications/RobloxStudio.app`.
- Roblox Studio MCP is installed at `/Applications/RobloxStudioMCP.app/Contents/MacOS/rbx-studio-mcp`.
- The Studio plugin is installed at `~/Documents/Roblox/Plugins/MCPStudioPlugin.rbxm`.
- Codex global MCP config now includes `Roblox_Studio`.
- Verified on 2026-04-21 from Codex:
  - MCP server initializes successfully.
  - Tools are exposed over stdio.
  - `get_studio_mode` returned `stop`.
  - `run_code` executed `print("ping from codex")` and returned `[OUTPUT] ping from codex`.

Current Codex sessions may need to be restarted before the native `mcp__Roblox_Studio__...` tools appear in tool discovery. Until then, `tools/roblox_mcp_smoke.py` can exercise the MCP server directly.

The saved smoke test treats Luau execution as the required check because that is the path used to build places:

```bash
python3 tools/roblox_mcp_smoke.py
```

## Cell Biology Game Prototype

The first source-driven Roblox prototype lives in `src/CellExperience`.
It builds a large explorable animal cell with generated Roblox parts only:

- membrane, cytoplasm, membrane proteins, and cytoskeleton
- nucleus, nucleolus, chromatin, rough ER, smooth ER, and ribosomes
- mitochondria, Golgi body, lysosomes, vesicles, and small vacuoles
- a pilotable explorer capsule/submarine with floating movement constraints
- 14 in-world learning hotspots with concise biology explanations

The project now uses a two-stage content pipeline:

1. `python3 tools/generate_cell_specs.py`
   - emits deterministic Luau geometry data under `src/CellExperience/Data/Generated`
2. `python3 tools/deploy_to_studio.py`
   - copies the full source tree into Studio and rebuilds the place

This lets the organelle builders consume dense generated geometry specs instead of
hardcoding a small number of primitive parts directly inside the Luau modules.

Deploy or refresh the open Roblox Studio place:

```bash
python3 tools/generate_cell_specs.py
python3 tools/deploy_to_studio.py
```

Validate the generated edit-mode hierarchy:

```bash
python3 tools/validate_studio_scene.py
```

Run a short server-only play validation for generated scripts:

```bash
python3 tools/validate_play_server.py
```

Print a structural/scale audit:

```bash
python3 tools/audit_studio_scene.py
```

## Backend Tests

```bash
cd backend
python3 -m venv .venv
./.venv/bin/pip install -e .[dev]
./.venv/bin/pytest
```
