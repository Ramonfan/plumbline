## 0. 门禁

- [x] 0.1 用户确认把工作目录重命名为 `plumbline`；验证证据：2026-11-12 用户回复“可以”，授权执行目录重命名。

## 1. 目录重命名

- [x] 1.1 确认目标路径不存在且当前 Git 工作区状态已记录；验证：移动前 `/Users/leigod/雷神/plumbline` 不存在，`git status --short` 为 27 项。
- [x] 1.2 将 `/Users/leigod/雷神/AI工作流` 重命名为 `/Users/leigod/雷神/plumbline`；验证：旧路径不存在，新路径为 Git 仓库根目录。
- [x] 1.3 将当前会话工作目录移动到新路径；验证：会话工作目录已切换为 `/Users/leigod/雷神/plumbline`。

## 2. 文档同步

- [x] 2.1 更新 `README.md`、`CHANGELOG.md` 和 `PROJECT_PROFILE.md` 中“目录未重命名”的过期说明；验证：三份文档改为 `plumbline`，不再声称目录保持旧名。
- [x] 2.2 保留归档 change 原文；验证：历史归档未被改写。

## 3. 验证

- [x] 3.1 在新路径运行 `git status --short`、`openspec context`、`openspec doctor`、`./scripts/verify.sh` 和 strict validation；验证证据：Git 改动数量保持 27 项，`openspec context` 显示 `plumbline`，校验命令退出码 0。
- [x] 3.2 用户确认新路径、文档同步和未提交状态；验证证据：2026-11-12 用户选择“验收并归档”，接受新路径和 27 项未提交改动无丢失。
- [x] 3.3 用户验收后归档 change 并更新 README 最近归档；验证：归档目录存在，README 不再把该 change 列为活跃项。

## 交付记录

- 影响仓库：本地工作区路径。
- 实际改动：工作目录从 `/Users/leigod/雷神/AI工作流` 重命名为 `/Users/leigod/雷神/plumbline`；更新 `README.md`、`CHANGELOG.md` 和 `PROJECT_PROFILE.md` 的目录说明；新增本 change 工件。
- 提交 / Patch：未提交 Git；未打 tag，未配置远程。
- 自动验证命令与结果：`git status --short` 移动前后均为 27 项；`openspec context` 显示 `plumbline`；`openspec doctor` 退出码 0；`./scripts/verify.sh` 输出 `ALL_CHECKS_PASSED`；`openspec validate rename-workspace-to-plumbline --strict`、`openspec validate --specs` 通过。
- 人工验收：2026-11-12 用户选择“验收并归档”，接受新路径、文档同步和 27 项未提交改动无丢失。
- 未覆盖项与残留风险：归档 change 保留“当时未重命名目录”的历史事实；外部脚本或书签若引用旧绝对路径需要人工更新；Git 未提交内容随目录移动保留，但未做备份提交。
- 后续事项：本 change 已归档；提交和打 tag 需另行授权。
