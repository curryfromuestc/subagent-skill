# Spawn Claude Workflow Reference

## Preconditions

- Run commands from the target repository root.
- Install `claude` CLI.
- Ensure wrapper script is executable.

## Wrapper Setup

Project skill source:

```bash
mkdir -p scripts
cp ".claude/skills/spawn-claude-worker/scripts/spawn-claude-worker.sh" ./scripts/spawn-claude-worker.sh
cp ".claude/skills/spawn-claude-worker/scripts/cc_env.sh" ./scripts/cc_env.sh
chmod +x ./scripts/spawn-claude-worker.sh
SPAWN_CLAUDE="./scripts/spawn-claude-worker.sh"
```

Plugin runtime source:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-claude-worker/scripts/spawn-claude-worker.sh" ./scripts/spawn-claude-worker.sh
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-claude-worker/scripts/cc_env.sh" ./scripts/cc_env.sh
chmod +x ./scripts/spawn-claude-worker.sh
```

If you need Codex workers, switch to `spawn-codex-worker` skill.

## Single Worker Template

```bash
"$SPAWN_CLAUDE" \
  --name impl-claude \
  --type coder \
  --task "Implement src/shared_memory.py with ring-buffer semantics and lock safety."
```

Third-party API template:

```bash
"$SPAWN_CLAUDE" \
  --name impl-claude-3p \
  --type coder \
  --task "Implement src/shared_memory.py with ring-buffer semantics and lock safety."
```

## Verified Default Smoke Test

When launching from inside Claude Code, unset `CLAUDECODE` first:

```bash
env -u CLAUDECODE "$SPAWN_CLAUDE" \
  --name smoke-claude-joke \
  --type coder \
  --task "Tell a joke."
```

Defaults already include:

- `--3rd-party` (unless `--no-3rd-party` is set)
- `--permission-mode bypassPermissions`
- `--dangerously-skip-permissions`

Claude runtime state is written to:

- `.claude-flow/runtime/<name>/home`

## Parallel Claude Template

```bash
"$SPAWN_CLAUDE" \
  --name producer-claude \
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
"$SPAWN_CLAUDE" \
  --name tester-claude \
  --type tester \
  --task "Create and run tests for acceptance criteria."
```

## Artifact and Debug Conventions

- Default logs: `.claude-flow/logs/<name>.log`
- Default results: `.claude-flow/results/<name>.md`
- Override with `--log` and `--result` for branch isolation.
- Re-run failed work as a new fix task; avoid direct coordinator edits.
