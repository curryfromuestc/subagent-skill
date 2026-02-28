# Validation Guide

## 1. Static Validation

Refresh shared symlinks first:

```bash
./scripts/sync-shared-assets.sh
```

Run all static checks:

```bash
./scripts/validate-subagent-skill.sh
```

### Skill Structure Validation

Verify all required skill files exist:

```bash
ls skills/spawn-coding-worker/{SKILL.md,scripts,references,agents}
```

### Script Syntax Validation

```bash
bash -n ./scripts/spawn-coding-worker.sh
```

Expected: no output and exit code `0`.

### Help Page Validation

```bash
./scripts/spawn-coding-worker.sh --help
```

Expected: help includes `--cli`, `--task`, `--background`, `--result`, and `--log`.

### Claude Plugin Manifest Validation

```bash
python3 -m json.tool .claude-plugin/plugin.json
```

### Claude Plugin Entry Validation

In a Claude Code session with this plugin loaded, verify:

- `/spawn-coding-worker` does not return Unknown skill

## 2. Runtime Validation Matrix

Goal: cover both main-session types and all worker CLIs.

### Case A: Main=Codex, Worker=Codex

```bash
./scripts/spawn-coding-worker.sh --cli codex --name v-a-codex --type coder --task "Create tmp_validation/a.txt with one line: ok-a"
```

### Case B: Main=Codex, Worker=Claude

```bash
./scripts/spawn-coding-worker.sh --cli claude --name v-b-claude --type coder --task "Create tmp_validation/b.txt with one line: ok-b"
```

### Case C: Main=Codex, Worker=Gemini

```bash
./scripts/spawn-coding-worker.sh --cli gemini --name v-c-gemini --type coder --task "Create tmp_validation/c.txt with one line: ok-c"
```

### Case D: Main=Codex, Worker=Kimi

```bash
./scripts/spawn-coding-worker.sh --cli kimi --name v-d-kimi --type coder --task "Create tmp_validation/d.txt with one line: ok-d"
```

### Case E: Main=Claude Code, Worker=Codex

Run after installing the plugin in Claude Code:

```bash
./scripts/spawn-coding-worker.sh --cli codex --name v-e-codex --type coder --task "Create tmp_validation/e.txt with one line: ok-e"
```

### Case F: Main=Claude Code, Worker=Claude

Run after installing the plugin in Claude Code:

```bash
env -u CLAUDECODE ./scripts/spawn-coding-worker.sh --cli claude --name v-f-claude --type coder --task "Create tmp_validation/f.txt with one line: ok-f"
```

### Case G: Main=Claude Code, Worker=Gemini

Run after installing the plugin in Claude Code:

```bash
./scripts/spawn-coding-worker.sh --cli gemini --name v-g-gemini --type coder --task "Create tmp_validation/g.txt with one line: ok-g"
```

### Case H: Main=Claude Code, Worker=Kimi

Run after installing the plugin in Claude Code:

```bash
./scripts/spawn-coding-worker.sh --cli kimi --name v-h-kimi --type coder --task "Create tmp_validation/h.txt with one line: ok-h"
```

## 3. Pass Criteria

- All cases return successful exit codes.
- `.claude-flow/results/` contains one result file per case.
- `.claude-flow/logs/` contains one log file per case.
- `tmp_validation/*.txt` contains expected content.

## 4. Troubleshooting

- `codex: command not found`: install/fix the Codex CLI.
- `claude: command not found`: install/fix the Claude CLI.
- `gemini: command not found`: install/fix the Gemini CLI.
- `kimi: command not found`: install/fix the Kimi CLI.
- `Error: --3rd-party env script not found`: copy `scripts/cc_env.sh` or pass `--3rd-party-env <path>`.
- `Error: Claude Code cannot be launched inside another Claude Code session.`: run `env -u CLAUDECODE ./scripts/spawn-coding-worker.sh --cli claude ...`.
- `npx claude-flow agent spawn` fails: add `--no-spawn` to validate worker execution path first.
