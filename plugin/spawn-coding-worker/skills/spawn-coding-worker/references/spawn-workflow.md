# Spawn Coding Workflow Reference

## Preconditions

- Run commands from the target repository root.
- Install the CLI you want to use (`codex`, `claude`, `gemini`, or `kimi`).
- Ensure wrapper scripts are executable.
- **When spawning Claude from Claude Code**: prefix with `env -u CLAUDECODE` to avoid nested session errors.

## Wrapper Setup

Project skill source:

```bash
mkdir -p scripts
cp ".claude/skills/spawn-coding-worker/scripts/spawn-coding-worker.sh" ./scripts/spawn-coding-worker.sh
cp ".claude/skills/spawn-coding-worker/scripts/cc_env.sh" ./scripts/cc_env.sh
chmod +x ./scripts/spawn-coding-worker.sh
SPAWN_WORKER="./scripts/spawn-coding-worker.sh"
```

Plugin runtime source:

```bash
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-coding-worker/scripts/spawn-coding-worker.sh" ./scripts/spawn-coding-worker.sh
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-coding-worker/scripts/cc_env.sh" ./scripts/cc_env.sh
chmod +x ./scripts/spawn-coding-worker.sh
```

## Single Worker Templates

Codex:

```bash
"$SPAWN_WORKER" --cli codex --name impl-codex --type coder --task "Implement src/shared_memory.py with ring-buffer semantics and lock safety."
```

Claude:

```bash
env -u CLAUDECODE "$SPAWN_WORKER" --cli claude --name impl-claude --type coder --task "Implement src/shared_memory.py with ring-buffer semantics and lock safety."
```

Gemini:

```bash
"$SPAWN_WORKER" --cli gemini --name impl-gemini --type coder --task "Implement src/shared_memory.py with ring-buffer semantics and lock safety."
```

Kimi:

```bash
"$SPAWN_WORKER" --cli kimi --name review-kimi --type reviewer --task "Explain what this code does: $(cat main.py)"
```

## Verified Default Smoke Tests

```bash
"$SPAWN_WORKER" --cli codex --name smoke-codex-joke --type coder --task "Tell a joke."
"$SPAWN_WORKER" --cli gemini --name smoke-gemini-joke --type coder --task "Tell a joke."
"$SPAWN_WORKER" --cli kimi --name smoke-kimi-joke --type reviewer --task "Explain what this code does: $(cat main.py)"
env -u CLAUDECODE "$SPAWN_WORKER" --cli claude --name smoke-claude-joke --type coder --task "Tell a joke."
```

## Parallel Template

```bash
"$SPAWN_WORKER" --cli codex --name coder-a --type coder --task "Implement module A." --background
"$SPAWN_WORKER" --cli kimi --name coder-b --type coder --task "Implement module B." --background
wait
```

## Artifact and Debug Conventions

- Default logs: `.claude-flow/logs/<name>.log`
- Default results: `.claude-flow/results/<name>.md`
- Codex runtime state: `.claude-flow/runtime/<name>/codex-home`
- Claude/Gemini/Kimi runtime state: `.claude-flow/runtime/<name>/home`
- Override with `--log` and `--result` for branch isolation.
- Re-run failed work as a new fix task; avoid direct coordinator edits.
