# Cell Classroom V3 Recovery

V3 is the named recoverable baseline for the current classroom experience. It
consolidates the working V7/V23 runtime into one restore path so future work can
recover the playable class without repairing the live Studio scene manually.

## Source Of Truth

- Recovery bundle: `releases/cell_classroom_v3_recoverable_2026-05-14/`
- Restore helper: `tools/restore_cell_classroom_v3.py`
- Studio installer: `tools/install_cell_classroom_v7_dev.py`
- Runtime root: `Workspace.CellClassroom_V7_Dev`
- Version attribute: `CellClassroom_V3_Recoverable`
- Recoverable baseline attributes:
  - `RecoverableBaselineAlias = "V3"`
  - `RecoverableBaselineName = "CellClassroom_V3"`
  - `RecoveryBundleName = "cell_classroom_v3_recoverable_2026-05-14"`

The runtime root intentionally keeps the historical V7 name to avoid breaking
the installed remotes, scripts, and telemetry readers. V3 is the recovery
baseline name, not a permission to mutate source assets.

## What V3 Contains

- Full 18-segment nucleus classroom flow using the existing uploaded V4 audio.
- Extended intro with narration and music.
- Grounded walking navigation with no upward drift.
- Dr Riviera soft-bubble teaching formation.
- Teacher pointer beam and component highlights.
- DNA/RNA transcription teaching interaction.
- Post-class free exploration: guided camera, locator, and auto-follow assist
  release after the class completes.
- Telemetry with player, camera, teacher, audio, component, and free-explore
  state.

## Restore

Restore files from the bundle:

```bash
python3 tools/restore_cell_classroom_v3.py
```

Restore files and reinstall into the open Roblox Studio scene:

```bash
python3 tools/restore_cell_classroom_v3.py --install --timeout 360
```

The installer only rebuilds the scoped V3 runtime. It must not save, publish, or
mutate `Workspace.MeshLibrary`, imported Blender sources, `Workspace.Nucleus_Model`,
or production V6.

## Validation

Before accepting a restored V3 scene:

1. Compile the restore and installer tools.
2. Install into the open Studio scene.
3. Confirm `Workspace.CellClassroom_V7_Dev` exists.
4. Confirm runtime attributes report V3.
5. Confirm the nucleus clone has nonzero MeshParts.
6. Confirm the client and server scripts are enabled/present.
7. Confirm `NoSaveNoPublishGate = true`.
8. Run a Play-mode pass when Studio MCP is healthy.
9. Verify the final class state releases the camera to normal player control.

## Safety Rule

If the live scene diverges, restore V3 from the bundle instead of repairing the
live scene by broad name-matching. Any new experiment must either update this
V3 bundle deliberately or create a later named baseline.
