# Roblox Integration Notes

## Core principle
The nucleus should import into Roblox as a cohesive `Model` with a clear primary pivot and separate functional submodels. Do not collapse the entire nucleus into one mesh.

## Recommended Roblox model tree

```text
Nucleus_Model
├── PrimaryPart: NucleusSocket_Center or Nucleus_RootRig_Proxy
├── NuclearEnvelope
├── NuclearPoreSystem
├── NuclearLamina
├── Nucleoplasm
├── GenomeSystem
├── Nucleolus
├── TransportSystem
├── ERConnection
├── MitosisFragments
├── InteractionHotspots
└── ReviewLabels
```

## Animation scripting targets

- `Hotspot_Transport` triggers import/export path tweens.
- `Hotspot_Transcription` highlights `TranscriptionHotspot_01..03`.
- `Hotspot_Mitosis` switches visibility between interphase chromatin and condensed chromosomes, then splits envelope panels.
- `Hotspot_Envelope` highlights outer membrane, inner membrane, and perinuclear lumen.
- `Hotspot_Nucleolus` pulses nucleolus subregions and starts ribosomal export cargo.
- `Hotspot_Chromatin` toggles euchromatin/heterochromatin highlights.

## Export rules

1. Keep separate objects for anything that must animate.
2. Merge only repeated non-animated decorations after validation.
3. Keep panel surfaces thick enough for Roblox; avoid single-sided sheets.
4. Bake complex procedural textures into simple colors/normal maps if needed.
5. Transparent materials should be limited and readable.
6. Use LOD1/LOD2 for gameplay if LOD0 is too heavy.
7. Record triangle count for each group before import.
