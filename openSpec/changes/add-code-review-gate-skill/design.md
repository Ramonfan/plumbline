## Context

见 `proposal.md`。当前权威模板只交付规则和清单，没有可执行 skill；消费项目因此需要临时拼装 OpenSpec、Git 差异和 Superpowers 审查能力。模板安装器采用显式 `sources` / `destinations` 映射和冲突零写入，验证器精确比较安装树；新增 skill 会同时改变模板公开文件、安装清单和基线版本。

## Goals / Non-Goals

**Goals:**

- 交付一个跨技术栈、跨 agent、自动可发现、只读且能产出二元 verdict 的代码审查门禁 skill。
- 同时提供 Codex/通用 agent 的 `.agents/skills/` 入口和 Claude Code 的 `.claude/skills/` 入口，共享同一份技能内容。
- 复用 OpenSpec 事实源和 Superpowers 审查能力，避免建立第二套需求或反馈处理规则。
- 保持 L1 本地审查和高风险独立审查的差异，支持多仓和项目专属适配。
- 把 skill 纳入安全安装、结构验证、版本基线、变更日志和消费项目升级路径。

**Non-Goals:**

- 不实现 Git hook、CI required check、代码托管平台审批或自动提交。
- 不向通用核心加入 iOS、Web、后端或特定业务审查清单。
- 不修改 Superpowers 原始技能，也不要求所有低风险任务启动代理。

## Decisions

### 1. 采用项目级编排 skill，而不是复制 Superpowers

新增 `running-code-review-gate` 负责定位 change、确定提交范围、读取项目规则、选择审查方式、整合 findings 和给出 verdict。通用技术审查和反馈核验继续由 `requesting-code-review`、`receiving-code-review` 和执行者的本地审查能力承担。

替代方案一是直接把 `requesting-code-review` 写进模板路由，但它假设单仓 SHA 且总是独立 reviewer；替代方案二是复制并改写 Superpowers，会造成上游能力分叉。编排层只补项目治理缺口，边界更稳定。

### 2. Skill 使用渐进披露结构

计划文件：

- `.agents/skills/running-code-review-gate/SKILL.md`：规范源，供 Codex 和通用 agent 发现；包含触发条件、只读边界、门禁主流程、风险路由和所需参考。
- `.agents/skills/running-code-review-gate/references/review-contract.md`：严重级别、finding 字段、verdict 条件和 OpenSpec 回写格式。
- `.agents/skills/running-code-review-gate/references/reviewer-brief.md`：高风险独立 reviewer 的最小上下文模板。
- `.agents/skills/running-code-review-gate/agents/openai.yaml`：Codex 显示名称、简述和默认提示，保持隐式调用开启。
- `.claude/skills/running-code-review-gate/`：Claude Code 镜像入口，包含相同的 `SKILL.md` 和两个 references；不包含 `agents/openai.yaml`。

`.agents/skills/` 是规范源，`.claude/skills/` 是受验证的镜像。`scripts/verify.sh` 使用目录比较确保两边内容一致，防止漂移；安装器把两棵目录都映射到目标项目。这样 Codex 和 Claude Code 都能自动发现技能，又不需要维护两套不同正文。

项目专属审查点不进入这些通用文件；skill 必须读取根规则、`PROJECT_PROFILE.md` 和实际触及的领域规格。消费项目可以在不改变通用行为的前提下增加本地 reference，并在根规则中声明路由。

### 3. 输出采用二元 verdict 和三档 finding

最终固定为 `Ready: Yes/No`，findings 使用 Critical/Important/Minor，以兼容现有模板实施清单和消费项目历史记录。Critical/Important、范围未知、方案门禁未过、必需验证缺失或强制独立审查未完成时为 `No`。Minor 和人工验收项可以与 `Yes` 共存，但必须显式列出。

相比增加 `Ready with risks` 第三状态，二元 verdict 更适合门禁自动判断；风险通过独立字段表达，避免提交者把中间状态理解为通过。

### 4. Skill TDD 是实施前置条件

依据 skill authoring 约束，实施先运行无 skill 基线压力场景，再编写内容。至少覆盖：

1. 低风险任务被无差别升级为独立审查。
2. 多仓工作区错误使用根目录或单一 SHA。
3. 高风险异步/权限/公共接口任务被本地自审放行。
4. 无关脏改、未跟踪文件或验证缺口被忽略。
5. 用户施压要求“先提交再审”时仍必须输出阻断 verdict。

GREEN 阶段用同一场景验证，REFACTOR 阶段只针对实际出现的新合理化补充约束。测试使用隔离临时目录；不在真实消费项目制造测试改动。

### 5. 安装、验证和版本处理

`scripts/install.sh` 的显式映射增加 `.agents/skills/running-code-review-gate/` 和 `.claude/skills/running-code-review-gate/` 两棵目录，现有父路径预检会自然覆盖；冲突仍在任何写入前统一停止。`scripts/verify.sh` 同步更新必需文件、安装映射、精确树、两棵目录内容比较和通用核心泄漏检查，并增加 frontmatter、名称、引用目标和未完成占位校验。

开发环境额外运行 skill-creator 的 `quick_validate.py`；统一 `verify.sh` 不依赖用户主目录中的 Codex 工具，以保持模板项目可移植。`0.1.0-dev.5` 是本 change 的未发布基线：`dev.2` 已被编码行为准则 change 占用，`dev.3` 已被跨 agent 入口 change 占用，`dev.4` 已被升级路径 change 占用。CHANGELOG 记录新增文件、双入口和历史项目人工升级要求。

### 6. 影响入口、职责与数据契约

- 入口：用户请求审查、准备提交/合并、准备声明实现完成，或 tasks 进入审查步骤。
- 调用方：消费项目的 Codex、Claude Code 或通用 agent 实现流程。
- 被调用方：OpenSpec CLI、各实际仓库的只读 Git 命令、项目规则/规格、Superpowers 审查与反馈接收能力；高风险时调用独立 reviewer。
- 数据契约：change、任务等级、提交范围、仓库列表、需求映射、验证引用、findings、残留风险、人工验收和 `Ready`。
- 文件映射：规范源位于 `templates/project-workflow/.agents/skills/running-code-review-gate/`，Claude Code 镜像位于 `templates/project-workflow/.claude/skills/running-code-review-gate/`；安装目标保持同路径，并由验证器比较两边内容。

## Risks / Trade-offs

- [skill 无法像 CI 一样物理阻止人工 Git 提交] → 明确第一阶段是 agent 工作流门禁；平台强制执行另建 change。
- [两棵技能目录内容漂移] → `.agents/skills/` 为规范源，`.claude/skills/` 为镜像；`verify.sh` 使用目录比较强制一致。
- [模板文件和安装树扩大，冲突概率增加] → 保持全部预检和零写入，历史项目只支持人工比较合并。
- [独立 reviewer 消耗上下文或误读项目] → 仅在风险要求时使用，采用干净的最小 reviewer brief，findings 必须经项目事实核验。
- [通用 skill 过度抽象而漏掉技术栈风险] → 强制读取根规则、项目配置和触及领域规格；技术栈示例继续留在 `examples/` 或消费项目。
- [验证器依赖 Codex 本机工具降低可移植性] → `quick_validate.py` 仅作为开发证据，`scripts/verify.sh` 自带必要结构检查。

## Migration Plan

1. 在隔离场景完成 RED 基线并记录失败模式。
2. 初始化并编写通用 skill，完成 GREEN/REFACTOR、quick validation 和只读行为回归。
3. 更新模板规则、主规格、安装器、验证器、基线和 CHANGELOG。
4. 运行安装预览、空目标安装、冲突零写入、重复安装、完整 `verify.sh` 和 OpenSpec strict validation。
5. 消费项目通过关联 change 人工合并适用增量并分别验证。

回滚时恢复安装映射、验证树和基线版本，并移除本次新增的模板 skill 与规格增量；不得删除消费项目已经人工适配的同名文件，消费侧回滚由其关联 change 单独处理。
