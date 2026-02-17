# Validation Guide

## 1. Static Validation (Already Run)

You can run the all-in-one validation script:

```bash
./scripts/validate-subagent-skill.sh
```

### Skill Structure Validation

```bash
python3 /home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./skills/spawn-codex-worker
python3 /home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./skills/spawn-claude-worker
python3 /home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./.claude/skills/spawn-codex-worker
python3 /home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./.claude/skills/spawn-claude-worker
python3 /home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./plugin/claude-codex-subagent/skills/spawn-codex-worker
python3 /home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./plugin/claude-codex-subagent/skills/spawn-claude-worker
```

Expected: all commands output `Skill is valid!`

### Script Syntax Validation

```bash
bash -n ./scripts/spawn-codex-worker.sh
bash -n ./scripts/spawn-claude-worker.sh
```

Expected: no output and exit code `0`.

### Help Page Validation

```bash
./scripts/spawn-codex-worker.sh --help
./scripts/spawn-claude-worker.sh --help
```

Expected: option help prints correctly, including `--task`, `--background`, `--result`, `--log`.
For Claude wrapper defaults, help should include `--3rd-party` and `--no-3rd-party`.

### Claude Dual-Entry Validation

In a Claude Code session, verify:

- `/spawn-codex-worker` does not return Unknown skill
- `/spawn-claude-worker` does not return Unknown skill

## 2. Runtime Validation Matrix (Run in a Fresh Session)

Goal: cover all 2x2 combinations of main session and sub-agent type.

### Case A: Main=Codex, Sub=Codex

```bash
./scripts/spawn-codex-worker.sh --name v-a-codex --type coder --task "Create tmp_validation/a.txt with one line: ok-a"
```

### Case B: Main=Codex, Sub=Claude

```bash
./scripts/spawn-claude-worker.sh --name v-b-claude --type coder --task "Create tmp_validation/b.txt with one line: ok-b"
```

If using third-party Claude API:

```bash
./scripts/spawn-claude-worker.sh --name v-b-claude-3p --type coder --task "Create tmp_validation/b3p.txt with one line: ok-b3p" --3rd-party
```

### Case C: Main=Claude Code, Sub=Codex

Run after triggering the skill in a Claude Code session:

```bash
./scripts/spawn-codex-worker.sh --name v-c-codex --type coder --task "Create tmp_validation/c.txt with one line: ok-c"
```

### Case D: Main=Claude Code, Sub=Claude

Run after triggering the skill in a Claude Code session:

```bash
env -u CLAUDECODE ./scripts/spawn-claude-worker.sh --name v-d-claude --type coder --task "Create tmp_validation/d.txt with one line: ok-d"
```

## 3. Pass Criteria

- All 4 cases return successful exit codes.
- `.claude-flow/results/` contains `v-a-codex.md`, `v-b-claude.md`, `v-c-codex.md`, `v-d-claude.md`.
- `.claude-flow/logs/` contains corresponding log files (at minimum, execution records).
- Target repository contains `tmp_validation/*.txt` files with expected content.

## 4. Troubleshooting

- `codex: command not found`: install or fix the Codex CLI.
- `claude: command not found`: install or fix the Claude CLI.
- `Error: --3rd-party env script not found`: ensure `scripts/cc_env.sh` is copied into the target repo, or pass `--3rd-party-env <path>`.
- Claude permission interaction blocks execution: keep wrapper default `--dangerous`, or switch `--permission-mode` for your environment.
- `Error: Claude Code cannot be launched inside another Claude Code session.`: run `env -u CLAUDECODE ./scripts/spawn-claude-worker.sh ...`.
- `npx claude-flow agent spawn` fails: add `--no-spawn` to skip agent registration and validate the worker execution path first.
