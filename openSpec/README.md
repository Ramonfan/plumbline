# AI 工作流 OpenSpec

本目录管理 AI 工作流项目自身的需求、行为规格、设计、任务、验证证据和归档。

## 长期主规格

| 能力 | 路径 | 说明 |
|---|---|---|
| 研发流程 | `specs/development-workflow/spec.md` | 分级、门禁、审查、验证与交付 |
| 可迁移项目工作流 | `specs/portable-project-workflow/spec.md` | 独立项目、模板分层、安全安装和校验契约 |

## 新变更流程

```text
需求与任务分级
→ 创建或定位 change
→ proposal / specs / design / tasks
→ 用户通过方案门禁
→ 修改模板、脚本或文档
→ scripts/verify.sh
→ 更新 CHANGELOG.md
→ 用户结构验收
→ 同步主规格并归档
```

## 常用命令

```bash
openspec list
openspec status --change <change-name>
openspec validate <change-name> --strict
openspec validate development-workflow --type spec --strict
openspec validate portable-project-workflow --type spec --strict
openspec doctor
openspec context
```

对外安装模板位于 `../templates/project-workflow/`。项目自身规则见根目录 `AGENTS.md` 和 `PROJECT_PROFILE.md`。
