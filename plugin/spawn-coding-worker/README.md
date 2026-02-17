# spawn-coding-worker Plugin

Claude Code plugin package that embeds one mixed-subagent skill.

## Included components

- `.claude-plugin/plugin.json`
- `skills/spawn-coding-worker/SKILL.md`
- `skills/spawn-coding-worker/scripts/spawn-coding-worker.sh`
- `skills/spawn-coding-worker/scripts/cc_env.sh`
- `skills/spawn-coding-worker/references/spawn-workflow.md`

## Purpose

Enable Claude Code main sessions to orchestrate Claude, Codex, Gemini, or Kimi sub-agents through one entrypoint:

- `/spawn-coding-worker`

Use `--cli` to select runtime (`claude`, `codex`, `gemini`, or `kimi`).

## Verified Smoke Commands

Run from repository root after skill/plugin is loaded.

```bash
./scripts/spawn-coding-worker.sh --cli codex --name smoke-codex-joke --type coder --task "Tell a joke."
./scripts/spawn-coding-worker.sh --cli gemini --name smoke-gemini-joke --type coder --task "Tell a joke."
./scripts/spawn-coding-worker.sh --cli kimi --name smoke-kimi-explain --type reviewer --task "Explain what this code does: $(cat main.py)"
env -u CLAUDECODE ./scripts/spawn-coding-worker.sh --cli claude --name smoke-claude-joke --type coder --task "Tell a joke."
```

> **Note**: The `env -u CLAUDECODE` prefix is required when spawning Claude workers from within a Claude Code session. This prevents nested session conflicts.
