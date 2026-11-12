## 0. 门禁

- [x] 0.1 用户确认采用 **Plumbline（准绳）** 作为项目正式名称，并授权创建 L2 改名 change；验证证据：2026-11-12 用户选择“采用 Plumbline（准绳）”。

## 1. 名称替换

- [x] 1.1 更新根 `AGENTS.md`、`PROJECT_PROFILE.md` 和 `README.md` 的项目名称、标题、定位和目录树标识；验证：三份文档使用 `Plumbline（准绳）`，身份文件不再出现旧名称。
- [x] 1.2 更新 `CHANGELOG.md`、`openSpec/config.yaml`、`openSpec/README.md` 和 `templates/project-workflow/INSTALL.md`；验证：项目描述、OpenSpec context 和安装说明名称一致。
- [x] 1.3 将 `templates/project-workflow/WORKFLOW_BASELINE.yaml` 的 `authority_name` 改为 `Plumbline`，同步 `scripts/verify.sh` 断言；验证：基线解析和断言通过。

## 2. 一致性与兼容

- [x] 2.1 在 `scripts/verify.sh` 增加名称一致性检查，扫描身份文件（根 `AGENTS.md`、`PROJECT_PROFILE.md`、`README.md`、`openSpec/config.yaml`、`openSpec/README.md` 和模板 `INSTALL.md`）；验证：身份文件不含旧名称，旧名称只保留在历史归档、`CHANGELOG.md` 改名记录和本 change 工件中。
- [x] 2.2 确认安装映射、占位符范围、安装退出码和比较状态未变化；验证：`./scripts/verify.sh` 的安装、冲突、零写入和比较用例全部通过；`authority_name` 变化只造成消费项目基线文件一次预期 `theirs-only`，分类语义和退出码不变。
- [x] 2.3 确认 `workflow_version` 仍为 `0.1.0-dev.4`；验证：基线和验证脚本断言一致，未占用新的 `dev.N`。

## 3. 规格与自动验证

- [x] 3.1 在 `openSpec/changes/rename-project-to-plumbline/specs/portable-project-workflow/spec.md` 新增权威项目名称一致性 Requirement；验证：`openspec validate rename-project-to-plumbline --strict` 输出 valid。
- [x] 3.2 运行 `bash -n`、`./scripts/verify.sh`、`openspec validate rename-project-to-plumbline --strict`、受影响主规格 strict validation、`openspec context` 和 `openspec doctor`；验证证据：`bash -n` 退出码 0；`verify.sh` 输出 `ALL_CHECKS_PASSED`；change/spec validation 均 valid；`context` 和 `doctor` 退出码 0，CLI 目录标题仍显示未重命名的实际目录。

## 4. 审查、验收与归档

- [x] 4.1 对名称一致性、历史归档保留、安装契约不变和文档无遗漏执行独立审查；验证证据：独立审查结论 `Ready: Yes`，无 Critical/Important；已修复临时目录旧前缀、CHANGELOG 兼容表述、INSTALL 权威来源更新步骤、OpenSpec context 口径、authority_name 精确口径和验收扫描范围说明。
- [x] 4.2 用户确认新名称、目录不自动重命名和消费项目人工更新来源方式；验证证据：2026-11-12 用户选择“验收并归档”，接受目录保持现状和消费项目人工更新来源。
- [x] 4.3 用户验收后同步 delta spec、补齐交付记录并归档 change；验证：名称一致性 Requirement 已同步到 `openSpec/specs/portable-project-workflow/spec.md` 并通过 strict validation。

## 交付记录

- 影响仓库：本权威项目仓库；不直接写入任何消费项目，不重命名工作目录。
- 实际改动：根 `AGENTS.md`、`PROJECT_PROFILE.md`、`README.md`、`CHANGELOG.md`、`openSpec/config.yaml`、`openSpec/README.md`、`templates/project-workflow/INSTALL.md`、`templates/project-workflow/WORKFLOW_BASELINE.yaml`、`scripts/verify.sh` 和本 change 工件统一为 `Plumbline（准绳）`；`authority_name` 改为 `Plumbline`。
- 提交 / Patch：本轮未提交 Git；工作区改动保持未提交状态，等待用户授权。
- 自动验证命令与结果：`bash -n scripts/install.sh scripts/verify.sh scripts/compare.sh scripts/workflow-files.sh` 退出码 0；`./scripts/verify.sh` 退出码 0，输出 `ALL_CHECKS_PASSED`；`openspec validate rename-project-to-plumbline --strict`、`openspec validate portable-project-workflow --type spec --strict`、`openspec validate --specs`、`openspec context` 和 `openspec doctor` 全部通过。
- 人工业务 / 交互 / 视觉 / 环境验收：2026-11-12 用户选择“验收并归档”，接受目录保持现状和消费项目人工更新来源。
- 工作流同步结论：名称一致性 Requirement 已同步到 `portable-project-workflow` 长期主规格；改名只影响项目身份和权威来源元数据，不改变安装映射、占位符、退出码、比较分类语义或升级流程。
- 关联权威项目 change：本项目即权威工作流项目。
- 未覆盖项与残留风险：实际工作目录仍为 `AI工作流`，`openspec context` 的 CLI 标题仍显示目录名；消费项目需要人工更新记录的权威来源名称；历史归档保留旧名称；未在真实消费项目执行改名同步。
- 后续事项：目录重命名、Git 提交、打 tag 和远程配置均需用户另行授权。
