## ADDED Requirements

### Requirement: 模板必须交付可复用代码审查门禁 skill
可安装模板 MUST 包含自动可发现的代码审查门禁 skill 及其必要参考文件，并将其纳入安装清单、结构验证、版本基线和升级说明。通用 skill 不得包含消费项目业务专名或技术栈硬编码，项目专属检查必须从根规则、项目配置或领域规格加载。

#### Scenario: 安装到空目标项目
- **WHEN** 使用者向没有同名文件的目标项目执行安装
- **THEN** 安装结果必须包含完整审查 skill，并通过模板结构和 skill 格式校验

#### Scenario: 目标已有同名 skill 文件
- **WHEN** 任一计划安装的 skill 文件或父路径冲突
- **THEN** 安装必须沿用冲突或不安全路径零写入规则，列出冲突并要求人工比较合并

#### Scenario: 历史消费项目升级
- **WHEN** 已安装旧模板的项目希望接入审查门禁
- **THEN** 升级说明必须要求比较权威模板和本地规则，人工合并 skill、规格和项目适配，不得自动覆盖

#### Scenario: 验证双入口一致性
- **WHEN** 执行权威项目统一验证
- **THEN** 验证必须确认 `.agents/skills/` 与 `.claude/skills/` 包含同一组必需文件、内容逐字节一致，且 Claude 镜像不包含 `agents/openai.yaml`

#### Scenario: 验证模板隔离性
- **WHEN** 执行权威项目统一验证
- **THEN** 验证必须检查 skill 文件完整、名称和 frontmatter 合法、安装映射一致、无占位残留且通用核心没有技术栈或业务规则泄漏
