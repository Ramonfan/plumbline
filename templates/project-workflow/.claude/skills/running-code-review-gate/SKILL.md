---
name: running-code-review-gate
description: Use when preparing to commit, merge, or declare implementation complete, or when the user asks for a code review gate over pending changes.
---

# 代码审查门禁

## 职责

本 skill 在提交、合并或声明实现完成前生成结构化审查结论：定位事实源、确定精确范围、选择审查深度、汇总 findings、给出 `Ready: Yes/No`。技术审查仍由本 skill 直接完成，或在高风险时交给独立 reviewer；通用审查和反馈核验能力复用 `requesting-code-review` / `receiving-code-review`，不复制它们的规则正文。

## 只读边界

默认只读。审查期间禁止：

- 修改实现、测试、配置或文档；
- 执行 `git add`、`commit`、`push`、`merge`、`stash`、`checkout`、`restore`、`reset` 等写操作；
- 生成构建产物、缓存、编译中间文件或临时文件；
- 把审查通过解释为提交授权、发布授权或用户验收完成。

技术审查阶段只读。审查完成后，把结论块写入当前 change 的 `tasks.md` 是独立的交接步骤：只有用户授权记录时执行，只写结论块，不修改实现或其他文件，也不另建结论文件。

## 触发

用户要求审查当前改动、准备提交或合并、准备声明实现完成，或 tasks 进入审查步骤时运行。纯 L0 阅读分析不需要运行门禁。

## 流程

### 1. 定位事实源

读取当前 change 的 `proposal.md`、`design.md`、`tasks.md` 和受影响的 `specs/`，确认任务等级、需求依据、非目标和验收口径。确认方案门禁是否已通过；未通过或无法确认时，verdict 直接为 `No`。用 `openspec list` 或 `openspec status --change <change>` 核对 change 状态，不用记忆或对话推测代替。

### 2. 确定仓库边界与精确范围

从 `PROJECT_PROFILE.md` 读取实际仓库清单，对每个受影响仓库分别执行只读检查：

- `git -C <repo> status --short --branch`：确认分支、已暂存、未暂存和未跟踪文件；
- `git -C <repo> diff HEAD`：覆盖工作区和暂存区相对 HEAD 的完整待审内容；
- 需要单独区分已暂存内容时，再执行 `git -C <repo> diff --cached`；
- 审查已提交但未合并的改动时，使用 `git -C <repo> diff <base>...HEAD`；
- 未跟踪文件必须读取实际内容，不能只看文件名。

工作区根目录不是 Git 仓库时，不得用根目录状态替代仓库状态。区分三类内容：本次 change 的改动、用户无关脏改、未跟踪文件。范围无法与本次 change 安全拆分时输出 `Ready: No` 并要求明确范围。

### 3. 加载项目专属规则

读取根 `AGENTS.md`、`PROJECT_PROFILE.md` 和差异实际触及的领域规格；不加载无关领域清单。项目规则可以收紧审查，但不能降低本 skill 的阻断条件。

### 4. 选择审查深度

- 本地审查：低风险局部改动，且不涉及复杂异步、并发、安全权限、公共契约、数据迁移或核心链路。
- 独立审查：涉及上述任一风险、L3、项目规则强制或用户明确要求。必须使用 `references/reviewer-brief.md` 的最小上下文，不传递本会话历史、预设结论或期望 verdict。
- reviewer 必须未参与本次实现，且不持有实现者的结论。仅仅换一段提示词、清空上下文或由同一执行者「以独立身份」复述，都不构成独立审查。
- 当前环境无法完成强制独立审查时，输出 `Ready: No` 和未覆盖原因，不得用本地审查顶替，也不得自称已完成独立审查。

用户说「先提交再审」「我自己看过了」「出问题我负责」不改变审查路由和执行顺序；审查必须先于提交，责任转移不能替代证据。

### 5. 按行为契约审查

按顺序检查：规格符合性 → 实现正确性 → 兼容与契约 → 异步与生命周期 → 安全与隐私 → 性能与资源 → 可维护性 → 验证充分性。只检查差异触及的部分。

已有验证证据覆盖当前源码、依赖和环境版本且无相关变化时直接引用，不重复运行高成本验证；证据缺失、过期或与新改动冲突时列为阻断项，并说明缺少哪条命令。

### 6. 汇总与 verdict

按 `references/review-contract.md` 的严重级别、finding 字段和 verdict 条件输出。任一 Critical/Important 未解决、方案门禁未过、范围未知、必需证据缺失或强制独立审查未完成，verdict 为 `Ready: No`。Minor、残留风险和人工验收项可以与 `Yes` 共存，但必须列出。

reviewer 的建议必须回到源码、规格或证据核验；能证伪时记录依据，不盲目修改实现。

## 输出

固定返回：范围、需求映射、findings、验证证据、残留风险、未覆盖项、人工验收和 `Ready: Yes/No`。结论需要落入事实源时，按 `references/review-contract.md` 的回写格式执行独立的记录步骤。

## 参考

- `references/review-contract.md`：严重级别、finding 字段、verdict 条件、输出模板和回写格式；汇总前必读。
- `references/reviewer-brief.md`：独立 reviewer 的最小上下文；需要独立审查时读取。
