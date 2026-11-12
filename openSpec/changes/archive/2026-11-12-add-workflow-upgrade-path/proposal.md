## Why

已经接入本工作流的项目目前只能通过 `README.md` 和 `INSTALL.md` 的零散说明得知“不要整目录覆盖、比较基线和 CHANGELOG”，缺少可执行的版本升级路径。消费项目无法快速回答：自己当前对应哪份模板、新版本改了哪些文件、哪些文件可以取模板、哪些必须保留本地修改，以及何时才能更新记录的接入基线。

本变更按 **L2 常规模板变化** 处理。用户于 2026-11-12 确认按“文档 + 只读比较脚本”范围落地升级能力；目标是让已接入项目安全、可追溯地合并模板增量，而不是自动覆盖已有治理文件。

## What Changes

- 新增权威侧只读比较脚本 `scripts/compare.sh`，逐文件比较已安装项目、当前模板和可选的旧模板快照。
- 将安装文件映射抽取为 `scripts/workflow-files.sh`，由 `install.sh`、`verify.sh` 和 `compare.sh` 共享，避免新增文件时三处漂移。
- 比较脚本按文件输出 `unchanged`、`ours-only`、`theirs-only`、`both-changed`、`missing` 等状态；`AGENTS.md`、`CLAUDE.md`、`PROJECT_PROFILE.md` 和 `openSpec/config.yaml` 始终标记为人工处理。
- 比较脚本只读，不写入目标项目或旧模板快照；差异存在时仍以成功状态输出报告。
- 在模板 `INSTALL.md` 增加“升级已接入项目”完整 runbook：版本化差异、消费项目 OpenSpec change、三方合并、重新基线、验证、验收和回滚。
- 在根 `README.md` 增加升级入口，说明消费项目如何获取旧版本快照、运行比较、处理分类结果和更新基线。
- 在 `CHANGELOG.md` 增加每个版本的 Upgrade 记录约定，并记录本 change 的升级能力。
- 将 `WORKFLOW_BASELINE.yaml` 升级到 `0.1.0-dev.4`，同步 `scripts/verify.sh` 基线校验；`add-code-review-gate-skill` 顺延到 `0.1.0-dev.5`。
- 更新 OpenSpec 主规格，要求已接入项目升级必须经过只读差异、人工合并、真实验证和重新基线。

## Capabilities

### Modified Capabilities

- `portable-project-workflow`: 新增已接入项目安全升级契约，要求权威项目提供只读差异比较和升级 runbook，消费项目通过 OpenSpec change 完成合并、验证和重新基线。

## Impact

- 新增 `scripts/compare.sh`、`scripts/workflow-files.sh` 和本 change 工件。
- 修改 `scripts/install.sh`、`scripts/verify.sh`、`templates/project-workflow/INSTALL.md`、`templates/project-workflow/WORKFLOW_BASELINE.yaml`、`README.md`、`CHANGELOG.md`、`AGENTS.md`、`PROJECT_PROFILE.md`、`openSpec/changes/add-code-review-gate-skill/proposal.md`、`openSpec/changes/add-code-review-gate-skill/design.md`、`openSpec/changes/add-code-review-gate-skill/tasks.md` 和 `openSpec/specs/portable-project-workflow/spec.md`。
- 不新增安装目标文件，不改变安装映射、占位符范围、退出码或零写入契约；`compare.sh` 属于权威项目工具，不安装到消费项目。
- 历史消费项目不会自动升级；升级需要人工创建 change、比较差异、合并、验证并更新基线。

## Acceptance

- `compare.sh` 在目标项目与当前模板一致时报告全部 `unchanged`。
- 提供旧模板快照时，能区分仅消费项目修改、仅模板修改、两边修改和缺失文件。
- `AGENTS.md`、`CLAUDE.md`、`PROJECT_PROFILE.md` 和 `openSpec/config.yaml` 始终提示人工处理，脚本不写入任何文件。
- 没有旧模板快照时，脚本降级为两方比较并明确提示无法区分本地修改和模板修改。
- README 和 INSTALL 给出可执行升级步骤、分类处理规则、基线更新时机和回滚方式。
- `./scripts/verify.sh`、OpenSpec strict validation 和安装行为回归全部通过。
