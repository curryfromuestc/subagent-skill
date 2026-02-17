#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Spawn a Claude Code subagent in non-interactive mode.

Usage:
  scripts/spawn-claude-worker.sh --task "Implement auth API" [options]

Options:
  --task <text>              Task prompt for claude -p (required)
  --name <id>                Worker name/session id (default: claude-worker-<timestamp>)
  --type <agent-type>        claude-flow agent type for spawn (default: coder)
  --model <model>            Claude model alias/name (default: sonnet)
  --permission-mode <mode>   acceptEdits|bypassPermissions|default|delegate|dontAsk|plan (default: bypassPermissions)
  --output-format <format>   text|json|stream-json (default: text)
  --workdir <path>           Working directory (default: current directory)
  --result <path>            Result output path (default: .claude-flow/results/<name>.md)
  --log <path>               Stderr log path (default: .claude-flow/logs/<name>.log)
  --dangerous                Add --dangerously-skip-permissions (default: on)
  --no-dangerous             Do not add --dangerously-skip-permissions
  --no-spawn                 Skip "npx claude-flow agent spawn"
  --background               Run worker in background
  --help                     Show this help

Examples:
  scripts/spawn-claude-worker.sh \
    --name claude-coder-1 \
    --type coder \
    --task "Implement user service and tests"

  scripts/spawn-claude-worker.sh \
    --name claude-reviewer-1 \
    --type reviewer \
    --task "Review src/auth for security gaps" \
    --background
EOF
}

task=""
name=""
agent_type="coder"
model="sonnet"
permission_mode="bypassPermissions"
output_format="text"
workdir="$(pwd)"
result_path=""
log_path=""
dangerous=1
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
    --permission-mode)
      permission_mode="${2:-}"
      shift 2
      ;;
    --output-format)
      output_format="${2:-}"
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
    --dangerous)
      dangerous=1
      shift
      ;;
    --no-dangerous)
      dangerous=0
      shift
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
  name="claude-worker-$(date +%Y%m%d%H%M%S)"
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "Error: claude CLI not found in PATH." >&2
  exit 1
fi

if [[ ! -d "$workdir" ]]; then
  echo "Error: workdir does not exist: $workdir" >&2
  exit 1
fi

case "$permission_mode" in
  acceptEdits|bypassPermissions|default|delegate|dontAsk|plan) ;;
  *)
    echo "Error: invalid --permission-mode value: $permission_mode" >&2
    exit 1
    ;;
esac

case "$output_format" in
  text|json|stream-json) ;;
  *)
    echo "Error: invalid --output-format value: $output_format" >&2
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

claude_cmd=(
  claude
  -p
  --model "$model"
  --permission-mode "$permission_mode"
  --output-format "$output_format"
  "$task"
)

if [[ "$dangerous" -eq 1 ]]; then
  claude_cmd=(
    claude
    -p
    --model "$model"
    --permission-mode "$permission_mode"
    --output-format "$output_format"
    --dangerously-skip-permissions
    "$task"
  )
fi

echo "[run] (cd \"$workdir\" && ${claude_cmd[*]})"
echo "[log] $log_path"
echo "[result] $result_path"

if [[ "$background" -eq 1 ]]; then
  (
    cd "$workdir"
    "${claude_cmd[@]}" >"$result_path" 2>"$log_path"
  ) &
  pid=$!
  echo "[pid] $pid"
  exit 0
fi

(
  cd "$workdir"
  "${claude_cmd[@]}" 2> >(tee "$log_path" >&2)
) | tee "$result_path"
