# AI 工作流

一个可独立维护、可安装到其他项目的 OpenSpec + Superpowers + Codex 工作流项目。

## 核心能力

- L0～L3 任务分级。
- 需求、方案和交付三个用户门禁。
- OpenSpec 作为需求、规格、任务、证据和归档的唯一事实源。
- Superpowers 按风险参与调试、测试、审查和完成前验证。
- 编码行为准则：先列假设、最小实现、手术式改动、孤儿代码边界、改动可追溯和可验证目标。
- 通用核心与 `PROJECT_PROFILE.md` 项目配置分层。
- 机器可读的 `WORKFLOW_BASELINE.yaml`，支持消费项目记录接入版本并人工比较升级。
- 安全安装：预览、无冲突复制、发现冲突、符号链接或非目录父路径时零写入。
- 模板自身和目标项目实际验证分层。
- 消费项目通用改进通过关联 OpenSpec change 回流，专属规则保留在本地。

## 项目结构

```text
AI工作流/
├── AGENTS.md
├── PROJECT_PROFILE.md
├── README.md
├── CHANGELOG.md
├── openSpec/
├── templates/project-workflow/
└── scripts/
    ├── install.sh
    └── verify.sh
```

## 安装到其他项目

先预览：

```bash
./scripts/install.sh --target /path/to/project --dry-run
```

确认目标目录没有冲突后安装：

```bash
./scripts/install.sh --target /path/to/project
```

脚本不会覆盖同名文件，也不会沿目标目录内部的符号链接或非目录父路径写入。安装结果包含 `WORKFLOW_BASELINE.yaml`；目标项目应把其中的 `workflow_version` 记录到自己的 `PROJECT_PROFILE.md`。已有治理文件时，按 `templates/project-workflow/INSTALL.md` 手工比较和合并。

冲突和不安全路径会在复制前零写入退出；实际复制阶段不是事务性的。如果磁盘、权限或读取错误发生在复制过程中，目标可能留下部分新增文件，必须检查实际目录树后再重试或人工处理。

## 验证本项目

```bash
./scripts/verify.sh
```

校验依赖 `bash`、`find`、`rg`、`ruby` 和 OpenSpec CLI；缺少任一命令时会在写入临时目录前以状态 `69` 退出并输出缺少的命令。校验使用 `${TMPDIR:-/tmp}` 创建受控临时目录，覆盖模板文件、基线字段、Markdown/YAML、占位符范围、技术示例隔离、安装预览、部分冲突、重复安装、符号链接父路径拒绝和 OpenSpec 长期主规格。

## 维护方式

1. 通过 `openSpec/changes/` 创建或定位 change。
2. 更新模板、脚本和必要的长期主规格。
3. 运行 `scripts/verify.sh` 并回写证据。
4. 更新 `CHANGELOG.md`。
5. 用户结构验收后同步规格并归档。

## 消费项目改进回流

1. 消费项目先判断改进属于通用流程、技术栈专属还是业务专属。
2. 通用改进在两端分别创建或定位 OpenSpec change，并互相记录名称与同步状态。
3. 本项目审查适用边界，更新模板、长期主规格、验证和变更日志；消费项目人工合并后复验。
4. 技术栈专属规则只进入消费项目配置或本项目的明确示例；业务专属规则只留在消费项目。
5. 流程 change 交付前必须记录“已同步”或“无需同步及原因”；不运行自动跨项目覆盖。

详细规则见 [AGENTS.md](./AGENTS.md)，项目边界见 [PROJECT_PROFILE.md](./PROJECT_PROFILE.md)，模板使用说明见 [INSTALL.md](./templates/project-workflow/INSTALL.md)。
