#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VALIDATOR="/home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py"

cd "$ROOT_DIR"

echo "[1/4] Validate skill structure"
python3 "$VALIDATOR" skills/spawn-codex-worker
python3 "$VALIDATOR" .claude/skills/spawn-codex-worker
python3 "$VALIDATOR" plugin/claude-codex-subagent/skills/spawn-codex-worker

echo "[2/4] Validate shell syntax"
bash -n scripts/spawn-codex-worker.sh
bash -n scripts/spawn-claude-worker.sh

echo "[3/4] Validate plugin manifest JSON"
python3 -m json.tool plugin/claude-codex-subagent/.claude-plugin/plugin.json >/dev/null

echo "[4/4] Validate help output"
scripts/spawn-codex-worker.sh --help >/dev/null
scripts/spawn-claude-worker.sh --help >/dev/null

echo
echo "Static validation passed."
echo "Run docs/VALIDATION.md for 2x2 runtime matrix checks."
