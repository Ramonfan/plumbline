# Changelog

本文件记录 Plumbline（准绳）项目工作流模板的结构、安装接口和行为契约变化。具体需求、设计、任务和验证证据以 OpenSpec change 为准。

## 版本记录约定

每个进入可接入状态的版本必须提供可追溯快照，并在本文件对应版本下写明 Upgrade 信息：

- 新增、修改、删除的模板文件和安装映射；
- 占位符或必填配置字段变化；
- 安装、比较和验证行为变化，包括退出码；
- 是否需要消费项目创建 OpenSpec change、人工合并或迁移；
- 是否破坏兼容，以及回滚依据。

`dev.N` 表示未发布开发基线。消费项目必须记录精确基线，不自动跟随最新版本；升级流程见 `templates/project-workflow/INSTALL.md` 的“升级已接入项目”。

## Unreleased

### Added

- 建立独立、自维护的 Plumbline（准绳）项目结构。
- 增加通用项目工作流模板及 iOS 项目配置示例。
- 增加 OpenSpec `spec-driven` 配置、研发流程主规格和周报模板。
- 增加安全安装脚本：支持预览、无冲突安装和冲突零写入。
- 增加一键验证脚本，覆盖模板结构、格式、隔离边界、安装行为和 OpenSpec 校验。
- 增加消费项目流程改进回流机制：权威来源字段、双 change 关联、专属规则隔离和交付同步结论。
- 增加机器可读的 `WORKFLOW_BASELINE.yaml`，初始预发布基线为 `0.1.0-dev.1`。
- 当前未发布集成基线推进到 `0.1.0-dev.2`（编码行为准则）、`0.1.0-dev.3`（跨 agent 入口）、`0.1.0-dev.4`（升级路径）和 `0.1.0-dev.5`（代码审查门禁 skill）。
- 模板新增 `CLAUDE.template.md`，安装为根目录 `CLAUDE.md`；Claude Code 通过 `@AGENTS.md` 和 `@PROJECT_PROFILE.md` 导入同一规则源，不复制规则。
- 安装器和验证器同步新增 `CLAUDE.md` 映射、必需文件、安装树、重复安装冲突、导入检查和模板入口反复制检查。
- 验证器加强跨 agent 入口守卫：导入必须位于列 0 且每项恰好一次（跳过代码围栏和缩进），根 `CLAUDE.md` 与模板逐字节一致，模板入口与 `AGENTS.template.md` 的标题和正文行不得重合，新增仅有 `CLAUDE.md` 的冲突用例，并在 Markdown、占位符和泄漏扫描中包含隐藏目录（不进入 `.git`）。
- 重写根 `README.md`，补充项目定位、支持的 agent、快速开始、安装与合并、日常流程、验证和常见问题。
- 根 `AGENTS.md`、`PROJECT_PROFILE.md`、`openSpec/config.yaml` 和 `openSpec/README.md` 改为 agent-neutral，说明 Codex 与 Claude Code 的入口关系。
- 模板 `AGENTS.template.md` 增加编码行为准则：先列关键假设、采用最小实现、只做手术式改动、只清理自己的孤儿代码、保持改动簇可追溯，并以可验证目标完成实现。
- 模板实施清单增加编码行为与范围控制检查项，明确安全、权限、异步和迁移等风险要求的防御路径不属于过度设计。
- 模板 OpenSpec 工件职责补充关键假设、更简替代方案和可验证任务目标指引，不新增并行事实源。
- 新增非安装型示例 `examples/coding-behavior-guidelines.md`，提供隐藏假设、过度抽象、顺手重构和模糊目标的通用反例。
- 安装器新增目标父路径预检；符号链接和非目录父路径以状态 `73` 在写入前拒绝。
- 验证器改用 `${TMPDIR:-/tmp}`，并新增部分冲突、完整冲突清单、重复安装和符号链接零写入检查。
- 验证器新增 `bash`、`find`、`rg`、`ruby`、OpenSpec CLI 和 `sort`、`cksum`、`cmp`、`readlink`、`ln`、`mktemp` 等常用 POSIX 工具的前置依赖检测；缺少任一命令时以状态 `69` 退出且不创建临时目录。
- 新增只读比较脚本 `scripts/compare.sh --target <dir> [--base <dir>]`：逐文件输出 `unchanged`、`ours-only`、`theirs-only`、`both-changed`、`converged`、`missing`、`base-missing` 或 `differs`；项目专属文件标记 `manual: project-specific`，基线文件标记 `metadata: update after merge`。
- 抽取 `scripts/workflow-files.sh`，由 `install.sh`、`verify.sh` 和 `compare.sh` 共享安装映射，避免新增文件时多处漂移。
- 模板 `INSTALL.md` 新增“升级已接入项目”runbook：旧基线确认、消费项目 change、三方输入、分类处理、真实项目验证、重新基线、验收和回滚。
- 根 `README.md` 新增升级入口、比较状态说明和升级常见问题。
- 验证器新增比较脚本正反向用例：一致、仅本地修改、仅模板修改、双方修改、收敛、缺失、base 缺失、两方比较、无效参数和只读快照检查。
- 模板新增 `running-code-review-gate` 代码审查门禁 skill：`.agents/skills/` 为规范源，`.claude/skills/` 为内容一致的 Claude Code 镜像（不含 `agents/openai.yaml`）。
- skill 定义事实源定位、逐仓精确范围、项目规则加载、本地/独立审查路由、Critical/Important/Minor findings、`Ready: Yes/No` verdict 和只读边界；独立 reviewer 使用最小 brief，不继承编排会话。
- 安装映射新增两棵 skill 目录；安装器支持递归目录复制、目录预检和冲突零写入，验证器新增 skill frontmatter、名称、引用可达性、占位残留、双入口内容一致、安装树、skill 目录冲突和符号链接父路径检查。
- `compare.sh` 新增 `local-extra` 分类，报告目标 skill 目录中模板不存在的本地扩展文件；`install.sh`、`compare.sh` 和 `verify.sh` 共用精确 skill 文件集校验，防止必需文件缺失或镜像混入 Codex 专属文件。
- 模板 `AGENTS.template.md`、`PROJECT_PROFILE.template.md`、`development-workflow` 主规格和实施检查清单接入审查门禁与项目专属检查点；`INSTALL.md` 和 `README.md` 补充 skill 安装、升级和验证说明。

### Changed

- 项目正式名称从「AI 工作流」改为 **Plumbline（准绳）**；`WORKFLOW_BASELINE.yaml` 的 `authority_name` 同步改为 `Plumbline`。
- 根 `AGENTS.md`、`PROJECT_PROFILE.md`、`README.md`、`openSpec/config.yaml`、`openSpec/README.md` 和模板 `INSTALL.md` 已统一使用新名称。
- 本次改名本身不改变安装映射、占位符范围、安装或比较退出码、比较分类语义和升级流程，当时未单独推进 `workflow_version`（后续变更已推进到 `0.1.0-dev.5`）。消费项目持有改名前进度快照时，`WORKFLOW_BASELINE.yaml` 会因 `authority_name` 变化出现一次预期的 `theirs-only`，合并后消失。
- 历史归档 change 保留原名和原内容；工作目录已重命名为 `plumbline`，建议仓库标识为 `plumbline`。
- 工作区目录从 `AI工作流` 重命名为 `plumbline`；Git 未提交改动随目录移动保留，不改变模板内容、安装映射、占位符或脚本契约。

### Compatibility

- 初始未发布版本，没有破坏性的安装接口需要迁移；已有项目仍需人工合并内容增量。
- 项目已初始化 Git 并完成初始提交；本轮不自动创建提交、推送或发布。
- 回流机制不自动覆盖消费项目或权威项目文件，已安装项目需人工比较并合并增量。
- 编码行为准则属于增量内容，不改变安装映射、退出码或占位符范围；历史消费项目需人工比较并合并 `AGENTS.md`、实施清单和主规格增量。
- `examples/coding-behavior-guidelines.md` 仅供人工参考，不进入安装映射，也不会自动出现在已安装项目。
- 当前预发布基线为 `0.1.0-dev.5`；历史项目仍必须先确认来源和实际文件差异，不能把新基线冒充历史版本。
- 审查 skill 属于新增文件和目录映射，不删除或重命名现有模板文件、占位符或安装参数；目标项目已有 `.agents/skills/running-code-review-gate` 或 `.claude/skills/running-code-review-gate` 时安装以状态 `2` 零写入停止，需要人工比较合并。
- 历史消费项目不会自动获得 skill、门禁规则或 `PROJECT_PROFILE.md` 的审查字段；必须通过关联 change 人工合并 `.agents/skills/`、`.claude/skills/`、根规则、主规格和实施清单。
- 审查 skill 是 agent 工作流门禁，不是 Git hook、CI required check 或平台审批；它能输出阻断结论，但不能物理阻止人工提交。
- 新增 `CLAUDE.md` 安装映射属于增量变化；目标项目已有同名文件时安装以状态 `2` 零写入停止，需人工比较合并。
- `CLAUDE.md` 只做导入适配，不复制 `AGENTS.md` 规则；历史项目不会自动获得该入口，也不会自动获得 Claude 专属技能目录。
- 新增基线文件不会自动补入历史消费项目；历史基线未知时必须先人工确认来源，不能把最新版本冒充历史版本。
- 使用符号链接承载计划安装父目录的项目将被安全安装器拒绝，需要人工审查并合并文件。
- 写入前预检不等于事务式复制；磁盘、权限或读取错误发生在复制阶段时，目标可能保留部分新增文件，需要人工核对。
- `compare.sh` 和 `workflow-files.sh` 是权威项目工具，不进入安装映射；升级能力不改变目标项目文件清单、占位符范围或安装退出码。
- 升级不提供自动覆盖或自动合并。消费项目必须自行创建 OpenSpec change，取得旧基线快照，人工处理 `AGENTS.md`、`CLAUDE.md`、`PROJECT_PROFILE.md` 和 `openSpec/config.yaml`，并在真实验证和用户验收后更新基线。
- 比较脚本发现差异时返回 `0`，因为差异是正常结果；参数错误返回 `64`，目标、base 或映射路径不是可读普通文件返回 `66`，模板源缺失返回 `70`。没有旧基线快照时只能做两方比较，必须人工审查。
- 升级前必须让权威项目处于目标版本且模板目录无未提交改动；每个可接入版本必须有 tag、提交或归档快照。`0.1.0-dev.5` 已打预发布标签 `v0.1.0-dev.5`，消费项目可将其作为可追溯快照，但仍必须人工比较合并并自行验证，不得视为自动升级。
- 项目改名属于权威来源元数据变化。消费项目需要人工把 `PROJECT_PROFILE.md` 记录的权威名称从「AI 工作流」更新为 `Plumbline`；比较脚本不读取该字段做逻辑判断，升级流程和退出码不变。历史归档不回写新名称。
