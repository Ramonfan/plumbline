# 项目 OpenSpec 工作流

OpenSpec 是项目管理需求、行为规格、技术设计、任务进度、验收证据和归档结果的唯一事实源。Superpowers 只参与开发执行，执行者负责串联任务分级、门禁、实现和验证。

项目技术栈、仓库边界、命令和人工验收方式见根目录 `PROJECT_PROFILE.md`。

## 目录结构

```text
openSpec/
├── config.yaml
├── specs/
│   └── development-workflow/spec.md
├── changes/
│   └── archive/
├── README.md
└── weekly_report_template.md
```

- `config.yaml`：schema、项目上下文、工件规则和 apply/archive 指引。
- `specs/`：已经生效、长期有效的能力规格。
- `changes/`：活跃 change，每项包含当前需求的规划与证据。
- `changes/archive/`：通过交付门禁并同步长期规格后的 change。
- `weekly_report_template.md`：只汇总当前周期发生状态变化的事项。

## 职责边界

- **OpenSpec**：需求、规格、设计、任务、进度、证据和归档。
- **Superpowers**：测试驱动开发、系统化调试、代码审查和完成前验证。
- **执行者**：任务分级、维护 change、执行实现与验证、回写结果。
- **PROJECT_PROFILE.md**：技术栈、仓库、目录、命令、环境和项目专属规则。

Superpowers 不创建第二份需求、设计、任务或归档事实源。

## 任务分级

| 等级 | 定义 | OpenSpec 要求 |
|---|---|---|
| L0 | 只读分析、解释、梳理或审查 | 不创建 change；转实现时重新分级 |
| L1 | 小型、明确、低风险修复 | 精简 proposal/spec/tasks；design 按 CLI 条件和风险 |
| L2 | 常规功能、接口、UI、数据或跨文件行为变化 | 完整 proposal、specs、design、tasks |
| L3 | 核心链路、架构、安全或显著公共契约变化 | 完整工件、影响分析、分阶段任务、回滚与验收矩阵 |

跨仓和跨文件是风险信号，不自动判定 L3。风险扩大时提升等级，不得降级规避流程。

## 三个门禁

1. **需求门禁**：确认目标、非目标、范围和验收标准。
2. **方案门禁**：确认设计、任务、兼容、风险和验证方式，并明确允许落地。
3. **交付门禁**：自动验证完成后，由用户确认业务、交互、视觉、设备或部署环境结果。

未通过方案门禁不得修改实现；未通过交付门禁不得 archive。

## 标准流程

```text
读取 AGENTS.md 和 PROJECT_PROFILE.md
→ L0～L3 分级
→ 定位同目标活跃 change；无匹配才创建
→ proposal：为什么做、做什么、影响什么
→ specs：可观察、可验证的行为契约
→ design：关键决策、数据流、兼容、风险与验证
→ tasks：可独立验证的实施任务
→ 用户通过方案门禁
→ apply tasks 并即时回写证据
→ 按风险调试、测试和审查
→ 完成前验证
→ 用户通过交付门禁
→ 同步长期主规格
→ archive
```

## 工件职责

### proposal

- 标注任务等级。
- 明确背景、目标、非目标、影响范围和验收口径。
- 记录需求门禁结论。

### specs

- 只描述外部可观察和验证的行为。
- 使用 Requirement 和 Scenario。
- 按风险覆盖失败、兼容、安全、重复进入和生命周期边界。

### design

- 描述现状与目标链路、职责、数据流和关键时序。
- 记录技术决策、关键假设、更简替代方案、兼容、迁移、回滚和验证方式。
- 明确实际仓库边界和受影响上下游。

### tasks

- 每项使用 CLI 可识别的 checkbox。
- 每项包含可验证的成功标准和验证方式。
- 完成一项立即回写，不批量补记。
- 自动验证和用户验收分别记录。

## 常用命令

以当前安装版本的 `openspec --help` 为准。常用命令示例：

```bash
openspec list
openspec status --change <change-name>
openspec instructions <artifact> --change <change-name> --json
openspec instructions apply --change <change-name> --json
openspec validate <change-name> --strict
openspec doctor
openspec context
openspec archive <change-name>
```

## 上下文与验证

- L0/L1 使用最小上下文包，只在任务触及对应领域时读取长期主规格。
- 实际命令、运行目录、成功标准和环境限制以 `PROJECT_PROFILE.md` 为准。
- 证据覆盖当前源码和依赖版本且无相关变化时可以复用；变化后重新验证。
- 修复构建、迁移或部署失败后必须执行对应真实命令。
- 人工验收未完成时，不勾选交付任务、不归档。

## 长期主规格

模板只预置 `development-workflow`。新项目应根据真实高风险领域建立少量长期主规格，并在 `PROJECT_PROFILE.md` 中维护索引。单次需求和临时修复不得直接写入长期主规格，应先通过 change 形成 delta。

## 统一交付记录

```markdown
## 交付记录

- 影响仓库：
- 实际改动：
- 提交 / Patch：
- 自动验证命令与结果：
- 人工业务 / 交互 / 视觉 / 环境验收：
- 未覆盖项与残留风险：
- 后续事项：
```

纯文档或配置 change 应明确说明未运行项目构建的原因，不得为了形式启动无关构建。

## 周报

使用 `weekly_report_template.md`，只统计当前周期有新增、完成、验收或状态变化的事项。收益优先使用可复核数据；无真实线上数据时，明确标注为代码路径测算或估算。
