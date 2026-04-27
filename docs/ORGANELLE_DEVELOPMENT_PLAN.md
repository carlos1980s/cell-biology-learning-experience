# Organelle Development Plan

## Recommended Roblox Object Model

Build each organelle as a Roblox `Model`, not as a loose group of parts. A model
gives us a single unit that can be moved, scaled conceptually, tagged, inspected,
and assembled into the final human-cell scene.

Use this hierarchy inside each model:

```text
OrganelleModel
  PivotRoot              -- invisible anchored/base part or central reference
  Visuals                -- generated parts, mesh parts, beams, trails, emitters
  InteractionMarkers     -- attachments or parts used by prompts/hotspots
  Effects                -- particles, lights, motion helpers
  Metadata               -- optional configuration values or folders
```

For placement, prefer `Model:PivotTo(CFrame)` and keep all descendants under the
model. The existing `src/CellExperience` code already follows a builder-module
pattern, so each organelle project should end by producing a module with:

```lua
function Organelle.build(parent, utils, spec)
    return model, hotspots
end
```

## Development Sequence

1. Start with `01_membrane` because it defines the playable boundary, scale,
   translucent visual style, and outside/inside relationship.
2. Add `02_cytoplasm` as the navigable interior medium and spacing reference.
3. Add `03_cytoskeleton` early because it gives learners spatial orientation.
4. Build the nucleus group next: `04_nucleus` and `05_nucleolus_chromatin`.
5. Build protein-production flow: rough ER, smooth ER, ribosomes.
6. Build energy and logistics: mitochondria, Golgi, lysosomes, vesicles/vacuoles.
7. Assemble all organelles through `OrganelleRegistry.lua`.
8. Add education passes: hotspots, quiz hooks, guided routes, and backend agent
   state.

## Per-Organelle Workflow

For each organelle:

1. Fill in `organelle_projects/<name>/specs/organelle.spec.json`.
2. Prototype the builder in that organelle folder.
3. Validate it as a standalone `Model`.
4. Promote the builder into `src/CellExperience/OrganelleModels/`.
5. Register the builder in `src/CellExperience/OrganelleRegistry.lua`.
6. Deploy to Studio and validate with the existing tools.

## Design Rules

- Keep each organelle self-contained.
- Use attributes for metadata instead of relying on model names alone.
- Avoid cross-organelle hard dependencies. Communication should go through specs,
  registry, or backend state.
- Use deterministic generated geometry for dense repeated structures such as
  membrane lipids, ribosomes, pores, and vesicles.
- Keep high-detail clusters close to learning hotspots and use lower-density
  detail elsewhere.

