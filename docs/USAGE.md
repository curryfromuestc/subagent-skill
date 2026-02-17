# 使用文档

## 目标

在以下任意主会话中，调用任意 sub-agent：

- Main session: `codex` 或 `claude code`
- Sub-agent: `codex` 或 `claude code`

## 前置条件

- 本机安装 `codex` CLI（用于 Codex sub-agent）
- 本机安装 `claude` CLI（用于 Claude sub-agent）
- 目标仓库允许执行本地 shell 脚本

## 可用脚本

- `scripts/spawn-codex-worker.sh`：启动 Codex sub-agent
- `scripts/spawn-claude-worker.sh`：启动 Claude sub-agent

## 安装方式 A：Codex Skill（全局）

```bash
SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
mkdir -p "$SKILLS_DIR"
cp -R /path/to/subagent-skill/skills/spawn-codex-worker "$SKILLS_DIR/spawn-codex-worker"
```

安装后在 Codex 会话中可通过 `$spawn-codex-worker` 触发 skill 逻辑。

## 安装方式 B：Claude Code 项目级 Skill（推荐）

在目标项目根目录执行：

```bash
mkdir -p .claude/skills
cp -R /path/to/subagent-skill/skills/spawn-codex-worker .claude/skills/spawn-codex-worker
```

安装后在 Claude Code 会话中可通过自然语言显式提及 `spawn-codex-worker` skill 触发；若你的环境支持技能斜杠入口，也可尝试 `/spawn-codex-worker`。

## 安装方式 C：Claude Code Plugin

插件目录：`plugin/claude-codex-subagent/`

会话级加载示例：

```bash
claude --plugin-dir /path/to/subagent-skill/plugin/claude-codex-subagent
```

加载后，插件内嵌 skill 可被 Claude Code 使用。

## 在目标仓库准备 wrapper

```bash
mkdir -p scripts
cp .claude/skills/spawn-codex-worker/scripts/spawn-codex-worker.sh ./scripts/spawn-codex-worker.sh
cp .claude/skills/spawn-codex-worker/scripts/spawn-claude-worker.sh ./scripts/spawn-claude-worker.sh
chmod +x ./scripts/spawn-codex-worker.sh ./scripts/spawn-claude-worker.sh
```

若通过 plugin 运行，也可从 `${CLAUDE_PLUGIN_ROOT}/skills/spawn-codex-worker/scripts/` 复制两份脚本。

## 常用调用模板

Codex sub-agent：

```bash
./scripts/spawn-codex-worker.sh \
  --name coder-codex \
  --type coder \
  --task "Implement feature A with tests."
```

Claude sub-agent：

```bash
./scripts/spawn-claude-worker.sh \
  --name reviewer-claude \
  --type reviewer \
  --task "Review feature A for bugs and missing tests."
```

混合并行：

```bash
./scripts/spawn-codex-worker.sh --name codex-a --type coder --task "Implement module A." --background
./scripts/spawn-claude-worker.sh --name claude-b --type coder --task "Implement module B." --background
wait
```

## 产物位置

- 结果文件：`.claude-flow/results/<worker-name>.md`
- 日志文件：`.claude-flow/logs/<worker-name>.log`
