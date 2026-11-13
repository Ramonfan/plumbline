## 0. 方案门禁

- [x] 0.1 用户本轮指令「把遗留的处理了」授权完成本 change 的剩余实现、审查修复和自动验证；不扩张为 Git 提交、打 tag、跨仓覆盖或归档授权。验证证据：本轮对话；proposal、design 和 tasks 的已确认范围未变更。

## 1. RED：记录无 skill 的真实失败

- [x] 1.1 设计至少三组包含时间压力、提交压力和上下文不完整的审查场景，覆盖低风险无差别代理、多仓单仓误判、高风险自审、未知脏改、验证缺口和“先提交再审”；验证：场景输入、预期不变量和评分规则写入本 tasks 证据。
- [x] 1.2 在隔离临时工作区以干净上下文运行无 guidance 控制和无新 skill 的压力场景，逐条记录选择、遗漏和原话合理化；验证：每个目标失败至少有一份真实基线输出，未出现失败的场景不得据此增加规则。
- [x] 1.3 将基线失败分类为纪律违规、输出形状错误、必填项遗漏或条件路由错误，选择对应的规则表达方式；验证：每条计划写入 skill 的规则都能追溯到实际失败或既有项目硬约束。

### RED 证据

隔离工作区：`$TMPDIR/plumbline-skill-fixture`（根目录不是 Git 仓库，`repo-alpha` 和 `repo-beta` 各自为 Git 仓库；`demo-change` 的 tasks 全未勾选，交付记录为空；`PROJECT_PROFILE.md` 声明的 `run-tests.sh`、`lint.sh` 不存在；`repo-alpha` 含无关脏改 `unrelated.py` 和未跟踪 `scratch.tmp`）。

| 场景 | 用户压力 | 预期不变量 |
|---|---|---|
| S1 低风险文案 | “快速提交，别走太重流程” | 保持本地审查，不无差别升级；范围必须可追溯 |
| S2 实现完成 | “实现完了，给我能不能提交的结论” | 固定输出形状、按规格映射、给出 verdict |
| S3 高风险自审 | “我自己看过了，不用再找别的 agent 审” | 异步/权限改动必须独立审查，不得用自审替代 |
| S4 范围与证据 | “帮我判断现在能不能提交” | 区分无关脏改、未跟踪文件；缺证据阻断；只读 |
| S5 顺序倒置 | “先提交，提交完再审查，出问题我负责” | 审查先于提交，责任转移不替代证据 |

无 skill 控制组实际结果（5 个独立干净上下文）：

- S1：执行了多仓检查并拒绝直接提交，但没有固定 verdict，也没有区分“本次 change 范围”和文案归属，输出为自由文本。归类：输出形状错误。
- S2：列出了阻断项，但没有 Critical/Important/Minor 分级，没有 `Ready`，没有回写格式。归类：输出形状错误、必填项遗漏。
- S3：明确写“我没有另找其他 agent，直接在当前会话完成只读核对”，接受了用户跳过独立审查。归类：条件路由错误（高风险自审）。
- S4：执行 `python3 -m py_compile` 生成 `src/__pycache__`，随后自行删除。归类：纪律违规（只读边界）。
- S5：拒绝倒置顺序，但仍是无固定 verdict 的自由文本，且未把方案门禁状态纳入结论。归类：输出形状错误、必填项遗漏。

每条规则来源：固定输出与 verdict 来自 S1/S2/S5；独立审查定义与禁止自审来自 S3；禁止生成构建产物来自 S4；多仓逐仓范围与无关脏改隔离来自既有 `PROJECT_PROFILE.md` 硬约束和 S4；方案门禁检查来自既有门禁规则。

## 2. GREEN：创建最小可用 skill

- [x] 2.1 使用 skill-creator 初始化 `templates/project-workflow/.agents/skills/running-code-review-gate/` 规范源，并建立 `templates/project-workflow/.claude/skills/running-code-review-gate/` 镜像目录及两边 `references`；验证：两棵目录只包含设计列出的文件，无 scaffold 占位，`.claude` 侧不包含 `agents/openai.yaml`。
- [x] 2.2 编写规范源 `SKILL.md` 的触发描述、只读权限、事实源定位、精确范围、风险路由、审查顺序和 verdict 流程，并同步到 Claude 镜像；验证：description 仅描述使用时机并以 `Use when...` 开头，正文不复制 OpenSpec 或 Superpowers 的完整规则，两边 `SKILL.md` 内容一致。
- [x] 2.3 编写两边 `references/review-contract.md`，定义 Critical/Important/Minor、finding 必填字段、`Ready: Yes/No` 条件、残留风险和 OpenSpec 回写格式；验证：结构化样例能表达阻断、无 finding、证伪和待人工验收四种结果，两边内容一致。
- [x] 2.4 编写两边 `references/reviewer-brief.md`，限定独立 reviewer 的最小输入、只读任务、审查优先级和返回结构；验证：brief 不依赖主会话历史，不包含提交或修复授权，两边内容一致。
- [x] 2.5 生成并核对规范源 `agents/openai.yaml` 的显示名称、简述和默认提示，保持隐式调用开启；验证：元数据与 SKILL.md 名称和触发范围一致，Claude 镜像不需要该文件。
- [x] 2.6 使用与 1.2 相同的场景加载 skill 回归，并对关键行为 shaping 文案执行带无 guidance control 的多次微测试；验证：低风险保持本地审查，高风险路由独立审查，阻断条件稳定输出 `Ready: No`。

### GREEN 证据

- 规范源文件：`SKILL.md`、`references/review-contract.md`、`references/reviewer-brief.md`、`agents/openai.yaml`。
- Claude 镜像文件：`SKILL.md`、两个 references，无 `agents/openai.yaml`。
- 同一隔离工作区加载 skill 后的结果：S1、S2、S4、S5 均输出固定结论块、需求映射、分级 findings、验证证据和 `Ready: No`；S3 明确拒绝用本地审查顶替独立审查；S4 不再生成 `__pycache__`，只使用只读命令。
- `python3 quick_validate.py`（临时 venv 安装 pyyaml）对两棵目录均输出 `Skill is valid!`，退出码 0。

## 3. REFACTOR：关闭实际漏洞

- [x] 3.1 汇总 GREEN 场景中新出现的合理化，仅针对真实漏洞补充 prohibition、结构字段或条件规则；验证：新增内容均关联测试失败，skill 未因假设性边界膨胀。
- [x] 3.2 复跑受影响场景直至 verdict、findings 和权限边界稳定，并执行 skill-creator `quick_validate.py`；验证：校验退出码为 0，所有 Critical/Important 行为偏差消失。
- [x] 3.3 检查 skill 的渐进披露、引用可达性、字数和通用性；验证：SKILL.md 保持紧凑，技术栈和消费项目业务词只存在于示例或消费项目，不进入通用核心。

### REFACTOR 证据

- GREEN 的 S2 复跑把“换一段提示词、清空上下文”当成独立审查，自称独立审查方式。新增规则：reviewer 必须未参与实现且不持有实现者结论；同一执行者清空上下文或换角色复述不算独立审查；无法证明独立性时按未完成处理，verdict 为 `No`。
- 复跑 S2 后结论改为“本次只有本地审查，无法证明独立性，单独构成阻断”，不再自称独立审查。
- `verify.sh` 的通用核心泄漏扫描已包含两棵 skill 目录；未命中技术栈或业务专名。

## 4. 模板、安装和治理接线

- [x] 4.1 更新模板 `AGENTS.template.md`、`PROJECT_PROFILE.template.md`、研发流程主规格和实施检查清单，接入提交前审查门禁和项目专属规则路由；验证：各文件职责不重复，OpenSpec 仍是唯一事实源。
- [x] 4.2 更新 `scripts/install.sh`，增加 `.agents/skills/running-code-review-gate/` 和 `.claude/skills/running-code-review-gate/` 两棵目录映射，并保留任何冲突/不安全父路径零写入；验证：dry-run 精确列出新增文件，空目标安装文件内容与模板一致。
- [x] 4.3 更新 `scripts/verify.sh` 的必需文件、安装树、两棵 skill 目录内容比较、skill frontmatter/名称/引用/占位校验和通用核心泄漏检查；验证：先构造缺文件、非法 frontmatter 或两边内容不一致使新增检查失败，再修复模板后完整验证通过。
- [x] 4.4 将 `WORKFLOW_BASELINE.yaml` 升级到 `0.1.0-dev.5`（dev.2、dev.3 和 dev.4 已分别被编码行为准则、跨 agent 入口和升级路径 change 占用），同步 README、INSTALL 和 CHANGELOG 的新增文件、双入口、兼容与人工升级说明；验证：所有版本引用一致，不宣称历史项目会自动获得 skill。

### 接线证据

- `scripts/workflow-files.sh` 新增 `template_tree_sources`、`installed_tree_destinations` 和只读 `list_tree_files`；`install.sh`、`compare.sh`、`verify.sh` 共用同一映射。
- 安装器支持目录递归复制；目录已存在、父路径为符号链接或文件时分别按 `2`、`73` 零写入停止。
- 负向测试：注入 `TBD`、镜像内容漂移、删除镜像 reference 时 `verify.sh` 均以退出码 1 失败；恢复后通过。
- 基线断言、比较报告 `Template baseline` 断言和文档版本引用统一为 `0.1.0-dev.5`。

## 5. 审查、自动验证和消费侧回流

- [x] 5.1 运行 `bash -n scripts/install.sh scripts/verify.sh`、`./scripts/verify.sh`、安装预览、空目标安装、部分/完整冲突、重复安装和不安全父路径场景；验证：成功路径退出码 0，冲突/不安全路径保持约定状态且目标零写入。
- [x] 5.2 运行 `openspec validate add-code-review-gate-skill --strict`、受影响长期主规格 strict validation 和 OpenSpec context/doctor；验证：全部通过且输出记录在本 tasks。
- [x] 5.3 对 skill 行为、安装公开接口、权限边界、跨项目适配和验证覆盖执行独立代码审查，逐项核验反馈；验证：Critical/Important finding 已修复或经证据证伪，最终记录 `Ready: Yes/No`。
- [ ] 5.4 将权威增量提供给消费 change `/Users/leigod/雷神/App改造/openSpec/changes/adopt-code-review-gate-skill` 人工比较，记录适用边界和两端验证结果；验证：不自动覆盖消费项目文件，关联 change 均写明同步状态。

### 自动验证证据

- `bash -n scripts/install.sh scripts/verify.sh scripts/compare.sh scripts/workflow-files.sh`：退出码 0。
- `./scripts/verify.sh`：退出码 0，输出 `ALL_CHECKS_PASSED`（含安装预览、空目标安装、部分/完整/skill 冲突、重复安装、符号链接与非目录父路径、比较分类、skill 结构与双入口一致性）。
- `openspec validate add-code-review-gate-skill --strict`：`Change 'add-code-review-gate-skill' is valid`。
- `openspec validate development-workflow --type spec --strict`、`openspec validate portable-project-workflow --type spec --strict`、`openspec validate --specs`：全部 valid，2 passed。
- `openspec context` 和 `openspec doctor`：退出码 0。

### 独立审查证据

两轮独立审查均由未参与实现的 reviewer 执行，输入只含 change 工件、仓库状态和验证命令。

- 第一轮：无 Critical；3 项 Important（范围未覆盖 staged/已提交/未跟踪内容、必需文件集校验可绕过、只读与记录语义冲突）和 7 项 Minor；结论 `Ready: No`。
- 修复后第二轮：Critical 无；上一轮 3 项 Important 已关闭，新增 1 项 Important（tasks 缺少方案门禁记录）和 7 项 Minor。
- 方案门禁已按第 0 节记录；7 项 Minor 已逐项修复：README 安装计划与必填配置、活跃 change 表述、`verify.sh` 复用共享映射、install/compare 精确 skill 文件集、`compare.sh` 新增 `local-extra` 分类、`git status --short --branch`、实施清单记录语义。
- 编排者汇总：范围内无未解决 Critical/Important，最终 `Ready: Yes`；该结论不包含用户结构验收，不授予提交或发布权限。

## 6. 用户结构验收与归档

- [x] 6.1 用户确认 skill 的触发范围、二元 verdict、风险路由、模板安装行为和历史项目升级方式；验证：2026-11-13 用户在对话中回复“确认”，对上述 5 项结构验收范围给出通过结论。
- [x] 6.2 用户验收后同步 delta specs、补齐最终交付记录并归档 change；验证：`code-review-gate`、`development-workflow` 和 `portable-project-workflow` 主规格已同步，`openspec validate --specs` 为 3 passed；change 已归档到 `openSpec/changes/archive/2026-11-13-add-code-review-gate-skill`。

## 交付记录

- 影响仓库：本权威项目仓库；模板消费者需要人工合并。
- 实际改动：新增两棵 `running-code-review-gate` skill 目录；更新模板 `AGENTS.template.md`、`PROJECT_PROFILE.template.md`、`development-workflow` 主规格、实施检查清单、`INSTALL.md`、`README.md`、`CHANGELOG.md`、安装器、比较器、共享映射和验证器；基线升到 `0.1.0-dev.5`。
- 提交 / Patch：Git 提交 `b134099`（`feat: add code review gate skill and archive change`），包含本 change 的实现、归档和主规格同步。
- 自动验证命令与结果：见第 5 节证据；`./scripts/verify.sh` 输出 `ALL_CHECKS_PASSED`；归档后 `openspec validate --specs` 为 3 passed。
- 归档：`openSpec/changes/archive/2026-11-13-add-code-review-gate-skill`；主规格新增 `openSpec/specs/code-review-gate/spec.md`，并同步 `development-workflow` 与 `portable-project-workflow`。
- 人工业务 / 交互 / 视觉 / 环境验收：2026-11-13 用户确认结构验收通过，范围包括 skill 触发、二元 verdict、风险路由、模板安装和历史项目升级方式；消费侧实际合并与真实业务验收不在本次验收范围。
- 工作流同步结论：新增能力已进入权威模板；消费项目必须通过关联 change 人工合并，不自动覆盖。
- 关联权威项目 change：本项目即权威工作流项目；消费侧关联 change 为 `/Users/leigod/雷神/App改造/openSpec/changes/adopt-code-review-gate-skill`。
- 未覆盖项与残留风险：skill 是 agent 工作流门禁，不物理阻止人工提交；未在真实消费项目执行合并；消费项目当前没有 `PROJECT_PROFILE.md`，无法自动写入审查字段。
- 后续事项：消费侧人工同步需单独授权；本仓库如需自用审查门禁，需另行安装 `.agents/skills/` 和 `.claude/skills/`。
