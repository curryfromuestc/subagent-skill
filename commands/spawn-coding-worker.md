---
name: spawn-coding-worker
description: Spawn coding subagents with scripts/spawn-coding-worker.sh from Codex or Claude Code main sessions. Use when the user asks for /spawn-coding-worker and needs claude, codex, gemini, or kimi worker runs with log/result artifacts.
---

# Spawn Coding Worker

Use one wrapper for all worker CLIs.

- Wrapper script: `scripts/spawn-coding-worker.sh`
- Required selector: `--cli claude|codex|gemini|kimi`

## Prepare the task brief first

Before each coding/testing/review spawn, write a task-local documentation pack in the worker prompt:

- Interface Brief: public signatures, input/output contracts, error semantics, and concurrency/locking constraints.
- Component Function Map: responsibilities of each target file, explicit non-goals, and dependencies.
- Acceptance Mapping: exact acceptance criteria this worker is expected to satisfy.

Avoid vague prompts. Make each worker prompt independently executable.

## Choose wrapper script paths

When installed as a Claude Code plugin, scripts are available at `${CLAUDE_PLUGIN_ROOT}`. Use this order:

1. Plugin runtime (auto-available after `/plugin install`):
   - `${CLAUDE_PLUGIN_ROOT}/skills/spawn-coding-worker/scripts/spawn-coding-worker.sh`
2. Repository-local script (if copied to your project):
   - `./scripts/spawn-coding-worker.sh`
3. Global Codex skill path:
   - `${CODEX_HOME:-$HOME/.codex}/skills/spawn-coding-worker/scripts/spawn-coding-worker.sh`

To copy scripts into your project for standalone use:

```bash
mkdir -p scripts
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-coding-worker/scripts/spawn-coding-worker.sh" ./scripts/spawn-coding-worker.sh
cp "${CLAUDE_PLUGIN_ROOT}/skills/spawn-coding-worker/scripts/cc_env.sh" ./scripts/cc_env.sh
chmod +x ./scripts/spawn-coding-worker.sh
```

## Spawn with standard patterns

Read `references/spawn-workflow.md` for ready-to-run command templates.

Minimum operating pattern:

1. Spawn a focused coder/tester/reviewer with `--task` and `--cli`.
2. Use `--background` for independent workers that can run in parallel.
3. Use `wait` before dependent stages.
4. Inspect `.claude-flow/logs/*.log` and `.claude-flow/results/*.md`.
5. If validation fails, spawn a follow-up fix worker instead of patching directly in the coordinator session.

## Example quick start

Codex worker:

```bash
./scripts/spawn-coding-worker.sh --cli codex --name coder-codex --type coder --task "Implement src/service.py and tests."
```

Claude worker:

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

## Important: Claude Code session nesting

When spawning a Claude worker from within a Claude Code main session, you **must** prefix the command with `env -u CLAUDECODE`:

```bash
env -u CLAUDECODE ./scripts/spawn-coding-worker.sh --cli claude --name my-worker --task "..."
```

This unsets the `CLAUDECODE` environment variable to prevent nested session conflicts. Without it, Claude Code will reject the spawn with:

```
Error: Claude Code cannot be launched inside another Claude Code session.
Nested sessions share runtime resources and will crash all active sessions.
```

This is not needed when spawning from Codex, Gemini, Kimi, or a regular shell.

## Default permission behavior

- Codex worker default: `--dangerously-bypass-approvals-and-sandbox` (override with `--sandbox`)
- Claude worker defaults: `--permission-mode bypassPermissions` + `--dangerously-skip-permissions` + `--3rd-party`
- Gemini worker default: `--approval-mode=yolo`
- Kimi worker default: `--print -p "<task>"`

Runtime state is isolated under:

- `.claude-flow/runtime/<worker-name>/...`

## Enforce orchestration governance

- Do not call raw `agent_spawn` directly when wrappers are available.
- Do not edit implementation files in the coordinator session when orchestration mode is required.
- Route all code/test changes through sub-agents.
- Keep worker names and artifact paths explicit so runs are auditable.
