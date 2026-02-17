# Usage Guide

## Goal

From either main session type, run either sub-agent type:

- Main session: `codex` or `claude code`
- Sub-agent: `codex` or `claude code`

## Prerequisites

- `codex` CLI is installed (for Codex sub-agents)
- `claude` CLI is installed (for Claude sub-agents)
- The target repository allows local shell script execution

## Available Scripts

- `scripts/spawn-codex-worker.sh`: start a Codex sub-agent
- `scripts/spawn-claude-worker.sh`: start a Claude sub-agent
- `scripts/cc_env.sh`: third-party Claude API env vars (loaded by default in Claude wrapper)

## Installation A: Global Codex Skills

```bash
SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
mkdir -p "$SKILLS_DIR"
cp -R /path/to/subagent-skill/skills/spawn-codex-worker "$SKILLS_DIR/spawn-codex-worker"
cp -R /path/to/subagent-skill/skills/spawn-claude-worker "$SKILLS_DIR/spawn-claude-worker"
```

After installation, in a Codex session you can use:

- `$spawn-codex-worker` (Codex sub-agent)
- `$spawn-claude-worker` (Claude sub-agent)

## Installation B: Claude Code Project Skills (Recommended)

Run at the target repository root:

```bash
mkdir -p .claude/skills
cp -R /path/to/subagent-skill/skills/spawn-codex-worker .claude/skills/spawn-codex-worker
cp -R /path/to/subagent-skill/skills/spawn-claude-worker .claude/skills/spawn-claude-worker
```

After installation, in a Claude Code session you can use:

- `/spawn-codex-worker` to run Codex sub-agent flow
- `/spawn-claude-worker` to run Claude sub-agent flow

## Installation C: Claude Code Plugin

Plugin directory: `plugin/claude-codex-subagent/`

Session-scoped load example:

```bash
claude --plugin-dir /path/to/subagent-skill/plugin/claude-codex-subagent
```

After loading, both embedded skills are available in Claude Code.

## Prepare Wrappers in Target Repository

```bash
mkdir -p scripts
cp .claude/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh ./scripts/spawn-codex-worker.sh
cp .claude/skills/spawn-claude-worker/scripts/spawn-claude-worker.sh ./scripts/spawn-claude-worker.sh
cp .claude/skills/spawn-claude-worker/scripts/cc_env.sh ./scripts/cc_env.sh
chmod +x ./scripts/spawn-codex-worker.sh ./scripts/spawn-claude-worker.sh
```

If using plugin runtime, copy from:

- `${CLAUDE_PLUGIN_ROOT}/skills/spawn-codex-worker/scripts/`
- `${CLAUDE_PLUGIN_ROOT}/skills/spawn-claude-worker/scripts/`

Copy the corresponding scripts. If using third-party Claude API, copy `cc_env.sh` as well.

## Common Invocation Templates

Default permission mode (YOLO):

- Codex wrapper defaults to `--dangerously-bypass-approvals-and-sandbox`
- Claude wrapper defaults to `--permission-mode bypassPermissions` + `--dangerous` + `--3rd-party`
- Optional overrides: Codex `--sandbox <mode>`, Claude `--no-3rd-party`, `--permission-mode`, `--no-dangerous`

Codex sub-agent:

```bash
./scripts/spawn-codex-worker.sh \
  --name coder-codex \
  --type coder \
  --task "Implement feature A with tests."
```

Claude sub-agent:

```bash
env -u CLAUDECODE ./scripts/spawn-claude-worker.sh \
  --name reviewer-claude \
  --type reviewer \
  --task "Review feature A for bugs and missing tests."
```

Claude sub-agent (disable third-party env):

```bash
env -u CLAUDECODE ./scripts/spawn-claude-worker.sh \
  --name reviewer-claude-local \
  --type reviewer \
  --task "Review feature A for bugs and missing tests." \
  --no-3rd-party
```

When running from a Claude Code main session, unset `CLAUDECODE` as shown above to avoid nested-session rejection.

Claude runtime state writes to this repository:

- `.claude-flow/runtime/<worker-name>/home`

Mixed parallel run:

```bash
./scripts/spawn-codex-worker.sh --name codex-a --type coder --task "Implement module A." --background
./scripts/spawn-claude-worker.sh --name claude-b --type coder --task "Implement module B." --background
wait
```

## Entry Mapping (Expected Behavior)

- `/spawn-codex-worker` -> use `spawn-codex-worker` skill + `spawn-codex-worker.sh`
- `/spawn-claude-worker` -> use `spawn-claude-worker` skill + `spawn-claude-worker.sh`

## Artifact Locations

- Result file: `.claude-flow/results/<worker-name>.md`
- Log file: `.claude-flow/logs/<worker-name>.log`
- Codex runtime state: `.claude-flow/runtime/<worker-name>/codex-home` (does not write to `~/.codex`)
- Claude runtime state: `.claude-flow/runtime/<worker-name>/home` (does not write to `~/.claude`)
