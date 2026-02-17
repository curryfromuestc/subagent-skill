# Spawn Codex Workflow Reference

## Preconditions

- Run commands from the target repository root.
- Install `codex` CLI.
- Ensure wrapper scripts are executable.

## Wrapper Setup

Project skill source:

```bash
mkdir -p scripts
cp ".claude/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh" ./scripts/spawn-codex-worker.sh
chmod +x ./scripts/spawn-codex-worker.sh
SPAWN_CODEX="./scripts/spawn-codex-worker.sh"
```

Plugin runtime source:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh" ./scripts/spawn-codex-worker.sh
chmod +x ./scripts/spawn-codex-worker.sh
```

If you need Claude workers, switch to `spawn-claude-worker` skill.

## Single Worker Template

```bash
"$SPAWN_CODEX" \
  --name impl-codex \
  --type coder \
  --task "Implement src/shared_memory.py with ring-buffer semantics and lock safety."
```

## Verified Default Smoke Test

```bash
"$SPAWN_CODEX" \
  --name smoke-codex-joke \
  --type coder \
  --task "Tell a joke."
```

Default behavior already uses:

- `--dangerously-bypass-approvals-and-sandbox`

Use `--sandbox <mode>` only when you intentionally want sandboxed execution.

## Parallel Codex Template

```bash
"$SPAWN_CODEX" \
  --name producer-codex \
  --type coder \
  --task "Implement src/producer.py with full-buffer handling." \
  --background

"$SPAWN_CODEX" \
  --name consumer-codex \
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
```

## Artifact and Debug Conventions

- Default logs: `.claude-flow/logs/<name>.log`
- Default results: `.claude-flow/results/<name>.md`
- Codex runtime state: `.claude-flow/runtime/<name>/codex-home`
- Override with `--log` and `--result` for branch isolation.
- Re-run failed work as a new fix task; avoid direct coordinator edits.
