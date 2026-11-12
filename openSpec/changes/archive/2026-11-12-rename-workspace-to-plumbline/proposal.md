## Why

项目已正式命名为 **Plumbline（准绳）**，但实际工作目录仍叫 `AI工作流`，导致 `openspec context` 标题、路径引用和仓库标识不一致。2026-11-12 用户确认把工作目录重命名为 `plumbline`。

本变更按 **L1 本地工作区调整** 处理：只改变目录名和对应文档，不改变模板内容、安装映射、占位符、脚本契约或升级行为。

## What Changes

- 将工作目录 `/Users/leigod/雷神/AI工作流` 重命名为 `/Users/leigod/雷神/plumbline`。
- 更新 `README.md`、`CHANGELOG.md` 和 `PROJECT_PROFILE.md` 中“目录未重命名”的过期说明。
- 保留历史归档 change 的原文，不改写当时“未重命名目录”的事实。
- 验证新路径下 Git 状态、OpenSpec 根目录、脚本和严格校验正常。

## Impact

- 影响本地目录路径和当前会话工作目录。
- 不修改安装映射、模板文件、占位符、退出码或 OpenSpec 规格行为。
- Git 工作区未提交内容随目录移动保留；不自动提交、打 tag 或配置远程。

## Acceptance

- 新目录 `/Users/leigod/雷神/plumbline` 存在，旧目录不存在。
- `git status` 仍显示原有未提交改动，无文件丢失。
- `openspec context` 显示 `plumbline`，`openspec doctor`、`./scripts/verify.sh` 和 strict validation 通过。
- 文档不再声称工作目录未重命名。
