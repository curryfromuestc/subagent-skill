#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR"

require_path() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo "Error: required path not found: $path" >&2
    exit 1
  fi
}

link_path() {
  local link_path="$1"
  local target="$2"
  rm -rf "$link_path"
  ln -s "$target" "$link_path"
  echo "[link] $link_path -> $target"
}

require_path "skills/spawn-coding-worker/SKILL.md"
require_path "skills/spawn-coding-worker/scripts/spawn-coding-worker.sh"
require_path "skills/spawn-coding-worker/scripts/cc_env.sh"
require_path "skills/spawn-coding-worker/references/spawn-workflow.md"
require_path "skills/spawn-coding-worker/agents/openai.yaml"

link_path "scripts/spawn-coding-worker.sh" "../skills/spawn-coding-worker/scripts/spawn-coding-worker.sh"
link_path "scripts/cc_env.sh" "../skills/spawn-coding-worker/scripts/cc_env.sh"

echo
echo "Shared links refreshed."
