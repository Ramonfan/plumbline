## 1. RED：记录无 skill 的真实失败

- [ ] 1.1 设计至少三组包含时间压力、提交压力和上下文不完整的审查场景，覆盖低风险无差别代理、多仓单仓误判、高风险自审、未知脏改、验证缺口和“先提交再审”；验证：场景输入、预期不变量和评分规则写入本 tasks 证据。
- [ ] 1.2 在隔离临时工作区以干净上下文运行无 guidance 控制和无新 skill 的压力场景，逐条记录选择、遗漏和原话合理化；验证：每个目标失败至少有一份真实基线输出，未出现失败的场景不得据此增加规则。
- [ ] 1.3 将基线失败分类为纪律违规、输出形状错误、必填项遗漏或条件路由错误，选择对应的规则表达方式；验证：每条计划写入 skill 的规则都能追溯到实际失败或既有项目硬约束。

## 2. GREEN：创建最小可用 skill

- [ ] 2.1 使用 skill-creator 初始化 `templates/project-workflow/.agents/skills/running-code-review-gate/` 及 `references`、`agents/openai.yaml`，不创建无用途资源；验证：目录只包含设计列出的文件且无 scaffold 占位。
- [ ] 2.2 编写 `SKILL.md` 的触发描述、只读权限、事实源定位、精确范围、风险路由、审查顺序和 verdict 流程；验证：description 仅描述使用时机并以 `Use when...` 开头，正文不复制 OpenSpec 或 Superpowers 的完整规则。
- [ ] 2.3 编写 `references/review-contract.md`，定义 Critical/Important/Minor、finding 必填字段、`Ready: Yes/No` 条件、残留风险和 OpenSpec 回写格式；验证：结构化样例能表达阻断、无 finding、证伪和待人工验收四种结果。
- [ ] 2.4 编写 `references/reviewer-brief.md`，限定独立 reviewer 的最小输入、只读任务、审查优先级和返回结构；验证：brief 不依赖主会话历史，不包含提交或修复授权。
- [ ] 2.5 生成并核对 `agents/openai.yaml` 的显示名称、简述和默认提示，保持隐式调用开启；验证：元数据与 SKILL.md 名称和触发范围一致。
- [ ] 2.6 使用与 1.2 相同的场景加载 skill 回归，并对关键行为 shaping 文案执行带无 guidance control 的多次微测试；验证：低风险保持本地审查，高风险路由独立审查，阻断条件稳定输出 `Ready: No`。

## 3. REFACTOR：关闭实际漏洞

- [ ] 3.1 汇总 GREEN 场景中新出现的合理化，仅针对真实漏洞补充 prohibition、结构字段或条件规则；验证：新增内容均关联测试失败，skill 未因假设性边界膨胀。
- [ ] 3.2 复跑受影响场景直至 verdict、findings 和权限边界稳定，并执行 skill-creator `quick_validate.py`；验证：校验退出码为 0，所有 Critical/Important 行为偏差消失。
- [ ] 3.3 检查 skill 的渐进披露、引用可达性、字数和通用性；验证：SKILL.md 保持紧凑，技术栈和消费项目业务词只存在于示例或消费项目，不进入通用核心。

## 4. 模板、安装和治理接线

- [ ] 4.1 更新模板 `AGENTS.template.md`、`PROJECT_PROFILE.template.md`、研发流程主规格和实施检查清单，接入提交前审查门禁和项目专属规则路由；验证：各文件职责不重复，OpenSpec 仍是唯一事实源。
- [ ] 4.2 更新 `scripts/install.sh` 的四个 skill 文件映射并保留任何冲突/不安全父路径零写入；验证：dry-run 精确列出新增文件，空目标安装文件内容与模板一致。
- [ ] 4.3 更新 `scripts/verify.sh` 的必需文件、安装树、skill frontmatter/名称/引用/占位校验和通用核心泄漏检查；验证：先构造缺文件或非法 frontmatter 使新增检查失败，再修复模板后完整验证通过。
- [ ] 4.4 将 `WORKFLOW_BASELINE.yaml` 升级到 `0.1.0-dev.2`；若 dev.2 已被 `add-coding-behavior-guidelines` 通过用户验收并归档占用，则升级到 dev.3，同步 README、INSTALL 和 CHANGELOG 的新增文件、兼容与人工升级说明；验证：所有版本引用一致，不宣称历史项目会自动获得 skill。

## 5. 审查、自动验证和消费侧回流

- [ ] 5.1 运行 `bash -n scripts/install.sh scripts/verify.sh`、`./scripts/verify.sh`、安装预览、空目标安装、部分/完整冲突、重复安装和不安全父路径场景；验证：成功路径退出码 0，冲突/不安全路径保持约定状态且目标零写入。
- [ ] 5.2 运行 `openspec validate add-code-review-gate-skill --strict`、受影响长期主规格 strict validation 和 OpenSpec context/doctor；验证：全部通过且输出记录在本 tasks。
- [ ] 5.3 对 skill 行为、安装公开接口、权限边界、跨项目适配和验证覆盖执行独立代码审查，逐项核验反馈；验证：Critical/Important finding 已修复或经证据证伪，最终记录 `Ready: Yes/No`。
- [ ] 5.4 将权威增量提供给消费 change `/Users/leigod/雷神/App改造/openSpec/changes/adopt-code-review-gate-skill` 人工比较，记录适用边界和两端验证结果；验证：不自动覆盖消费项目文件，关联 change 均写明同步状态。

## 6. 用户结构验收与归档

- [ ] 6.1 用户确认 skill 的触发范围、二元 verdict、风险路由、模板安装行为和历史项目升级方式；验证：记录结构验收结论，未确认时保持本任务未完成。
- [ ] 6.2 用户验收后同步 delta specs、补齐最终交付记录并归档 change；验证：交付记录包含模板版本、实际文件、验证命令、消费侧同步、残留风险和无 Git 提交说明。
