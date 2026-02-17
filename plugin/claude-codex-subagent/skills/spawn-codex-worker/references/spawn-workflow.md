# Spawn Workflow Reference (Codex + Claude)

## Preconditions

- Run commands from the target repository root.
- Install at least one runtime:
  - `codex` CLI for Codex sub-agents
  - `claude` CLI for Claude sub-agents
- Ensure wrapper scripts are executable.

## Wrapper Setup

Project skill source:

```bash
mkdir -p scripts
cp ".claude/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh" ./scripts/spawn-codex-worker.sh
cp ".claude/skills/spawn-codex-worker/scripts/spawn-claude-worker.sh" ./scripts/spawn-claude-worker.sh
chmod +x ./scripts/spawn-codex-worker.sh ./scripts/spawn-claude-worker.sh
SPAWN_CODEX="./scripts/spawn-codex-worker.sh"
SPAWN_CLAUDE="./scripts/spawn-claude-worker.sh"
```

Plugin runtime source:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh" ./scripts/spawn-codex-worker.sh
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-codex-worker/scripts/spawn-claude-worker.sh" ./scripts/spawn-claude-worker.sh
chmod +x ./scripts/spawn-codex-worker.sh ./scripts/spawn-claude-worker.sh
```

## Runtime Selection

- Use `SPAWN_CODEX` for `codex exec` workers.
- Use `SPAWN_CLAUDE` for `claude -p` workers.
- Both can coexist in one stage.

## Single Worker Templates

Codex worker:

```bash
"$SPAWN_CODEX" \
  --name impl-codex \
  --type coder \
  --task "Implement src/shared_memory.py with ring-buffer semantics and lock safety."
```

Claude worker:

```bash
"$SPAWN_CLAUDE" \
  --name review-claude \
  --type reviewer \
  --task "Review src/shared_memory.py for correctness, edge cases, and risks."
```

## Mixed Parallel Template

```bash
"$SPAWN_CODEX" \
  --name producer-codex \
  --type coder \
  --task "Implement src/producer.py with full-buffer handling." \
  --background

"$SPAWN_CLAUDE" \
  --name consumer-claude \
  --type coder \
  --task "Implement src/consumer.py with empty-buffer handling and clear error semantics." \
  --background

wait
```

## Test and Review Stage Template

```bash
"$SPAWN_CODEX" \
  --name tester-codex \
  --type tester \
  --task "Create and run tests for acceptance criteria."

"$SPAWN_CLAUDE" \
  --name reviewer-claude \
  --type reviewer \
  --task "Review implementation and test coverage; report risks and gaps."
```

## Artifact and Debug Conventions

- Default logs: `.claude-flow/logs/<name>.log`
- Default results: `.claude-flow/results/<name>.md`
- Override with `--log` and `--result` for branch isolation.
- Re-run failed work as a new fix task; avoid direct coordinator edits.
