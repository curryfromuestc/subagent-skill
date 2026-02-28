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

## Installation A: Claude Code Plugin

Add the marketplace and install:

```
/plugin marketplace add git@github.com:curryfromuestc/subagent-skill.git
/plugin install spawn-coding-worker@curryfromuestc
```

After installation, use `/spawn-coding-worker` in any Claude Code session. No manual file copying required.

## Installation B: Global Codex Skills

Clone and run the install script:

```bash
git clone https://github.com/curryfromuestc/subagent-skill.git
cd subagent-skill
./scripts/install-codex-skill.sh
```

Or install manually:

```bash
SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
mkdir -p "$SKILLS_DIR"
cp -R /path/to/subagent-skill/skills/spawn-coding-worker "$SKILLS_DIR/spawn-coding-worker"
```

After installation, use `$spawn-coding-worker` in Codex sessions.

## Codex vs Claude Differences

- Codex: install as global skill under `${CODEX_HOME:-$HOME/.codex}/skills`.
- Claude Code: install as plugin via `/plugin install`.
- Codex trigger: `$spawn-coding-worker`.
- Claude trigger: `/spawn-coding-worker`.
- Claude worker spawned inside Claude Code must use `env -u CLAUDECODE` prefix.

## Prepare Wrapper in Target Repository

When installed as a plugin, scripts are available via `${CLAUDE_PLUGIN_ROOT}`. To copy them into your project for standalone use:

```bash
mkdir -p scripts
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-coding-worker/scripts/spawn-coding-worker.sh" ./scripts/spawn-coding-worker.sh
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-coding-worker/scripts/cc_env.sh" ./scripts/cc_env.sh
chmod +x ./scripts/spawn-coding-worker.sh
```

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

Kimi worker:

```bash
./scripts/spawn-coding-worker.sh --cli kimi --name reviewer-kimi --type reviewer --task "Explain what this code does: $(cat main.py)"
```

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
