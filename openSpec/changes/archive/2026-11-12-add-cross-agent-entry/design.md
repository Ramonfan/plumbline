## Context

见 `proposal.md`。当前模板的可移植规则入口只有 `AGENTS.md`。Codex 和多数遵循 `AGENTS.md` 约定的 agent 可以直接读取，但 Claude Code 的传统项目规则入口是 `CLAUDE.md`。Claude Code v2.1.277 及以上在完全缺少 `CLAUDE.md` 和 `CLAUDE.local.md` 时也会直接读取 `AGENTS.md`，但旧版本、受限会话和需要 Claude 专属补充的场景仍需显式入口。官方支持在 `CLAUDE.md` 中用 `@AGENTS.md` 导入既有规则，而不是复制规则。

本变更只补一个薄适配层，不改变 OpenSpec 事实源、任务分级、门禁、安装安全边界或现有退出码。

## Goals / Non-Goals

**Goals:**

- 让 Codex、Claude Code 和通用 agent 共享同一份项目规则。
- 让新项目安装后开箱即用，不需要用户手工创建 `CLAUDE.md`。
- 让已有 `CLAUDE.md` 的项目继续遵守“冲突零写入、人工合并”的安全安装契约。
- 重写 README，使首次使用者能判断项目是否适合自己并完成第一次安装和 change。

**Non-Goals:**

- 不为每个 agent 复制一套规则文件。
- 不引入 Cursor、Windsurf、Gemini 等额外入口；需要时按同一模式扩展。
- 不改变 OpenSpec schema、任务等级、三个门禁或 Superpowers 职责。
- 不在本次实现审查技能；该 skill 的 agent 目录适配在 `add-code-review-gate-skill` 中完成。
- 不自动迁移或覆盖历史项目已有 `CLAUDE.md`。

## Decisions

### 1. `AGENTS.md` 保持流程规则事实源

根级规则、任务分级、门禁、编码行为准则、工作区保护和交付记录继续只维护在 `AGENTS.md`。Codex 和通用 agent 不因新增 `CLAUDE.md` 改变读取路径。

### 2. `CLAUDE.md` 只做导入

模板 `CLAUDE.template.md` 内容固定为：

```markdown
# Claude Code 入口

本项目的流程规则事实源是根目录 `AGENTS.md`；项目边界、命令和验收配置的事实源是 `PROJECT_PROFILE.md`。本文件只负责导入，不重复维护规则；Claude 专属补充写在导入之后。

@AGENTS.md
@PROJECT_PROFILE.md
```

不变量：只包含事实源说明、两个列 0 导入和必要的 Claude 专属补充位置；不超过 60 行；不与 `AGENTS.template.md` 的标题或正文行重合；根 `CLAUDE.md` 必须与模板入口逐字节一致。使用官方 `@path` 导入语法，Claude Code 会在会话启动时展开两个文件。项目如果确有 Claude 专属规则，可以追加在导入之后，但不得复制 `AGENTS.md` 已有内容。

替代方案是双份完整规则或符号链接。双份会漂移；符号链接在 Windows 和安装脚本中增加平台与安全路径复杂度。导入语法是 Claude Code 官方推荐做法，且不产生第二份内容。

### 3. 安装映射和验证按普通模板文件处理

`CLAUDE.template.md` 加入 `scripts/install.sh` 的源文件和目标文件列表，目标为 `CLAUDE.md`。现有冲突检测、父路径预检、dry-run、重复安装和零写入行为自然覆盖新文件。`scripts/verify.sh` 增加：

- 根项目和模板必需文件检查；
- 安装预览、空目标安装树、部分冲突、仅有 `CLAUDE.md` 的冲突和重复安装零写入检查；
- `CLAUDE.md` 和模板入口必须在列 0 各包含且仅包含一个 `@AGENTS.md` 与 `@PROJECT_PROFILE.md`，代码围栏和缩进导入不算有效导入；
- 根 `CLAUDE.md` 必须与 `CLAUDE.template.md` 逐字节一致；
- 模板入口不超过 60 行，且不得与 `AGENTS.template.md` 的标题或正文行重合，防止退化成第二份规则；
- 基线版本校验更新到 `0.1.0-dev.3`。

### 4. README 面向首次使用者重写

保留现有安装、验证和回流事实，重组为“定位 → 支持的 agent → 核心概念 → 快速开始 → 安装/合并 → 日常使用 → 验证 → FAQ → 当前状态”。README 明确 Claude Code 的 `/context all` 验证方式，以及 Codex 不需要 `CLAUDE.md`。

### 5. 版本与关联 change 协调

`0.1.0-dev.2` 已被已归档的 `add-coding-behavior-guidelines` 占用。本变更使用 `0.1.0-dev.3`。因此 `add-code-review-gate-skill` 若在本变更后实施，应使用 `0.1.0-dev.4`；同时把该 change 的技能入口计划扩展为 `.agents/skills/` 和 `.claude/skills/` 双入口，并由验证脚本校验内容一致。

## Risks / Trade-offs

- [Claude Code 版本差异导致导入行为不同] → 使用官方文档支持的 `@path` 语法；README 指引用户用 `/context all`（可用版本也可使用 `/memory`）确认 `CLAUDE.md` 和导入文件已加载，并说明 v2.1.277 之前的版本和受限会话不能直接读取 `AGENTS.md`。
- [两个 agent 的子目录加载时机不同] → 文档说明 Codex 沿目录向上扫描 `AGENTS.md`；模板安装后有根 `CLAUDE.md`，Claude Code 默认只读 `CLAUDE.md` 链路，子目录 `AGENTS.md` 需薄 `CLAUDE.md` 或 `claude-md-and-agents-md` 才会加载；完全没有 `CLAUDE.md` 时才是直接读取 `AGENTS.md` 的路径。不声称两者加载顺序完全等价。
- [安装映射在脚本、验证、INSTALL 和 README 多处维护] → 脚本和验证脚本由 `verify.sh` 的精确安装树与 dry-run 比对覆盖；文档映射仍需在新增文件时同步检查，已记录为维护风险。
- [项目已有 `CLAUDE.md` 时安装失败] → 这是有意保留的冲突零写入行为；INSTALL 和 README 说明人工比较合并。
- [`CLAUDE.md` 逐渐被写成第二份规则] → 验证脚本检查模板入口行数上限、与 `AGENTS.template.md` 的标题和正文行重合，以及根入口与模板逐字节一致；文档明确只允许追加 Claude 专属内容。该校验是启发式，不能替代审查。
- [`PROJECT_PROFILE.md` 未填写时导入占位符] → 与 `AGENTS.md` 当前要求一致；安装完成检查要求先填写项目配置。
- [与审查技能 change 的版本冲突] → 本变更占用 dev.3，关联 change 明确使用 dev.4。
- [额外入口增加安装冲突概率] → 只新增一个文件，且冲突会在任何写入前统一报告；比复制整套规则更可控。

## Migration Plan

1. 新增模板和根目录 `CLAUDE.md`。
2. 更新安装映射、验证脚本、模板配置和安装文档。
3. 重写 README，更新根规则、项目配置、OpenSpec 入口和 CHANGELOG。
4. 运行 `bash -n`、`./scripts/verify.sh`、安装预览、空目标安装、冲突零写入、重复安装和 OpenSpec strict validation。
5. 用户结构验收后同步 `portable-project-workflow` 长期主规格并归档。

回滚时移除新增的 `CLAUDE.md`、模板 `CLAUDE.template.md`、安装映射、验证检查和文档增量，恢复基线到 `0.1.0-dev.2`；不删除消费项目已经人工合并的 `CLAUDE.md`。
