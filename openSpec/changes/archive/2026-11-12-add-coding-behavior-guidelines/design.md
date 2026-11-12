## Context

见 `proposal.md`。当前模板已经具备项目治理闭环，但执行约束主要围绕“流程是否正确”和“是否保护工作区”，对“模型是否在编码时静默假设、过度设计、顺手修改”缺少显式、可检查的规则。外部 `multica-ai/andrej-karpathy-skills` 用四条原则和示例补上了这一层，但它是单文件提示包，没有 OpenSpec 事实源、门禁、验证证据和安装升级协议。

本变更只吸收其通用行为原则，不复制其安装方式，也不把 `CLAUDE.md` 作为第二套项目规则。

## Goals / Non-Goals

**Goals:**

- 在不增加流程层级的前提下，为模板补充可执行的编码行为约束。
- 把“先列假设、最小实现、手术式改动、可验证目标”落到 AGENTS、实施清单和 OpenSpec 工件指引。
- 提供一份非安装型示例，帮助使用者理解错误模式和修正方式。
- 保持安装接口、冲突零写入和现有验证矩阵不变。

**Non-Goals:**

- 不引入新的技能、插件、Git hook、CI 检查或自动修复流程。
- 不复制外部仓库的 `CLAUDE.md`、Cursor 规则或 Claude Code 插件清单。
- 不把具体技术栈、业务模块、类名或产品规则写入通用核心。
- 不新增 OpenSpec schema 字段，不创建与 proposal/specs/design/tasks 并行的记录文件。
- 不把“最小实现”解释为删除必要的规格、门禁、审查或风险防御。

## Decisions

### 1. 只改模板核心，不新增流程层

在 `AGENTS.template.md` 新增独立的“编码行为准则”小节，位置放在工作区保护之后、实施原则之前。规则使用 MUST/不得等执行语言，但保持简短，不复制外部文档全文，也不重复 OpenSpec、Superpowers 或实施清单的既有职责。

替代方案是新增一个独立 skill 或 `CLAUDE.md` 副本，但这会引入第二套规则入口和额外安装映射，不符合本次“薄层增强”的目标。

### 2. 用实施清单把原则变成可勾选检查

在 `superPowers/implementation_checklist.md` 增加“编码行为与范围控制”小节，覆盖假设、过度设计、顺手修改、孤儿代码、改动簇追溯、可验证目标和风险防御例外。检查项只服务实施阶段，验证证据仍回写 OpenSpec tasks，不形成第二事实源。

### 3. OpenSpec 工件只增加指引，不增加字段

在模板 AGENTS 的“OpenSpec 工件职责”中补充：design 记录关键假设和更简替代方案；tasks 必须写成可验证目标。仍然使用现有 proposal/specs/design/tasks，不新增模板文件、frontmatter 或并行状态。

### 4. 示例作为非安装型参考

新增 `templates/project-workflow/examples/coding-behavior-guidelines.md`，用通用伪代码展示隐藏假设、过度抽象、顺手重构和模糊目标四类问题。示例不加入 `scripts/install.sh` 映射，也不进入安装树；`INSTALL.md` 明确它仅供人工参考。这样既能让使用者获得具体反例，又不扩大安装面和冲突概率。

### 5. 版本与兼容处理

本变更修改模板核心行为，按 `portable-project-workflow` 的版本说明要求把 `WORKFLOW_BASELINE.yaml` 从 `0.1.0-dev.1` 推进到 `0.1.0-dev.2`，并同步 `scripts/verify.sh` 的硬编码基线校验。`0.1.0-dev.2` 是当前**未发布的集成基线**，当前内容清单只包含本 change 的编码行为准则增量；`add-code-review-gate-skill` 尚未实施，不计入 dev.2 已交付内容。本 change 通过用户验收并归档后即视为占用 dev.2；若该 change 在该时点前落地，两个 change 可以共同构成 dev.2，若在该时点后落地则使用 dev.3。交付或正式发布前必须重新确认 dev.2 对应的已落地 change 清单，不能把未实现内容冒充为 dev.2 已有能力。

安装映射、目标路径、占位符范围和退出码均不变。历史消费项目需要人工比较并合并 AGENTS、实施清单和主规格增量；新增示例不会被自动复制。

## Risks / Trade-offs

- [编码行为准则可能与既有“按风险防御”规则冲突] → 明确安全、权限、异步、迁移等风险要求的失败、取消、幂等和释放路径不属于过度设计。
- [规则过多会变成新的流程负担] → 只保留四类高频失败模式，AGENTS 保持短节，详细信息放实施清单和示例。
- [示例包含技术栈内容可能污染通用核心] → 示例使用通用伪代码，且不进入安装映射；通用核心泄漏检查仍只针对核心文件。
- [与活跃审查 skill change 的基线版本重叠] → 把 dev.2 明确为未发布集成基线；交付或发布前重新核对已落地 change 清单，未落地 change 使用后续版本。
- [历史项目不会自动获得新规则] → README、INSTALL 和 CHANGELOG 明确人工合并要求，不宣称自动升级。

## Migration Plan

1. 更新模板 AGENTS、实施清单、OpenSpec 工件指引和示例。
2. 更新模板 `development-workflow` 主规格、INSTALL、README、基线、验证脚本和 CHANGELOG。
3. 运行 Markdown/YAML 检查、基线校验、安装预览、空目标安装、冲突/不安全路径零写入、重复安装、change strict validation 和长期主规格 strict validation。
4. 由用户完成结构验收后，把 delta spec 同步到本项目长期主规格并归档。

回滚时恢复 AGENTS、实施清单、工件指引、示例、INSTALL、README、基线、验证脚本和 CHANGELOG，并移除本次 delta spec；不删除消费项目已经人工合并的段落。
