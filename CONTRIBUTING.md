# Contributing

This project combines Roblox Luau, Python backend services, and biology learning
design. Keep changes scoped to one layer when possible.

## Development Guidelines

- Prefer deterministic, source-generated Roblox content over marketplace assets.
- Keep each organelle as a movable Roblox `Model` with a clear builder contract.
- Preserve the backend as the authoritative simulation state owner.
- Treat LLM output as advisory; validate all game-state changes through rules.
- Add or update organelle research briefs before implementing new biological
  structures.

## Validation

Backend tests:

```bash
cd backend
python3 -m venv .venv
./.venv/bin/pip install -e .[dev]
./.venv/bin/pytest
```

Roblox source generation and Studio validation:

```bash
python3 tools/generate_cell_specs.py
python3 tools/deploy_to_studio.py
python3 tools/validate_studio_scene.py
python3 tools/audit_studio_scene.py
```

## Pull Request Checklist

- Source, docs, and generated specs are consistent.
- Backend tests pass when backend behavior changes.
- Roblox validation scripts pass when scene/build behavior changes.
- New organelles include biology scope, Roblox design notes, hotspots, and
  performance notes.

