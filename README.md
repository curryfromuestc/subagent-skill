# Cross-Agent Subagent Skill/Plugin

This repository provides reusable capabilities for mixed sub-agent orchestration from both **Codex** and **Claude Code** main sessions:

- Codex sub-agents (`codex exec`)
- Claude sub-agents (`claude -p`)

## Key Directories

- `scripts/`: repository-level wrapper scripts
- `skills/spawn-codex-worker/`: Codex sub-agent skill
- `skills/spawn-claude-worker/`: Claude sub-agent skill
- `.claude/skills/spawn-codex-worker/`: Claude Code project-level Codex skill
- `.claude/skills/spawn-claude-worker/`: Claude Code project-level Claude skill
- `plugin/claude-codex-subagent/`: Claude Code plugin package
- `docs/USAGE.md`: installation and usage guide
- `docs/VALIDATION.md`: validation guide and acceptance matrix

## Sub-Agent Wrappers

- `scripts/spawn-codex-worker.sh`
- `scripts/spawn-claude-worker.sh`
- `scripts/cc_env.sh` (example env vars for third-party Claude API)

Third-party Claude API example:

```bash
env -u CLAUDECODE ./scripts/spawn-claude-worker.sh --name demo-claude --type coder --task "tell a joke"
```

Default permission mode (YOLO):

- Codex sub-agent: `--dangerously-bypass-approvals-and-sandbox` (override with `--sandbox`)
- Claude sub-agent: `--3rd-party` + `bypassPermissions` + `--dangerously-skip-permissions` (override with flags)

When launching Claude workers from inside a Claude Code main session, use `env -u CLAUDECODE` as shown above.

## Next Steps

1. Install both skills following `docs/USAGE.md`.
2. In Claude Code, verify both `/spawn-codex-worker` and `/spawn-claude-worker` are available.
3. Run the 4-session combination validation from `docs/VALIDATION.md`.
