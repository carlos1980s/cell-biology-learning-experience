# Cell Biology Learning Experience

This source folder defines a repeatable Roblox Studio build for a large, explorable
animal eukaryotic cell aimed at learners around ages 12-14.

## Build Shape

- `OrganelleModels/` creates biological sub-models as Roblox `Model` instances.
- `Gameplay/` creates the floating explorer craft, camera/player helpers, and movement tuning.
- `Education/` creates inspectable hotspots with concise learning text.
- `BuildCellExperience.server.lua` assembles the scene into `Workspace.CellBiologyExperience`.

## Scale

The main cell is a large translucent sphere/ovoid roughly 420 studs across. The
player starts inside a small science-sub craft and explores by floating through
cytoplasm. Organelle models should be readable from a distance, but include
smaller details close up: ribosomes on rough ER, mitochondrial cristae, nuclear
pores, Golgi vesicles, cytoskeleton strands, and membrane channel/protein hints.

## Biology Scope

Default assumption: animal eukaryotic cell. Include membrane, cytoplasm, nucleus,
nucleolus, chromatin, rough ER, smooth ER, ribosomes, mitochondria, Golgi body,
lysosomes, small vacuoles/vesicles, and cytoskeleton.

## Module Contract

Organelle modules return a table with a `build(parent, utils, spec)` function.
The function creates its own model under `parent`, names all major children, and
returns the model plus a list of educational hotspot descriptors:

```lua
return model, {
    {
        id = "nucleus",
        title = "Nucleus",
        body = "Controls cell activities and stores DNA.",
        position = Vector3.new(0, 0, 0),
    },
}
```

All code should avoid external marketplace assets. The build must use Roblox
parts, meshes, beams, particle emitters, lights, and materials generated from
Luau.
