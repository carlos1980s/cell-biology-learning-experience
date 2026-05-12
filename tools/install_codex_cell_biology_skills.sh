#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="${CODEX_HOME:-$HOME/.codex}/skills"

mkdir -p "$DEST_DIR"

for skill_dir in "$ROOT_DIR"/skills/*; do
  [ -d "$skill_dir" ] || continue
  [ -f "$skill_dir/SKILL.md" ] || continue

  skill_name="$(basename "$skill_dir")"
  mkdir -p "$DEST_DIR/$skill_name"
  rsync -a "$skill_dir/" "$DEST_DIR/$skill_name/"
done

printf 'Installed Cell Biology Codex skills into %s\n' "$DEST_DIR"
