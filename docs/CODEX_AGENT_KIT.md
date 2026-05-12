# Codex Cell Biology Agent Kit

This repository contains the reusable Codex context for the Cell Blender to
Roblox biology workflow: project rules, organelle briefs, nucleus part-agent
instructions, review protocols, Roblox import rules, and Codex skill folders.

Use this when starting a different Codex session or a different Codex account
that needs to continue the same cell-biology production method.

## Quick Start In A New Codex Account

1. Clone the repository.

```bash
git clone https://github.com/carlos1980s/cell-biology-learning-experience.git
cd cell-biology-learning-experience
```

2. Open Codex with the repository root as the workspace.

Codex should read the root `AGENTS.md` as the production contract. The active
focus is the nucleus, with part-level work under `organelles/nucleus/parts/`.

3. Install the reusable skills.

```bash
bash tools/install_codex_cell_biology_skills.sh
```

Restart the Codex session after installing skills so they appear in the next
session context.

## Skill Catalog

- `director-orchestrator` coordinates the full cell-production pipeline.
- `nucleus-director` coordinates nucleus-only part production.
- `nucleus-part-builder` builds one nucleus part in its scoped folder.
- `nucleus-part-reviewer` reviews one nucleus part against visual, biology,
  export, and pipeline criteria.
- `organelle-builder` builds one organelle production phase.
- `visual-quality-reviewer` reviews organic visual quality from render evidence.
- `biology-accuracy-reviewer` reviews biological correctness and naming.
- `roblox-import-assembly` drives the Blender-to-Roblox import and validation
  loop.
- `integration-reviewer` checks approved organelles as a whole-cell assembly.

## Important Entry Points

- `AGENTS.md` is the top-level production contract.
- `PROJECT_PIPELINE.md` defines the phase-based workflow.
- `STYLE_BIBLE.md` defines the premium organic visual standard.
- `BIOLOGY_RULES.md` defines biological accuracy requirements.
- `ROBLOX_EXPORT_RULES.md` defines Roblox package and import readiness.
- `REVIEW_PROTOCOL.md` defines pass/fail review evidence.
- `docs/MULTI_AGENT_PRODUCTION_SYSTEM.md` explains the agent workflow.
- `organelles/nucleus/NUCLEUS_PIPELINE.md` is the active nucleus pipeline.
- `organelles/nucleus/PART_AGENT_TEMPLATE.md` is the template for new part
  agents.

## Working Rule For New Sessions

Do not scale to every organelle first. Prove the full loop on the nucleus:
Blender source, review renders, JSON reviews, Roblox package/import readiness,
edit-mode validation, and play-mode validation. Then reuse that same evidence
loop for the next organelle.
