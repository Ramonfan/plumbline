## Purpose

定义可复用项目工作流在代码提交、合并或实现完成声明前执行结构化代码审查门禁的行为，使审查范围、风险路由、发现、验证证据和最终提交结论能够跨技术栈保持一致并由项目配置补充专属规则。

## ADDED Requirements

### Requirement: 门禁必须先确定事实源和提交范围
代码审查门禁 MUST 在开始技术审查前定位当前 OpenSpec change、任务等级、方案门禁状态、待审任务、实际仓库边界和本次提交范围，并保护不属于当前任务的工作区改动。

#### Scenario: 审查一个已规划的实现
- **WHEN** 用户准备提交、合并或声明当前 change 的实现完成
- **THEN** 门禁必须列出 change、需求依据、受影响仓库、待审范围和引用的当前版本验证证据

#### Scenario: 工作区包含多个仓库
- **WHEN** 本次实现跨越两个或更多独立 Git 仓库
- **THEN** 门禁必须分别读取并报告每个实际仓库的状态和差异，不得使用工作区根目录代替

#### Scenario: 提交范围不明确
- **WHEN** 待审差异包含无法与本次 change 安全拆分的未知或无关改动
- **THEN** 门禁必须输出 `Ready: No` 并请求明确范围，不得默认把全部改动纳入提交

### Requirement: 审查深度必须与项目风险匹配
门禁 MUST 根据 OpenSpec 任务等级、项目配置和实际风险选择本地审查或独立审查，不得无差别增加代理，也不得用自审替代强制独立审查。

#### Scenario: 低风险局部改动
- **WHEN** 项目将任务判定为低风险且没有复杂状态、安全、权限或公共契约风险
- **THEN** 门禁默认执行本地审查和最窄有效验证

#### Scenario: 高风险改动
- **WHEN** 项目规则要求独立审查，或改动涉及复杂异步、安全权限、公共接口、数据迁移、核心链路或 L3 风险
- **THEN** 门禁必须使用独立 reviewer，并只提供精确需求、差异、仓库边界、验证证据和项目专属检查点

#### Scenario: 独立审查无法完成
- **WHEN** 当前环境不能完成项目要求的独立审查
- **THEN** 门禁必须输出 `Ready: No` 和未覆盖原因，不得把本地审查标记为等价替代

### Requirement: 技术审查必须以行为契约为先
门禁 MUST 先检查实现是否满足当前 OpenSpec specs 和 tasks，再按项目实际触及的领域审查正确性、兼容、安全、竞态、循环、性能、资源和生命周期，不加载无关领域规则。

#### Scenario: 实现偏离已确认规格
- **WHEN** 当前差异与 specs、design 或 tasks 的已确认行为不一致
- **THEN** 门禁必须将偏离列为阻断 finding，除非先更新 OpenSpec 并重新通过必要门禁

#### Scenario: 项目提供专属审查规则
- **WHEN** 根规则、项目配置或领域规格定义了与当前差异相关的技术栈、仓库或运行环境检查
- **THEN** 门禁必须把这些规则纳入审查，并在输出中说明实际覆盖项

#### Scenario: 现有验证证据仍有效
- **WHEN** 同一任务已有覆盖当前源码、依赖和环境的有效验证，且相关内容没有变化或新疑点
- **THEN** 门禁必须引用该证据，不得仅为执行审查重复运行高成本验证

### Requirement: Findings 和 verdict 必须结构化
门禁 MUST 输出按 Critical、Important、Minor 排序的 findings。每项 finding 必须包含可定位证据、影响、触发条件和处理方向；最终必须给出 `Ready: Yes` 或 `Ready: No`。

#### Scenario: 存在未解决阻断项
- **WHEN** 存在未解决的 Critical/Important finding、方案门禁未通过、提交范围未知、必需验证缺失或强制独立审查未完成
- **THEN** verdict 必须为 `Ready: No`

#### Scenario: reviewer 建议与项目事实冲突
- **WHEN** 源码、规格或验证证据证明 reviewer finding 不成立
- **THEN** 门禁必须记录核验依据并允许技术性驳回，不得盲目修改实现

#### Scenario: 提交条件满足
- **WHEN** 范围明确、所有 Critical/Important finding 已修复、证伪或经用户明确接受并记录，且必需证据覆盖当前版本
- **THEN** verdict 可以为 `Ready: Yes`，同时保留 Minor、残留风险、未覆盖项和人工验收

### Requirement: 审查 skill 必须保持只读和权限收敛
审查 skill MUST 只读取项目事实并生成结论，不得自动修改实现、创建提交、推送、合并、批准远程变更或扩张用户授权。审查证据 MUST 回写当前 OpenSpec change，不得形成第二事实源。

#### Scenario: 用户只请求代码审查
- **WHEN** 用户要求审查当前改动或运行提交门禁
- **THEN** skill 只能返回 findings 和 verdict，不得顺手修复或执行 Git 写操作

#### Scenario: 用户明确要求修复 findings
- **WHEN** 用户在审查后授权处理问题
- **THEN** 实现者必须逐项核验、修改和验证，再对新版本重新运行门禁

#### Scenario: 自动审查通过但人工验收未完成
- **WHEN** verdict 为 `Ready: Yes` 但项目要求的业务、交互、视觉、设备或环境验收尚未完成
- **THEN** change 必须保持活跃，代码审查通过不得被解释为交付完成
