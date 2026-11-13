## ADDED Requirements

### Requirement: 提交和实现完成声明必须经过代码审查门禁
项目 MUST 在执行代码提交、合并或声明实现完成前运行与任务风险匹配的代码审查门禁。技术审查 MUST 保持只读；用户授权记录时，MUST 把审查范围、findings、验证引用和 verdict 作为独立记录步骤写入当前 OpenSpec change。该门禁 MUST NOT 替代用户人工验收，也不得自动获得 Git 写操作权限。

#### Scenario: 准备提交实现
- **WHEN** change 的实现任务完成并准备创建提交或合并
- **THEN** 必须先获得覆盖精确提交范围和当前版本证据的 `Ready: Yes`

#### Scenario: 门禁阻断
- **WHEN** verdict 为 `Ready: No`
- **THEN** 不得执行提交、合并或完成声明，必须处理阻断项并重新审查

#### Scenario: 用户只授权审查
- **WHEN** 用户要求代码审查但没有要求提交、推送或合并
- **THEN** 执行者只能报告审查结论，不得把审查请求扩张为 Git 写操作授权
