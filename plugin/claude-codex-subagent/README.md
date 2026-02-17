# claude-codex-subagent Plugin

Claude Code plugin package that embeds mixed-subagent skills.

## Included components

- `.claude-plugin/plugin.json`
- `skills/spawn-codex-worker/SKILL.md`
- `skills/spawn-claude-worker/SKILL.md`
- `skills/spawn-codex-worker/scripts/spawn-codex-worker.sh`
- `skills/spawn-claude-worker/scripts/spawn-claude-worker.sh`
- `skills/spawn-claude-worker/scripts/cc_env.sh`
- `skills/spawn-codex-worker/references/spawn-workflow.md`
- `skills/spawn-claude-worker/references/spawn-workflow.md`

## Purpose

Enable Claude Code main sessions to orchestrate both Codex and Claude sub-agents through two separate skill entrypoints:

- `/spawn-codex-worker`
- `/spawn-claude-worker`

## Claude Code Defaults

- Codex wrapper default: `--dangerously-bypass-approvals-and-sandbox`
- Claude wrapper defaults: `--3rd-party`, `--permission-mode bypassPermissions`, `--dangerously-skip-permissions`

## Verified Smoke Commands

Run from repository root after skill/plugin is loaded.

Codex sub-agent:

```bash
./scripts/spawn-codex-worker.sh \
  --name smoke-codex-joke \
  --type coder \
  --task "Tell a joke."
```

Claude sub-agent from Claude Code main session:

```bash
env -u CLAUDECODE ./scripts/spawn-claude-worker.sh \
  --name smoke-claude-joke \
  --type coder \
  --task "Tell a joke."
```
