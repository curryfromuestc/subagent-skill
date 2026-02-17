---
name: spawn-codex-worker
description: Orchestrate mixed subagents from either Codex or Claude Code main sessions. Use when you need to spawn Codex workers via scripts/spawn-codex-worker.sh and Claude Code workers via scripts/spawn-claude-worker.sh, including parallel execution, artifact tracking, and no-direct-edit coordinator governance.
---

# Spawn Mixed Subagents

Use this skill to run worker wrappers consistently while keeping the main session focused on orchestration.

- Codex sub-agent wrapper: `scripts/spawn-codex-worker.sh`
- Claude Code sub-agent wrapper: `scripts/spawn-claude-worker.sh`

## Prepare the task brief first

Before each coding/testing/review spawn, write a task-local documentation pack in the worker prompt:

- Interface Brief: public signatures, input/output contracts, error semantics, and concurrency/locking constraints.
- Component Function Map: responsibilities of each target file, explicit non-goals, and dependencies.
- Acceptance Mapping: exact acceptance criteria this worker is expected to satisfy.

Avoid vague prompts. Make each worker prompt independently executable.

## Select sub-agent runtime

Choose runtime per task:

1. Use Codex sub-agent for implementation-heavy edits and full-auto codex runs.
2. Use Claude sub-agent for workflows that rely on Claude Code behavior or Claude-specific prompting.
3. Mix both in one pipeline when tasks are independent, then `wait` before merge/validation stages.

This skill supports all 4 combinations:

- Main `codex` -> Sub `codex`
- Main `codex` -> Sub `claude`
- Main `claude code` -> Sub `codex`
- Main `claude code` -> Sub `claude`

## Choose wrapper script paths

Prefer repository-local scripts:

- `./scripts/spawn-codex-worker.sh`
- `./scripts/spawn-claude-worker.sh`

If missing, copy from skill resources:

- `.claude/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh` (project skill)
- `.claude/skills/spawn-codex-worker/scripts/spawn-claude-worker.sh` (project skill)
- `${CLAUDE_PLUGIN_ROOT}/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh` (plugin runtime)
- `${CLAUDE_PLUGIN_ROOT}/skills/spawn-codex-worker/scripts/spawn-claude-worker.sh` (plugin runtime)
- `${CODEX_HOME:-$HOME/.codex}/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh` (global Codex skill path)
- `${CODEX_HOME:-$HOME/.codex}/skills/spawn-codex-worker/scripts/spawn-claude-worker.sh` (global Codex skill path)
- Run `chmod +x ./scripts/spawn-codex-worker.sh`
- Run `chmod +x ./scripts/spawn-claude-worker.sh`

## Spawn with standard patterns

Read `references/spawn-workflow.md` for ready-to-run command templates.

Minimum operating pattern:

1. Spawn a focused coder/tester/reviewer with `--task`.
2. Choose wrapper per worker (`spawn-codex-worker.sh` or `spawn-claude-worker.sh`).
3. Use `--background` for independent workers that can run in parallel.
4. Use `wait` before dependent stages.
5. Inspect `.claude-flow/logs/*.log` and `.claude-flow/results/*.md`.
6. If validation fails, spawn a follow-up fix worker instead of patching directly in the coordinator session.

## Example quick start

1. Start Codex coder worker:

```bash
./scripts/spawn-codex-worker.sh \
  --name coder-codex \
  --type coder \
  --task "Implement src/service.py and tests."
```

2. Start Claude reviewer worker:

```bash
./scripts/spawn-claude-worker.sh \
  --name reviewer-claude \
  --type reviewer \
  --task "Review src/service.py and tests for risks."
```

3. Run mixed parallel workers:

```bash
./scripts/spawn-codex-worker.sh --name codex-a --type coder --task "Implement module A." --background
./scripts/spawn-claude-worker.sh --name claude-b --type coder --task "Implement module B." --background
wait
```

## Enforce orchestration governance

- Do not call raw `agent_spawn` directly when wrappers are available.
- Do not edit implementation files in the coordinator session when orchestration mode is required.
- Route all code/test changes through sub-agents.
- Keep worker names and artifact paths explicit so runs are auditable.
