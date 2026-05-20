# Nucleus Mesh Experience

Clean standalone Roblox prototype for the nucleus as a walkable, organic biological building.

This experience is intentionally separate from `src/CellExperience` so the mesh direction can be tested without the older assembled cell scene.

## Assets

Generated source mesh files live in:

```text
organelle_projects/04_nucleus/assets/mesh/
```

The deployment path reads those OBJ files and converts them into Roblox `EditableMesh` geometry inside a fresh Studio scene.

## Deploy

```bash
blender --background --python tools/blender_generate_nucleus_mesh_assets.py
python3 tools/deploy_nucleus_mesh_experience.py
```

The deploy script clears the current Studio workspace and creates a new standalone scene named `NucleusMeshExperience`.

## Notes

- The Blender OBJ files remain the source of truth.
- Roblox does not allow a normal game script to assign `MeshPart.MeshId` from a local OBJ file path.
- This prototype uses `AssetService:CreateEditableMesh()` and `AssetService:CreateMeshPartAsync(Content.fromObject(...))` to create the mesh geometry directly in Studio.
- Floors, ramps, labels, and collision guides remain Roblox parts so the nucleus is walkable and functional.
