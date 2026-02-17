# Usage Guide

## Goal

From either main session type, run any worker CLI with one command:

- Main session: `codex` or `claude code`
- Worker CLI: `codex` or `claude` or `gemini` or `kimi`
- Wrapper: `scripts/spawn-coding-worker.sh`

## Prerequisites

- Install `codex` CLI for Codex workers
- Install `claude` CLI for Claude workers
- Install `gemini` CLI for Gemini workers
- Install `kimi` CLI for Kimi workers
- The target repository allows local shell script execution

## Available Scripts

- `scripts/spawn-coding-worker.sh`: start a worker with `--cli`
- `scripts/cc_env.sh`: third-party Claude API env vars (loaded by default for `--cli claude`)

## Installation A: Global Codex Skills

```bash
SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
mkdir -p "$SKILLS_DIR"
cp -R /path/to/subagent-skill/skills/spawn-coding-worker "$SKILLS_DIR/spawn-coding-worker"
```

After installation, in a Codex session use:

- `$spawn-coding-worker`

## Installation B: Claude Code Project Skills

Run at target repository root:

```bash
mkdir -p .claude/skills
cp -R /path/to/subagent-skill/skills/spawn-coding-worker .claude/skills/spawn-coding-worker
```

After installation, in Claude Code use:

- `/spawn-coding-worker`

## Installation C: Claude Code Plugin

Plugin directory: `plugin/spawn-coding-worker/`

Session-scoped load example:

```bash
claude --plugin-dir /path/to/subagent-skill/plugin/spawn-coding-worker
```

## Prepare Wrapper in Target Repository

```bash
mkdir -p scripts
cp .claude/skills/spawn-coding-worker/scripts/spawn-coding-worker.sh ./scripts/spawn-coding-worker.sh
cp .claude/skills/spawn-coding-worker/scripts/cc_env.sh ./scripts/cc_env.sh
chmod +x ./scripts/spawn-coding-worker.sh
```

If using plugin runtime, copy from:

- `${CLAUDE_PLUGIN_ROOT}/skills/spawn-coding-worker/scripts/`

## Common Invocation Templates

Codex worker:

```bash
./scripts/spawn-coding-worker.sh --cli codex --name coder-codex --type coder --task "Implement feature A with tests."
```

Claude worker:

```bash
env -u CLAUDECODE ./scripts/spawn-coding-worker.sh --cli claude --name reviewer-claude --type reviewer --task "Review feature A for bugs and missing tests."
```

Gemini worker:

```bash
./scripts/spawn-coding-worker.sh --cli gemini --name tester-gemini --type tester --task "Write and run integration tests for feature A."
```

Gemini no-permission default:

- `--cli gemini` uses `gemini --approval-mode=yolo 'prompt'`

Kimi worker:

```bash
./scripts/spawn-coding-worker.sh --cli kimi --name reviewer-kimi --type reviewer --task "Explain what this code does: $(cat main.py)"
```

Kimi auto-approve/default mode:

- `--cli kimi` uses `kimi --print -p 'prompt'`

Mixed parallel run:

```bash
./scripts/spawn-coding-worker.sh --cli codex --name codex-a --type coder --task "Implement module A." --background
./scripts/spawn-coding-worker.sh --cli kimi --name kimi-b --type coder --task "Implement module B." --background
wait
```

## Artifact Locations

- Result file: `.claude-flow/results/<worker-name>.md`
- Log file: `.claude-flow/logs/<worker-name>.log`
- Codex runtime state: `.claude-flow/runtime/<worker-name>/codex-home`
- Claude/Gemini/Kimi runtime state: `.claude-flow/runtime/<worker-name>/home`
