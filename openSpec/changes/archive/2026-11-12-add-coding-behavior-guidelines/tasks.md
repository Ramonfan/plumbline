## 0. 方案门禁

- [x] 0.1 用户确认把四项编码行为原则薄层接入模板，并明确允许落地；验证方式：2026-11-12 用户回复“我觉得你的建议可以，落地”，视为方案门禁授权。

## 1. 模板核心

- [x] 1.1 `templates/project-workflow/AGENTS.template.md` 中存在可执行的“编码行为准则”，覆盖关键假设、最小实现、手术式改动、孤儿代码边界、改动簇可追溯、可验证目标和风险防御例外；验证证据：`grep -n '编码行为准则' templates/project-workflow/AGENTS.template.md` 命中第 77 行，条款包含生成物/锁文件/工具强制格式变更的追溯例外，未把最小实现解释为删除必要流程。
- [x] 1.2 `templates/project-workflow/superPowers/implementation_checklist.md` 中存在“编码行为与范围控制”检查项，且与原测试检查项不重复；验证证据：第 17 行起共 7 项，覆盖假设、过度设计、顺手修改、孤儿代码、改动簇追溯、可验证目标和风险防御例外；原“没有顺手扩大需求或重构无关代码”已收敛为“没有扩大需求”。
- [x] 1.3 AGENTS 的 OpenSpec 工件职责、模板 `openSpec/config.template.yaml`、模板 `openSpec/README.md` 和本项目根 `openSpec/config.yaml` 已同步关键假设、更简替代方案和可验证任务目标指引；验证证据：四处均出现对应表述，未新增 OpenSpec 字段、frontmatter 或并行事实源。
- [x] 1.4 `templates/project-workflow/examples/coding-behavior-guidelines.md` 存在，用通用伪代码展示隐藏假设、过度抽象、顺手重构和模糊目标；验证证据：文件存在且 Markdown 围栏成对；`scripts/install.sh` 的 `sources`/`destinations` 未包含该示例，安装预览仍只列出原有文件。

## 2. 公开文档、基线与变更记录

- [x] 2.1 `templates/project-workflow/INSTALL.md` 和根 `README.md` 能说明编码行为准则、示例的非安装属性和历史项目人工合并方式；验证证据：INSTALL 映射表新增示例行并注明“不直接复制”，合并指引加入编码行为准则；README 核心能力加入编码行为准则，并声明验证依赖 `bash`、`find`、`rg`、`ruby` 和 OpenSpec CLI。
- [x] 2.2 `templates/project-workflow/WORKFLOW_BASELINE.yaml` 的 `workflow_version` 为 `0.1.0-dev.2`，`scripts/verify.sh` 的基线校验同步；验证证据：Ruby YAML 解析输出 `YAML_OK`，`grep` 确认基线版本为 `0.1.0-dev.2`；默认入口 `./scripts/verify.sh` 的 dry-run、空目标安装、冲突零写入和安装树检查在 3.2 的同一验证轮次中通过，安装映射未变化；design/CHANGELOG 明确 dev.2 是未发布集成基线，当前内容清单只含本 change。
- [x] 2.3 `CHANGELOG.md` 的 `Unreleased` 记录编码行为准则、实施清单、工件指引、非安装示例、基线变化和兼容边界；验证证据：Added 与 Compatibility 均包含对应条目，明确历史项目需人工合并、示例不自动安装、dev.2 为未发布集成基线，未把未实施的审查 skill 变化混入本 change 描述。

## 3. 规格与自动验证

- [x] 3.1 模板 `openSpec/specs/development-workflow/spec.md` 与 delta spec 中包含可验证的编码行为 Requirement 和场景；验证证据：delta `openspec validate add-coding-behavior-guidelines --strict` 输出 valid；用 `awk` 提取两份文件的同一 Requirement 块并 `diff -B -u`，输出 `REQUIREMENT_BLOCK_MATCH`。
- [x] 3.2 `bash -n`、统一校验和安装矩阵可复现；验证证据：已安装 `ripgrep 15.2.0`，`rg --version` 正常；`bash -n scripts/install.sh scripts/verify.sh` 退出码 0；`./scripts/verify.sh` 输出 `ALL_CHECKS_PASSED`、退出码 0，覆盖 dry-run、空目标安装、部分/完整冲突、重复安装、符号链接/非目录父路径、基线、占位符和泄漏检查。安装依赖前曾用临时 `rg` shim 验证同一逻辑，shim 未进入项目；当前默认入口已可直接复现。
- [x] 3.3 OpenSpec 环境和规格校验通过；验证证据：`openspec validate add-coding-behavior-guidelines --strict`、`openspec validate development-workflow --type spec --strict`、`openspec validate portable-project-workflow --type spec --strict` 均为 valid；`openspec validate --specs` 为 2 passed / 0 failed；`openspec context` 识别根目录，`openspec doctor` 报告 OpenSpec root ok。

## 4. 审查、验收与归档

- [x] 4.1 对新增规则、示例、安装兼容、版本一致性和验证覆盖执行独立审查，逐项核验问题；验证证据：共三轮只读审查。首轮无 Critical、4 项 Important、9 项 Minor，Ready: No；修复后第二轮无 Critical、3 项 Important、7 项 Minor，Ready: No；第三轮无 Critical、无 Important、2 项 Minor，Ready: Yes。两轮 Important 涉及 tasks 证据缺失、规则例外、版本占用、模板规格验证声明、确认口径和 MUST/“优先”冲突，均已修复或改写；第三轮剩余两项 Minor（版本交接表述、`command -v` 多参数检查）已修复并复跑验证，无未处理阻断项。
- [x] 4.2 用户确认编码行为准则的范围、措辞、示例边界和历史项目升级方式；验证证据：2026-11-12 在交付摘要和“等待结构验收后同步主规格并归档”的说明后，用户回复“继续”，按上下文视为结构验收通过，确认当前范围、措辞、示例非安装边界和“历史项目人工比较合并、不自动升级”的方式。
- [x] 4.3 用户验收后同步 delta spec、补齐交付记录并归档 change；验证证据：2026-11-12 用户回复“继续”，视为结构验收通过；`openspec archive add-coding-behavior-guidelines --yes` 首次更新主规格后因 `archived delta changed during final move` 失败，已人工将编码行为 Requirement 同步到 `openSpec/specs/development-workflow/spec.md`，再用 `openspec archive add-coding-behavior-guidelines --yes --skip-specs` 归档为 `openSpec/changes/archive/2026-11-12-add-coding-behavior-guidelines`；长期主规格和 `openspec validate --specs` 均通过。

## 交付记录

- 影响仓库：当前工作区不是 Git 仓库；未执行 Git 提交、远程配置或发布。
- 实际改动：新增编码行为准则、实施检查项、OpenSpec 工件指引和非安装型示例；同步模板主规格、模板配置、模板 OpenSpec README、INSTALL、README、PROJECT_PROFILE、基线、验证脚本、CHANGELOG、根 OpenSpec 配置和长期主规格；协调关联审查 skill change 的版本表述；归档本 change 的 proposal、design、delta spec 和 tasks。
- 提交 / Patch：无提交；项目未初始化 Git。
- 自动验证命令与结果：已安装 `ripgrep 15.2.0`；`bash -n scripts/install.sh scripts/verify.sh` 退出码 0；默认入口 `./scripts/verify.sh` 输出 `ALL_CHECKS_PASSED` 且退出码 0；change 和两份长期主规格 strict validation 均 valid；`openspec validate --specs` 为 2 passed / 0 failed；`openspec context` 和 `openspec doctor` 正常；delta 与模板主规格的编码行为 Requirement 块 `diff -B` 输出 `REQUIREMENT_BLOCK_MATCH`。
- 人工业务 / 交互 / 视觉 / 环境验收：2026-11-12 用户回复“继续”，结构验收通过。
- 工作流同步结论：本项目即权威工作流项目，通用增量已落入权威模板、验证、文档、CHANGELOG 和长期主规格；delta spec 已同步，独立审查最终结论为 Ready: Yes。
- 关联权威项目 change：不适用（本项目即权威工作流项目）；已协调 `add-code-review-gate-skill` 的基线版本表述，但不实施该 change 的功能。
- 未覆盖项与残留风险：本机已安装 `ripgrep 15.2.0`；其他环境仍须安装该依赖，否则统一校验按设计以状态 69 退出。`0.1.0-dev.2` 是未发布集成基线，交付或发布前必须重新核对已落地 change 清单。
- 后续事项：本 change 已验收归档并占用 dev.2；`add-code-review-gate-skill` 若在该时点前落地可共用 dev.2，若在该时点后落地则使用 dev.3。
