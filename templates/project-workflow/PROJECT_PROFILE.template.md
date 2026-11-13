# {{PROJECT_NAME}} 项目配置

> 安装时将本文件复制为根目录 `PROJECT_PROFILE.md`，填写所有标记为“必填”的内容。完成后，全文件不应残留双花括号占位符。

## 1. 项目身份（必填）

- 项目名称：`{{PROJECT_NAME}}`
- 项目目标：{{PROJECT_GOAL}}
- 主要用户或调用方：{{PRIMARY_USERS}}
- 文档语言：{{DOCUMENT_LANGUAGE}}
- 工作区根目录：`{{WORKSPACE_ROOT}}`
- 默认 OpenSpec schema：`spec-driven`
- Agent 入口：`AGENTS.md`（Codex/通用 agent）和 `CLAUDE.md`（Claude Code，导入 `AGENTS.md` 与 `PROJECT_PROFILE.md`）

### 权威工作流来源（必填）

- 权威项目名称：{{WORKFLOW_AUTHORITY_NAME}}
- 权威项目路径或仓库地址：`{{WORKFLOW_AUTHORITY_SOURCE}}`
- 当前接入版本、标签或基线：{{WORKFLOW_AUTHORITY_BASELINE}}
- 通用流程改进的关联 change 与同步方式：{{WORKFLOW_SYNC_PROCESS}}

消费项目不得自动覆盖权威项目或其他项目文件。通用改进通过两端 OpenSpec change 关联、人工审查差异并分别验证；技术栈专属和业务专属规则按本项目根规则留在对应配置或领域规格。

若安装包包含 `WORKFLOW_BASELINE.yaml`，本字段必须记录其中的 `workflow_version`。历史项目缺少基线文件且无法确认来源时填写“历史基线未知”，完成逐文件比较后再记录新接入版本，不得把最新版本冒充历史版本。

## 2. 工作区与 Git 仓库边界（必填）

根目录是否为 Git 仓库：{{ROOT_IS_GIT_REPOSITORY}}

| 仓库或目录 | 绝对或项目相对路径 | 职责 | 默认分支 | 是否允许直接修改 |
|---|---|---|---|---|
| {{REPOSITORY_NAME_1}} | `{{REPOSITORY_PATH_1}}` | {{REPOSITORY_PURPOSE_1}} | `{{DEFAULT_BRANCH_1}}` | {{EDIT_POLICY_1}} |
| {{REPOSITORY_NAME_2}} | `{{REPOSITORY_PATH_2}}` | {{REPOSITORY_PURPOSE_2}} | `{{DEFAULT_BRANCH_2}}` | {{EDIT_POLICY_2}} |

规则：

- 执行 Git 状态、差异、提交或回滚前，必须先确认当前文件所属仓库。
- 多仓任务分别记录各仓库状态、目标差异、验证和提交信息。
- 未提交改动默认属于用户或其他任务，不得覆盖、回退或顺手整理。

## 3. 目录地图（必填）

| 类型 | 路径 | 说明 |
|---|---|---|
| 业务源码 | `{{SOURCE_PATHS}}` | {{SOURCE_DESCRIPTION}} |
| 自动化测试 | `{{TEST_PATHS}}` | {{TEST_DESCRIPTION}} |
| 配置 | `{{CONFIG_PATHS}}` | {{CONFIG_DESCRIPTION}} |
| 文档 | `{{DOCUMENTATION_PATHS}}` | {{DOCUMENTATION_DESCRIPTION}} |
| 生成产物 | `{{GENERATED_PATHS}}` | 默认不直接修改 |
| 依赖或缓存 | `{{DEPENDENCY_PATHS}}` | {{DEPENDENCY_EDIT_POLICY}} |

## 4. 技术栈与依赖（必填）

- 主要语言及版本：{{LANGUAGES_AND_VERSIONS}}
- 框架或运行时：{{FRAMEWORKS_AND_RUNTIMES}}
- 包管理器：{{PACKAGE_MANAGERS}}
- 数据库、消息、缓存或外部服务：{{DATA_AND_EXTERNAL_SERVICES}}
- 依赖安装规则：{{DEPENDENCY_INSTALLATION_RULES}}
- 外部 API 文档来源：{{EXTERNAL_API_DOCUMENTATION_SOURCE}}

第三方 API、框架或 SDK 签名不确定时，必须先查阅当前官方文档；项目内部 API 以本地实现和既有调用为准。

## 5. 标准命令（必填）

没有对应能力时填写“不适用”并说明原因，不得保留空白。

| 目的 | 命令 | 运行目录 | 成功标准 |
|---|---|---|---|
| 安装依赖 | `{{INSTALL_COMMAND}}` | `{{INSTALL_WORKDIR}}` | {{INSTALL_SUCCESS_CRITERIA}} |
| 格式检查 | `{{FORMAT_CHECK_COMMAND}}` | `{{FORMAT_WORKDIR}}` | {{FORMAT_SUCCESS_CRITERIA}} |
| 静态检查 | `{{LINT_COMMAND}}` | `{{LINT_WORKDIR}}` | {{LINT_SUCCESS_CRITERIA}} |
| 类型或语法检查 | `{{TYPECHECK_COMMAND}}` | `{{TYPECHECK_WORKDIR}}` | {{TYPECHECK_SUCCESS_CRITERIA}} |
| 单元测试 | `{{UNIT_TEST_COMMAND}}` | `{{UNIT_TEST_WORKDIR}}` | {{UNIT_TEST_SUCCESS_CRITERIA}} |
| 集成测试 | `{{INTEGRATION_TEST_COMMAND}}` | `{{INTEGRATION_TEST_WORKDIR}}` | {{INTEGRATION_TEST_SUCCESS_CRITERIA}} |
| 构建 | `{{BUILD_COMMAND}}` | `{{BUILD_WORKDIR}}` | {{BUILD_SUCCESS_CRITERIA}} |
| 本地运行 | `{{RUN_COMMAND}}` | `{{RUN_WORKDIR}}` | {{RUN_SUCCESS_CRITERIA}} |
| 数据迁移检查 | `{{MIGRATION_CHECK_COMMAND}}` | `{{MIGRATION_WORKDIR}}` | {{MIGRATION_SUCCESS_CRITERIA}} |
| OpenSpec 校验 | `openspec validate <change-name> --strict` | `{{WORKSPACE_ROOT}}` | 输出 valid 且退出码为 0 |

### 最窄验证映射（必填）

| 改动类型 | 最小自动验证 | 追加验证条件 | 人工验收 |
|---|---|---|---|
| 文档或配置 | {{DOC_VALIDATION}} | {{DOC_ESCALATION}} | {{DOC_MANUAL_ACCEPTANCE}} |
| 局部业务逻辑 | {{LOGIC_VALIDATION}} | {{LOGIC_ESCALATION}} | {{LOGIC_MANUAL_ACCEPTANCE}} |
| 公共接口或数据契约 | {{API_VALIDATION}} | {{API_ESCALATION}} | {{API_MANUAL_ACCEPTANCE}} |
| UI 或交互 | {{UI_VALIDATION}} | {{UI_ESCALATION}} | {{UI_MANUAL_ACCEPTANCE}} |
| 数据库或迁移 | {{MIGRATION_VALIDATION}} | {{MIGRATION_ESCALATION}} | {{MIGRATION_MANUAL_ACCEPTANCE}} |
| 构建或部署 | {{DEPLOY_VALIDATION}} | {{DEPLOY_ESCALATION}} | {{DEPLOY_MANUAL_ACCEPTANCE}} |

### 代码审查门禁（必填）

- 强制独立审查条件：{{REVIEW_GATE_INDEPENDENT_TRIGGERS}}
- 项目专属审查检查点：{{REVIEW_GATE_PROJECT_CHECKS}}
- 审查结论记录位置：当前 change 的 `tasks.md`；补充证据保存位置：{{REVIEW_GATE_EVIDENCE_LOCATION}}
- 门禁 skill 入口：`.agents/skills/running-code-review-gate/`（Codex/通用 agent）和 `.claude/skills/running-code-review-gate/`（Claude Code）；两边内容除 `agents/openai.yaml` 外必须一致。

项目专属检查点只写在本文件和根规则，不修改通用 skill 正文。未填写强制独立审查条件时，按根规则的高风险定义执行。

## 6. 运行与验收环境（必填）

| 环境 | 用途 | 可用性 | 验证方式 | 限制 |
|---|---|---|---|---|
| 本地开发 | {{LOCAL_PURPOSE}} | {{LOCAL_AVAILABILITY}} | {{LOCAL_VALIDATION}} | {{LOCAL_LIMITS}} |
| 自动化测试 | {{TEST_ENV_PURPOSE}} | {{TEST_ENV_AVAILABILITY}} | {{TEST_ENV_VALIDATION}} | {{TEST_ENV_LIMITS}} |
| 预发布 | {{STAGING_PURPOSE}} | {{STAGING_AVAILABILITY}} | {{STAGING_VALIDATION}} | {{STAGING_LIMITS}} |
| 生产 | {{PRODUCTION_PURPOSE}} | {{PRODUCTION_AVAILABILITY}} | {{PRODUCTION_VALIDATION}} | {{PRODUCTION_LIMITS}} |

人工验收责任人或角色：{{ACCEPTANCE_OWNER}}

人工验收至少覆盖：

- 正常路径：{{HAPPY_PATH_MATRIX}}
- 失败与取消：{{FAILURE_MATRIX}}
- 重复进入、重试或幂等：{{REENTRY_MATRIX}}
- 权限、安全和隐私：{{SECURITY_MATRIX}}
- 性能、资源或生命周期：{{LIFECYCLE_MATRIX}}
- 兼容、设备、浏览器或环境差异：{{COMPATIBILITY_MATRIX}}

## 7. 代码与文档约定（必填）

- 命名规则：{{NAMING_RULES}}
- 新文件头或作者规则：{{FILE_HEADER_RULES}}
- 注释语言及关键注释标准：{{COMMENT_RULES}}
- 错误处理方式：{{ERROR_HANDLING_RULES}}
- 日志与敏感数据规则：{{LOGGING_AND_PRIVACY_RULES}}
- 格式化工具及配置：{{FORMATTER_RULES}}
- 公共组件、服务或工具复用入口：{{REUSE_ENTRYPOINTS}}

## 8. 长期领域规格索引（必填）

只列长期有效的能力边界；具体需求通过 change 管理。

| 能力 | 主规格路径 | 适用范围 |
|---|---|---|
| 研发流程 | `openSpec/specs/development-workflow/spec.md` | 分级、门禁、审查、验证与归档 |
| {{DOMAIN_CAPABILITY_1}} | `{{DOMAIN_SPEC_PATH_1}}` | {{DOMAIN_SPEC_SCOPE_1}} |
| {{DOMAIN_CAPABILITY_2}} | `{{DOMAIN_SPEC_PATH_2}}` | {{DOMAIN_SPEC_SCOPE_2}} |

## 9. 禁止操作与高风险动作（必填）

默认禁止：

- 未经确认执行破坏性删除、数据清空、强制回滚或覆盖用户改动。
- 直接修改生成产物、第三方依赖缓存或由其他系统维护的文件。
- 把凭据、令牌、个人信息、生产数据或内部地址写入代码、日志和交付文档。
- 未通过方案门禁修改实现，或未通过交付门禁归档 change。

项目追加禁止项：

- {{PROHIBITED_ACTION_1}}
- {{PROHIBITED_ACTION_2}}
- {{PROHIBITED_ACTION_3}}

需要额外审批的动作：{{APPROVAL_REQUIRED_ACTIONS}}

## 10. 发布、回滚与交付（必填）

- 发布流程：{{RELEASE_PROCESS}}
- 回滚流程：{{ROLLBACK_PROCESS}}
- 版本或变更日志规则：{{VERSIONING_AND_CHANGELOG_RULES}}
- 提交、分支和合并策略：{{GIT_DELIVERY_RULES}}
- CI/CD 入口：{{CI_CD_ENTRYPOINTS}}
- 交付证据保存位置：{{EVIDENCE_LOCATION}}
- 用户确认完成的方式：{{USER_ACCEPTANCE_SIGNAL}}

## 11. 安装完成检查

- [ ] 全文件无双花括号占位符。
- [ ] `AGENTS.md` 和 `CLAUDE.md` 均存在；`CLAUDE.md` 只导入 `AGENTS.md` 与 `PROJECT_PROFILE.md`，未复制规则。
- [ ] 仓库和目录路径已核实。
- [ ] 标准命令在对应环境可执行，或明确标记为不适用。
- [ ] 人工验收责任人与环境已确认。
- [ ] 权威工作流来源、基线和回流方式已确认。
- [ ] 代码审查门禁的强制独立审查条件、项目专属检查点和证据位置已填写。
- [ ] `WORKFLOW_BASELINE.yaml` 可解析，且 `workflow_version` 与本文件记录的接入基线一致。
- [ ] 长期主规格索引已建立。
- [ ] 禁止操作、发布和回滚规则已确认。
- [ ] 已使用一个 L0 任务和一个 L1 change 验证流程。
