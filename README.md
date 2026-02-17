# Spawn Coding Worker Skill/Plugin

This repository provides one unified worker wrapper for mixed sub-agent orchestration from both **Codex** and **Claude Code** main sessions.

- Worker CLIs: `codex`, `claude`, `gemini`, `kimi`
- Single wrapper: `scripts/spawn-coding-worker.sh`
- Single skill name: `spawn-coding-worker`

## Key Directories

- `scripts/`: repository-level wrapper scripts
- `skills/spawn-coding-worker/`: Codex skill package
- `.claude/skills/spawn-coding-worker/`: Claude project skill package
- `plugin/spawn-coding-worker/`: Claude plugin package
- `docs/USAGE.md`: installation and usage guide
- `docs/VALIDATION.md`: validation guide and acceptance matrix

## Sub-Agent Wrapper

- `scripts/spawn-coding-worker.sh`
- `scripts/cc_env.sh` (example env vars for third-party Claude API)

Default permission mode:

- Codex worker: `--dangerously-bypass-approvals-and-sandbox` (override with `--sandbox`)
- Claude worker: `--permission-mode bypassPermissions` + `--dangerously-skip-permissions` + `--3rd-party`
- Gemini worker: `gemini --approval-mode=yolo 'prompt'` via `--cli gemini`
- Kimi worker: `kimi --print -p 'prompt'` via `--cli kimi`

Example:

```bash
./scripts/spawn-coding-worker.sh --cli gemini --name demo-gemini --type coder --task "tell a joke"
./scripts/spawn-coding-worker.sh --cli kimi --name demo-kimi --type reviewer --task "Explain what this code does: $(cat main.py)"
```

When launching Claude workers from inside a Claude Code main session, use `env -u CLAUDECODE`.

## Next Steps

1. Install `spawn-coding-worker` following `docs/USAGE.md`.
2. In Claude Code, verify `/spawn-coding-worker` is available.
3. Run the validation flow from `docs/VALIDATION.md`.
