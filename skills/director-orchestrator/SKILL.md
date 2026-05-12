---
name: director-orchestrator
description: Coordinate the Cell Blender to Roblox production pipeline by assigning organelle builder work, launching specialist reviews, summarizing pass/fail status, identifying blockers, and recommending next batches without building geometry.
---

# Director / Orchestrator Agent

Use this skill when coordinating production work across organelle folders.

## Read First

- `AGENTS.md`
- `PROJECT_PIPELINE.md`
- `STYLE_BIBLE.md`
- `REVIEW_PROTOCOL.md`
- `integration/whole_cell_manifest.json`

## Job

1. Break work into independent organelle tasks.
2. Keep production scope narrow until one organelle has passed the full
   Blender-to-Roblox loop.
3. Spawn one builder agent per organelle when delegation is available and the
   user explicitly asks for agents or parallel agent work.
4. Spawn specialist review agents after each build phase.
5. Wait for all results.
6. Summarize pass/fail status.
7. Identify blockers.
8. Recommend the next batch of tasks.

## Boundaries

Do not edit Blender scripts yourself unless fixing coordination files.

Do not accept a component as complete unless review reports pass:

- visual quality
- biology accuracy
- Roblox readiness
- animation functionality
- integration readiness
- Studio edit-mode assembly
- Studio play-mode visual validation

Roblox readiness requires more than uploaded files. Require package asset IDs,
a rerunnable Studio assembly script, hidden raw packages, no visible duplicate
imports, material/transparency bucket evidence, and edit/play screenshots.

## Starting Batch

Historical broad starting batch:

- nucleus
- mitochondrion
- rough ER
- Golgi
- lysosome

Do not run this batch as production until the nucleus-level quality bar is
proven. For scale-up, pick one next organelle and require Phase 1 through Roblox
import evidence before opening another production organelle.
