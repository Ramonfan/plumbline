## 0. 方案门禁

- [x] 0.1 用户确认 proposal、delta spec、design、兼容矩阵、任务拆分和验证方式，并明确允许修改模板与脚本；验证方式：2026-09-18 用户回复“落地”，视为方案门禁授权。

## 1. 工作流基线

- [x] 1.1 新增 `templates/project-workflow/WORKFLOW_BASELINE.yaml`，包含 `schema_version: 1`、`workflow_version: 0.1.0-dev.1` 和 `authority_name: AI 工作流`，并把它加入安装源、目标映射与模板必需文件清单；验证证据：先扩展 `verify.sh` 后运行失败（退出码 1，缺少基线文件），新增文件与安装映射后 `./scripts/verify.sh` 退出码 0，输出 `ALL_CHECKS_PASSED`，并通过 YAML 字段和安装文件一致性检查。
- [x] 1.2 更新 `templates/project-workflow/INSTALL.md`、`templates/project-workflow/PROJECT_PROFILE.template.md` 和根 `README.md`，说明基线读取、历史项目未知基线处理及人工升级比较；同步检查结论：`AGENTS.template.md`、OpenSpec 配置模板和实施清单不涉及版本文件或安装路径实现，无需修改。验证证据：`./scripts/verify.sh` 退出码 0，文件映射、YAML 和占位符范围检查通过。

## 2. 安装路径安全与零写入

- [x] 2.1 先在 `scripts/verify.sh` 增加部分冲突空目标、冲突清单、退出码、完整树零变化和符号链接父路径零写入检查，并记录当前 `scripts/install.sh` 未满足新增场景的预期失败；验证证据：修改测试后 `./scripts/verify.sh` 退出码 1，输出 `Symlink parent installation returned 0 instead of 73.`，证明测试命中真实缺口。
- [x] 2.2 修改 `scripts/install.sh`，在任何 `mkdir` 或 `cp` 前完成全部计划文件和目录的路径安全预检，符号链接或非目录父路径均以状态 `73` 退出，同时保持普通目录、dry-run 和冲突状态 `2` 的既有接口；验证证据：顶层符号链接测试先失败为状态 0，非目录父路径测试先失败为状态 1，审查新增的 `openSpec/changes` 嵌套符号链接测试再次先失败为状态 0；统一建模八个文件和 archive 目录后，四个嵌套符号链接/普通文件场景、`bash -n` 与完整校验均通过且目标外部树不变。
- [x] 2.3 强化重复安装验证，断言所有安装目标均被报告为冲突、退出状态为 `2` 且完整目录树未变化；验证证据：统一校验逐项检查八个目标路径、状态 `2` 和完整树快照，最终输出 `ALL_CHECKS_PASSED`。

## 3. 可移植临时目录

- [x] 3.1 将 `scripts/verify.sh` 的临时目录入口改为规范化后的 `${TMPDIR:-/tmp}`，校验目录可写并限制清理范围；验证证据：修改前契约检查退出码 1 并输出 `TEMP_DIR_CONTRACT_FAIL`；修改后 `bash -n` 退出码 0，源码不含 `/private/tmp` 且包含 `${TMPDIR:-/tmp}`。
- [x] 3.2 分别在未设置 `TMPDIR` 和设置为新建可写目录时运行完整校验，确认输出 `ALL_CHECKS_PASSED` 且没有遗留 `ai-workflow-verify.*` 目录；验证证据：`env -u TMPDIR ./scripts/verify.sh` 与 `TMPDIR=<临时目录> ./scripts/verify.sh` 均退出码 0、输出 `ALL_CHECKS_PASSED`，前后目录快照和自定义目录清理检查输出 `TEMP_DIR_CHECKS_PASSED`；不存在或不可搜索的 `TMPDIR` 均返回状态 73 和明确错误。

## 4. 项目契约与变更记录

- [x] 4.1 更新根 `PROJECT_PROFILE.md` 的验收矩阵和必要依赖说明，更新 `CHANGELOG.md` 的 `Unreleased`，记录新增基线文件、路径安全收紧、临时目录兼容和历史消费项目迁移方式；验证证据：README、PROJECT_PROFILE、INSTALL 和 CHANGELOG 明确状态 `2`/`73`、`${TMPDIR:-/tmp}`、人工升级及“预检零写入但复制阶段非事务”的边界，未宣称自动升级或事务式安装。
- [x] 4.2 对照模板同步清单检查 `AGENTS.template.md`、`PROJECT_PROFILE.template.md`、OpenSpec 配置、长期主规格、README、安装文档和实施清单；同步结论：`PROJECT_PROFILE.template.md`、根 README、安装文档已修改；`AGENTS.template.md`、OpenSpec 配置模板和实施清单无需修改；长期主规格按交付门禁保留 delta，待用户验收后同步。验证证据：所有入口已有明确结论，`./scripts/verify.sh` 和 change strict validation 均通过。
- [x] 4.3 使用 Archify workflow schema v2 生成双泳道工作流图，覆盖 L0/L1–L3 分流、三个门禁、OpenSpec 工件、实施验证、验收归档和消费项目回流；验证证据：`ai-workflow-v2.json` showcase validation 为 9/9、0 composition errors、0 warnings；`ai-workflow.html` delivery 成功，规格 SHA-256 为 `abfbb02e47ea782141b0a92ffc655742a48b81071b5bd9b5427bfbcb371a498a`，HTML SHA-256 为 `dc451d558ac50516e3642f2fc580daa9776db9d8f996db2aaa5990f1ec102366`；visual-check 在 1440×900、1600×1000、1920×1080 和 2048×1320 全部无溢出，明暗主题截图视觉审阅通过，修正轮次为 2。

## 5. 自动验证与交付证据

- [x] 5.1 运行 `./scripts/verify.sh`、`openspec validate harden-portable-installation-baseline --strict`、两份长期主规格 strict validation、`openspec context` 和 `openspec doctor`；验证证据：默认与自定义 `TMPDIR` 两轮 `verify.sh` 均退出码 0 并输出 `ALL_CHECKS_PASSED`；无效 `TMPDIR` 返回 73；change 与 `development-workflow`、`portable-project-workflow` strict validation 均 valid；context 正确识别根目录，doctor 报告 OpenSpec root ok。
- [x] 5.2 按当前 change 逐项审查实际文件、安装映射、退出状态、兼容矩阵和未覆盖风险，补充交付记录；验证证据：独立代码审查首轮发现 archive 目录未预检、映射验证不足、非事务边界缺文档和 TMPDIR 搜索权限问题；逐项修复后复核结论为 Critical/Important/Minor 均无，Ready: Yes。交付记录见下文。

## 6. 用户验收与归档

- [x] 6.1 用户完成结构验收，确认基线文件、安装安全行为、验证输出、兼容和迁移说明符合预期；验证方式：2026-11-12 用户回复“验收归档”，视为结构验收通过并授权归档。
- [x] 6.2 用户验收后将 delta spec 同步到长期主规格并归档 change；验证方式：CLI 归档失败后手工完成移动，长期 `portable-project-workflow` strict validation 通过且 archive 中保留完整工件和交付证据。

## 交付记录

- 影响仓库：当前工作区不是 Git 仓库；`git status --short` 返回 128，与 `PROJECT_PROFILE.md` 声明一致。
- 实际改动：新增 `templates/project-workflow/WORKFLOW_BASELINE.yaml`；扩展安装映射；统一预检八个文件与 `openSpec/changes/archive` 目录的符号链接和非目录路径；强化 dry-run、精确映射、部分冲突、重复安装、嵌套路径和完整树验证；临时目录改用 `${TMPDIR:-/tmp}`；同步 README、PROJECT_PROFILE、INSTALL 和 CHANGELOG。
- 提交 / Patch：无提交；项目未初始化 Git，本轮只保留工作区文件改动。
- 自动验证命令与结果：`bash -n scripts/install.sh scripts/verify.sh` 退出码 0；默认和自定义 `TMPDIR` 的 `./scripts/verify.sh` 均退出码 0 并输出 `ALL_CHECKS_PASSED`；不存在和不可搜索 `TMPDIR` 返回 73；当前 change 与两份长期主规格 strict validation 均 valid；`openspec context` 正确，`openspec doctor` 报告 root ok。
- 代码审查：首轮发现一项 Critical、两项 Important、一项 Minor；修复后同一审查者复核为无遗留问题，Ready: Yes。
- 人工业务 / 交互 / 视觉 / 环境验收：2026-11-12 用户结构验收通过。Archify 双泳道正式图已通过 showcase 9/9、四档桌面 visual-check 和明暗主题截图审阅；自动浏览器证据与最终 HTML 摘要绑定一致。
- 工作流同步结论：本项目即权威工作流项目，通用增量已落入权威模板、验证、文档、delta spec 和 CHANGELOG；长期主规格已同步完成。
- 关联权威项目 change：`harden-portable-installation-baseline`（本 change）。
- 未覆盖项与残留风险：复制阶段不是事务操作，磁盘、权限或源文件读取错误仍可能留下部分新增文件；Archify 图是阅读辅助，OpenSpec 仍是唯一事实源。
- 后续事项：无。
