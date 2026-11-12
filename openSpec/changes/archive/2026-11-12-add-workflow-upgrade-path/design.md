## Context

见 `proposal.md`。模板通过显式安装映射复制文件，并记录 `WORKFLOW_BASELINE.yaml`。安装器故意不覆盖同名文件，因此版本升级不能复用安装流程。消费项目真正需要的是“知道差异在哪，再由人和 OpenSpec change 决定怎么合并”。

本变更只补只读比较能力和升级 runbook，不引入自动覆盖、自动提交或第二套事实源。

## Goals / Non-Goals

**Goals:**

- 让消费项目能用一条只读命令得到逐文件升级差异。
- 区分模板变更、消费项目本地修改、双方修改、缺失文件和项目专属文件。
- 把升级纳入消费项目自己的 OpenSpec change、真实验证、用户验收和重新基线。
- 消除安装映射在 `install.sh`、`verify.sh` 和比较脚本之间的重复维护。

**Non-Goals:**

- 不提供自动写入、自动三方合并、自动提交或自动升级。
- 不覆盖 `PROJECT_PROFILE.md`、`openSpec/config.yaml` 等项目配置。
- 不引入文件校验清单或第二份安装清单格式；本变更只使用当前模板、目标项目和可选旧模板快照。
- 不改变安装退出码、占位符范围或零写入契约。

## Decisions

### 1. 共享安装映射

新增 `scripts/workflow-files.sh`，定义 `template_sources`、`installed_destinations` 和 `installed_directories`。`install.sh`、`verify.sh`、`compare.sh` 统一 source 该文件，避免新增文件时三处漂移。该文件不安装到消费项目。

替代方案是继续复制数组。它短期简单，但本变更新增比较脚本后会出现第三份映射，长期必然漂移。

### 2. `compare.sh` 只读比较

命令形式：

```bash
./scripts/compare.sh --target /path/to/consumer [--base /path/to/old-template]
```

- `--target`：已安装项目根目录，必须存在。
- `--base`：可选，权威项目在消费项目记录的旧基线时的模板目录快照，必须包含 `AGENTS.template.md`。
- 不提供 `--base` 时执行两方比较：目标文件与当前模板；不同即报告 `differs` 并提示无法区分本地修改和模板修改。

比较维度：

- `local_changed`：目标文件与 base 不同。
- `template_changed`：base 与当前模板文件不同。
- 分类：
  - 目标缺失 → `missing`
  - 无 base：相同 → `unchanged`，不同 → `differs`
  - 有 base：
    - 都未变 → `unchanged`
    - 只有本地变 → `ours-only`
    - 只有模板变 → `theirs-only`
    - 双方都变且目标已等于当前模板 → `converged`
    - 双方都变 → `both-changed`

项目专属文件 `AGENTS.md`、`CLAUDE.md`、`PROJECT_PROFILE.md`、`openSpec/config.yaml` 无论分类结果如何都追加 `manual: project-specific` 提示。`WORKFLOW_BASELINE.yaml` 追加 `metadata: update after merge` 提示。

### 3. 差异存在不是脚本失败

报告差异是正常结果，因此发现 `ours-only`、`theirs-only`、`both-changed`、`missing` 或 `differs` 时仍以状态 `0` 退出。只有参数错误（`64`）、目录或模板快照无效（`66`）、模板源缺失（`70`）才非零退出。升级门禁由消费项目的 OpenSpec change 和真实验证承担，不由比较脚本阻断。

### 4. 升级流程独立于安装

INSTALL 增加“升级已接入项目”章节：

1. 记录旧基线，确认目标版本。
2. 在消费项目创建 `adopt-workflow-<version>` change，声明范围和非目标。
3. 从权威项目获取旧基线对应的模板快照。
4. 运行 `compare.sh`，把报告写入 change。
5. 按分类逐文件合并：项目专属文件人工处理，模板变更合并增量，双方修改进行三方合并。
6. 运行消费项目实际验证和用户验收。
7. 验收后更新 `PROJECT_PROFILE.md` 记录的基线和 `WORKFLOW_BASELINE.yaml`。
8. 同步消费项目规格、归档 change；回滚使用升级前 Git 提交或备份。

### 5. 版本与关联 change 协调

`0.1.0-dev.3` 已被归档的 `add-cross-agent-entry` 占用。本变更使用 `0.1.0-dev.4`；`add-code-review-gate-skill` 顺延到 `0.1.0-dev.5`。

## Risks / Trade-offs

- [消费项目没有旧模板快照] → 两方比较仍能发现差异，但明确标注无法区分本地修改和模板修改；runbook 要求先获取旧基线快照或人工审查。
- [项目专属文件被误覆盖] → 比较脚本不写入；文档要求所有 `manual` 文件必须人工处理，且不提供升级覆盖参数。
- [差异分类依赖 base 正确] → `--base` 必须包含 `AGENTS.template.md`，否则以状态 `66` 拒绝；报告中打印目标基线和当前模板版本，要求人工核对。
- [共享映射重构影响安装器] → 现有安装、冲突、零写入和验证用例全部回归；映射文件只含数组，不执行副作用。
- [版本继续顺延] → 本变更占用 dev.4，review-gate 使用 dev.5，所有文档和脚本同步更新。

## Migration Plan

1. 抽取共享映射并让安装器、验证器使用。
2. 新增 `compare.sh` 和验证用例。
3. 更新 INSTALL、README、CHANGELOG、版本基线和关联 change。
4. 运行 shell 语法、比较脚本正反向用例、`./scripts/verify.sh` 和 OpenSpec strict validation。
5. 用户结构验收后同步 `portable-project-workflow` 主规格并归档。

回滚时移除 `scripts/compare.sh`、`scripts/workflow-files.sh`，恢复安装器和验证器的内联映射、文档增量和基线到 `0.1.0-dev.3`；消费项目已完成的升级不回退。
