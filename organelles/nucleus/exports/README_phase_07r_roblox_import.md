# Phase 07R Roblox Group Import

This is the production import path for the nucleus through rough ER.

## Export from Blender

```bash
blender --background --python tools/export_nucleus_phase07r_roblox_groups.py
python3 tools/validate_nucleus_phase07r_roblox_export_manifest.py
```

Outputs:

- `organelles/nucleus/exports/phase_07r_roblox/*.fbx`
- `organelles/nucleus/exports/nucleus_phase_07r_roblox_asset_manifest.json`

The exporter builds group-level FBX files from `manifest_component` tags and
excludes cameras, lights, reference planes, review boards, and hidden mitosis
markers.

## Upload Through Roblox Open Cloud

Set credentials in the shell:

```bash
export ROBLOX_OPEN_CLOUD_API_KEY="..."
export ROBLOX_GROUP_ID="..."
```

Dry-run request payloads:

```bash
python3 tools/upload_nucleus_phase07r_open_cloud_assets.py --dry-run
```

Real upload:

```bash
python3 tools/upload_nucleus_phase07r_open_cloud_assets.py
```

The uploader writes returned operation/package asset data back into
`nucleus_phase_07r_roblox_asset_manifest.json`.

## Assemble in Roblox Studio

After every group has a `package_asset_id`:

```bash
python3 tools/assemble_nucleus_phase07r_packages_in_studio.py --legacy-bridge
python3 tools/validate_nucleus_phase07r_studio_assembly.py --legacy-bridge
```

Studio hierarchy:

```text
Workspace
├── MeshLibrary
│   └── Nucleus_Phase07R_RawPackages
└── Nucleus_Model
    ├── NucleusEnvelope
    ├── NuclearPoreComplexes
    ├── NuclearLamina
    ├── Nucleoplasm
    ├── Chromatin
    ├── Nucleolus
    ├── TransportCargo
    ├── RoughERConnection
    ├── CollisionProxy
    └── AnchorSockets
```
