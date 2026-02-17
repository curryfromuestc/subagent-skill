#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Spawn a codex subagent with optional claude-flow agent registration.

Usage:
  scripts/spawn-codex-worker.sh --task "Implement auth API" [options]

Options:
  --task <text>          Task prompt for codex exec (required)
  --name <id>            Worker name/session id (default: codex-worker-<timestamp>)
  --type <agent-type>    claude-flow agent type for spawn (default: coder)
  --model <model>        Codex model (default: gpt-5.3-codex)
  --sandbox <mode>       read-only|workspace-write|danger-full-access (default: workspace-write)
  --workdir <path>       Working directory (default: current directory)
  --result <path>        Result markdown path (default: .claude-flow/results/<name>.md)
  --log <path>           Log file path (default: .claude-flow/logs/<name>.log)
  --no-spawn             Skip "npx claude-flow agent spawn"
  --background           Run codex exec in background
  --help                 Show this help

Examples:
  scripts/spawn-codex-worker.sh \
    --name coder-1 \
    --type coder \
    --task "Implement user service and tests"

  scripts/spawn-codex-worker.sh \
    --name tester-1 \
    --type tester \
    --task "Write integration tests for auth endpoints" \
    --background
EOF
}

task=""
name=""
agent_type="coder"
model="gpt-5.3-codex"
sandbox="workspace-write"
workdir="$(pwd)"
result_path=""
log_path=""
do_spawn=1
background=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      task="${2:-}"
      shift 2
      ;;
    --name)
      name="${2:-}"
      shift 2
      ;;
    --type)
      agent_type="${2:-}"
      shift 2
      ;;
    --model)
      model="${2:-}"
      shift 2
      ;;
    --sandbox)
      sandbox="${2:-}"
      shift 2
      ;;
    --workdir)
      workdir="${2:-}"
      shift 2
      ;;
    --result)
      result_path="${2:-}"
      shift 2
      ;;
    --log)
      log_path="${2:-}"
      shift 2
      ;;
    --no-spawn)
      do_spawn=0
      shift
      ;;
    --background)
      background=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$task" ]]; then
  echo "Error: --task is required." >&2
  usage
  exit 1
fi

if [[ -z "$name" ]]; then
  name="codex-worker-$(date +%Y%m%d%H%M%S)"
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "Error: codex CLI not found in PATH." >&2
  exit 1
fi

if [[ ! -d "$workdir" ]]; then
  echo "Error: workdir does not exist: $workdir" >&2
  exit 1
fi

case "$sandbox" in
  read-only|workspace-write|danger-full-access) ;;
  *)
    echo "Error: invalid --sandbox value: $sandbox" >&2
    exit 1
    ;;
esac

if [[ -z "$result_path" ]]; then
  result_path=".claude-flow/results/${name}.md"
fi

if [[ -z "$log_path" ]]; then
  log_path=".claude-flow/logs/${name}.log"
fi

mkdir -p "$(dirname "$result_path")" "$(dirname "$log_path")"

if [[ "$do_spawn" -eq 1 ]]; then
  echo "[spawn] npx claude-flow agent spawn --type \"$agent_type\" --name \"$name\""
  npx claude-flow agent spawn --type "$agent_type" --name "$name"
fi

codex_cmd=(
  codex exec
  -C "$workdir"
  -m "$model"
  --sandbox "$sandbox"
  --full-auto
  -o "$result_path"
  "$task"
)

echo "[run] ${codex_cmd[*]}"
echo "[log] $log_path"
echo "[result] $result_path"

if [[ "$background" -eq 1 ]]; then
  "${codex_cmd[@]}" >"$log_path" 2>&1 &
  pid=$!
  echo "[pid] $pid"
  exit 0
fi

"${codex_cmd[@]}" 2>&1 | tee "$log_path"
