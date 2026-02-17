# 验证文档

## 1. 静态验证（已执行）

可直接运行一键脚本：

```bash
./scripts/validate-subagent-skill.sh
```

### Skill 结构验证

```bash
python3 /home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./skills/spawn-codex-worker
python3 /home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./.claude/skills/spawn-codex-worker
python3 /home/zyy/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./plugin/claude-codex-subagent/skills/spawn-codex-worker
```

预期：全部输出 `Skill is valid!`

### 脚本语法验证

```bash
bash -n ./scripts/spawn-codex-worker.sh
bash -n ./scripts/spawn-claude-worker.sh
```

预期：无输出且退出码为 0。

### 脚本帮助页验证

```bash
./scripts/spawn-codex-worker.sh --help
./scripts/spawn-claude-worker.sh --help
```

预期：正确打印参数说明，并包含 `--task`、`--background`、`--result`、`--log` 等选项。

## 2. 运行时验证矩阵（你将在新会话执行）

目标：覆盖主会话与 sub-agent 的 2x2 组合。

### Case A: Main=Codex, Sub=Codex

```bash
./scripts/spawn-codex-worker.sh --name v-a-codex --type coder --task "Create tmp_validation/a.txt with one line: ok-a"
```

### Case B: Main=Codex, Sub=Claude

```bash
./scripts/spawn-claude-worker.sh --name v-b-claude --type coder --task "Create tmp_validation/b.txt with one line: ok-b"
```

### Case C: Main=Claude Code, Sub=Codex

在 Claude Code 会话中触发 skill 后执行：

```bash
./scripts/spawn-codex-worker.sh --name v-c-codex --type coder --task "Create tmp_validation/c.txt with one line: ok-c"
```

### Case D: Main=Claude Code, Sub=Claude

在 Claude Code 会话中触发 skill 后执行：

```bash
./scripts/spawn-claude-worker.sh --name v-d-claude --type coder --task "Create tmp_validation/d.txt with one line: ok-d"
```

## 3. 通过标准

- 4 个 case 都能返回成功退出码。
- `.claude-flow/results/` 下存在 `v-a-codex.md`、`v-b-claude.md`、`v-c-codex.md`、`v-d-claude.md`。
- `.claude-flow/logs/` 下存在同名日志文件（至少包含执行记录）。
- 目标仓库出现对应 `tmp_validation/*.txt` 文件，内容与任务一致。

## 4. 失败排查

- `codex: command not found`：安装或修复 Codex CLI。
- `claude: command not found`：安装或修复 Claude CLI。
- 权限交互阻塞（Claude）：在 wrapper 中保持默认 `--dangerous`，或根据环境切换 `--permission-mode`。
- `npx claude-flow agent spawn` 失败：加 `--no-spawn` 先跳过 agent 注册，仅验证 worker 执行链路。
