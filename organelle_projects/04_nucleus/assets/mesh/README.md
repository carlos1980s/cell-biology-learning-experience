# Nucleus Mesh Assets

Generated OBJ files in this folder are the first mesh-based art direction for
the walkable nucleus.

## Import Workflow

1. Run:

   ```bash
   python3 tools/generate_nucleus_mesh_assets.py
   ```

2. In Roblox Studio, use the 3D Importer to import:

   - `nucleus_organic_shell_v1.obj`
   - `nucleolus_core_v1.obj`
   - `nuclear_pore_gate_ring_v1.obj`

3. Copy the generated Roblox asset IDs into:

   `src/CellExperience/Data/NucleusMeshAssets.lua`

4. Redeploy:

   ```bash
   python3 tools/deploy_to_studio.py
   ```

The visual mesh should remain separate from collision. The current nucleus code
keeps simple floors, ramps, and invisible guide walls for reliable walking.
