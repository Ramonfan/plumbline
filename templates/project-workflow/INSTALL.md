# 可迁移项目工作流安装指南

本模板采用“通用核心 + 项目配置层”。安装目标不是把示例原样复制，而是让目标项目获得一致的需求、实施、验证和归档闭环，同时保留自己的技术栈与业务规则。

## 交付文件映射

| 模板文件 | 目标项目文件 | 处理方式 |
|---|---|---|
| `AGENTS.template.md` | `AGENTS.md` | 新项目复制并改名；已有文件逐段合并 |
| `CLAUDE.template.md` | `CLAUDE.md` | 新项目复制；已有文件逐段合并。Claude Code 入口，只导入 `AGENTS.md` 和 `PROJECT_PROFILE.md` |
| `PROJECT_PROFILE.template.md` | `PROJECT_PROFILE.md` | 复制、填写全部必填项并移除占位符 |
| `WORKFLOW_BASELINE.yaml` | 同路径 | 记录模板格式版本、工作流版本和权威项目名称；人工升级时用于比较来源基线 |
| `openSpec/config.template.yaml` | `openSpec/config.yaml` | 复制并替换项目变量；已有配置按字段合并 |
| `openSpec/specs/development-workflow/spec.md` | 同路径 | 作为首个长期主规格，冲突时合并现有规则 |
| `openSpec/README.md` | 同路径 | 工作流入口和命令索引 |
| `openSpec/weekly_report_template.md` | 同路径 | 周报模板 |
| `superPowers/implementation_checklist.md` | 同路径 | 实施阶段检查清单 |
| `.agents/skills/running-code-review-gate/` | 同路径 | Codex/通用 agent 的代码审查门禁 skill，规范源 |
| `.claude/skills/running-code-review-gate/` | 同路径 | Claude Code 的同一 skill 镜像，不含 `agents/openai.yaml` |
| `examples/ios/PROJECT_PROFILE.example.md` | 不直接复制 | 仅供 iOS 项目填写配置时参考 |
| `examples/coding-behavior-guidelines.md` | 不直接复制 | 供合并 `AGENTS.md`、培训和审查时参考 |

## Agent 入口

模板提供两个 agent 入口，并共享一份项目配置事实源：

- `AGENTS.md`：Codex 和通用 agent 直接读取，包含完整流程规则。
- `CLAUDE.md`：Claude Code 读取，只包含 `@AGENTS.md` 和 `@PROJECT_PROFILE.md` 导入，不复制规则。
- `PROJECT_PROFILE.md`：项目边界、命令和验收配置的事实源，由两个入口共同引用。

不要把 `AGENTS.md` 的内容复制到 `CLAUDE.md`；Claude 专属补充写在导入之后。Claude Code 会话中可用 `/context all`（可用版本也可使用 `/memory`）确认 `CLAUDE.md` 和导入文件已加载。

子目录中有更细的 `AGENTS.md` 时，模板安装后的根 `CLAUDE.md` 会让 Claude Code 默认只读 `CLAUDE.md` 链路，子目录 `AGENTS.md` 不会自动叠加。可在 `/config` 把 **Project instructions** 设为 `claude-md-and-agents-md`，或在子目录增加只导入同目录 `AGENTS.md` 的薄 `CLAUDE.md`。较新版本的 Claude Code（v2.1.277 及以上）在完全缺少 `CLAUDE.md` 和 `CLAUDE.local.md` 时会直接读取根 `AGENTS.md`；更细的目录加载行为以目标版本和 `/context all` 结果为准。旧版本和受限会话仍需本模板提供的导入入口。

## 代码审查门禁 skill

模板附带可自动发现的 `running-code-review-gate` skill，同时安装到两个入口：

- `.agents/skills/running-code-review-gate/`：规范源，Codex 和通用 agent 读取；
- `.claude/skills/running-code-review-gate/`：Claude Code 镜像，内容与规范源一致，不包含 `agents/openai.yaml`。

skill 在准备提交、合并或声明实现完成时运行，负责定位 OpenSpec change、确认实际仓库和精确差异、读取项目专属规则、选择本地或独立审查、汇总 findings 并给出 `Ready: Yes/No`。它默认只读，不修改实现、不执行 Git 写操作，也不把审查通过当成用户验收。

项目专属检查点不进入通用 skill：技术栈、仓库边界、命令和强制独立审查条件写入 `PROJECT_PROFILE.md` 与根规则，领域规则写入对应主规格。安装后请确认这些字段已填写，否则 skill 只能得到不完整结论。

## 安装前检查

在目标项目根目录确认：

```bash
pwd
find . -maxdepth 2 \( -name AGENTS.md -o -name CLAUDE.md -o -name PROJECT_PROFILE.md -o -name WORKFLOW_BASELINE.yaml -o -name config.yaml \) -print
find . -maxdepth 3 -type d -name .git -print
```

如果已经存在 `AGENTS.md`、`CLAUDE.md`、`PROJECT_PROFILE.md`、`openSpec/`、`superPowers/`、CI 或构建规则，进入“已有治理文件的项目”流程。不要直接复制覆盖。

## 新项目安装

### 1. 复制目录结构

从模板包逐项复制，并按上方映射移除 `.template` 后缀。复制后应得到：

```text
<project-root>/
├── AGENTS.md
├── CLAUDE.md
├── PROJECT_PROFILE.md
├── WORKFLOW_BASELINE.yaml
├── .agents/skills/running-code-review-gate/
│   ├── SKILL.md
│   ├── references/review-contract.md
│   ├── references/reviewer-brief.md
│   └── agents/openai.yaml
├── .claude/skills/running-code-review-gate/
│   ├── SKILL.md
│   └── references/
├── openSpec/
│   ├── config.yaml
│   ├── README.md
│   ├── weekly_report_template.md
│   ├── specs/development-workflow/spec.md
│   └── changes/archive/
└── superPowers/implementation_checklist.md
```

如果本模板来自独立 **Plumbline（准绳）** 项目，可以先使用安全安装脚本预览：

```bash
./scripts/install.sh --target /path/to/project --dry-run
```

确认无冲突后移除 `--dry-run` 执行安装。脚本不提供覆盖参数；存在任一同名文件时会列出全部冲突、以状态 `2` 在写入前停止。若计划目标的既有父路径是符号链接或非目录对象，脚本会列出不安全路径、以状态 `73` 停止，避免文件被写到目标根目录之外。也可以在人工核实路径后逐个合并文件。

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
rg -n '\{\{[A-Z0-9_]+\}\}' AGENTS.md CLAUDE.md PROJECT_PROFILE.md openSpec superPowers
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
- 从 `CLAUDE.template.md` 合并 Claude Code 入口；已有 `CLAUDE.md` 时保留本地 Claude 专属内容，只补充缺失的 `@AGENTS.md` 和 `@PROJECT_PROFILE.md` 导入，不复制 `AGENTS.md`。
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
test -f CLAUDE.md
test -f PROJECT_PROFILE.md
test -f WORKFLOW_BASELINE.yaml
test -f openSpec/config.yaml
test -f openSpec/README.md
test -f openSpec/weekly_report_template.md
test -f openSpec/specs/development-workflow/spec.md
test -f superPowers/implementation_checklist.md
test -f .agents/skills/running-code-review-gate/SKILL.md
test -f .agents/skills/running-code-review-gate/references/review-contract.md
test -f .agents/skills/running-code-review-gate/references/reviewer-brief.md
test -f .agents/skills/running-code-review-gate/agents/openai.yaml
test -f .claude/skills/running-code-review-gate/SKILL.md
test -f .claude/skills/running-code-review-gate/references/review-contract.md
test -f .claude/skills/running-code-review-gate/references/reviewer-brief.md
rg -F -q '@AGENTS.md' CLAUDE.md
rg -F -q '@PROJECT_PROFILE.md' CLAUDE.md
```

两棵 skill 目录除 `agents/openai.yaml` 外必须逐字节一致；`.claude/` 侧不包含该文件。

### 占位符

```bash
rg -n '\{\{[A-Z0-9_]+\}\}' AGENTS.md CLAUDE.md PROJECT_PROFILE.md openSpec superPowers
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

## 升级已接入项目

升级不是重新安装，也不是整目录覆盖。安装器遇到同名文件会零写入停止，因此升级必须由消费项目自己的 OpenSpec change 驱动：先看清差异，再人工合并，最后真实验证和重新基线。

权威项目和消费项目的职责分开：

- 权威项目提供版本化模板快照、`CHANGELOG.md` 的 Upgrade 记录和只读比较脚本 `scripts/compare.sh`。
- 消费项目负责创建 change、取得旧基线快照、执行合并、运行真实项目验证并更新基线。
- 比较脚本只输出报告，不写入任何目录；不存在自动升级或自动提交。

### 1. 确认版本和范围

1. 读取消费项目根目录 `WORKFLOW_BASELINE.yaml` 的 `workflow_version`，这是当前接入基线。
2. 读取 `PROJECT_PROFILE.md` 中记录的权威项目名称、路径或仓库，确认来源没有被替换。
3. 读取权威项目 `CHANGELOG.md`，确认目标版本及其 Upgrade 记录：新增、修改、删除的文件，占位符变化，安装行为变化，是否需要迁移。
4. 选定一个明确目标版本，不要使用“最新版本”这类移动目标。

消费项目应在自己的仓库创建 change，例如 `adopt-workflow-0.1.0-dev.5`，并在 proposal 中记录：

- 旧基线版本和目标版本；
- 本次纳入的模板变更范围；
- 明确不在本次升级内的内容；
- 需要保留的本地规则和已知冲突点；
- 验证方式、验收人和回滚点。

### 2. 准备版本快照并取得三方输入

`compare.sh` 的 `theirs` 固定取自权威项目当前 `templates/project-workflow/`，因此运行前必须让工作区处于目标版本：

1. 在权威项目检出目标版本的 Git tag 或明确提交。
2. 确认 `git status --short -- templates/project-workflow` 为空；模板目录有未提交改动时，该工作区只能视为未发布内容，不得作为升级目标。
3. 确认权威项目 `WORKFLOW_BASELINE.yaml`、`CHANGELOG.md` 和检出内容指向同一版本。
4. 为旧基线取得独立快照，例如 `git archive <old-tag> templates/project-workflow | tar -x -C <snapshot-dir>` 或从对应提交导出的目录副本。

每个可接入版本都必须有可追溯快照。权威项目未提交、未打 tag 或模板目录不干净时，消费项目应记录“目标版本不可追溯”并停止升级，不要用漂移中的工作区代替正式版本。

逐文件比较需要三份输入：

| 输入 | 内容 | 来源 |
|---|---|---|
| base | 消费项目旧基线对应的模板快照 | 权威项目旧版本 tag、提交或归档快照 |
| ours | 消费项目当前文件 | 消费项目工作区 |
| theirs | 目标版本的权威模板 | 已检出目标版本的权威工作区 |

获取 base 时优先使用版本标签或明确提交，不要用“当前模板”代替旧基线。权威项目没有旧基线可追溯快照时，只能做两方比较，并在 change 中记录“历史基线未知”及人工审查结论。

### 3. 运行只读比较

在权威项目根目录执行：

```bash
./scripts/compare.sh --target /path/to/consumer \
  --base /path/to/authority-at-old-baseline
```

省略 `--base` 时执行两方比较：只能判断目标文件与当前模板是否相同，不能区分本地修改和模板修改。

脚本输出每个映射文件的状态和备注：

| 状态 | 含义 | 建议动作 |
|---|---|---|
| `unchanged` | 三方一致，或两方比较下目标与模板一致 | 跳过 |
| `ours-only` | 只有消费项目相对旧基线改过 | 保留本地内容，确认是否需要叠加模板语义 |
| `theirs-only` | 只有模板相对旧基线改过 | 人工合并模板增量 |
| `both-changed` | 两边都改过且内容仍不同 | 三方合并，记录决策依据 |
| `converged` | 两边都改过但目标已等于当前模板 | 确认后跳过 |
| `missing` | 目标缺少映射文件 | 判断是否补装或说明不适用 |
| `differs` | 无 base 时目标与模板不同 | 人工审查，补齐旧基线快照或逐文件判断 |
| `base-missing` | 旧基线快照缺少该文件 | 确认快照是否完整，再补比较 |
| `local-extra` | 目标 skill 目录包含模板没有的文件 | 确认是否项目专属扩展，记录保留依据并纳入后续验证 |

`AGENTS.md`、`CLAUDE.md`、`PROJECT_PROFILE.md` 和 `openSpec/config.yaml` 始终附带 `manual: project-specific`。这些文件包含项目专属内容，任何状态都必须人工处理，不能直接取模板。`WORKFLOW_BASELINE.yaml` 附带 `metadata: update after merge`，只能在合并和验证完成后更新。

报告头部会打印 `Target baseline`、`Template baseline`；提供 base 时还会打印 `Base baseline`。三者应分别等于消费项目记录的旧基线、目标版本和旧基线快照版本；不一致时先修正输入，不要继续合并。

比较脚本按当前安装映射遍历文件。模板侧删除或重命名文件不会自动出现在报告中；升级时必须同时核对权威 `CHANGELOG.md` 的删除/重命名记录，并人工检查目标项目是否残留孤儿文件。

比较脚本发现差异时仍以成功状态退出，因为差异是正常结果而不是脚本故障。参数错误返回 `64`，目标目录、base 快照或映射路径不是可读普通文件时返回 `66`，模板源缺失返回 `70`。

### 4. 逐文件合并

按状态处理，不按目录批量复制：

- `theirs-only`：只把模板增量落到目标文件，保留项目已有的章节结构和本地措辞。
- `both-changed`：先读 base，再读 ours 和 theirs，形成三方合并；在 change 的 tasks 或 design 中记录取舍理由。
- `ours-only` / `converged`：确认模板语义是否已被本地规则覆盖，避免重复表达同一约束。
- `missing`：确认该文件在目标项目是否适用；补装时仍然人工合并，不能直接复制覆盖相邻配置。
- 项目专属文件：合并规则而不是复制文件，优先保留项目现有仓库、命令、技术栈、权限和业务规则。

通用流程变化更新 `AGENTS.md`、`CLAUDE.md`（仅导入和 Claude 专属补充）、`development-workflow` 和必要的 OpenSpec 配置规则；技术栈、命令、目录和环境变化只更新 `PROJECT_PROFILE.md`；领域行为变化通过对应 OpenSpec change 更新长期主规格。

代码审查门禁 skill 属于新增目录映射。升级时把 `.agents/skills/running-code-review-gate/` 并入目标，再复制为 `.claude/skills/running-code-review-gate/`（去掉 `agents/openai.yaml`），两边 `SKILL.md` 和 `references/` 必须逐字节一致；项目专属检查点写入 `PROJECT_PROFILE.md` 和根规则，不修改通用 skill 正文。

### 5. 验证与验收

合并完成后依次执行：

1. 消费项目自己的结构检查：文件存在、占位符已替换、Markdown 围栏闭合、YAML 可解析、两棵 skill 目录内容一致且 frontmatter 合法、OpenSpec strict validation 通过。
2. 消费项目 `PROJECT_PROFILE.md` 定义的真实命令：测试、静态检查、构建、迁移或部署验证。
3. 受影响的流程试运行：至少覆盖一次 L1 change 的 proposal、spec、tasks、证据回写和归档链路。
4. 用户结构验收：确认入口导入、门禁、目录和命令与项目实际一致。

结构校验不能证明业务实现或运行时正确；两层验证都要有实际输出和退出码。

### 6. 重新基线与归档

只有合并完成、真实项目验证通过、用户完成验收后，才：

1. 更新消费项目 `WORKFLOW_BASELINE.yaml` 的 `workflow_version` 和来源信息。
2. 更新 `PROJECT_PROFILE.md` 记录的权威来源名称、接入基线、关联权威 change 和同步状态。权威项目改名时，必须在这里人工把旧名称更新为新名称。
3. 把比较报告、合并决策、验证命令和退出码回写消费项目 change 的 tasks。
4. 同步受影响的长期主规格并归档该 change。

不要在合并前更新基线，否则下一次比较会错把未合并的本地状态当成目标版本。

### 7. 回滚

升级前先确认回滚点：

- Git 仓库：记录升级前提交或建立专用分支，回滚使用 `git revert` 或恢复该提交。
- 非 Git 仓库：在升级前保存目标文件和 OpenSpec 目录的安全副本。
- 比较脚本不提供回滚能力，因为它不写入任何文件。

回滚后把消费项目基线恢复到实际内容对应的版本，并重新记录未解决项。不要用覆盖当前模板的方式“回滚”到新版本以外的状态。

## 升级检查清单

- [ ] 已读取旧基线、`PROJECT_PROFILE.md` 来源和权威 `CHANGELOG.md`。
- [ ] 消费项目 change 已声明旧基线、目标版本、范围和非目标。
- [ ] base、ours、theirs 三方输入可追溯，base 确实是旧基线快照。
- [ ] 已运行 `compare.sh` 并把报告写入 change。
- [ ] 项目专属文件全部人工合并，未直接取模板。
- [ ] `.agents/skills/` 与 `.claude/skills/` 的审查 skill 已人工合并，两边内容一致且项目专属规则留在 `PROJECT_PROFILE.md`。
- [ ] 结构验证和真实项目验证均有实际输出与退出码。
- [ ] 用户结构验收已完成。
- [ ] 权威项目改名时，`PROJECT_PROFILE.md` 记录的权威来源名称已人工更新。
- [ ] 基线只在验证和验收后更新，并已归档 change。
