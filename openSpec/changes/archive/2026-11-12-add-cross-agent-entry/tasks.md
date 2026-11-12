## 0. 方案门禁

- [x] 0.1 用户确认跨 agent 入口采用“单一事实源 + CLAUDE.md 薄适配”，并确认 Codex 继续通过 AGENTS.md 使用；验证证据：2026-11-12 用户要求“按照CLAUDE适配，codex是否可以用”，并确认 Codex 继续读取 `AGENTS.md`；按该指令进入实施。

## 1. 入口文件

- [x] 1.1 新增 `templates/project-workflow/CLAUDE.template.md`，只包含事实源说明、`@AGENTS.md` 和 `@PROJECT_PROFILE.md` 导入；验证证据：文件不含 `{{...}}` 占位符；`verify.sh` 检查模板入口与 `AGENTS.template.md` 的二级/三级标题无交集，且文件不超过 60 行。
- [x] 1.2 新增根目录 `CLAUDE.md`，内容与模板入口一致，供 Claude Code 使用本项目；验证证据：`verify.sh` 用 `cmp` 要求根入口与模板入口完全一致；`rg -n '^@AGENTS.md$|^@PROJECT_PROFILE.md$' CLAUDE.md` 命中第 5、6 行。

## 2. 安装与验证

- [x] 2.1 更新 `scripts/install.sh`，增加 `CLAUDE.template.md` → `CLAUDE.md` 映射；验证证据：dry-run 输出包含 `- CLAUDE.md`；空目标安装后 `test -f "$tmp_dir/CLAUDE.md"` 命中，`cmp` 输出 `INSTALLED_CONTENT_MATCH`。
- [x] 2.2 更新 `scripts/verify.sh`，增加根项目和模板必需文件、安装树、重复安装冲突、`CLAUDE.md` 导入检查和模板入口反复制检查；验证证据：`./scripts/verify.sh` 输出 `ALL_CHECKS_PASSED`、退出码 0；导入检查要求列 0 且每项恰好一次，跳过 ``` 与 ~~~ 围栏和缩进代码，反向文本、重复导入、围栏内导入都会失败；根 `CLAUDE.md` 与模板入口用 `cmp` 要求完全一致；反复制检查使用模板与 `AGENTS.template.md` 的标题交集、正文行交集和 60 行上限；部分冲突、仅有 `CLAUDE.md` 的冲突和重复安装均覆盖且零写入。Markdown 围栏、占位符和泄漏扫描覆盖隐藏目录并排除 `.git`；隐藏的未闭合围栏、隐藏文件中的泄漏内容会被发现，正常的 `.git` 内容和隐藏文件不会误报。反向测试：`不要导入 @AGENTS.md`、重复导入、重复标题、正文行复制、`~~~` 围栏内导入、4 空格缩进导入、61 行入口分别返回 1。
- [x] 2.3 将 `templates/project-workflow/WORKFLOW_BASELINE.yaml` 升级到 `0.1.0-dev.3`，同步 `scripts/verify.sh` 基线校验；验证证据：Ruby YAML 解析输出 `YAML_OK`，基线字段为 `0.1.0-dev.3`，`verify.sh` 硬编码校验同步。

## 3. 文档与治理

- [x] 3.1 更新 `templates/project-workflow/INSTALL.md`，补充 `CLAUDE.md` 映射、安装树、已有项目合并和 agent 入口说明；验证证据：文件映射表新增 `CLAUDE.template.md`，安装前检查包含 `CLAUDE.md`，新项目树、文件清单和合并指引均已同步，未宣称自动覆盖。
- [x] 3.2 更新模板 `PROJECT_PROFILE.template.md`、模板 `openSpec/README.md` 和模板 `openSpec/config.template.yaml`，说明两个入口共享同一事实源；验证证据：三处均出现 `AGENTS.md`/`CLAUDE.md` 入口说明，未新增占位符范围，代理配置仍只读取现有事实源。
- [x] 3.3 更新根 `AGENTS.md`、`PROJECT_PROFILE.md`、`openSpec/config.yaml` 和 `openSpec/README.md`，改为 agent-neutral 并记录当前 Git 状态；验证证据：根规则不再限定 Codex 专用，`PROJECT_PROFILE.md` 记录 `main` 分支和初始提交，OpenSpec 配置与 README 增加 agent 入口说明。
- [x] 3.4 重写根 `README.md`，覆盖定位、支持的 agent、核心概念、快速开始、安装与合并、日常流程、验证、FAQ 和当前状态；验证证据：`./scripts/verify.sh` 的 Markdown 围栏检查通过；README 中的安装计划、退出码、依赖和 OpenSpec 命令与脚本一致。
- [x] 3.5 更新 `CHANGELOG.md` 的 `Unreleased`，记录 `CLAUDE.md` 入口、安装兼容、dev.3 基线和历史项目人工合并要求；验证证据：Added 与 Compatibility 均包含对应条目，未把审查技能实现混入本 change。
- [x] 3.6 更新 `openSpec/changes/add-code-review-gate-skill/proposal.md`、`design.md` 和 `tasks.md`，把基线改为 `0.1.0-dev.4`，并补充 `.agents/skills/` 与 `.claude/skills/` 双入口计划；验证证据：该 change 的 proposal/design/tasks 已同步，`openspec validate add-code-review-gate-skill --strict` 输出 valid；本 change 未实施该 skill。

## 4. 规格与自动验证

- [x] 4.1 在 `openSpec/changes/add-cross-agent-entry/specs/portable-project-workflow/spec.md` 新增跨 agent 入口 Requirement 和场景；验证证据：`openspec validate add-cross-agent-entry --strict` 输出 valid。
- [x] 4.2 运行 `bash -n scripts/install.sh scripts/verify.sh`、`./scripts/verify.sh`、安装预览、空目标安装、部分/完整冲突、仅有 `CLAUDE.md` 的冲突、重复安装和不安全父路径场景；验证证据：`bash -n` 退出码 0；`./scripts/verify.sh` 输出 `ALL_CHECKS_PASSED`、退出码 0；dry-run 退出码 0 且目标零写入；空目标安装退出码 0；部分冲突、仅有 `CLAUDE.md` 的冲突、重复安装和不安全路径均由 `verify.sh` 覆盖并通过且零写入。
- [x] 4.3 运行 `openspec validate add-cross-agent-entry --strict`、受影响长期主规格 strict validation 和 `openspec context`/`openspec doctor`；验证证据：change 和 `portable-project-workflow` 均 valid；`openspec validate --specs` 为 2 passed / 0 failed；`openspec context` 和 `openspec doctor` 退出码均为 0。

## 5. 审查、验收与归档

- [x] 5.1 对入口单一事实源、安装兼容、版本一致性、README 准确性和验证覆盖执行独立审查；验证证据：共三轮只读独立审查。首轮 Ready: No，I1 导入/反复制漏报、I2 Claude Code 子目录规则未说明、I3 事实源措辞不一致；修复后第二轮 Ready: No，剩余 design 旧措辞 I3；再次修复并加强守卫后第三轮 Ready: Yes，无 Critical/Important。三轮提出的 Important/Minor 均已修复，包括列 0 唯一导入、`cmp` 根/模板一致、标题与正文行重合检查、仅有 `CLAUDE.md` 冲突、隐藏目录扫描并排除 `.git`、退出码拆分、依赖清单对齐和文档措辞统一。
- [x] 5.2 用户确认 README 结构、CLAUDE.md 薄适配边界和历史项目合并方式；验证证据：2026-11-12 用户选择“验收并归档”，确认通过 README、CLAUDE.md 薄适配、安装与验证行为，并要求同步主规格后归档。
- [x] 5.3 用户验收后同步 delta spec、补齐交付记录并归档 change；验证证据：2026-11-12 将跨 agent 入口 Requirement 同步到 `openSpec/specs/portable-project-workflow/spec.md`，`openspec validate portable-project-workflow --type spec --strict` 输出 valid；使用 `openspec archive add-cross-agent-entry --yes --skip-specs` 归档为 `openSpec/changes/archive/2026-11-12-add-cross-agent-entry/`；交付记录包含实际文件、验证命令、兼容、残留风险和无自动提交说明。

## 交付记录

- 影响仓库：当前工作区为 Git 仓库，分支 `main`；本轮未创建提交、未配置远程仓库、未推送或发布。
- 实际改动：新增模板 `CLAUDE.template.md` 和根 `CLAUDE.md`；更新安装器、验证器、基线、模板 INSTALL、模板项目配置、模板 OpenSpec README/config、iOS 示例配置、根 AGENTS、PROJECT_PROFILE、README、OpenSpec README/config、CHANGELOG；协调 `add-code-review-gate-skill` 的 proposal/design/tasks，落实 dev.4 基线和双技能入口计划；新增本 change 的 proposal、design、delta spec 和 tasks。
- 提交 / Patch：无提交；工作区保留未提交改动。
- 自动验证命令与结果：`bash -n scripts/install.sh scripts/verify.sh` 退出码 0；`./scripts/verify.sh` 输出 `ALL_CHECKS_PASSED`、退出码 0；`openspec validate add-cross-agent-entry --strict` 和 `openspec validate add-code-review-gate-skill --strict` 均 valid；`openspec validate portable-project-workflow --type spec --strict` 和 `development-workflow` valid；`openspec validate --specs` 为 2 passed / 0 failed；`openspec context`、`openspec doctor` 退出码 0；入口守卫负向测试覆盖反向文本、重复导入、```/~~~ 围栏、缩进导入、标题/正文复制、61 行入口、隐藏目录未闭合围栏和隐藏泄漏文件；`.git` 内容被排除；空目标安装内容与模板一致。
- 人工业务 / 交互 / 视觉 / 环境验收：2026-11-12 用户确认选择“验收并归档”，通过 README、CLAUDE.md 薄适配、安装与验证行为；本环境未实际启动 Claude Code 执行 `/context all`。
- 工作流同步结论：本项目即权威工作流项目，模板、安装、验证、文档和 delta spec 已落地；跨 agent 入口 Requirement 已同步到 `openSpec/specs/portable-project-workflow/spec.md`。
- 关联权威项目 change：不适用（本项目即权威工作流项目）；已协调 `add-code-review-gate-skill` 的版本和技能入口计划。
- 未覆盖项与残留风险：未在真实 Claude Code 会话中验证 `/context all` 和子目录/版本差异；未验证其他 agent 的入口；`.agents/skills/` 与 `.claude/skills/` 双入口尚未实现，由 `add-code-review-gate-skill` 承担；历史项目不会自动获得 `CLAUDE.md`；反复制检查是启发式，仍不能完全替代审查。
- 后续事项：归档位置为 `openSpec/changes/archive/2026-11-12-add-cross-agent-entry/`；`add-code-review-gate-skill` 实施时使用 `0.1.0-dev.4`。
