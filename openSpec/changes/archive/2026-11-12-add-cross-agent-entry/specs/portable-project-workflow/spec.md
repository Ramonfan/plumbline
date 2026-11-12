## ADDED Requirements

### Requirement: 模板提供共享事实源的跨 agent 入口
可安装模板 MUST 同时提供面向 Codex/通用 agent 的 `AGENTS.md` 入口和面向 Claude Code 的 `CLAUDE.md` 入口。`CLAUDE.md` MUST 通过导入引用 `AGENTS.md` 和 `PROJECT_PROFILE.md`，不得复制或另行维护一套需求、门禁、任务或项目规则。两个入口 MUST 在安装、冲突检测和结构验证中被视为同一模板包的一部分；任一入口已存在时 MUST 零写入停止并要求人工合并。

#### Scenario: Codex 或通用 agent 使用项目
- **WHEN** 执行者读取根目录 `AGENTS.md`
- **THEN** 获得完整项目规则，不依赖 `CLAUDE.md` 是否存在

#### Scenario: Claude Code 使用项目
- **WHEN** Claude Code 读取根目录 `CLAUDE.md`
- **THEN** 通过 `@AGENTS.md` 和 `@PROJECT_PROFILE.md` 获得同一规则源，不出现第二套规则

#### Scenario: 安装到空项目
- **WHEN** 目标项目没有 `AGENTS.md` 和 `CLAUDE.md`
- **THEN** 安装同时生成两个入口文件，且 `CLAUDE.md` 只包含事实源说明、导入和必要的 Claude 专属补充位置

#### Scenario: 目标项目已有 CLAUDE.md
- **WHEN** 安装前检测到目标项目已有 `CLAUDE.md`
- **THEN** 安装列出冲突并以状态 `2` 零写入停止，要求人工比较合并

#### Scenario: 验证跨 agent 入口
- **WHEN** 运行模板验证
- **THEN** 检查两个入口存在、`CLAUDE.md` 包含两个导入，且模板 `CLAUDE.template.md` 未复制 `AGENTS.md` 的主要规则章节
