#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Spawn a coding subagent with Claude, Codex, Gemini, or Kimi CLI.

Usage:
  scripts/spawn-coding-worker.sh --cli <claude|codex|gemini|kimi> --task "Implement auth API" [options]

Required:
  --cli <name>                  Worker CLI: claude | codex | gemini | kimi
  --task <text>                 Task prompt for the selected CLI

Common options:
  --name <id>                   Worker name/session id (default: <cli>-worker-<timestamp>)
  --type <agent-type>           claude-flow agent type for spawn (default: coder)
  --model <model>               Model alias/name for selected CLI
  --workdir <path>              Working directory (default: current directory)
  --result <path>               Result output path (default: .claude-flow/results/<name>.md)
  --log <path>                  Log file path (default: .claude-flow/logs/<name>.log)
  --no-spawn                    Skip "npx claude-flow agent spawn"
  --background                  Run worker in background
  --help                        Show this help

Codex options:
  --sandbox <mode>              read-only | workspace-write | danger-full-access
                                If omitted, uses --dangerously-bypass-approvals-and-sandbox

Claude options:
  --permission-mode <mode>      acceptEdits|bypassPermissions|default|delegate|dontAsk|plan
                                (default: bypassPermissions)
  --output-format <format>      text|json|stream-json (default: text)
  --3rd-party                   Source env script before launching claude (default: on)
  --no-3rd-party                Disable env script loading
  --3rd-party-env <path>        Env script path for --3rd-party (default: scripts/cc_env.sh)
  --dangerous                   Add --dangerously-skip-permissions (default: on)
  --no-dangerous                Do not add --dangerously-skip-permissions

Gemini options:
  --gemini-approval-mode <m>    Gemini approval mode (default: yolo)

Kimi behavior:
  Kimi runs in auto mode as: kimi --print -p "<task>"

Examples:
  scripts/spawn-coding-worker.sh --cli codex --name coder-1 --type coder --task "Implement user service and tests"
  scripts/spawn-coding-worker.sh --cli claude --name reviewer-1 --type reviewer --task "Review src/auth for security gaps"
  scripts/spawn-coding-worker.sh --cli gemini --name gemini-1 --type coder --task "Draft API tests for auth endpoints"
  scripts/spawn-coding-worker.sh --cli kimi --name kimi-1 --type reviewer --task "Explain what this code does: $(cat main.py)"
USAGE
}

task=""
cli=""
name=""
agent_type="coder"
model=""
workdir="$(pwd)"
caller_dir="$(pwd -P)"
result_path=""
log_path=""
do_spawn=1
background=0

# Codex options
sandbox=""
use_bypass=1
default_codex_home="${CODEX_HOME:-$HOME/.codex}"
codex_state_home=""

# Claude options
permission_mode="bypassPermissions"
output_format="text"
use_third_party=1
third_party_env="scripts/cc_env.sh"
third_party_env_resolved=""
dangerous=1
claude_state_home=""

# Gemini options
gemini_approval_mode="yolo"
gemini_state_home=""
default_home="$HOME"
kimi_state_home=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      task="${2:-}"
      shift 2
      ;;
    --cli)
      cli="${2:-}"
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
      use_bypass=0
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
    --3rd-party)
      use_third_party=1
      shift
      ;;
    --no-3rd-party)
      use_third_party=0
      shift
      ;;
    --3rd-party-env)
      third_party_env="${2:-}"
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
    --gemini-approval-mode)
      gemini_approval_mode="${2:-}"
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

if [[ -z "$cli" ]]; then
  echo "Error: --cli is required (claude|codex|gemini|kimi)." >&2
  usage
  exit 1
fi

case "$cli" in
  claude|codex|gemini|kimi) ;;
  *)
    echo "Error: invalid --cli value: $cli (expected claude|codex|gemini|kimi)" >&2
    exit 1
    ;;
esac

if [[ -z "$name" ]]; then
  name="${cli}-worker-$(date +%Y%m%d%H%M%S)"
fi

if [[ ! -d "$workdir" ]]; then
  echo "Error: workdir does not exist: $workdir" >&2
  exit 1
fi

if [[ -z "$result_path" ]]; then
  result_path="${caller_dir}/.claude-flow/results/${name}.md"
elif [[ "$result_path" != /* ]]; then
  result_path="${caller_dir}/${result_path}"
fi

if [[ -z "$log_path" ]]; then
  log_path="${caller_dir}/.claude-flow/logs/${name}.log"
elif [[ "$log_path" != /* ]]; then
  log_path="${caller_dir}/${log_path}"
fi

mkdir -p "$(dirname "$result_path")" "$(dirname "$log_path")"

if [[ "$do_spawn" -eq 1 ]]; then
  echo "[spawn] npx claude-flow agent spawn --type \"$agent_type\" --name \"$name\""
  npx claude-flow agent spawn --type "$agent_type" --name "$name"
fi

echo "[cli] $cli"

run_codex() {
  if ! command -v codex >/dev/null 2>&1; then
    echo "Error: codex CLI not found in PATH." >&2
    exit 1
  fi

  if [[ "$use_bypass" -eq 0 ]]; then
    case "$sandbox" in
      read-only|workspace-write|danger-full-access) ;;
      *)
        echo "Error: invalid --sandbox value: $sandbox" >&2
        exit 1
        ;;
    esac
  fi

  if [[ -z "$model" ]]; then
    model="gpt-5.3-codex"
  fi

  codex_state_home="${caller_dir}/.claude-flow/runtime/${name}/codex-home"
  mkdir -p "$codex_state_home"

  if [[ -f "$default_codex_home/auth.json" && ! -f "$codex_state_home/auth.json" ]]; then
    cp "$default_codex_home/auth.json" "$codex_state_home/auth.json"
    chmod 600 "$codex_state_home/auth.json" || true
  fi
  if [[ -f "$default_codex_home/config.toml" && ! -f "$codex_state_home/config.toml" ]]; then
    cp "$default_codex_home/config.toml" "$codex_state_home/config.toml"
    chmod 600 "$codex_state_home/config.toml" || true
  fi

  codex_cmd=(
    codex exec
    -C "$workdir"
    -m "$model"
    -o "$result_path"
  )

  if [[ "$use_bypass" -eq 1 ]]; then
    codex_cmd+=(--dangerously-bypass-approvals-and-sandbox)
  else
    codex_cmd+=(--sandbox "$sandbox")
  fi

  codex_cmd+=("$task")

  echo "[state] CODEX_HOME=$codex_state_home"
  echo "[run] ${codex_cmd[*]}"
  echo "[log] $log_path"
  echo "[result] $result_path"

  if [[ "$background" -eq 1 ]]; then
    (
      export CODEX_HOME="$codex_state_home"
      "${codex_cmd[@]}" >"$log_path" 2>&1
    ) &
    echo "[pid] $!"
    return
  fi

  (
    export CODEX_HOME="$codex_state_home"
    "${codex_cmd[@]}" 2>&1
  ) | tee "$log_path"
}

run_claude() {
  if ! command -v claude >/dev/null 2>&1; then
    echo "Error: claude CLI not found in PATH." >&2
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

  if [[ "$use_third_party" -eq 1 ]]; then
    third_party_env_resolved="$third_party_env"
    if [[ "$third_party_env_resolved" != /* ]]; then
      third_party_env_resolved="$workdir/$third_party_env_resolved"
    fi
    if [[ ! -f "$third_party_env_resolved" ]]; then
      echo "Error: --3rd-party env script not found: $third_party_env_resolved" >&2
      exit 1
    fi
  fi

  if [[ -z "$model" ]]; then
    model="sonnet"
  fi

  claude_state_home="${caller_dir}/.claude-flow/runtime/${name}/home"
  mkdir -p "$claude_state_home"

  claude_cmd=(
    claude
    -p
    --model "$model"
    --permission-mode "$permission_mode"
    --output-format "$output_format"
  )
  if [[ "$dangerous" -eq 1 ]]; then
    claude_cmd+=(--dangerously-skip-permissions)
  fi
  claude_cmd+=("$task")

  echo "[state] HOME=$claude_state_home"
  if [[ "$use_third_party" -eq 1 ]]; then
    echo "[env] source $third_party_env_resolved"
  fi
  echo "[run] (cd \"$workdir\" && ${claude_cmd[*]})"
  echo "[log] $log_path"
  echo "[result] $result_path"

  if [[ "$background" -eq 1 ]]; then
    (
      cd "$workdir"
      export HOME="$claude_state_home"
      export XDG_CONFIG_HOME="$HOME/.config"
      export XDG_CACHE_HOME="$HOME/.cache"
      export XDG_STATE_HOME="$HOME/.local/state"
      if [[ "$use_third_party" -eq 1 ]]; then
        # shellcheck source=/dev/null
        source "$third_party_env_resolved"
      fi
      "${claude_cmd[@]}" >"$result_path" 2>"$log_path"
    ) &
    echo "[pid] $!"
    return
  fi

  (
    cd "$workdir"
    export HOME="$claude_state_home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_STATE_HOME="$HOME/.local/state"
    if [[ "$use_third_party" -eq 1 ]]; then
      # shellcheck source=/dev/null
      source "$third_party_env_resolved"
    fi
    "${claude_cmd[@]}" 2> >(tee "$log_path" >&2)
  ) | tee "$result_path"
}

run_gemini() {
  if ! command -v gemini >/dev/null 2>&1; then
    echo "Error: gemini CLI not found in PATH." >&2
    exit 1
  fi

  gemini_state_home="${caller_dir}/.claude-flow/runtime/${name}/home"
  mkdir -p "$gemini_state_home"

  if [[ -d "$default_home/.gemini" && ! -e "$gemini_state_home/.gemini" ]]; then
    cp -R "$default_home/.gemini" "$gemini_state_home/.gemini"
  fi

  gemini_cmd=(
    gemini
    "--approval-mode=${gemini_approval_mode}"
  )
  if [[ -n "$model" ]]; then
    gemini_cmd+=(--model "$model")
  fi
  gemini_cmd+=("$task")

  echo "[state] HOME=$gemini_state_home"
  echo "[run] (cd \"$workdir\" && ${gemini_cmd[*]})"
  echo "[log] $log_path"
  echo "[result] $result_path"

  if [[ "$background" -eq 1 ]]; then
    (
      cd "$workdir"
      export HOME="$gemini_state_home"
      export XDG_CONFIG_HOME="$HOME/.config"
      export XDG_CACHE_HOME="$HOME/.cache"
      export XDG_STATE_HOME="$HOME/.local/state"
      "${gemini_cmd[@]}" >"$result_path" 2>"$log_path"
    ) &
    echo "[pid] $!"
    return
  fi

  (
    cd "$workdir"
    export HOME="$gemini_state_home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_STATE_HOME="$HOME/.local/state"
    "${gemini_cmd[@]}" 2> >(tee "$log_path" >&2)
  ) | tee "$result_path"
}

run_kimi() {
  if ! command -v kimi >/dev/null 2>&1; then
    echo "Error: kimi CLI not found in PATH." >&2
    exit 1
  fi

  kimi_state_home="${caller_dir}/.claude-flow/runtime/${name}/home"
  mkdir -p "$kimi_state_home"

  if [[ -d "$default_home/.kimi" && ! -e "$kimi_state_home/.kimi" ]]; then
    cp -R "$default_home/.kimi" "$kimi_state_home/.kimi"
  fi

  if [[ -n "$model" ]]; then
    echo "[warn] --model is ignored for --cli kimi." >&2
  fi

  kimi_cmd=(
    kimi
    --print
    -p "$task"
  )

  echo "[state] HOME=$kimi_state_home"
  echo "[run] (cd \"$workdir\" && ${kimi_cmd[*]})"
  echo "[log] $log_path"
  echo "[result] $result_path"

  if [[ "$background" -eq 1 ]]; then
    (
      cd "$workdir"
      export HOME="$kimi_state_home"
      export XDG_CONFIG_HOME="$HOME/.config"
      export XDG_CACHE_HOME="$HOME/.cache"
      export XDG_STATE_HOME="$HOME/.local/state"
      "${kimi_cmd[@]}" >"$result_path" 2>"$log_path"
    ) &
    echo "[pid] $!"
    return
  fi

  (
    cd "$workdir"
    export HOME="$kimi_state_home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_STATE_HOME="$HOME/.local/state"
    "${kimi_cmd[@]}" 2> >(tee "$log_path" >&2)
  ) | tee "$result_path"
}

case "$cli" in
  codex)
    run_codex
    ;;
  claude)
    run_claude
    ;;
  gemini)
    run_gemini
    ;;
  kimi)
    run_kimi
    ;;
esac
