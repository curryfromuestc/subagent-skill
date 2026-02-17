# Cross-Agent Subagent Skill/Plugin

这个仓库提供一套可复用能力，用于在 **Codex** 和 **Claude Code** 主会话中，混合调用两类 sub-agent：

- Codex sub-agent（`codex exec`）
- Claude sub-agent（`claude -p`）

## 关键目录

- `scripts/`：仓库级 wrapper 脚本
- `skills/spawn-codex-worker/`：Codex skill 源码（也可复用于其他分发）
- `.claude/skills/spawn-codex-worker/`：Claude Code 项目级 skill
- `plugin/claude-codex-subagent/`：Claude Code plugin 打包目录
- `docs/USAGE.md`：安装与使用文档
- `docs/VALIDATION.md`：验证文档与验收矩阵

## 两个 sub-agent wrapper

- `scripts/spawn-codex-worker.sh`
- `scripts/spawn-claude-worker.sh`

## 下一步

1. 按 `docs/USAGE.md` 安装你需要的形态（Codex skill / Claude skill / Claude plugin）。
2. 按 `docs/VALIDATION.md` 运行 4 组主会话与子会话组合验证。
