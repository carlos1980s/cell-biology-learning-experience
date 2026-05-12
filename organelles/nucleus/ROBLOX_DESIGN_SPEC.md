# Nucleus Roblox Design Spec

This document defines how the nucleus should be designed for Roblox before
additional nucleus geometry is built.

## Current Status

Phase 2 produced the first envelope-system anatomy:

- `OuterNuclearMembrane_Panels`
- `InnerNuclearMembrane_Panels`
- `PerinuclearLumen_Segments`
- `NuclearPore_Complexes`
- `NuclearPore_GateCores`
- partial `NuclearLamina_Lattice`

Do not add nucleoplasm, chromatin, nucleolus, cargo, ER connection, mitosis
fragments, or hotspots until this envelope system has a Roblox-safe design.

## Reference Baselines

Use these as review baselines:

- `reference_images/nucleus_specs/01_nuclear_envelope.png`
- `reference_images/nucleus_specs/02_nuclear_pores.png`
- `reference_images/nucleus_specs/06_nuclear_lamina.png`

The references define biological read, color language, and component
relationships. They are not flat geometry templates.

## Roblox Object Contract

Recommended Roblox hierarchy:

```text
Nucleus_Model
├── Nucleus_RootRig              # Model pivot / metadata equivalent
├── WholeCell_ContextSocket      # Attachment or hidden anchor
├── OuterNuclearMembrane_Panels
├── InnerNuclearMembrane_Panels
├── PerinuclearLumen_Segments
├── NuclearPore_Complexes
├── NuclearPore_GateCores
└── NuclearLamina_Lattice
```

`Nucleus_RootRig` should become the Roblox model pivot or a hidden root
Attachment. `WholeCell_ContextSocket` should become a placement Attachment or
metadata object, not visible biological geometry.

## Material Fallbacks

Blender procedural nodes will not be trusted as final Roblox materials.

| Blender Intent | Roblox Fallback |
| --- | --- |
| purple organic membrane with noise/bump | MeshPart with purple material, baked color variation texture if needed |
| glowing perinuclear lumen | simple cyan/blue emissive-style material or thin neon accent mesh |
| violet pore complexes | separate violet MeshPart or baked vertex color |
| cyan/violet gate cores | lower-poly central gate mesh with clear contrast |
| gold lamina | simplified gold lattice mesh or baked line texture |

## Budget Targets

Envelope-system target before internal detail:

- mesh objects: 8-16
- triangles: target under 45k, hard cap 65k before LOD
- materials: 6 or fewer preferred
- textures: 0-3 baked maps

If the envelope exceeds the target, do not add chromatin or nucleolus until LOD
variants are created.

## LOD Requirements

Create at least two future variants:

- `Nucleus_Hero_LOD0`: close inspection model
- `Nucleus_Game_LOD1`: normal gameplay model

Pores and lamina should reduce first in `LOD1`; envelope silhouette and double
layer readability must remain.

## Animation Hooks

Reserve named animation hooks:

- `InspectEnvelope`
- `HighlightPores`
- `PulsePerinuclearLumen`
- `ShowSelectiveGate`
- `HighlightLamina`
- `EnvelopeBreakdownFuture`
- `EnvelopeReassemblyFuture`

Animation should teach function. Avoid constant decorative motion.

## Export Rules

Before Roblox import:

- apply or bake transforms
- keep exact manifest names
- exclude cameras/lights/review-only guides
- document material fallbacks
- record object, triangle, material, and texture counts
- verify root pivot/socket behavior in Roblox

## Export Package

The current Phase 2 design package is:

- `organelles/nucleus/exports/nucleus_phase_02_export_manifest.json`

Validate the design package before further modeling:

```bash
python3 tools/validate_nucleus_roblox_design.py
```

This does not replace a Roblox Studio import test. It only verifies that the
design/export contract is complete enough to guide the next build pass.
