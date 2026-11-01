# Antigravity Multi-Agent & Pair-Programming Guidelines for Tuner Flutter

> **项目目标**: 将开源 Android Kotlin 调音器项目（基线仓库：`https://github.com/daniel-freiermuth/Tuner`，本地分支 `feature/advanced-pitch-algorithms`，HEAD commit `d570fa9`）渐进式重构成使用 Flutter、Dart 和 Material Design 3 的高精度跨平台调音器。
> **基线状态**: 当前 Flutter 仓库已回滚至清晰干净的脚手架检出点 `e58c406` (分支 `feature/rollback`)。此前的探索性代码已归档于 `main` 分支供查阅参考，禁止未经验证盲目复用。

---

## 核心开发铁律 (Strict Guidelines)

1. **以实际代码为唯一事实来源 (Code is Ground Truth)**:
   - 严禁仅凭类名、文件名、README 或旧报告假定某项功能已完成。
   - 所有声明的“已实现”必须有实际连通的调用链；所有声明的“已验证”必须有自动化测试证据。
2. **纯粹渐进式重构 (Progressive Single-Slice)**:
   - 每次任务只允许推进**一个边界明确、可独立验证的功能切片**。
   - 严禁在同一会话中同时进行架构调整、算法重写与 UI 堆砌。
3. **保护源仓库不受污染 (Zero Contamination)**:
   - 严禁修改、删除或污染原 Kotlin 仓库 `/Users/huzongyao/flutterProjects/Tuner` 中的任何文件。
4. **测试门禁与质量优先 (Test-Driven & Quality Gates)**:
   - 每一个功能切片提交前，必须运行：
     1. `dart format --output=none --set-exit-if-changed .`
     2. `flutter analyze` (零 warning、零 error)
     3. `flutter test` (相关单测与回归测试 100% 通过)
5. **严禁降低测试标准 (No Compromises)**:
   - 严禁为了通过测试而放宽误差容限、删除断言或屏蔽静态分析。
   - 若发现算法输出与预期不符，必须深究数学原理或原版实现细节。
6. **严禁混淆“底层算法就绪”与“UI 功能完成” (No Fake Completeness)**:
   - 严禁将纯 Dart 领域模型、算法数学公式或单元测试通过声称为“某某功能已完成”。
   - 任何涉及用户交互的功能（如乐器定弦、19 种律制选择、延展调音、升降号偏好、乐器增删改），必须在 UI 界面上有明确、高保真、可交互的组件或弹窗入口，并具备 Widget 交互测试验证。
   - 严禁使用通用的占位符图标（如使用 `Icons.music_note` 替代吉他/小提琴等 7 种专属乐器矢量图标）或临时简化弹窗糊弄过关，必须 1:1 对标 Kotlin 原版设计语言与视觉资产。

---

## 项目工程结构

```text
tuner_flutter/
├── AGENTS.md                          # 本多 Agent 开发与协同指引规范
├── docs/
│   ├── audit_and_migration_plan.md    # 基础审计与完整迁移白皮书 (全覆盖计划)
│   ├── feature_matrix.md              # 85 项双端功能状态与覆盖度矩阵
│   ├── architecture.md                # 现代化 Clean Architecture 架构方案
│   ├── algorithm_specification.md     # 核心 DSP 算法数学规格书 (FFT, MPM, TWM, etc.)
│   ├── known_issues.md                # 双端已知缺陷与声学物理痛点分析表
│   ├── migration_status.md            # 当前迁移进度、已验证列表与进行中任务
│   ├── decisions.md                   # 架构与技术决策记录 (ADR)
│   └── session_handoff.md             # 会话交接与上下文恢复备忘录
├── lib/
│   ├── core/                          # 基础常量、主题扩展、工具函数
│   ├── domain/                        # 纯 Dart 乐理模型、律制与调音实体
│   ├── dsp/                           # 纯 Dart 音频信号处理与音高检测多引擎
│   ├── audio/                         # 平台音频采集管道与多线程 Isolate 隔离
│   ├── data/                          # 本地持久化、SharedPreferences 与 Scala 文件 IO
│   ├── state/                         # Riverpod 状态管理控制器
│   └── ui/                            # Material Design 3 视图、Canvas 绘图与对话框
└── test/
    ├── unit/                          # 纯 Dart DSP 与乐理单元测试
    ├── widget/                        # M3 Widget 渲染与交互测试
    ├── integration/                   # 端到端音频数据流集成测试
    └── regression/                    # 针对已发现 Bug 的回归测试套件
```
