## Why

可复用工作流模板已经定义按风险执行代码审查，但没有随模板交付可执行的审查门禁 skill。现有 Superpowers `requesting-code-review` 以单仓 Git SHA 和独立代理为默认，无法直接覆盖 OpenSpec 事实源、L1 本地审查、多仓工作区、验证证据复用和提交阻断结论。

本变更按 **L2 常规模板变化** 处理，来源消费项目为 `/Users/leigod/雷神/App改造/openSpec/changes/adopt-code-review-gate-skill`。需求门禁已具备：建立通用的提交前代码审查 skill，供 Codex 和 Claude Code 使用；不新增 Git hook、CI 平台、远程服务或自动提交权限。

## What Changes

- 在权威模板新增 `.agents/skills/running-code-review-gate/` 规范源，以及 `.claude/skills/running-code-review-gate/` 镜像入口，作为 OpenSpec 与 Superpowers 之间的项目级审查编排层。
- skill 在提交、合并或实现完成声明前定位当前 change、任务等级、方案门禁、待审差异、仓库边界和有效验证证据。
- skill 按风险选择本地审查或独立审查，复用 `requesting-code-review` / `receiving-code-review`，但不复制它们的通用技术判断规则。
- 统一 findings 和门禁输出：范围、需求映射、Critical/Important/Minor、验证缺口、残留风险、未覆盖项与 `Ready: Yes/No`；Critical/Important、未知提交范围或必需证据缺失时阻断。
- skill 保持只读：不自动修改实现，不执行 commit、push、merge，不把审查结论当作用户人工验收。
- 为项目专属审查点预留 `PROJECT_PROFILE.md`、根规则和领域规格路由，不把 iOS 或业务规则写入通用 skill 核心。
- 更新模板安装映射、验证脚本、研发流程规格、模板治理规格、实施检查清单、基线版本和 CHANGELOG；历史消费项目通过人工差异合并接入。
- 使用 skill TDD：先以无 skill 的压力场景记录基线失败，再完成 GREEN/REFACTOR 和结构验证。

## Capabilities

### New Capabilities

- `code-review-gate`: 定义可复用提交前代码审查门禁的触发条件、输入、风险路由、输出契约、阻断规则和证据归属。

### Modified Capabilities

- `development-workflow`: 将代码提交、合并和实现完成声明纳入风险匹配的审查门禁，并明确 OpenSpec 与 Superpowers 的职责边界。
- `portable-project-workflow`: 将审查 skill 纳入权威模板、安装清单、结构校验、版本基线和消费项目升级路径。

## Impact

- 预计影响 `templates/project-workflow/.agents/skills/running-code-review-gate/`、`templates/project-workflow/.claude/skills/running-code-review-gate/`、模板 `AGENTS.template.md`、`PROJECT_PROFILE.template.md`、研发流程主规格、实施检查清单、`scripts/install.sh`、`scripts/verify.sh`、`WORKFLOW_BASELINE.yaml`（`0.1.0-dev.5`）、`README.md`、`CHANGELOG.md` 和本 change 工件。
- skill 自动发现保持启用；安装属于新增文件映射，空目标可直接安装，已有同名路径继续按冲突零写入规则停止并要求人工合并。
- 兼容性为增量兼容：不删除现有模板文件或参数，不改变未接入 skill 的消费项目现状；历史项目需人工比较并新增 skill 与相应规则。
- 验证覆盖 skill 基线失败与回归场景、`quick_validate.py`、安装预览、空目标安装、冲突零写入、重复安装、模板隔离和 OpenSpec strict validation。

## Acceptance

- 低风险局部改动默认完成本地审查，不因 skill 存在自动启动独立代理。
- 高风险或项目规则指定的改动能够获得独立审查，且 reviewer 只接收精确范围和必要事实，不继承编排会话历史。
- 任一 Critical/Important finding、方案门禁未通过、提交范围不明确或必需验证缺失都会产生 `Ready: No`。
- findings 全部处理且当前版本证据完整时可产生 `Ready: Yes`，同时保留项目要求的人工验收项。
- 模板安装和验证能识别两棵 skill 目录；Codex 和 Claude Code 都能自动发现，且 `.agents/skills/` 与 `.claude/skills/` 内容一致；通用 skill 不含消费项目业务专名或技术栈硬编码。
