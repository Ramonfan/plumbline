# AI 工作流项目配置

## 项目身份

- 项目名称：AI 工作流。
- 目标：维护可复制、可验证、不会覆盖目标文件的项目治理模板。
- 文档语言：简体中文；OpenSpec 结构标题和 SHALL/MUST 保留英文。
- 工作区根目录：当前项目目录。
- 当前 Git 状态：未初始化；不得据此推断未来版本管理方式。

## 权威来源与回流

- 本项目即可复用工作流的权威来源；对外安装内容以 `templates/project-workflow/` 为准。
- 消费项目应在其 `PROJECT_PROFILE.md` 中记录本项目的路径或仓库地址、当前基线和回流方式。
- 通用改进使用“消费项目 change ↔ 本项目 change”关联，本项目审查、实施并验证权威增量，消费项目再人工合并并复验。
- 不自动跨项目覆盖；延期同步必须由用户确认并在消费项目交付记录中保留关联 change 和后续安排。

## 目录地图

| 路径 | 职责 |
|---|---|
| `templates/project-workflow/` | 对外复用模板的权威版本 |
| `templates/project-workflow/WORKFLOW_BASELINE.yaml` | 对外模板的机器可读版本基线 |
| `scripts/install.sh` | 安全安装到目标项目，不覆盖同名文件 |
| `scripts/verify.sh` | 校验项目、模板、脚本和 OpenSpec |
| `openSpec/specs/` | 长期工作流能力规格 |
| `openSpec/changes/` | 活跃 change 与实施证据 |
| `CHANGELOG.md` | 对外可见的版本变化摘要 |

## 技术与依赖

- 文件类型：Markdown、YAML、POSIX 风格 shell。
- 必需工具：`bash`、`find`、`rg`、`ruby`、OpenSpec CLI。
- 模板不得依赖业务项目源码、包管理器或构建系统。
- iOS 等技术栈内容只能位于对应示例目录。

## 标准命令

| 目的 | 命令 | 成功标准 |
|---|---|---|
| 完整校验 | `./scripts/verify.sh` | 退出码 0 并输出 `ALL_CHECKS_PASSED` |
| 验证依赖前置 | `for c in bash find rg ruby openspec; do command -v "$c" >/dev/null || exit 1; done` | 所有命令均可解析；缺失时 `verify.sh` 以状态 `69` 退出 |
| Shell 语法 | `bash -n scripts/install.sh scripts/verify.sh` | 退出码 0 |
| OpenSpec 环境 | `openspec context && openspec doctor` | 根目录识别正常，无结构错误 |
| 研发流程规格 | `openspec validate development-workflow --type spec --strict` | 输出 valid |
| 模板治理规格 | `openspec validate portable-project-workflow --type spec --strict` | 输出 valid |

## 验收矩阵

- 依赖前置：缺少 `bash`、`find`、`rg`、`ruby` 或 OpenSpec CLI 时，统一校验以状态 `69` 退出且不创建临时目录。
- 安装预览：目标目录无文件变化。
- 空目标安装：生成完整文件映射和基线文件，保留模板占位符等待项目填写。
- 冲突目标：列出全部冲突、状态码为 2、目标目录树零新增零修改。
- 符号链接父路径：列出不安全路径、状态码为 73、目标目录和链接指向位置零新增零修改。
- 非目录父路径：列出不安全路径、状态码为 73、目标目录树零新增零修改。
- 模板验证：文件清单、基线字段、Markdown、YAML、占位符和技术示例隔离通过；默认与自定义临时目录均可重复执行并清理产物。
- 复制阶段异常：明确不具备事务回滚保证，必须检查目标实际目录树并人工处理部分新增文件。
- OpenSpec：项目 context、doctor 和两份长期主规格 strict validation 通过。

## 长期主规格

| 能力 | 路径 |
|---|---|
| 研发流程 | `openSpec/specs/development-workflow/spec.md` |
| 可迁移项目工作流 | `openSpec/specs/portable-project-workflow/spec.md` |

## 禁止操作

- 安装脚本不得覆盖、删除或修改目标项目已有文件。
- 不把真实凭据、业务专名、本机用户目录或项目私有地址写入模板。
- 未经用户授权不执行 `git init`、提交、推送、发布或远端操作。
- 结构校验不得冒充目标项目真实构建、测试或人工验收。

## 交付规则

- 任何行为变化通过 OpenSpec change 管理。
- 消费项目回流的通用改进必须记录关联 change、适用边界和两端验证证据。
- 自动验证证据记录实际命令与结果。
- 用户结构验收前不归档。
- 发布版本前更新 `CHANGELOG.md`，并说明兼容与迁移影响。
