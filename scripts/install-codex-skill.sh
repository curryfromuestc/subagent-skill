#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
DEST="$SKILLS_DIR/spawn-coding-worker"

if [[ -d "$DEST" ]]; then
  echo "Existing installation found at $DEST"
  echo "Removing old version..."
  rm -rf "$DEST"
fi

mkdir -p "$SKILLS_DIR"
cp -R "$ROOT_DIR/skills/spawn-coding-worker" "$DEST"

echo "Installed spawn-coding-worker skill to $DEST"
echo "Use \$spawn-coding-worker in Codex sessions to invoke."
