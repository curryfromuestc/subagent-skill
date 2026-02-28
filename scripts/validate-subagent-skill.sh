#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR"

echo "[0/4] Refresh shared symlinks"
scripts/sync-shared-assets.sh >/dev/null

echo "[1/4] Validate skill structure"
for f in skills/spawn-coding-worker/SKILL.md \
         skills/spawn-coding-worker/scripts/spawn-coding-worker.sh \
         skills/spawn-coding-worker/scripts/cc_env.sh \
         skills/spawn-coding-worker/references/spawn-workflow.md \
         skills/spawn-coding-worker/agents/openai.yaml; do
  if [[ ! -e "$f" ]]; then
    echo "Error: missing required file: $f" >&2
    exit 1
  fi
done
echo "  Skill structure OK"

echo "[2/4] Validate shell syntax"
bash -n scripts/spawn-coding-worker.sh

echo "[3/4] Validate plugin manifest JSON"
python3 -m json.tool .claude-plugin/plugin.json >/dev/null

echo "[4/4] Validate help output"
scripts/spawn-coding-worker.sh --help >/dev/null

echo
echo "Static validation passed."
echo "Run docs/VALIDATION.md for runtime matrix checks."
