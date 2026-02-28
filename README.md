# spawn-coding-worker

Claude Code plugin that spawns Claude, Codex, Gemini, or Kimi coding subagents through one unified wrapper script.

## Installation

### Claude Code (one-click)

```
/plugin install github:curryfromuestc/subagent-skill
```

After installation, use `/spawn-coding-worker` in any Claude Code session.

### Codex (global skill)

Clone and run the install script:

```bash
git clone https://github.com/curryfromuestc/subagent-skill.git
cd subagent-skill
./scripts/install-codex-skill.sh
```

After installation, use `$spawn-coding-worker` in Codex sessions.

## What it does

Enable Claude Code or Codex main sessions to orchestrate subagents through one entrypoint:

- `/spawn-coding-worker` (Claude Code)
- `$spawn-coding-worker` (Codex)

Use `--cli` to select the worker runtime: `claude`, `codex`, `gemini`, or `kimi`.

## Quick examples

Codex worker:

```bash
./scripts/spawn-coding-worker.sh --cli codex --name coder-codex --type coder --task "Implement src/service.py and tests."
```

Claude worker (from Claude Code session):

```bash
env -u CLAUDECODE ./scripts/spawn-coding-worker.sh --cli claude --name reviewer-claude --type reviewer --task "Review src/service.py and tests."
```

Gemini worker:

```bash
./scripts/spawn-coding-worker.sh --cli gemini --name tester-gemini --type tester --task "Write integration tests for auth endpoints."
```

Kimi worker:

```bash
./scripts/spawn-coding-worker.sh --cli kimi --name reviewer-kimi --type reviewer --task "Explain what this code does: $(cat main.py)"
```

## Plugin components

```
.claude-plugin/plugin.json                          Plugin manifest
commands/spawn-coding-worker.md                     Slash command entry point
skills/spawn-coding-worker/SKILL.md                 Skill definition
skills/spawn-coding-worker/scripts/spawn-coding-worker.sh   Core wrapper script
skills/spawn-coding-worker/scripts/cc_env.sh        Third-party Claude API env vars
skills/spawn-coding-worker/references/spawn-workflow.md     Command templates
skills/spawn-coding-worker/agents/openai.yaml       OpenAI agent interface
```

## Documentation

- [Usage Guide](docs/USAGE.md)
- [Shared Assets](docs/SHARED-ASSETS.md)
- [Validation Guide](docs/VALIDATION.md)

## Development

Refresh symlinks after editing shared source:

```bash
./scripts/sync-shared-assets.sh
```

Run static validation:

```bash
./scripts/validate-subagent-skill.sh
```
