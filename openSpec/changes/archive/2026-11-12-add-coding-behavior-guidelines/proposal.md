## Why

当前模板已经规定 OpenSpec 事实源、L0～L3 分级、三个门禁、工作区保护和验证证据，但对执行者的**编码行为**缺少显式约束：容易静默假设、为当前任务引入未要求的抽象、顺手修改无关代码，以及用主观判断代替可验证目标。外部轻量行为规范（`multica-ai/andrej-karpathy-skills`，MIT）提供了四个可复用原则，但它是单文件提示包，不能替代本项目的 OpenSpec 治理、门禁和证据体系。

本变更按 **L2 常规模板变化** 处理：只把通用、可迁移的编码行为准则薄层接入现有模板，不引入第二套流程、事实源或安装协议。

需求门禁结论：目标、非目标、影响范围、兼容方式和验收口径已在本文档及 delta spec 中明确；用户于 2026-11-12 回复“落地”，授权进入方案实施。

## What Changes

- 在模板 `AGENTS.template.md` 增加“编码行为准则”，覆盖关键假设、最小实现、手术式改动、孤儿代码边界、改动簇可追溯和可验证目标，并明确风险要求的防御路径不属于过度设计。
- 在模板 `superPowers/implementation_checklist.md` 增加实施阶段检查项，把上述准则变成可勾选、可复核的完成前检查。
- 在模板 OpenSpec 工件职责中补充：design 记录关键假设和更简替代方案，tasks 必须写成可验证目标；不新增 OpenSpec 字段或并行模板。
- 新增模板示例 `examples/coding-behavior-guidelines.md`，用通用伪代码展示四类常见错误和修正方式；示例仅供人工参考，不进入安装映射。
- 更新 `INSTALL.md`、`README.md`、模板 `development-workflow` 主规格、`WORKFLOW_BASELINE.yaml`（`0.1.0-dev.2`）、`scripts/verify.sh` 和 `CHANGELOG.md`。
- 不修改安装文件映射、退出码、占位符范围或安全安装行为；历史消费项目仍需人工比较并合并 AGENTS、检查清单和规格增量。
- 协调关联 change `add-code-review-gate-skill` 的基线版本表述，避免未落地的审查 skill 与本 change 共享同一已交付版本；不实施该 change 的功能。

## Capabilities

### Modified Capabilities

- `development-workflow`: 新增编码行为约束，要求先管理假设、采用最小实现、限制改动范围、维护孤儿代码边界并以可验证目标完成实现。

## Impact

- 预计影响 `templates/project-workflow/AGENTS.template.md`、`templates/project-workflow/superPowers/implementation_checklist.md`、`templates/project-workflow/openSpec/specs/development-workflow/spec.md`、`templates/project-workflow/openSpec/config.template.yaml`、`templates/project-workflow/openSpec/README.md`、`templates/project-workflow/examples/coding-behavior-guidelines.md`、`templates/project-workflow/INSTALL.md`、`templates/project-workflow/WORKFLOW_BASELINE.yaml`、`README.md`、`PROJECT_PROFILE.md`、`scripts/verify.sh`、`CHANGELOG.md`、本项目 `openSpec/config.yaml`、`openSpec/changes/add-code-review-gate-skill/design.md`、`openSpec/changes/add-code-review-gate-skill/tasks.md` 和本 change 工件。
- 安装接口保持增量兼容：不新增或删除安装目标，不改变预览、空目标安装、冲突零写入和退出码；示例文件不自动复制到消费项目。
- 历史消费项目通过人工比较合并新增段落和检查项；本次不宣称旧项目会自动获得编码行为准则。
- 验证覆盖 Markdown/YAML、按版本基线、安装预览、空目标安装、冲突/不安全路径零写入、模板隔离、change strict validation 和长期主规格 strict validation。

## Acceptance

- 模板 `AGENTS.template.md` 能明确约束：先列假设、影响已确认契约或验收口径时先确认、采用最小实现、只做手术式改动、只清理自己的孤儿代码、每个改动簇可追溯到当前 task、以可验证目标完成实现。
- 实施检查清单包含与上述约束对应的可勾选项，且不替代 OpenSpec tasks 或验证证据。
- design/tasks 指引能表达关键假设、更简替代方案和可验证成功标准，不新增第二事实源。
- 示例文档只作为参考存在，不进入安装映射；通用核心不包含技术栈或业务专名。
- 安装预览、空目标安装、冲突零写入和不安全父路径行为与变更前一致；基线、验证脚本、README、INSTALL 和 CHANGELOG 的版本信息一致。
