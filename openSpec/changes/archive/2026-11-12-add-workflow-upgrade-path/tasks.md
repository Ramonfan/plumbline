## 0. 门禁

- [x] 0.1 用户确认按“文档 + 只读比较脚本”落地已接入项目升级能力；验证证据：2026-11-12 用户选择“文档 + 只读比较脚本 (Recommended)”，明确不提供自动覆盖。

## 1. 共享映射

- [x] 1.1 新增 `scripts/workflow-files.sh`，集中定义模板源、安装目标、目录映射；验证：文件只包含数组和只读保护，不执行写入。
- [x] 1.2 让 `scripts/install.sh` 和 `scripts/verify.sh` source 共享映射并删除内联数组；验证：`./scripts/verify.sh` 覆盖预览、空目标安装、部分冲突、仅有 `CLAUDE.md` 冲突、重复安装和不安全路径，输出 `ALL_CHECKS_PASSED`，退出码 0。

## 2. 比较脚本

- [x] 2.1 新增 `scripts/compare.sh --target <dir> [--base <dir>]`，逐文件输出 `unchanged`、`ours-only`、`theirs-only`、`both-changed`、`converged`、`missing`、`base-missing` 或 `differs`；验证：`verify.sh` 覆盖全部状态，无效/不可读目标或 base 返回 `66`，空 base 和未知参数返回 `64`。
- [x] 2.2 为项目专属文件追加 `manual: project-specific`，为基线文件追加 `metadata: update after merge`；验证：`verify.sh` 断言两类备注均存在。
- [x] 2.3 保证脚本只读：不创建、修改或删除目标、base 或模板文件；验证：`verify.sh` 的 `run_compare` 在比较前后对目标树、base 树和模板目录做快照比较，任何变化即失败。
- [x] 2.4 在报告中打印目标记录基线、base 快照基线和当前模板基线；验证：脚本输出 `Target baseline`、`Base baseline` 和 `Template baseline`，YAML 不可解析时输出 `unknown` 而不中断。

## 3. 文档与版本

- [x] 3.1 在 `templates/project-workflow/INSTALL.md` 增加“升级已接入项目”runbook，覆盖旧基线、权威版本快照和工作区干净度、消费项目 change、三方输入、分类处理、真实验证、重新基线、验收、回滚和检查清单；验证：步骤可执行，明确不做整目录覆盖。
- [x] 3.2 在根 `README.md` 增加升级入口、版本快照前置条件、`compare.sh` 示例、状态表、删除/重命名限制、FAQ、目录结构和 dev.4 当前状态；验证：命令、状态和退出码与脚本一致。
- [x] 3.3 在 `CHANGELOG.md` 增加每版本 Upgrade 记录约定，并记录比较脚本、共享映射、升级 runbook 和兼容影响；验证：新增/修改/删除文件、占位符、安装行为和兼容影响有明确位置。
- [x] 3.4 将 `WORKFLOW_BASELINE.yaml` 升级到 `0.1.0-dev.4`，同步 `scripts/verify.sh`、根 README、CHANGELOG；`add-code-review-gate-skill` 的 proposal/design/tasks 顺延到 `0.1.0-dev.5`；验证：`verify.sh` 的基线断言通过。
- [x] 3.5 更新 `AGENTS.md`、`PROJECT_PROFILE.md` 和 `openSpec/README.md`，记录比较脚本、共享映射、升级验证要求和升级命令；验证：未引入第二套流程事实源。

## 4. 规格与自动验证

- [x] 4.1 在 `openSpec/changes/add-workflow-upgrade-path/specs/portable-project-workflow/spec.md` 新增已接入项目升级 Requirement 和场景；验证：只写可观察行为，`openspec validate add-workflow-upgrade-path --strict` 输出 valid。
- [x] 4.2 在 `scripts/verify.sh` 增加比较脚本正反向用例：一致、仅本地修改、仅模板修改、双方修改、收敛、缺失、base 缺失、两方比较、空 base、映射路径为目录、无效参数、项目专属标记、三份基线输出和只读快照；验证：`./scripts/verify.sh` 输出 `ALL_CHECKS_PASSED`。
- [x] 4.3 运行 `bash -n`、`./scripts/verify.sh`、安装回归、`openspec validate add-workflow-upgrade-path --strict`、受影响主规格 strict validation、`openspec context` 和 `openspec doctor`；验证证据：`bash -n` 退出码 0；`verify.sh` 退出码 0 且输出 `ALL_CHECKS_PASSED`；change 和 spec validation 均 valid；`openspec validate --specs` 为 2 passed；`context` 与 `doctor` 退出码 0。审查修复后已重新执行，结果一致。

## 5. 审查、验收与归档

- [x] 5.1 对比较分类正确性、只读性、映射重构回归、文档可执行性和版本一致性执行独立审查；验证证据：独立审查结论为无 Critical、4 项 Important；已修复版本快照前置条件、theirs 版本选择、模板目录只读快照、不可访问目录和非常规文件退出码，并补齐空 base、映射目录、三份基线输出和删除/重命名限制说明；修复后 `verify.sh` 再次输出 `ALL_CHECKS_PASSED`。
- [x] 5.2 用户确认升级 runbook、比较脚本范围和重新基线时机；验证证据：2026-11-12 用户选择“验收并归档”，接受版本快照前置条件、只读比较范围、人工合并和验收后重新基线时机。
- [x] 5.3 用户验收后同步 delta spec、补齐交付记录并归档 change；验证：upgrade Requirement 已同步到 `openSpec/specs/portable-project-workflow/spec.md` 并通过 strict validation，交付记录包含实际文件、命令、兼容、残留风险和无自动提交说明。

## 交付记录

- 影响仓库：本权威项目仓库；不直接写入任何消费项目。
- 实际改动：新增 `scripts/compare.sh`、`scripts/workflow-files.sh`；修改 `scripts/install.sh`、`scripts/verify.sh`、`templates/project-workflow/INSTALL.md`、`templates/project-workflow/WORKFLOW_BASELINE.yaml`、`README.md`、`CHANGELOG.md`、`AGENTS.md`、`PROJECT_PROFILE.md`、`openSpec/README.md` 和 `add-code-review-gate-skill` 的版本引用。
- 提交 / Patch：本轮未提交 Git；工作区改动保持未提交状态，等待用户授权。
- 自动验证命令与结果：`bash -n scripts/install.sh scripts/verify.sh scripts/compare.sh scripts/workflow-files.sh` 退出码 0；`./scripts/verify.sh` 退出码 0，输出 `ALL_CHECKS_PASSED`；`openspec validate add-workflow-upgrade-path --strict`、`openspec validate portable-project-workflow --type spec --strict`、`openspec validate --specs`、`openspec context` 和 `openspec doctor` 全部通过。审查修复后已全部重新执行，结果一致。
- 独立审查：结论无 Critical，4 项 Important 已修复并回归；Minor 中已修正 CHANGELOG 状态枚举、README 笔误、`unchanged` 两方语义、PROFILE 零写入口径、`bash -n` 范围、死映射、备注拼接、base 基线输出、空 base 和映射路径为目录的输入边界，以及删除/重命名限制说明。
- 人工业务 / 交互 / 视觉 / 环境验收：2026-11-12 用户选择“验收并归档”，接受升级 runbook、比较脚本范围和重新基线时机。
- 工作流同步结论：升级能力限定为文档 + 只读比较；消费项目仍需通过自身 change、人工合并、真实验证和用户验收后重新基线。upgrade Requirement 已同步到 `portable-project-workflow` 长期主规格。
- 关联权威项目 change：本项目即权威工作流项目。
- 未覆盖项与残留风险：未在真实消费项目执行一次完整升级；未在真实 Claude Code 会话中执行 `/context all`；自动合并不在范围内；当前 dev.4 尚未提交或打 tag，打 tag 前不能作为消费项目升级目标。
- 后续事项：提交和打 tag 需用户另行授权；`add-code-review-gate-skill` 使用 `0.1.0-dev.5`。
