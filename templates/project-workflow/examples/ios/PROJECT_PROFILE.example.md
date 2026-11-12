# ExampleMobileApp 项目配置示例

> 本文件仅演示如何填写 iOS 项目配置。复制到目标项目后，应根据真实目录、scheme、依赖工具和设备环境重新核实，不能直接作为执行命令使用。

## 1. 项目身份

- 项目名称：`ExampleMobileApp`
- 项目目标：维护一款包含主工程和本地组件仓的 iOS 客户端。
- 主要用户：移动端用户、测试人员和业务开发者。
- 文档语言：简体中文。
- 工作区根目录：`.`。
- 默认 OpenSpec schema：`spec-driven`。
- Agent 入口：`AGENTS.md`（Codex/通用 agent）和 `CLAUDE.md`（Claude Code，导入 `AGENTS.md` 与 `PROJECT_PROFILE.md`）。

## 2. 工作区与 Git 仓库边界

根目录不是 Git 仓库，主工程和本地组件分别维护版本历史。

| 仓库或目录 | 项目相对路径 | 职责 | 默认分支 | 是否允许直接修改 |
|---|---|---|---|---|
| App 主工程 | `ios-app/` | App Target、入口、业务装配和工程配置 | `develop` | 允许，需保护无关脏改 |
| SharedCore | `ios-app/Development Pods/SharedCore/` | 公共模型、网络、基础 UI 和工具 | `develop` | 允许，需单独检查仓库 |
| FeatureModule | `ios-app/Development Pods/FeatureModule/` | 示例业务模块 | `develop` | 允许，需单独检查仓库 |

执行 `git status`、`git diff`、提交或回滚前，必须先确认文件所属仓库。不得用工作区根目录状态代替子仓结论。

## 3. 目录地图

| 类型 | 路径 | 说明 |
|---|---|---|
| 主工程源码 | `ios-app/App/` | App Target 源码 |
| 本地组件源码 | `ios-app/Development Pods/` | 独立 Git 组件仓 |
| 自动化测试 | `ios-app/AppTests/` | 单元和集成测试 |
| 依赖声明 | `ios-app/Podfile`、各组件 podspec | CocoaPods 依赖入口 |
| 生成产物 | `ios-app/Pods/`、`DerivedData/` | 不直接修改或提交 |
| 工作流文档 | `openSpec/`、`AGENTS.md`、`CLAUDE.md`、`PROJECT_PROFILE.md` | 规格、规则和证据 |

## 4. 技术栈与依赖

- 语言：Swift、Objective-C。
- UI：UIKit，局部按项目约定使用 Auto Layout。
- 依赖管理：CocoaPods；本地组件通过 Development Pods 调试。
- IDE 与工具链：目标项目锁定版本的 Xcode 和 Swift toolchain。
- 依赖安装：优先使用项目封装命令；没有封装时才执行 `bundle exec pod install`。
- 禁止直接编辑 `Pods/`、`.xcworkspace` 内生成引用或 DerivedData。

## 5. 标准命令

下列名称为示例，使用前必须替换真实 workspace 和 scheme。

| 目的 | 示例命令 | 运行目录 | 成功标准 |
|---|---|---|---|
| 安装依赖 | `bundle exec pod install` | `ios-app/` | 退出码 0，依赖工程生成成功 |
| Swift 语法检查 | `xcrun swiftc -frontend -parse <file.swift>` | 对应组件仓 | 退出码 0 |
| 仓库差异检查 | `git diff --check` | 每个受影响仓库 | 无输出且退出码 0 |
| 真机 SDK 构建 | `xcodebuild -workspace ExampleMobileApp.xcworkspace -scheme ExampleMobileApp -configuration Debug -sdk iphoneos -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build` | `ios-app/` | 输出 `BUILD SUCCEEDED` 且退出码 0 |
| OpenSpec 校验 | `openspec validate <change-name> --strict` | 工作区根目录 | 输出 valid 且退出码 0 |

不支持或未配置模拟器时，不得为了通过模拟器构建而修改业务依赖。编译验证使用 `iphoneos`；运行、交互和视觉结果使用连接设备或人工真机回归。

## 6. 最窄验证映射

| 改动类型 | 最小自动验证 | 追加验证条件 | 人工验收 |
|---|---|---|---|
| Swift 局部逻辑 | 目标文件 parse、所属仓 `git diff --check` | 公共签名变化时执行受影响 scheme 编译 | 对应业务路径真机回归 |
| Objective-C 局部逻辑 | 所属仓 `git diff --check`、实际 target 编译 | 跨模块头文件变化时扩大编译范围 | 对应业务路径真机回归 |
| 公共组件 | 组件预览或示例、调用方编译 | 公共尺寸、状态或 API 变化时审查上下游 | 亮暗模式、小屏、复用和边界状态 |
| 路由、缓存或异步 | 静态检查、调用链审查、工程编译 | 涉及竞态或生命周期时独立审查 | 进入、退出、重复进入、失败和释放 |
| Podfile 或 podspec | 依赖安装、生成工程引用检查 | 依赖版本或资源变化时完整构建 | App 启动及受影响功能 |

## 7. 运行与验收环境

| 环境 | 用途 | 验证方式 | 限制 |
|---|---|---|---|
| 本地源码 | 静态检查和差异审查 | parse、lint、diff | 不证明链接或运行正确 |
| iphoneos 构建 | 编译、链接和资源验证 | generic iOS device 构建 | 不证明交互和视觉正确 |
| 连接真机 | 业务、交互、视觉和性能验收 | 人工回归矩阵 | 需要设备、账号和测试数据 |
| 测试环境 | 接口与跨端联调 | 真机连接测试环境 | 依赖服务和数据可用性 |

UI 或交互验收覆盖正常、空态、加载、失败、禁用、长文本、小屏、安全区、键盘、深浅色、重复进入和页面释放。

## 8. 代码与文档约定

- 新代码优先沿用所在模块既有前缀、目录和分层模式。
- 新增页面前先确认项目基础控制器、导航栏和统一 UI 组件能力。
- 源码注释解释业务意图、兼容原因、时序和生命周期，不复述代码。
- 网络请求沿用既有 Service、Model 和 ViewModel 模式，处理成功、失败、加载、空态和主线程 UI 更新。
- NotificationCenter、Rx、Timer、CADisplayLink、动画和异步回调必须具备清理路径。

## 9. 长期领域规格索引

| 能力 | 主规格路径 | 适用范围 |
|---|---|---|
| 研发流程 | `openSpec/specs/development-workflow/spec.md` | 分级、门禁、验证与归档 |
| iOS 工程治理 | `openSpec/specs/ios-project-governance/spec.md` | 多仓、命名、依赖、构建和真机验证 |
| UI 组件治理 | `openSpec/specs/ui-component-governance/spec.md` | 统一组件、设计资源和视觉验收 |
| 运行时生命周期 | `openSpec/specs/runtime-lifecycle/spec.md` | 异步、监听、Timer、动画和复用 |

## 10. 禁止操作与交付

- 不直接修改 `Pods/` 和生成工程文件。
- 不使用工作区根目录状态代替主工程或组件仓状态。
- 不把模拟器依赖问题当成本次业务缺陷，也不为模拟器修改既有依赖。
- 不回退、覆盖或暂存其他任务的改动。
- 自动验证通过但真机验收未完成时，不归档业务 change。

交付记录包含实际仓库、改动文件、依赖变化、验证命令、真机结果、无关脏改和残留风险。
