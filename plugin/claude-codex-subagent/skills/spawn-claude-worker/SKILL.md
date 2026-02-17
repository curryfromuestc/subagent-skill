---
name: spawn-claude-worker
description: Spawn Claude Code subagents with scripts/spawn-claude-worker.sh from either Codex or Claude Code main sessions. Use when the user asks for /spawn-claude-worker, needs claude -p worker runs, or wants Claude-based coding/testing/review tasks with log and result artifacts.
---

# Spawn Claude Worker

Use this skill only for Claude Code subagents.

- Wrapper script: `scripts/spawn-claude-worker.sh`
- If user asks for Codex subagent, use `/spawn-codex-worker` skill instead.

## Prepare the task brief first

Before each coding/testing/review spawn, write a task-local documentation pack in the worker prompt:

- Interface Brief: public signatures, input/output contracts, error semantics, and concurrency/locking constraints.
- Component Function Map: responsibilities of each target file, explicit non-goals, and dependencies.
- Acceptance Mapping: exact acceptance criteria this worker is expected to satisfy.

Avoid vague prompts. Make each worker prompt independently executable.

## Choose wrapper script paths

Prefer a repository-local script:

- `./scripts/spawn-claude-worker.sh`

If missing, copy from skill resources:

- `.claude/skills/spawn-claude-worker/scripts/spawn-claude-worker.sh` (project skill)
- `${CLAUDE_PLUGIN_ROOT}/skills/spawn-claude-worker/scripts/spawn-claude-worker.sh` (plugin runtime)
- `${CODEX_HOME:-$HOME/.codex}/skills/spawn-claude-worker/scripts/spawn-claude-worker.sh` (global Codex skill path)
- Copy `.claude/skills/spawn-claude-worker/scripts/cc_env.sh` to `./scripts/cc_env.sh` when using third-party Claude API
- Run `chmod +x ./scripts/spawn-claude-worker.sh`

## Spawn with standard patterns

Read `references/spawn-workflow.md` for ready-to-run command templates.

Minimum operating pattern:

1. Spawn a focused coder/tester/reviewer with `--task`.
2. Use `--background` for independent workers that can run in parallel.
3. Use `wait` before dependent stages.
4. Inspect `.claude-flow/logs/*.log` and `.claude-flow/results/*.md`.
5. If validation fails, spawn a follow-up fix worker instead of patching directly in the coordinator session.

## Example quick start

```bash
./scripts/spawn-claude-worker.sh \
  --name coder-claude \
  --type coder \
  --task "Implement src/service.py and tests."
```

Third-party Claude API:

```bash
./scripts/spawn-claude-worker.sh \
  --name reviewer-claude-3p \
  --type reviewer \
  --task "Review src/service.py and tests."
```

Default mode is YOLO for Claude workers:

- `--permission-mode bypassPermissions`
- `--dangerously-skip-permissions`
- `--3rd-party` (enabled by default)

Optional override:

- `--no-3rd-party`

Claude runtime state is isolated under:

- `.claude-flow/runtime/<worker-name>/home`

Parallel Claude workers:

```bash
./scripts/spawn-claude-worker.sh --name claude-a --type coder --task "Implement module A." --background
./scripts/spawn-claude-worker.sh --name claude-b --type coder --task "Implement module B." --background
wait
```

## Verified default smoke test

If running from within a Claude Code session, unset `CLAUDECODE` to allow nested worker launch:

```bash
env -u CLAUDECODE ./scripts/spawn-claude-worker.sh \
  --name smoke-claude-joke \
  --type coder \
  --task "Tell a joke."
```

## Enforce orchestration governance

- Do not call raw `agent_spawn` directly when wrappers are available.
- Do not edit implementation files in the coordinator session when orchestration mode is required.
- Route all code/test changes through sub-agents.
- Keep worker names and artifact paths explicit so runs are auditable.
