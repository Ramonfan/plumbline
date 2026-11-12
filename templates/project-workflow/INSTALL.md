# 可迁移项目工作流安装指南

本模板采用“通用核心 + 项目配置层”。安装目标不是把示例原样复制，而是让目标项目获得一致的需求、实施、验证和归档闭环，同时保留自己的技术栈与业务规则。

## 交付文件映射

| 模板文件 | 目标项目文件 | 处理方式 |
|---|---|---|
| `AGENTS.template.md` | `AGENTS.md` | 新项目复制并改名；已有文件逐段合并 |
| `PROJECT_PROFILE.template.md` | `PROJECT_PROFILE.md` | 复制、填写全部必填项并移除占位符 |
| `WORKFLOW_BASELINE.yaml` | 同路径 | 记录模板格式版本、工作流版本和权威项目名称；人工升级时用于比较来源基线 |
| `openSpec/config.template.yaml` | `openSpec/config.yaml` | 复制并替换项目变量；已有配置按字段合并 |
| `openSpec/specs/development-workflow/spec.md` | 同路径 | 作为首个长期主规格，冲突时合并现有规则 |
| `openSpec/README.md` | 同路径 | 工作流入口和命令索引 |
| `openSpec/weekly_report_template.md` | 同路径 | 周报模板 |
| `superPowers/implementation_checklist.md` | 同路径 | 实施阶段检查清单 |
| `examples/ios/PROJECT_PROFILE.example.md` | 不直接复制 | 仅供 iOS 项目填写配置时参考 |
| `examples/coding-behavior-guidelines.md` | 不直接复制 | 供合并 `AGENTS.md`、培训和审查时参考 |

## 安装前检查

在目标项目根目录确认：

```bash
pwd
find . -maxdepth 2 \( -name AGENTS.md -o -name PROJECT_PROFILE.md -o -name WORKFLOW_BASELINE.yaml -o -name config.yaml \) -print
find . -maxdepth 3 -type d -name .git -print
```

如果已经存在 `AGENTS.md`、`PROJECT_PROFILE.md`、`openSpec/`、`superPowers/`、CI 或构建规则，进入“已有治理文件的项目”流程。不要直接复制覆盖。

## 新项目安装

### 1. 复制目录结构

从模板包逐项复制，并按上方映射移除 `.template` 后缀。复制后应得到：

```text
<project-root>/
├── AGENTS.md
├── PROJECT_PROFILE.md
├── WORKFLOW_BASELINE.yaml
├── openSpec/
│   ├── config.yaml
│   ├── README.md
│   ├── weekly_report_template.md
│   ├── specs/development-workflow/spec.md
│   └── changes/archive/
└── superPowers/implementation_checklist.md
```

如果本模板来自独立“AI 工作流”项目，可以先使用安全安装脚本预览：

```bash
./scripts/install.sh --target /path/to/project --dry-run
```

确认无冲突后移除 `--dry-run` 执行安装。脚本不提供覆盖参数；存在任一同名文件时会列出全部冲突、以状态 `2` 在写入前停止。若计划目标的既有父路径是符号链接或非目录对象，脚本会列出不安全路径、以状态 `73` 停止，避免把文件写到目标根目录之外或在复制途中部分失败。也可以在人工核实路径后逐个合并文件。

上述零写入保证适用于安装前能够发现的冲突和路径问题。文件复制本身不是事务操作；如果磁盘空间、权限或源文件读取在复制阶段发生异常，目标可能保留部分新增文件。此时不要直接重跑，先检查实际目录树，删除或合并本次新增内容后再决定后续处理。

### 2. 填写项目配置

完整填写 `PROJECT_PROFILE.md`：

- 项目身份与工作区根目录；
- 每个独立 Git 仓库及职责；
- 源码、测试、配置、文档、生成产物和依赖目录；
- 安装、格式、静态检查、测试、构建、运行和迁移命令；
- 可用环境、人工验收责任人与验收矩阵；
- 代码约定、领域主规格、禁止操作、发布和回滚流程。

读取 `WORKFLOW_BASELINE.yaml` 的 `workflow_version`，填入“当前接入版本、标签或基线”。基线文件用于标识模板来源，不代表目标项目已经完成变量替换、真实构建或人工验收。

没有对应能力时填写“不适用”及原因，不要留空。

### 3. 替换 OpenSpec 变量

在 `openSpec/config.yaml` 中至少替换：

- `DOCUMENT_LANGUAGE`
- `PROJECT_NAME`
- `WORKSPACE_ROOT`

检查所有未替换变量：

```bash
rg -n '\{\{[A-Z0-9_]+\}\}' AGENTS.md PROJECT_PROFILE.md openSpec superPowers
```

命令无输出后，才可以认为变量替换完成。

### 4. 建立项目领域规格

保留 `development-workflow`，再按项目真实高风险领域建立少量长期主规格，例如：

- 工程与仓库治理；
- 安全与权限；
- 数据契约与迁移；
- UI 或 API 治理；
- 运行时生命周期；
- 发布与可观测性。

长期主规格描述稳定能力边界；单次需求、临时修复和验收证据放在 change 中。

### 5. 初始化并检查 OpenSpec

根据已安装的 OpenSpec CLI 版本执行：

```bash
openspec context
openspec doctor
openspec list
```

如目标版本需要初始化命令，先按该版本官方说明完成初始化，再合并模板文件。不要用旧版本示例覆盖新版本生成结构。

## 已有治理文件的项目

### 1. 保存基线

先记录目标项目现状：

```bash
git status --short
git diff -- AGENTS.md PROJECT_PROFILE.md WORKFLOW_BASELINE.yaml openSpec superPowers
```

如果根目录不是 Git 仓库，在实际管理这些文件的仓库执行；若文件不受 Git 管理，使用安全副本或外部差异工具。

### 2. 按职责合并

- 从 `AGENTS.template.md` 合并职责、分级、门禁、编码行为准则、执行顺序、工作区保护和交付规则。
- 把项目专属内容迁移或汇总到 `PROJECT_PROFILE.md`，不要删除仍有效的本地约束。
- 合并 `openSpec/config.yaml` 时保留目标项目 schema、store 和版本特有字段，只补充缺失的 context 与 rules。
- 对现有长期规格逐项比较；语义一致时保留原文件，不为了目录一致重复创建。
- Superpowers 清单只补充执行阶段缺失项，不迁移需求、设计和任务事实源。
- 比较权威模板和消费项目的 `WORKFLOW_BASELINE.yaml`；历史项目缺少该文件时，先确认实际来源。无法确认时记录“历史基线未知”，完成逐文件比较后再补入当前基线，不得把最新版本直接标成历史版本。

### 3. 解决冲突

规则优先级：用户当前明确指令 > 更具体目录规则 > 目标项目现有且仍有效的规则 > 模板默认值。

遇到会改变项目行为、权限、安全、发布或验收口径的冲突，创建独立 OpenSpec change，经用户确认后再调整；不要在安装过程中静默覆盖。

## 安装结构验证

### 文件清单

```bash
test -f AGENTS.md
test -f PROJECT_PROFILE.md
test -f WORKFLOW_BASELINE.yaml
test -f openSpec/config.yaml
test -f openSpec/README.md
test -f openSpec/weekly_report_template.md
test -f openSpec/specs/development-workflow/spec.md
test -f superPowers/implementation_checklist.md
```

### 占位符

```bash
rg -n '\{\{[A-Z0-9_]+\}\}' AGENTS.md PROJECT_PROFILE.md openSpec superPowers
```

预期：无输出。

### YAML

使用项目已有 YAML 工具；例如安装了 Ruby 时：

```bash
ruby -e 'require "yaml"; YAML.load_file("openSpec/config.yaml"); YAML.load_file("WORKFLOW_BASELINE.yaml"); puts "YAML_OK"'
```

### OpenSpec

```bash
openspec context
openspec doctor
openspec validate development-workflow --type spec --strict
```

不同 CLI 版本的参数可能变化，以当前 `openspec --help` 和官方文档为准。

## 流程试运行

安装结构验证完成后，用两个低风险任务验证流程：

1. **L0**：让执行者只读分析一个局部模块，确认没有创建 change 或修改文件。
2. **L1**：创建一个不影响生产的小型文档或配置 change，确认 proposal、spec、tasks、方案门禁、证据回写和用户验收后归档链路完整。

试运行失败时优先修正 `PROJECT_PROFILE.md` 的仓库、命令和验收信息，不要修改通用门禁来绕过问题。

## 两层验证不能混用

### 模板或安装结构验证

只能证明：文件存在、变量已替换、格式可解析、OpenSpec 结构有效。

### 目标项目实际验证

必须执行 `PROJECT_PROFILE.md` 中定义的真实命令，包括相关测试、静态检查、构建、迁移、部署或人工验收。结构校验不能证明业务实现、运行时或发布结果正确。

## 升级与维护

- 通用流程变化更新 `AGENTS.md`、`development-workflow` 和必要的 OpenSpec 配置规则。
- 技术栈、命令、目录和环境变化只更新 `PROJECT_PROFILE.md`。
- 领域行为变化通过对应 OpenSpec change 更新长期主规格。
- 升级模板前先比较版本差异；已有项目不做整目录覆盖。
- 升级前比较两端 `WORKFLOW_BASELINE.yaml` 和 `CHANGELOG.md`；合并完成并验证后，才把消费项目记录的接入基线更新为新版本。
