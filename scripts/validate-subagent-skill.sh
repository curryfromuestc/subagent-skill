#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VALIDATOR="/home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py"

cd "$ROOT_DIR"

echo "[1/4] Validate skill structure"
python3 "$VALIDATOR" skills/spawn-coding-worker
python3 "$VALIDATOR" .claude/skills/spawn-coding-worker
python3 "$VALIDATOR" plugin/spawn-coding-worker/skills/spawn-coding-worker

echo "[2/4] Validate shell syntax"
bash -n scripts/spawn-coding-worker.sh

echo "[3/4] Validate plugin manifest JSON"
python3 -m json.tool plugin/spawn-coding-worker/.claude-plugin/plugin.json >/dev/null

echo "[4/4] Validate help output"
scripts/spawn-coding-worker.sh --help >/dev/null

echo
echo "Static validation passed."
echo "Run docs/VALIDATION.md for runtime matrix checks."
