# Project Structure

This repository is organized around a Roblox learning experience with a
server-side simulation backend and research/design documentation for each cell
structure.

```text
.
├── backend/                    # FastAPI simulation authority and tests
├── docs/                       # Architecture, Roblox MCP, and development plans
├── organelle_projects/         # Per-organelle research/design workspaces
├── roblox_bridge/              # Luau scripts for backend communication
├── src/CellExperience/         # Source-driven Roblox place builder
├── tools/                      # Generation, deployment, and validation scripts
├── AnimalCellVillageBuilder.server.lua
├── README.md
└── CONTRIBUTING.md
```

## Core Layers

- `src/CellExperience` builds the Roblox world from Luau modules and generated
  geometry specs.
- `backend` owns canonical simulation state, biology rules, organelle agents,
  and API contracts.
- `roblox_bridge` shows how Roblox server scripts communicate with the backend
  through `HttpService`.
- `organelle_projects` is the planning and research layer for organelles and
  cell structures before they become production Roblox modules.

## Organelle Project Contract

Each organelle project should eventually produce a ModuleScript-compatible Luau
builder:

```lua
function Organelle.build(parent, utils, spec)
    return model, hotspots
end
```

The returned `model` should be movable as one Roblox `Model`, and `hotspots`
should describe the student-facing learning points.

