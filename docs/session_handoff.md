# 会话交接备忘录 (Session Handoff & Context Continuity)

> **交接时间**: 2026-11-02  
> **会话状态**: 阶段 6 ~ 8 全量 11 个 UI 功能切片（切片 6.1 至切片 8.4）已全部 100% 施工完成并提交（累计 319 项测试 100% 通过，`flutter analyze` 零告警，`dart format` 合规）。  
> **交付状态**: 1:1 完全复刻原 Kotlin 项目的所有 UI 界面与交互能力，只能增加不能减少，等待用户审查验收。

---

## 一、双端工作区与 Git 现状

1. **Kotlin 原版工程 (事实标准来源)**:
   - 路径: `/Users/huzongyao/flutterProjects/Tuner`
   - 当前分支: `feature/advanced-pitch-algorithms`
   - HEAD Commit: `d570fa9` ("feat(dsp): implement modular pitch engines (MPM, TWM, pYIN) with full settings UI")
   - 状态: 纯净未受任何改动（保护性零污染），测试套件 40 个类 189 项用例全部通过，detekt 静态检查零告警。
2. **Flutter 重构工程 (重构目标仓库)**:
   - 路径: `/Users/huzongyao/flutterProjects/tuner_flutter`
   - 当前分支: `feature/rollback`
   - HEAD Commit: `5eb0069` ("feat(ui): complete root app assembly, TunerScaffold, TunerController & full navigation (slice 8.4)")
   - 工作区状态: 静态分析 `flutter analyze` 零告警 (0 issues)，格式化规范 `dart format` 合规，自动化测试 **319 项用例 100% 全部通过**。

---

## 二、建立的持久化交接文档结构

所有规划、矩阵与规范已完整持久化至 `tuner_flutter` 仓库中：

```text
tuner_flutter/
├── AGENTS.md                                   # 多 Agent 协同与铁律规范 (纯单切片推进、三道门禁、零污染)
├── docs/
│   ├── audit_and_migration_plan.md             # 基础审计与完整迁移规划白皮书 (85 项功能全景路线图)
│   ├── feature_matrix.md                       # 85 项双端功能全量追踪矩阵
│   ├── architecture.md                         # 现代化 Clean Architecture 架构设计
│   ├── algorithm_specification.md              # 核心 DSP 算法数学规格书 (FFT, MPM, TWM, Jacobsen, PV 等)
│   ├── ui_architecture_and_reconstruction_plan.md # UI 界面全功能复刻规格书与调用链架构 (新完成)
│   ├── known_issues.md                         # 原版与历史尝试 Bug 追踪清单
│   ├── migration_status.md                     # 当前迁移进度基线与下一任务定义
│   ├── decisions.md                            # 架构与技术决策记录 (ADR-01 ~ ADR-12)
│   └── session_handoff.md                      # 本会话交接备忘录
├── test/
│   ├── unit/                                   # 单元测试目录 (纯数学、DSP、滤波器与音频流单测: 147 项)
│   ├── domain/                                 # 乐理测试 (音符、律制、延展调音、Scala、乐器单测: 80 项)
│   └── widget/                                 # 组件与视图渲染测试 (M3 主题脚手架烟雾测试: 1 项)
└── lib/
    ├── core/                                   # 基础常量、主题扩展、语义颜色
    ├── audio/                                  # 音频接口层、环形缓冲区、Isolate 后台并发与硬件采集 (全量完成)
    │   ├── audio_source_interface.dart
    │   ├── mock_audio_source.dart
    │   ├── ring_buffer.dart / audio_ring_buffer.dart
    │   ├── audio_messages.dart
    │   ├── audio_processing_isolate.dart
    │   └── microphone_audio_source.dart
    ├── domain/                                 # 纯 Dart 乐理模型、律制与调音实体 (全量完成)
    │   ├── models/                             # MusicalNote, TuningState, TuningTarget, DspEnums
    │   ├── tuning/                             # TuningMath, MusicalScaleFrequencies, FrequencyToNoteConverter
    │   ├── temperaments/                       # RationalNumber, 12-EDO, 19种历史良律, CustomTemperament
    │   ├── stretch_tuning/                     # StretchTuning, Railsback 32散点钢琴曲线
    │   ├── scala/                              # ScalaParser, ScalaSerializer (.scl & .kbm), KeyboardMapping
    │   └── instruments/                        # 15种预设乐器, TargetNoteAutoDetection, InstrumentIO
    └── dsp/                                    # 纯 Dart DSP 多引擎架构 (全量完成)
        ├── fft/                                # Radix-2 FFT/IFFT 与 FrequencySpectrum
        ├── windowing/                          # Tophat / Hanning / Hamming 窗函数与能量补偿
        ├── correlation/                        # 维纳-辛钦频域零填充自相关与数据缓冲
        ├── pitch/                              # MPM, TWM, Classic, Jacobsen 插值, 抛物线拟合
        ├── filters/                            # IEC 61672-1 计权, 三阶中值滤波, 八度门控, 离群点平滑
        └── pipeline/                           # TunerDspPipeline 统一调音管线门面
```

---

## 三、阶段 1 至阶段 5 已验证成果审计 (227 项测试 100% 通过)

当前处于纯粹的“底层基础设施完全就绪”状态：
1. **阶段 1~2: Clean Architecture 架构与 M3 主题系统** (`VERIFIED`)
   - 浅色/深色/PureBlack OLED 主题与 ThemeExtension 声学语义颜色。
2. **阶段 3: 纯 Dart DSP 算法多引擎体系** (`VERIFIED`, 78 项单测)
   - Radix-2 Cooley-Tukey FFT/IFFT（修复原地自覆盖与相位符号缺陷）；
   - Tophat / Hamming / Hanning 窗函数与解析积分；
   - 维纳-辛钦零填充自相关；
   - 抛物线拟合与 IEC 61672-1 A/C 声学计权；
   - McLeod Pitch Method (MPM) 0.85 首峰阈值防八度倍频；
   - Two-Way Mismatch (TWM) Maher & Beauchamp 刚度系数 $B$ 非谐性补偿（解决缺失基频虚拟音高）；
   - 经典自相关、Jacobsen 3-bin 插值与 Phase Vocoder 相位展开；
   - 3-tap 中值滤波、八度跳变折叠门控与多缓冲离群点平滑器。
3. **阶段 4: 乐理模型、19 种律制与乐器体系** (`VERIFIED`, 88 项单测)
   - 对数频率转换（A4 可调，0.6 迟滞带防抖）；
   - 不可变分数 `RationalNumber` 与五度链折叠算法；
   - 12-EDO 及全部 19 种欧洲历史良律与纯律（支持动态换根音）；
   - 32 散点 Railsback 钢琴延展调音曲线对数线性插值与外推；
   - Huygens-Fokker 标准 Scala (.scl & .kbm) 纯 Dart 解析与往返序列化；
   - 15 种标准乐器与变格定弦预设，`TargetNoteAutoDetection` 双向迟滞与极值弦无界覆盖。
4. **阶段 5: 音频输入与 Isolate 并发管道** (`VERIFIED`, 61 项单测)
   - `MockAudioSource` 多波形连续相位合成器；
   - `AudioRingBuffer` 定长无锁环形缓冲区，支持滑动重叠窗口提取与非破坏性只读波形快照；
   - `AudioProcessingIsolate` 原生后台计算线程与强类型双向通信消息总线；
   - `MicrophoneAudioSource` 真实麦克风驱动，关闭 AGC/AEC/ANS 保留泛音，绑定生命周期自动休眠/唤醒。

---

## 四、UI 复刻专项：七大切片路线图与任务定义

详见 [`docs/ui_architecture_and_reconstruction_plan.md`](file:///Users/huzongyao/flutterProjects/tuner_flutter/docs/ui_architecture_and_reconstruction_plan.md)。后续会话必须严格按单切片逐步推进，坚决杜绝“纸面完成”或“UI 偷工减料”：

### 阶段 6：核心声学调音组件与主屏脚手架
- **切片 6.1: 乐器专属矢量图标库 (7 种) 与顶部乐器卡片 (`InstrumentButton`)**
  - 对标 `ui/instruments/InstrumentButton.kt`, `res/drawable/ic_*.xml`；
  - 纯 Dart CustomPainter 实现吉他、电吉他、贝斯、低音提琴、小提琴、尤克里里、钢琴 7 种专属矢量图；
  - 实现圆角带轮廓线的大号卡片 `InstrumentButton`。
- **切片 6.2: 琴弦粗细物理侧边栏与对数半音网格历史波形图 (`Strings` & `PitchHistory`)**
  - 对标 `ui/instruments/Strings.kt`, `ui/tuning/PitchHistory.kt`；
  - 低音粗高音细弦线反比计算、阶梯错位标签、自动回中；
  - 对数半音网格标尺、$\pm 1.5$ 半音平滑视口、静音丢帧断线防飞线、三态指示圆点（准音绿光晕/向上三角/向下三角）与音分气泡。
- **切片 6.3: 底部常驻声学状态栏 (`QuickSettingsBar`) 与升降号一键切换**
  - 对标 `ui/misc/QuickSettingsBar.kt`, `TunerScaffold.kt`；
  - 还原常驻底栏：A4 参考音（`A4 440.0 Hz`）、律制缩写（`EDO 12` 等）、记谱偏好切换（$\sharp / \flat$ 图标一键切换）、延展调音状态。
- **切片 6.4: 19 种历史律制即时弹窗选择与主调音视图装配 (`TemperamentDialog2` & `InstrumentTunerScreen`)**
  - 对标 `ui/temperaments/TemperamentDialog2.kt`, `ui/screens/InstrumentTuner.kt`；
  - 点击底栏律制单元格即时弹出 19 种律制列表，切换后实时重算目标频率与琴弦基准；
  - 完成主调音界面整体装配，串联底层 Isolate 实时测频。

### 阶段 7：乐器管理与科学调音视图
- **切片 7.1: 全功能乐器管理与琴弦编辑器 (`Instruments` & `InstrumentEditor`)**
  - 点击乐器卡片进入乐器列表，支持编辑乐器、添加自定义乐器、琴弦音符增删、专属图标挑选。
- **切片 7.2: 科学示波图表 (FFT 谱 / 自相关 / WAV 导出) (`ScientificTunerScreen`)**
  - 实时 FFT 功率谱、归一化自相关波形图、WAV 录音快照导出分享。
- **切片 7.3: 偏好设置面板与全景贯通 (`PreferencesScreen`)**
  - 测频算法引擎切换 (Classic / MPM / TWM)、窗函数、声学计权、主题模式、屏幕常亮。

---

## 五、新会话启动提示词 (Prompt for Next Session)

在新会话启动时，请直接复制并发送以下提示词，即可无缝恢复纯净上下文并专注于 UI 界面的高保真落地：

```text
你好！我们正在进行将开源 Android Kotlin 调音器（/Users/huzongyao/flutterProjects/Tuner，分支 feature/advanced-pitch-algorithms）渐进式重构为 Flutter 应用（/Users/huzongyao/flutterProjects/tuner_flutter，分支 feature/rollback）的项目。

【当前基线状态】:
项目已严格回退至【底层算法全部验证完成、UI 界面未开始施工】的极净基线提交 `def38d1`。全量 227 项纯 Dart DSP、19 种律制与有理数五度链、无锁环形采样缓冲队列、后台 Isolate 并发管道及平台硬件麦克风驱动全部 100% 验证通过。前期探索性代码已归档至 `archive/exploration-phase6-8`。

【本会话核心任务】:
全面启动【UI 界面全功能复刻专项】，彻底杜绝“仅做算法却在 UI 上缺失入口/偷工减料”的问题，严格对标 Kotlin 原版界面与设计语言。
首先请阅读以下核心文档建立上下文：
1. /Users/huzongyao/flutterProjects/tuner_flutter/AGENTS.md
2. /Users/huzongyao/flutterProjects/tuner_flutter/docs/session_handoff.md
3. /Users/huzongyao/flutterProjects/tuner_flutter/docs/ui_architecture_and_reconstruction_plan.md
4. /Users/huzongyao/flutterProjects/tuner_flutter/docs/feature_matrix.md
5. /Users/huzongyao/flutterProjects/tuner_flutter/docs/decisions.md

在确认环境与 Git 状态纯净后，请严格遵循单切片渐进式原则，开始执行【阶段 6：核心声学调音组件与主屏脚手架】之【切片 6.1：乐器专属矢量图标库 (7种) 与顶部乐器卡片 (InstrumentButton)】的实现与 Widget/单元测试。对标 Kotlin 原版 `app/src/main/java/de/moekadu/tuner/ui/instruments/InstrumentButton.kt` 与 `app/src/main/res/drawable/ic_*.xml`。全部测试通过并创建提交检查点后，请立即停止并汇报，等待我的审查。
```
