# Organelle Projects

This folder breaks the Roblox human-cell experience into independent organelle
projects. Each project should be developed as a movable Roblox `Model` with a
consistent build contract, then assembled into the full cell scene.

## Project Layout

Each organelle folder uses the same shape:

- `src/` - Luau source for the organelle builder module.
- `specs/` - geometry, scale, color, hotspot, and interaction metadata.
- `assets/` - local reference images, concept notes, or generated visual assets.
- `tests/` - validation scripts or notes for Studio/play-mode checks.
- `docs/` - design notes, biology scope, and implementation decisions.
- `exports/` - optional `.rbxm`, screenshots, or generated handoff artifacts.

## Organelle Order

1. `01_membrane`
2. `02_cytoplasm`
3. `03_cytoskeleton`
4. `04_nucleus`
5. `05_nucleolus_chromatin`
6. `06_rough_er`
7. `07_smooth_er`
8. `08_ribosomes`
9. `09_mitochondria`
10. `10_golgi_apparatus`
11. `11_lysosomes`
12. `12_vesicles_vacuoles`
13. `13_peroxisomes`
14. `14_centrosome_centrioles`
15. `15_proteasomes`
16. `16_endosomes`
17. `17_extracellular_matrix`
18. `18_cilia_flagella`

## Roblox Assembly Contract

Each organelle project should eventually produce a ModuleScript-compatible Luau
module with this contract:

```lua
local Organelle = {}

function Organelle.build(parent, utils, spec)
    local model = utils.model(parent, "OrganelleName")
    -- Build parts under model.
    return model, {
        {
            id = "organelle_id",
            title = "Organelle Name",
            body = "Short learning explanation.",
            position = model:GetPivot().Position,
        },
    }
end

return Organelle
```

The full game should assemble these modules through
`src/CellExperience/OrganelleRegistry.lua`.

## Model Requirements

Each organelle should be a self-contained Roblox `Model`:

- Use `Model:PivotTo()` for placement and motion.
- Set a stable pivot or invisible root `Part` so the model can be moved as one
  unit.
- Put all visual parts, effects, attachments, and interaction markers under the
  organelle model.
- Add attributes such as `OrganelleId`, `DisplayName`, `BiologyRole`, and
  `AssemblyLayer`.
- Prefer generated Roblox parts, meshes, beams, particle emitters, and
  constraints over external marketplace assets.
- Keep educational hotspots separate from visual geometry so the same model can
  be used for exploration, quizzes, or guided tours.
