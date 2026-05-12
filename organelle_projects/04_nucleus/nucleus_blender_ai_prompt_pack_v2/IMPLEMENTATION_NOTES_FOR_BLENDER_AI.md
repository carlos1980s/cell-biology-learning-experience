# IMPLEMENTATION NOTES FOR THE BLENDER AI CODER

## Recommended coding approach

Use helper functions:
- `create_material(name, color, alpha, emission=False, roughness=0.5, metallic=0.0)`
- `create_uv_sphere(name, radius, location, material, segments, rings)`
- `create_shell_panel(name, radius, thickness, theta_range, phi_range, material)`
- `create_torus_or_ring(name, location, normal, radius, tube_radius, material)`
- `create_beveled_curve(name, points, bevel_depth, material)`
- `create_label(text, location, size, target_camera)`
- `parent_to(obj, parent_empty)`
- `key_visibility(obj, frame, visible)`
- `key_location(obj, frame, location)`
- `key_scale(obj, frame, scale)`
- `set_origin_to_center(obj)`

## Procedural geometry suggestions

- Nuclear envelope panels:
  Use parametric spherical patches. Generate vertices by sampling theta/phi ranges. Add thickness by duplicating inner/outer patch surfaces and side walls.

- NPC placement:
  Use Fibonacci sphere distribution or selected fixed points. Avoid placing too many pores in the front cutaway opening. Align rings to surface normals.

- Lamina:
  Use a set of curved arcs on the inside radius. Beveled curves are easier and lighter than complex meshes.

- Chromatin:
  Use random walk curves constrained inside radius 2.5. Use deterministic seed so output is reproducible.

- Nucleolus:
  Use UV sphere with noise displacement modifier, then shade smooth.

- ER connection:
  Use wavy sheet meshes or stacked flattened tubes attached to the right/back side of the outer membrane. Add orange ribosome dots.

## Roblox export suggestions

- Keep named components separate.
- Apply transforms before export only after animation rig decisions are final.
- Bake procedural materials into simple base color/roughness/emission maps if needed.
- Convert curves to mesh only for final export, keep editable curves in Blender source.
- Keep a `SOURCE_CONTROLS` collection hidden if helper curves/empties should not export.