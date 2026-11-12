## ADDED Requirements

### Requirement: 权威项目名称在事实源中保持一致
权威工作流项目 MUST 在项目配置、模板基线、公开文档和 OpenSpec context 中使用同一个正式名称。模板 `WORKFLOW_BASELINE.yaml` 的 `authority_name` MUST 为机器可读英文名称 `Plumbline`，并与 `PROJECT_PROFILE.md` 记录的项目名称指向同一项目。此处 OpenSpec context 指 `openSpec/config.yaml` 的 `context` 字段；CLI 显示的目录名不因改名自动变化。改名 MUST NOT 改变安装映射、占位符范围、安装或比较退出码，也 MUST NOT 改写历史归档记录。消费项目记录的权威来源可以在人工确认后更新，不得由本项目的升级流程自动覆盖。

#### Scenario: 基线名称与项目配置一致
- **WHEN** 校验模板基线和项目配置
- **THEN** `authority_name` 与项目名称一致，验证通过

#### Scenario: 公开文档使用正式名称
- **WHEN** 阅读根目录文档、OpenSpec context 和模板安装说明
- **THEN** 使用同一个正式名称，不出现互相冲突的项目身份

#### Scenario: 改名不改变安装契约
- **WHEN** 项目完成改名
- **THEN** 安装文件映射、占位符范围、安装退出码、比较状态和升级流程保持不变

#### Scenario: 历史记录不改写
- **WHEN** 项目改名后查看归档 change
- **THEN** 历史 change 保留原名和原有内容，新名称从改名 change 起生效

#### Scenario: 消费项目来源人工更新
- **WHEN** 消费项目需要跟随权威项目改名
- **THEN** 由消费项目人工更新记录的权威来源，不由权威项目自动写入
