---
name: spawn-codex-worker
description: Spawn Codex subagents with scripts/spawn-codex-worker.sh from either Codex or Claude Code main sessions. Use when the user asks for /spawn-codex-worker, needs codex exec worker runs, or wants codex-based coding/testing/review tasks with log and result artifacts.
---

# Spawn Codex Worker

Use this skill only for Codex subagents.

- Wrapper script: `scripts/spawn-codex-worker.sh`
- If user asks for Claude subagent, use `/spawn-claude-worker` skill instead.

## Prepare the task brief first

Before each coding/testing/review spawn, write a task-local documentation pack in the worker prompt:

- Interface Brief: public signatures, input/output contracts, error semantics, and concurrency/locking constraints.
- Component Function Map: responsibilities of each target file, explicit non-goals, and dependencies.
- Acceptance Mapping: exact acceptance criteria this worker is expected to satisfy.

Avoid vague prompts. Make each worker prompt independently executable.

## Choose wrapper script paths

Prefer a repository-local script:

- `./scripts/spawn-codex-worker.sh`

If missing, copy from skill resources:

- `.claude/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh` (project skill)
- `${CLAUDE_PLUGIN_ROOT}/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh` (plugin runtime)
- `${CODEX_HOME:-$HOME/.codex}/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh` (global Codex skill path)
- Run `chmod +x ./scripts/spawn-codex-worker.sh`

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
./scripts/spawn-codex-worker.sh \
  --name coder-codex \
  --type coder \
  --task "Implement src/service.py and tests."
```

Default mode is YOLO for Codex workers:

- `--dangerously-bypass-approvals-and-sandbox`

Sandboxed override when needed:

- `--sandbox workspace-write` (or `read-only` / `danger-full-access`)

Codex runtime state is isolated under:

- `.claude-flow/runtime/<worker-name>/codex-home`

Parallel codex workers:

```bash
./scripts/spawn-codex-worker.sh --name codex-a --type coder --task "Implement module A." --background
./scripts/spawn-codex-worker.sh --name codex-b --type coder --task "Implement module B." --background
wait
```

## Verified default smoke test

Use this command as the default connectivity check:

```bash
./scripts/spawn-codex-worker.sh \
  --name smoke-codex-joke \
  --type coder \
  --task "Tell a joke."
```

## Enforce orchestration governance

- Do not call raw `agent_spawn` directly when wrappers are available.
- Do not edit implementation files in the coordinator session when orchestration mode is required.
- Route all code/test changes through sub-agents.
- Keep worker names and artifact paths explicit so runs are auditable.
