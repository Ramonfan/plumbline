## Why

当前模板只有 `AGENTS.md` 入口，Codex 和通用 agent 可以直接读取。Claude Code v2.1.277 及以上在完全缺少 `CLAUDE.md` 和 `CLAUDE.local.md` 时也会直接读取 `AGENTS.md`，但旧版本、受限会话以及需要 Claude 专属补充的场景仍需要 `CLAUDE.md`。如果没有显式入口，同一个项目换一个 agent 就可能需要人工复制规则，容易产生第二套事实源和规则漂移。

本变更按 **L2 常规模板变化** 处理：为可安装模板增加 Claude Code 薄适配入口，同时保持 Codex 和通用 agent 继续使用 `AGENTS.md`，不引入第二套流程、事实源或安装协议。

需求门禁结论：目标、非目标、影响范围、兼容方式和验收口径已在本文档和 delta spec 中明确；用户于 2026-11-12 要求“按照 CLAUDE 适配”，并确认 Codex 仍需可用，视为方案门禁授权。

## What Changes

- 新增模板 `templates/project-workflow/CLAUDE.template.md`，安装为根目录 `CLAUDE.md`；内容只声明事实源并导入 `@AGENTS.md` 和 `@PROJECT_PROFILE.md`，不复制规则。
- 在权威项目根目录新增 `CLAUDE.md`，让 Claude Code 可以直接使用本项目，同时作为模板示例。
- 更新 `scripts/install.sh` 的文件映射、`scripts/verify.sh` 的必需文件、安装树、冲突检测、导入检查和模板泄漏检查。
- 更新 `templates/project-workflow/INSTALL.md`、`PROJECT_PROFILE.template.md`、模板 `openSpec/README.md`、模板 `openSpec/config.template.yaml`，说明 Codex 与 Claude Code 两个入口共享同一事实源。
- 重写根 `README.md`，面向首次使用者说明项目定位、支持的 agent、快速开始、安装与合并、日常流程、验证和常见问题。
- 更新根 `AGENTS.md`、`PROJECT_PROFILE.md`、`openSpec/config.yaml`、`openSpec/README.md`，把“Codex 专用”表述改为 agent-neutral，并记录当前 Git 状态。
- 将 `WORKFLOW_BASELINE.yaml` 升级到 `0.1.0-dev.3`，同步 `scripts/verify.sh` 的基线校验和 `CHANGELOG.md`。
- 协调 `add-code-review-gate-skill`：该 change 的基线改为 `0.1.0-dev.4`，并在实施时为同一审查技能提供 `.agents/skills/` 和 `.claude/skills/` 两个可发现入口。
- 不修改现有安装退出码、占位符范围或安全安装行为；历史消费项目仍需人工比较并合并 `CLAUDE.md` 增量。

## Capabilities

### Modified Capabilities

- `portable-project-workflow`: 新增跨 agent 入口契约，要求模板同时提供 `AGENTS.md` 和 `CLAUDE.md`，并由 `CLAUDE.md` 导入同一事实源。

## Impact

- 预计影响 `templates/project-workflow/CLAUDE.template.md`、模板 `AGENTS.template.md`、`PROJECT_PROFILE.template.md`、模板 `openSpec/README.md`、模板 `openSpec/config.template.yaml`、模板 `examples/ios/PROJECT_PROFILE.example.md`、`INSTALL.md`、`WORKFLOW_BASELINE.yaml`、根 `CLAUDE.md`、`AGENTS.md`、`PROJECT_PROFILE.md`、`README.md`、`openSpec/config.yaml`、`openSpec/README.md`、`scripts/install.sh`、`scripts/verify.sh`、`CHANGELOG.md`、`openSpec/changes/add-code-review-gate-skill/proposal.md`、`openSpec/changes/add-code-review-gate-skill/design.md`、`openSpec/changes/add-code-review-gate-skill/tasks.md` 和本 change 工件。
- 兼容性为增量兼容：不删除现有模板文件或参数；新增 `CLAUDE.md` 安装映射后，目标项目已有同名文件时按冲突零写入停止并要求人工合并。
- 验证覆盖两个入口存在、导入目标正确、`CLAUDE.md` 不复制规则、安装预览、空目标安装、冲突零写入、重复安装、模板泄漏检查和 OpenSpec strict validation。

## Acceptance

- Codex 和通用 agent 继续通过 `AGENTS.md` 获得完整规则，不依赖 `CLAUDE.md`。
- Claude Code 通过 `CLAUDE.md` 的 `@AGENTS.md` 和 `@PROJECT_PROFILE.md` 获得同一规则源，不出现第二套规则。
- 空目标安装同时生成 `AGENTS.md` 和 `CLAUDE.md`；已有任一入口时安装零写入停止。
- `CLAUDE.md` 只包含事实源说明、两个导入和必要的 Claude 专属补充位置，不包含任务分级、门禁或编码行为准则副本。
- 基线、README、INSTALL、CHANGELOG 和验证脚本的版本信息一致；不宣称历史项目会自动获得 `CLAUDE.md`。
