# Plumbline（准绳）

一套可以安装到任意代码项目的研发工作流模板：用 **OpenSpec** 管理需求、规格、任务和证据，用 **Superpowers** 承担测试、调试、审查和完成前验证，并通过明确的任务分级和用户门禁控制流程深度。

**Plumbline** 是建筑中的铅垂线，用来判断是否偏离基准。中文名「准绳」表达同一件事：让 AI 参与的研发始终对齐规格、证据和验收标准。

Codex、Claude Code 和通用 agent 共用同一份规则事实源：

- **Codex / 通用 agent**：读取根目录 `AGENTS.md`。
- **Claude Code**：读取根目录 `CLAUDE.md`，由它导入 `AGENTS.md` 和 `PROJECT_PROFILE.md`。

## 这是什么

这不是一个业务框架，也不是一套自动生成代码的工具。它解决的是项目协作中的流程问题：

- 需求、设计、任务和验证证据散落在聊天记录里，无法追溯；
- 小事走重流程，大事反而缺少审查和验收；
- AI 执行者静默假设、顺手重构、扩大范围，最后没人能判断改了什么；
- 换一个 agent（例如从 Codex 换成 Claude Code）就要复制一套规则，随后两份规则开始漂移；
- 安装模板时覆盖了目标项目已有规则，或者写到符号链接指向的目录之外。

本项目把这些问题收敛成一套可复制、可验证、不会覆盖目标文件的治理模板。

## 适合谁

- 希望让 AI 参与真实项目，但需要需求、设计、任务和验收证据可追溯的团队。
- 已有 `AGENTS.md` 或 `CLAUDE.md`，希望统一到一套规则源的团队。
- 需要把同一套工作流安装到多个项目，同时保留各项目技术栈、命令和业务规则的团队。
- 使用 Codex、Claude Code 或其他支持 `AGENTS.md` 的 agent 的个人开发者。

**不适合**：

- 只需要一次性脚本或一次性问答的场景。
- 希望用模板替代真实测试、构建、部署或人工验收的场景。
- 希望安装器自动覆盖已有治理文件的场景；本项目在冲突时会零写入停止。

## 支持的 agent

| Agent | 入口 | 说明 |
|---|---|---|
| Codex | `AGENTS.md` | 直接读取完整项目规则 |
| Claude Code | `CLAUDE.md` | 通过 `@AGENTS.md` 和 `@PROJECT_PROFILE.md` 导入同一规则源 |
| 其他支持 `AGENTS.md` 的 agent | `AGENTS.md` | 不需要 `CLAUDE.md` |
| 其他支持自定义规则的 agent | 按同一模式增加薄入口 | 只导入，不复制规则 |

`CLAUDE.md` 不维护第二套规则。Claude 专属补充写在导入之后；任务分级、门禁、编码行为准则、工作区保护和交付记录仍只维护在 `AGENTS.md`。

较新版本的 Claude Code（v2.1.277 及以上）在完全缺少 `CLAUDE.md` 和 `CLAUDE.local.md` 时，也会把根 `AGENTS.md` 当作项目指令读取。本项目仍提供显式 `CLAUDE.md`，用于旧版本、受限会话和 Claude 专属补充的稳定入口。

> 技能类扩展需要在各 agent 的项目技能目录中提供入口。模板已交付 `running-code-review-gate`：`.agents/skills/` 为规范源，`.claude/skills/` 为 Claude Code 镜像，验证脚本校验两边内容逐字节一致。

### 子目录规则

- **Codex**：会沿目录向上扫描 `AGENTS.md`，根规则和子目录规则都会生效。
- **Claude Code**：模板安装后有根 `CLAUDE.md`，默认 **Project instructions** 为 `claude-md-or-agents-md`，此时只读 `CLAUDE.md` 链路，子目录 `AGENTS.md` 不会自动叠加。需要子目录规则时，任选一种：
  - 在 `/config` 把 **Project instructions** 设为 `claude-md-and-agents-md`，让每个目录的 `CLAUDE.md` 和 `AGENTS.md` 一起加载；
  - 在子目录放一个只导入同目录 `AGENTS.md` 的薄 `CLAUDE.md`。

如果项目完全没有根 `CLAUDE.md`，Claude Code v2.1.277 及以上会直接读取根 `AGENTS.md`；更细的目录加载行为以目标版本和 `/context all` 结果为准。不要依赖两个 agent 的加载时机完全一致。

## 核心概念

### OpenSpec 是唯一事实源

需求、可观察行为规格、技术设计、任务进度、验收证据和归档结果都放在 `openSpec/`：

```text
openSpec/
├── config.yaml
├── specs/                 # 已生效的长期主规格
└── changes/
    ├── <active-change>/   # 当前需求、设计、任务和证据
    └── archive/           # 验收并同步主规格后的历史 change
```

Superpowers 和 agent 不创建第二份需求、设计、任务或归档事实源。

### 任务按风险分级

| 等级 | 适用场景 | 工件深度 |
|---|---|---|
| L0 | 只读分析、解释、梳理、审查 | 不创建 change，不修改实现 |
| L1 | 范围明确、低风险的局部修复 | 精简 proposal、spec、tasks |
| L2 | 常规功能、接口、UI、数据或跨文件行为变化 | 完整 proposal、specs、design、tasks |
| L3 | 核心链路、架构、安全边界或显著公共契约变化 | 完整工件 + 影响分析、分阶段任务、回滚策略和验收矩阵 |

跨仓、跨文件和高连接度是风险信号，不单独决定等级。实施中发现范围扩大时只能升级等级，不能为了减少流程而降级。

### 三个门禁

1. **需求门禁**：目标、非目标、影响范围和验收标准确认后，才能完成 proposal 和行为规格。
2. **方案门禁**：设计、任务、兼容策略、风险和验证方式确认，用户明确表达“可以、落地、执行”或同等意图后，才能修改实现。
3. **交付门禁**：代码审查和自动验证通过后，由用户完成项目要求的业务、交互、视觉、部署或运行环境验收；用户确认前不得归档。

### Superpowers 的职责边界

Superpowers 只参与测试驱动开发、系统化调试、代码审查和完成前验证。它不管理需求、设计、任务状态或归档。

### 代码审查门禁

模板附带 `running-code-review-gate` skill，同时交付给 Codex/通用 agent（`.agents/skills/`）和 Claude Code（`.claude/skills/`）。它在准备提交、合并或声明实现完成时运行：

- 定位当前 change、任务等级、方案门禁和受影响仓库；
- 逐仓库读取精确差异，区分本次改动、无关脏改和未跟踪文件；
- 按风险选择本地审查或未参与实现的独立 reviewer；
- 输出 Critical/Important/Minor findings 和 `Ready: Yes/No`；
- 默认只读，不修改实现、不执行 Git 写操作，也不替代用户验收。

项目专属检查点写入 `PROJECT_PROFILE.md` 和根规则，通用 skill 不含业务专名或技术栈硬编码。

### 编码行为准则

- 先列出影响方案的关键假设；会影响已确认契约或验收口径时先确认。
- 采用满足当前需求的最小实现，不为“以后可能用到”提前抽象。
- 只做当前 change 授权范围内的手术式改动。
- 只清理本次改动产生的孤儿代码；既有死代码只记录。
- 每个改动簇可追溯到当前 task；生成产物和锁文件需要说明来源、范围和验证方式。
- 把任务写成可验证目标，用实际命令或测试证明完成。
- 安全、权限、异步、迁移等风险要求的防御路径不属于过度设计。

## 快速开始

### 1. 准备依赖

本项目自身验证使用：

- `bash`
- `find`
- `rg`（ripgrep）
- `ruby`
- OpenSpec CLI（本项目验证使用 1.12.0）
- 常用 POSIX 工具：`sort`、`cksum`、`cmp`、`readlink`、`ln`、`mktemp`

检查：

```bash
for c in bash find rg ruby openspec sort cksum cmp readlink ln mktemp; do
  command -v "$c" >/dev/null || { echo "missing: $c"; exit 1; }
done
openspec --version
```

缺少任一依赖时，`./scripts/verify.sh` 会以状态 `69` 退出并输出缺少的命令。

### 2. 预览安装

把本项目安装到目标项目（目标目录必须已存在）：

```bash
./scripts/install.sh --target /path/to/project --dry-run
```

无冲突时预览只输出计划文件，不会写入目标目录。安装计划包含：

```text
AGENTS.md
CLAUDE.md
PROJECT_PROFILE.md
WORKFLOW_BASELINE.yaml
openSpec/config.yaml
openSpec/README.md
openSpec/weekly_report_template.md
openSpec/specs/development-workflow/spec.md
superPowers/implementation_checklist.md
.agents/skills/running-code-review-gate/
  SKILL.md
  agents/openai.yaml
  references/review-contract.md
  references/reviewer-brief.md
.claude/skills/running-code-review-gate/
  SKILL.md
  references/review-contract.md
  references/reviewer-brief.md
openSpec/changes/archive/ (directory)
```

### 3. 执行安装

确认目标项目没有同名文件后：

```bash
./scripts/install.sh --target /path/to/project
```

安装器不会覆盖同名文件。发现冲突时，它会列出全部冲突文件并以状态 `2` 在写入前停止；发现符号链接或非目录父路径时，会列出不安全路径并以状态 `73` 停止。dry-run 同样执行这些预检；存在冲突或不安全路径时，它只输出问题清单，不输出完整计划。

`install.sh` 退出码：

| 退出码 | 含义 |
|---|---|
| `0` | 安装成功、dry-run 完成，或使用 `--help` |
| `2` | 目标已有同名文件，零写入 |
| `64` | 缺少参数或存在未知参数 |
| `66` | 目标目录不存在或不是目录 |
| `70` | 模板源文件缺失 |
| `73` | 不安全父路径 |

复制阶段发生磁盘、权限或读取错误时，脚本按底层命令状态退出；此时不是零写入，按上文“安装过程中断”处理。

`verify.sh` 额外使用 `69` 表示缺少依赖，使用 `73` 表示临时目录不可用；其他非零退出表示结构或 OpenSpec 校验失败。

### 4. 填写项目配置

打开目标项目的 `PROJECT_PROFILE.md`，至少填写：

- 项目名称、目标、主要用户和文档语言；
- 每个 Git 仓库的路径、职责和是否允许直接修改；
- 源码、测试、配置、文档、生成产物和依赖目录；
- 安装、格式、静态检查、测试、构建、运行和迁移命令；
- 环境、人工验收责任人和验收矩阵；
- 长期领域规格、禁止操作、发布和回滚流程；
- 代码审查门禁的强制独立审查条件、项目专属检查点和审查证据位置。

把 `WORKFLOW_BASELINE.yaml` 中的 `workflow_version` 记录到“当前接入版本、标签或基线”。

然后替换 `openSpec/config.yaml` 中的项目变量，并确认无残留占位符：

```bash
rg -n '\{\{[A-Z0-9_]+\}\}' AGENTS.md CLAUDE.md PROJECT_PROFILE.md openSpec superPowers
```

命令无输出后，才认为变量替换完成。

### 5. 验证安装

```bash
test -f AGENTS.md
test -f CLAUDE.md
test -f PROJECT_PROFILE.md
test -f openSpec/config.yaml
test -f .agents/skills/running-code-review-gate/SKILL.md
test -f .claude/skills/running-code-review-gate/SKILL.md
rg -F -q '@AGENTS.md' CLAUDE.md
rg -F -q '@PROJECT_PROFILE.md' CLAUDE.md

openspec context
openspec doctor
openspec validate development-workflow --type spec --strict
```

结构验证只能证明文件存在、变量已替换、格式可解析和 OpenSpec 结构有效；真实业务验证必须执行 `PROJECT_PROFILE.md` 中定义的命令。

### 6. 跑第一个 change

先用一个 L0 任务确认 agent 不会创建 change，再用一个 L1 任务验证完整链路：

```text
定位或创建 change
→ proposal / spec / tasks
→ 用户通过方案门禁
→ 实现
→ 回写验证证据
→ 用户验收
→ 同步主规格并归档
```

## Agent 接入

### Codex

Codex 直接读取根目录 `AGENTS.md`。不需要额外创建文件。

### Claude Code

Claude Code 读取根目录 `CLAUDE.md`。模板中的内容是：

```markdown
# Claude Code 入口

本项目的流程规则事实源是根目录 `AGENTS.md`；项目边界、命令和验收配置的事实源是 `PROJECT_PROFILE.md`。本文件只负责导入，不重复维护规则；Claude 专属补充写在导入之后。

@AGENTS.md
@PROJECT_PROFILE.md
```

在 Claude Code 会话中运行 `/context all`（可用版本也可使用 `/memory`），确认 `CLAUDE.md` 出现在 Memory files 中，且导入的 `AGENTS.md` 和 `PROJECT_PROFILE.md` 已展开。

子目录存在更细 `AGENTS.md` 时，按上文“子目录规则”处理：默认只读 `CLAUDE.md` 链路，子目录 `AGENTS.md` 不会自动叠加；可把 Project instructions 设为 `claude-md-and-agents-md`，或在该子目录增加只导入同目录 `AGENTS.md` 的薄 `CLAUDE.md`。

如果项目已有 `CLAUDE.md`，安装器会把它视为冲突并零写入停止。人工合并时：

- 保留项目已有的 Claude 专属规则；
- 补充缺失的 `@AGENTS.md` 和 `@PROJECT_PROFILE.md` 导入；
- 不要把 `AGENTS.md` 的规则正文复制到 `CLAUDE.md`。

## 已有治理文件的项目

不要直接复制覆盖。按以下顺序处理：

1. 保存基线：`git status --short`、目标文件差异和现有 OpenSpec 结构。
2. 用 `./scripts/install.sh --target /path/to/project --dry-run` 执行预检；存在冲突时先读冲突清单，不要期待完整安装计划。
3. 如果存在冲突，按 `templates/project-workflow/INSTALL.md` 逐文件比较合并。
4. 优先保留目标项目现有的仓库、命令、技术栈和业务规则。
5. 合并 `AGENTS.md`、`CLAUDE.md`、`PROJECT_PROFILE.md`、OpenSpec 配置、长期主规格和 Superpowers 清单。
6. 完成变量替换后进行结构验证和真实项目验证。
7. 在目标项目记录本次接入的基线和关联的权威 change。

## 升级已接入项目

已经接入本工作流的项目不会自动跟随模板更新。升级必须走“版本化差异 + 人工合并 + 真实验证 + 重新基线”，不提供自动覆盖脚本。

### 1. 创建升级 change

在消费项目创建例如 `adopt-workflow-0.1.0-dev.5` 的 OpenSpec change，记录旧基线、目标版本、升级范围、明确不纳入的内容和回滚点。不要在没有 change 的情况下直接改治理文件。

### 2. 准备版本快照并取得三方输入

`compare.sh` 的 `theirs` 固定取权威项目当前 `templates/project-workflow/`。运行前必须：

1. 在权威项目检出目标版本的 Git tag 或明确提交。
2. 确认 `git status --short -- templates/project-workflow` 为空；模板目录不干净时只能视为未发布内容，不得作为升级目标。
3. 为旧基线导出独立快照，例如 `git archive <old-tag> templates/project-workflow | tar -x -C <snapshot-dir>`。

每个可接入版本都应有可追溯快照；权威项目未提交、未打 tag 或模板目录漂移时，消费项目应停止升级并记录“目标版本不可追溯”。

| 输入 | 含义 | 来源 |
|---|---|---|
| base | 旧基线对应的模板快照 | 权威项目旧版本 tag、提交或归档快照 |
| ours | 消费项目当前文件 | 消费项目工作区 |
| theirs | 目标版本模板 | 已检出目标版本的权威工作区 |

优先使用版本标签或明确提交作为 base；没有旧基线快照时只能降级为两方比较，并在 change 中记录“历史基线未知”。

### 3. 运行只读比较

在权威项目根目录执行：

```bash
./scripts/compare.sh --target /path/to/consumer \
  --base /path/to/authority-at-old-baseline
```

省略 `--base` 时只比较消费项目与当前模板，无法区分本地修改和模板修改。

| 状态 | 含义 | 处理方式 |
|---|---|---|
| `unchanged` | 三方一致；两方模式表示目标等于模板 | 跳过 |
| `ours-only` | 只有消费项目改过 | 保留本地内容 |
| `theirs-only` | 只有模板改过 | 人工合并模板增量 |
| `both-changed` | 两边都改过且不同 | 三方合并并记录决策 |
| `converged` | 两边都改过但已一致 | 确认后跳过 |
| `missing` | 目标缺少文件 | 判断补装或说明不适用 |
| `differs` | 无 base 时存在差异 | 人工审查 |
| `base-missing` | 旧快照缺少文件 | 先确认快照完整性 |
| `local-extra` | 目标 skill 目录包含模板没有的文件 | 确认是否为项目专属扩展，并记录保留依据 |

`AGENTS.md`、`CLAUDE.md`、`PROJECT_PROFILE.md`、`openSpec/config.yaml` 始终带 `manual: project-specific`，必须人工处理；`WORKFLOW_BASELINE.yaml` 带 `metadata: update after merge`，合并和验证完成后才能更新。

报告会打印 `Target baseline`、`Template baseline` 和提供 base 时的 `Base baseline`，三者不一致时先修正输入。脚本按当前安装映射遍历，模板侧删除或重命名不会自动出现在报告中，必须同时核对 `CHANGELOG.md` 并人工检查孤儿文件。

脚本只读，差异存在时仍以成功状态退出。参数错误返回 `64`，目标、base 或映射路径不是可读普通文件时返回 `66`，模板源缺失返回 `70`。完整 runbook 见 [`templates/project-workflow/INSTALL.md`](./templates/project-workflow/INSTALL.md#升级已接入项目)。

### 4. 合并、验证与重新基线

1. 按状态逐文件合并，项目专属文件优先保留本地规则。
2. 运行消费项目自己的结构检查、测试、构建或人工验收，保留实际输出和退出码。
3. 用户完成结构验收后，才更新 `WORKFLOW_BASELINE.yaml` 和 `PROJECT_PROFILE.md` 记录的接入基线。
4. 同步受影响的长期主规格，归档消费项目 change。

回滚使用升级前的 Git 提交或安全副本；比较脚本不写文件，也不提供回滚能力。

## 日常使用

### 新建 change

按任务等级创建或定位 `openSpec/changes/<change-name>/`。L1 可以使用精简工件；L2/L3 使用完整 proposal、specs、design 和 tasks。

### 方案门禁

实现前确认设计、任务、兼容、风险和验证方式都能落地。用户没有明确授权时，不修改实现。

### 实现与验证

- 只修改当前 change 授权范围。
- 每完成一个 task，立即更新 checkbox 和验证证据。
- 使用项目定义的命令执行真实测试、构建或人工验收。
- 验证失败或出现新疑点时重新验证，不复用失效证据。

### 验收与归档

用户完成交付门禁后，同步 delta spec 到长期主规格，补齐交付记录并归档到 `openSpec/changes/archive/`。

### 周报

使用 `openSpec/weekly_report_template.md`，只统计当前周期有新增、完成、验收或状态变化的事项。

## 验证本项目

```bash
./scripts/verify.sh
```

校验范围包括：

- 根项目、模板和示例的必需文件；
- `WORKFLOW_BASELINE.yaml` 的版本字段；
- Markdown 代码围栏和 YAML 解析，包含隐藏目录中的 Markdown；
- 模板占位符范围、业务专名泄漏和技术栈隔离，扫描包含隐藏文件但不进入 `.git`；
- `CLAUDE.md` 的列 0 唯一导入、根入口与模板逐字节一致，以及模板入口不复制规则（标题/正文行重合与 60 行上限）；
- 审查 skill 的 frontmatter、名称、引用可达性、占位残留、`agents/openai.yaml` 元数据，以及 `.agents/` 与 `.claude/` 内容一致性；
- 安装预览、空目标安装、部分/完整冲突、仅有 `CLAUDE.md` 的冲突、skill 目录冲突、重复安装；
- 符号链接和非目录父路径零写入；
- OpenSpec context、doctor 和长期主规格 strict validation。

成功时输出：

```text
ALL_CHECKS_PASSED
```

失败时按输出定位；缺少依赖时退出码为 `69`。

## 目录结构

```text
Plumbline/
├── AGENTS.md                    # Codex/通用 agent 的流程规则入口和事实源
├── CLAUDE.md                    # Claude Code 入口，只导入 AGENTS.md 和 PROJECT_PROFILE.md
├── PROJECT_PROFILE.md           # 本项目目录、命令、验证和发布约束
├── README.md
├── CHANGELOG.md
├── openSpec/                    # 本项目自身的 OpenSpec 事实源
├── scripts/
│   ├── install.sh               # 安全安装到目标项目
│   ├── compare.sh               # 只读比较已接入项目与模板差异
│   ├── workflow-files.sh        # 三个脚本共享的安装文件映射
│   └── verify.sh                # 统一自动验证入口
└── templates/project-workflow/  # 对外安装模板的权威版本
    ├── AGENTS.template.md
    ├── CLAUDE.template.md
    ├── PROJECT_PROFILE.template.md
    ├── WORKFLOW_BASELINE.yaml
    ├── INSTALL.md
    ├── .agents/skills/running-code-review-gate/   # 规范源
    ├── .claude/skills/running-code-review-gate/   # Claude Code 镜像
    ├── openSpec/
    ├── superPowers/
    └── examples/
```

## 常见问题

### 安装时报 “Existing destination files were found”

目标项目已有同名文件。安装器不会覆盖，退出码为 `2`。按 `INSTALL.md` 逐文件合并，不要删除现有规则后重装。

### 安装时报 “Unsafe destination parent paths were found”

计划目标的父路径是符号链接或非目录对象。安装器退出码为 `73`，不会写入。先人工确认链接指向，再决定替换为真实目录或手工合并。

### `./scripts/verify.sh` 提示缺少 `rg`

安装 ripgrep：

```bash
brew install ripgrep
rg --version
```

其他环境使用对应包管理器安装。缺少依赖时验证器不会创建临时目录。

### Claude Code 没有加载规则

确认根目录存在 `CLAUDE.md`，并在会话中运行 `/context all`（可用版本也可使用 `/memory`）查看 Memory files。`CLAUDE.md` 必须包含：

```markdown
@AGENTS.md
@PROJECT_PROFILE.md
```

不要把导入写在代码围栏或反引号中，否则 Claude Code 不会展开。

### 项目已有 `CLAUDE.md`，还能用吗

可以，但需要人工合并。保留已有 Claude 专属内容，补充两个导入，不复制 `AGENTS.md` 正文。

### 历史项目不知道基线版本

先确认实际来源和文件差异。无法确认时记录“历史基线未知”，完成逐文件比较后再记录新接入版本。不要把最新版本冒充历史版本。没有旧模板快照时，`compare.sh` 只能做两方比较，结果必须人工审查。

### 模板更新了，已接入项目怎么升级

不要重新安装或整目录覆盖。在消费项目创建升级 change，取得旧基线快照，运行 `./scripts/compare.sh --target ... --base ...`，按状态人工合并，完成真实验证和用户验收后再更新基线。详见[升级已接入项目](#升级已接入项目)。

### 安装过程中断，目标目录留下部分文件

安装前预检只能覆盖冲突和不安全路径，复制阶段不是事务操作。检查实际目录树，删除或合并本次新增内容后再重试。

## 消费项目改进回流

如果消费项目发现通用流程改进：

1. 先判断属于通用流程、技术栈专属还是业务专属。
2. 通用改进在消费项目和本项目分别创建或定位 OpenSpec change，并互相记录名称和同步状态。
3. 本项目审查适用边界，更新模板、主规格、验证和 `CHANGELOG.md`。
4. 消费项目人工比较并合并适用增量，两端分别验证。
5. 技术栈专属规则只进入消费项目的 `PROJECT_PROFILE.md` 或本项目明确标记的示例；业务规则只留在消费项目。

不提供自动双向覆盖。

## 当前状态

- 项目正式名称：`Plumbline（准绳）`；建议仓库标识 `plumbline`。
- 实际工作目录已重命名为 `plumbline`；旧路径 `/Users/leigod/雷神/AI工作流` 不再存在。
- 当前集成基线：`0.1.0-dev.5`（预发布标签 `v0.1.0-dev.5`）。
- 活跃 change：无；`add-code-review-gate-skill` 已通过结构验收并归档。
- 最近归档：`2026-11-13-add-code-review-gate-skill`、`2026-11-12-rename-workspace-to-plumbline`、`2026-11-12-rename-project-to-plumbline`、`2026-11-12-add-workflow-upgrade-path`、`2026-11-12-add-cross-agent-entry`、`2026-11-12-add-coding-behavior-guidelines`。
- 升级能力范围：文档 + 只读比较脚本 `scripts/compare.sh`，不提供自动覆盖。
- 项目已初始化 Git，默认分支 `main`，远程 `origin` 已配置；`0.1.0-dev.5` 已打标签 `v0.1.0-dev.5` 并推送，该标签可作为消费项目升级的可追溯快照；升级仍须人工比较合并并自行验证。

## 相关文档

- [AGENTS.md](./AGENTS.md)：流程规则事实源。
- [CLAUDE.md](./CLAUDE.md)：Claude Code 薄适配入口。
- [PROJECT_PROFILE.md](./PROJECT_PROFILE.md)：本项目目录、命令、验证和发布约束。
- [templates/project-workflow/INSTALL.md](./templates/project-workflow/INSTALL.md)：安装映射、已有项目合并和验证清单。
- [CHANGELOG.md](./CHANGELOG.md)：模板结构、安装接口和行为契约变化。
- [openSpec/README.md](./openSpec/README.md)：OpenSpec 目录、命令和变更流程。
