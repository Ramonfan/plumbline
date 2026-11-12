## Why

项目当前名为「AI 工作流」，只描述类别，不构成正式项目身份。随着模板已经具备跨 agent 入口、安全安装、只读升级比较、基线校验和 OpenSpec 治理，名称需要在文档、基线和消费项目来源记录中保持稳定、可识别且可迁移。2026-11-12 用户确认采用 **Plumbline（准绳）** 作为正式名称。

本变更按 **L2 模板和公开文档变化** 处理。改名只调整项目身份和公开名称，不改变安装映射、占位符范围、脚本契约或工作流行为。

## What Changes

- 将项目正式名称从「AI 工作流」改为 **Plumbline（准绳）**。
- 更新根 `AGENTS.md`、`PROJECT_PROFILE.md`、`README.md`、`CHANGELOG.md`、`openSpec/config.yaml` 和 `openSpec/README.md` 的项目名称。
- 将模板 `WORKFLOW_BASELINE.yaml` 的 `authority_name` 从 `AI 工作流` 改为 `Plumbline`，并同步 `scripts/verify.sh` 的基线断言。
- 在 `portable-project-workflow` 主规格增加权威项目名称一致性要求：基线 `authority_name`、文档标题和项目配置必须指向同一名称。
- 不重命名实际工作目录；目录迁移由用户另行决定。
- 历史归档 change 保留原名称，不改写历史记录。

## Capabilities

### Modified Capabilities

- `portable-project-workflow`: 权威项目名称必须在基线、项目配置和公开文档中保持一致；改名不得改变安装契约或历史归档。

## Impact

- 修改 `AGENTS.md`、`PROJECT_PROFILE.md`、`README.md`、`CHANGELOG.md`、`openSpec/config.yaml`、`openSpec/README.md`、`templates/project-workflow/INSTALL.md`、`templates/project-workflow/WORKFLOW_BASELINE.yaml`、`scripts/verify.sh` 和本 change 工件。
- 不新增或删除安装目标文件，不改变文件映射、占位符、退出码、安装零写入或比较语义。
- 消费项目若记录了旧权威名称，需要人工更新 `PROJECT_PROFILE.md` 的来源记录；比较脚本行为不受影响。
- 工作流版本仍为 `0.1.0-dev.4`；改名不占用新的 `dev.N` 基线。

## Acceptance

- 根项目、模板基线、OpenSpec context、README、CHANGELOG 和验证脚本使用一致的新名称。
- `WORKFLOW_BASELINE.yaml` 的 `authority_name` 为 `Plumbline`，验证脚本断言通过。
- 安装映射、占位符范围、安装/比较退出码和工作流行为不变。
- 历史归档保持原样，交付记录明确目录未自动重命名。
- `./scripts/verify.sh` 和 OpenSpec strict validation 通过。
