## Context

见 `proposal.md`。项目已经具备完整的工作流模板、安装器、只读比较器和基线校验，但名称仍是类别描述「AI 工作流」。正式名称需要同时出现在三类事实源：

1. 项目自身文档和 OpenSpec context；
2. 模板 `WORKFLOW_BASELINE.yaml` 的 `authority_name`；
3. 消费项目 `PROJECT_PROFILE.md` 记录的权威来源。

本变更只统一名称，不改变任何行为契约。

## Goals / Non-Goals

**Goals:**

- 建立正式、可识别、跨 agent 中立的项目名称。
- 让基线、项目配置、文档和验证脚本对名称的断言一致。
- 明确改名不改变安装、比较和升级行为。

**Non-Goals:**

- 不重命名当前工作目录或 Git 仓库。
- 不改变模板文件映射、占位符、安装退出码或比较状态。
- 不改写历史归档 change 的名称和内容。
- 不自动修改任何消费项目文件。

## Decisions

### 1. 正式名称

- 英文名：**Plumbline**
- 中文名：**准绳**
- 文档写法：`Plumbline（准绳）`
- 仓库标识建议：`plumbline`
- 基线 `authority_name`：`Plumbline`

Plumbline 是建筑铅垂线，表达基准、对齐和偏离检测，与项目的基线、门禁、证据和升级比较语义一致。中文「准绳」同时表达判断标准。

### 2. 名称出现位置

统一更新：

- 根 `AGENTS.md` 标题和项目描述；
- `PROJECT_PROFILE.md` 项目名称和权威来源；
- `README.md` 标题、定位和目录树标识；
- `CHANGELOG.md` 项目描述和改名记录；
- `openSpec/config.yaml` 的 Project context；
- `openSpec/README.md` 标题和说明；
- `templates/project-workflow/INSTALL.md` 中对权威项目的称呼；
- `templates/project-workflow/WORKFLOW_BASELINE.yaml` 的 `authority_name`；
- `scripts/verify.sh` 的 `authority_name` 断言。

模板占位符 `{{PROJECT_NAME}}` 不替换为 `Plumbline`：安装到消费项目时，占位符仍填写消费项目自己的名称。

### 3. 目录和仓库边界

本次不执行 `mv` 或目录重命名，避免影响当前工作区和未提交改动。README 目录树使用 `Plumbline/` 表达目标仓库名，实际本地目录保持现状；目录迁移由用户另行授权。

### 4. 版本与兼容

改名不改变工作流能力，因此不新增 `0.1.0-dev.N` 基线，`workflow_version` 保持 `0.1.0-dev.4`。`authority_name` 变化属于元数据变化：

- 消费项目需要人工把记录的权威来源从「AI 工作流」更新为「Plumbline」；
- 比较脚本和安装脚本不读取该字段做逻辑判断，行为不变；
- 历史消费项目不会自动改名，也不会自动更新基线。

### 5. 历史记录

归档 change 保留创建时的名称，因为它们记录的是当时的事实。新名称从本 change 起生效。

## Risks / Trade-offs

- [消费项目仍记录旧名称] → CHANGELOG 和升级文档说明人工更新；比较不受影响。
- [文档遗漏旧名称] → 验证脚本扫描身份文件，`rg` 允许旧名称保留在历史归档、`CHANGELOG.md` 改名记录和本 change 工件中。
- [目录名与新名称不一致] → README 和交付记录明确说明本次不移动目录，避免误以为路径已变。
- [品牌名称被占用] → 本变更只作为项目内部正式名称，不宣称商标独占；如未来公开发布，再单独评估域名和商标。

## Migration Plan

1. 创建本 change 并确认名称。
2. 更新根文档、OpenSpec context、模板基线、INSTALL 和验证脚本。
3. 在 `verify.sh` 增加名称一致性断言，确保基线 `authority_name` 与项目配置一致。
4. 运行 `bash -n`、`./scripts/verify.sh`、OpenSpec strict validation。
5. 用户结构验收后同步主规格并归档。
6. 回滚时恢复旧名称和 `authority_name`；安装与比较行为无需迁移。
