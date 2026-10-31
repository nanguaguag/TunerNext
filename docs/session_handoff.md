# 会话交接备忘录 (Session Handoff & Context Continuity)

> **交接时间**: 2026-10-31  
> **会话状态**: 【阶段 4：乐理模型、19种律制、延展调音、Scala 与乐器体系 (Slices 4.1 ~ 4.6)】已 100% 全部完成并验证，全量 166 项自动化测试全部通过，工作区纯净。下一任务为启动【阶段 5：平台音频流采集与 Isolate 并发管道】（切片 5.1：音频输入源抽象与平台通道驱动）。

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
   - 当前最新检出 Commit: `1b58c05` ("feat(theory): implement instrument models, presets, target note auto-detection, and InstrumentIO (slice 4.6)")
   - 工作区状态: 零未提交改动 (`working tree clean`)，静态分析 `flutter analyze` 零告警 (0 issues)，自动化测试 **166 项用例 100% 全部通过**。
   - 历史探索分支: `main`（保留历史记录供查阅，禁止盲目复用）。

---

## 二、建立的持久化交接文档结构

所有规划、矩阵与规范已完整持久化至 `tuner_flutter` 仓库中：

```text
tuner_flutter/
├── AGENTS.md                          # 多 Agent 协同与铁律规范 (纯单切片推进、三道门禁、零污染)
├── docs/
│   ├── audit_and_migration_plan.md    # 基础审计与完整迁移规划白皮书
│   ├── feature_matrix.md              # 85 项双端功能全量追踪矩阵 (DSP 全切片已标记 VERIFIED)
│   ├── architecture.md                # 现代化 Clean Architecture 架构设计
│   ├── algorithm_specification.md     # 核心 DSP 算法数学规格书 (FFT, MPM, TWM, Jacobsen, PV 等)
│   ├── known_issues.md                # 原版与历史尝试 Bug 追踪清单 (FORK-NEW-02, ACOUSTIC-01~03 等)
│   ├── migration_status.md            # 当前迁移进度基线与下一任务定义
│   ├── decisions.md                   # 架构与技术决策记录 (ADR)
│   └── session_handoff.md             # 本会话交接备忘录
├── test/
│   ├── unit/                          # 单元测试目录 (纯数学、DSP、滤波器与管线单测)
│   ├── domain/                        # 乐理测试 (音符、律制、延展调音、Scala、乐器单测)
│   ├── widget/                        # 组件与视图渲染测试 (M3 主题及烟雾测试)
│   ├── integration/                   # 端到端测试
│   └── regression/                    # 回归测试
└── lib/
    ├── core/                          # 基础常量、主题扩展、语义颜色
    ├── audio/                         # 音频接口层 (AudioSource)
    ├── domain/                        # 纯 Dart 乐理模型、律制与调音实体 (全量完成)
    │   ├── models/                    # MusicalNote, TuningState, TuningTarget
    │   ├── tuning/                    # TuningMath, MusicalScaleFrequencies, FrequencyToNoteConverter
    │   ├── temperaments/              # RationalNumber, 12-EDO, 19种历史良律, CustomTemperament
    │   ├── stretch_tuning/            # StretchTuning, Railsback 32散点钢琴曲线
    │   ├── scala/                     # ScalaParser, ScalaSerializer (.scl & .kbm), KeyboardMapping
    │   └── instruments/               # 15种预设乐器, TargetNoteAutoDetection, InstrumentIO
    └── dsp/                           # 纯 Dart DSP 多引擎架构 (全量完成)
        ├── fft/                       # Radix-2 FFT/IFFT 与 FrequencySpectrum
        ├── windowing/                 # Tophat / Hanning / Hamming 窗函数与能量补偿
        ├── correlation/               # 维纳-辛钦频域零填充自相关与数据缓冲
        ├── pitch/                     # MPM, TWM, Classic, Jacobsen 插值, 抛物线拟合
        ├── filters/                   # IEC 61672-1 计权, 三阶中值滤波, 八度门控, 离群点平滑
        └── pipeline/                  # TunerDspPipeline 统一调音管线门面
```

---

## 三、阶段 3 完成成果与阶段 4 准入标准

### 1. 阶段 3 已完工成果总览 (全部 VERIFIED，78 项自动化单测通过)
- **切片 3.1: 基础数学与 FFT/IFFT 引擎 (Pure Dart)** (`VERIFIED`):
  - 文件: `lib/dsp/fft/fft.dart` | 测试: `test/unit/fft_test.dart` (14 组)
  - 核心突破: Cooley-Tukey 算法，彻底消除 `FORK-NEW-02` 原地解包自覆盖 Bug 与逆变换虚部相位符号错误。
- **切片 3.2: 窗函数与自相关计算器 (Pure Dart)** (`VERIFIED`):
  - 文件: `lib/dsp/windowing/windowing.dart`, `lib/dsp/correlation/correlation.dart`, `lib/dsp/correlation/auto_correlation.dart` | 测试: `test/unit/windowing_test.dart`, `test/unit/correlation_test.dart` (11 组)
  - 核心突破: 维纳-辛钦定理 $2N$ 零填充频域自相关，位反转直充与波形归一化重映射。
- **切片 3.3: 抛物线拟合与声学计权曲线 (Pure Dart)** (`VERIFIED`):
  - 文件: `lib/dsp/pitch/polynomial_fit.dart`, `lib/dsp/filters/acoustic_weighting.dart` | 测试: `test/unit/polynomial_fit_test.dart`, `test/unit/acoustic_weighting_test.dart` (10 组)
  - 核心突破: 连续抛物线极值点亚采样插值（带零分母与边界防卫）；IEC 61672-1 A/C 计权衰减工频电声学干扰。
- **切片 3.4: McLeod Pitch Method (MPM) 引擎 (Pure Dart)** (`VERIFIED`):
  - 文件: `lib/dsp/pitch/mcleod_pitch_method.dart` | 测试: `test/unit/mcleod_pitch_method_test.dart` (6 组)
  - 核心突破: NSDF 归一化平方差与 0.85 首峰阈值比率，攻克小提琴高次谐波八度倍频缺陷 (BUG-04/ACOUSTIC-02)。
- **切片 3.5: Two-Way Mismatch (TWM) 引擎 (Pure Dart)** (`VERIFIED`):
  - 文件: `lib/dsp/pitch/two_way_mismatch.dart` | 测试: `test/unit/two_way_mismatch_test.dart` (5 组)
  - 核心突破: Maher & Beauchamp 谐波失配误差与刚度 $B$ 色散补偿，攻克大提琴粗弦基频缺失虚拟音高难题 (BUG-05/ACOUSTIC-03)。
- **切片 3.6: 经典自相关、Jacobsen 插值与 Phase Vocoder (Pure Dart)** (`VERIFIED`):
  - 文件: `lib/dsp/fft/frequency_spectrum.dart`, `lib/dsp/pitch/classic_pitch_detector.dart`, `lib/dsp/pitch/accurate_spectrum_peak.dart` | 测试: `test/unit/classic_pitch_detector_test.dart`, `test/unit/accurate_spectrum_peak_test.dart` (12 组)
  - 核心突破: 次谐波惩罚多重遍历、ACOUSTIC-01 15% 零延迟能量门限防护、复数 3-bin 二次插值与跨帧相位展开折叠。
- **切片 3.7: 时域滤波、平滑器与调音管线门面 (Facade) (Pure Dart)** (`VERIFIED`):
  - 文件: `lib/dsp/filters/pitch_temporal_filter.dart`, `lib/dsp/filters/outlier_removing_smoother.dart`, `lib/dsp/pipeline/tuner_dsp_pipeline.dart` | 测试: `test/unit/pitch_temporal_filter_test.dart`, `test/unit/outlier_removing_smoother_test.dart`, `test/unit/tuner_dsp_pipeline_test.dart` (16 组)
  - 核心突破: 3-tap 滑动中值滤波剔除尖峰脉冲、八度跳变折叠门控抑制擦弦破音、多缓冲离群点平滑与统一调度门面。

---

### 2. 下一阶段：阶段 4 乐理模型、律制与调音实体任务规划

在下一会话中，严格按功能切片渐进式推进【阶段 4】：

- **切片 4.1: 对数音符与频率双向映射器 (Frequency-to-Note Converter)** (`VERIFIED`):
  - 文件: `lib/domain/tuning/tuning_math.dart`, `lib/domain/tuning/musical_scale_frequencies.dart`, `lib/domain/tuning/frequency_to_note_converter.dart`, `lib/domain/models/musical_note.dart`
  - 测试: `test/domain/pitch_frequency_converter_test.dart` (13 组测试全部通过)
  - 核心突破:
    1. 乐理声学基础数学公式与对数互逆运算（`ratioToCents`, `centsToRatio`, `centsToFrequency`, `frequencyToCents`）。
    2. 扩展 `MusicalNote` 支持 MIDI 编号映射（A4=69, C4=60, A0=21, C8=108）与变音记号、等音双向转换。
    3. 对齐 Kotlin `MusicalScaleFrequencies`，实现全音域二分查找、连续浮点对数插值与几何外推。
    4. 统一门面 `FrequencyToNoteConverter`：支持 A4 基准调节（390Hz~490Hz）、开弦乐器标准定弦识别、音分偏差计算与调准状态评估 (`TuningState`)。
    5. 集成 0.6 迟滞门控 (Hysteresis Auto Detection)，彻底消除临界半音边界由于微小声学扰动引发的高频跳动。

---

- **切片 4.2: 律制体系架构与十二平均律 (12-EDO)** (`VERIFIED`):
  - 文件: `lib/domain/temperaments/rational_number.dart`, `lib/domain/temperaments/fifth_modification.dart`, `lib/domain/temperaments/temperament_circle_of_fifths.dart`, `lib/domain/temperaments/temperament.dart`, `lib/domain/temperaments/equal_temperament.dart`
  - 测试: `test/domain/equal_temperament_test.dart` (15 组测试全部通过)
  - 核心突破:
    1. 精确有理数模型 `RationalNumber`：欧几里得最大公约数约分化简、四则运算、幂运算与精确关系比较，杜绝浮点累积误差。
    2. 微音差五度修正项 `FifthModification`：毕氏音差 (PC)、普通音差 (SC)、劈音 (S) 与古典声学恒等式（$PC = SC + S$）化简。
    3. 五度相生圈模型 `TemperamentCircleOfFifths`：闭合 12 步五度圈，验证在每个五度收窄 -1/12 毕氏音差下与理想 12 平均律完全一致。
    4. 抽象律制基类 `Temperament` 与 `EqualTemperament`：支持标准 12-EDO（每级严格 100 音分，纯八度比率严格 2.0 倍）及通用微分音等分音阶（如 19/24/31-EDO）。

---

- **切片 4.3: 纯律与 19 种历史古典律制 (Just Intonation & Historical Temperaments)** (`VERIFIED`):
  - 文件: `lib/domain/temperaments/chain_of_fifths.dart`, `lib/domain/temperaments/chain_of_fifths_temperament.dart`, `lib/domain/temperaments/rational_temperament.dart`, `lib/domain/temperaments/predefined_temperament.dart`
  - 测试: `test/domain/historical_temperament_test.dart` (15 组测试全部通过)
  - 核心突破:
    1. 沿五度链折叠算法 `ChainOfFifths`：支持正向向上与逆向向下双向相生，并自动八度折叠归一化至 `[1.0, 2.0)`，实现闭合五度圈校正。
    2. 纯分数有理数律制 `RationalTemperament`：精确承载纯律 (Just Intonation, 5/4 大三度、3/2 纯五度) 与单弦物理弦长比率。
    3. 全量 19 种历史律制目录 `PredefinedTemperaments`：毕达哥拉斯律 (407.82c 大三度)、纯律 (386.31c 大三度)、中庸律家族 (1/4、15音扩展、1/3、1/5)、魏克迈斯特良律 (III/IV/V/VI)、基恩贝格 (I/II/III)、奈德哈特 (I/II/III)、瓦洛蒂与杨氏第 2 律。
    4. 动态根音切换：支持以任意主音为基准，实时重构律制频率与音阶。

---

- **切片 4.4: 延展调音曲线 (Stretch Tuning & Railsback Curve)** (`VERIFIED`):
  - 文件: `lib/domain/stretch_tuning/stretch_tuning.dart`, `lib/domain/stretch_tuning/predefined_stretch_tunings.dart`
  - 测试: `test/domain/stretch_tuning_test.dart` (10 组测试全部通过)
  - 核心突破:
    1. 纯 Dart `StretchTuning` 模型：支持任意音高散点集合，对数尺度分段线性插值计算延展音分，基于端点斜率实现几何平滑外推。
    2. 基准音动态归一化：支持任意参考基准音（如 A440、A442），自动保证参考音处的延展偏离量严格为 0 音分。
    3. 散点单调性校验与不可变编辑：提供 `isValid` 频率单调性检验，以及 `addControlPoint`, `modifyControlPoint`, `removeControlPoint` 纯函数式不可变增删改。
    4. 32 散点经典 Railsback 曲线：完整录入全钢琴 88 键实测经验延展，覆盖 A0（~28.4Hz, -35.95 cents）至 C8（~4202Hz, +32.07 cents），低音下沉与高音抬升物理声学特征完全对齐。
    5. 与 `MusicalScaleFrequencies` 完整联动：无缝将延展曲线注入调音音阶频率生成链路。

---

- **切片 4.5: Scala 音阶与键盘映射解析与导出 (.scl & .kbm)** (`VERIFIED`):
  - 文件: `lib/domain/scala/scala_scale.dart`, `lib/domain/scala/keyboard_mapping.dart`, `lib/domain/scala/scala_note_helper.dart`, `lib/domain/scala/scala_parser.dart`, `lib/domain/scala/scala_serializer.dart`, `lib/domain/temperaments/custom_temperament.dart`
  - 测试: `test/domain/scala_parser_test.dart` (17 组测试全部通过)
  - 核心突破:
    1. Huygens-Fokker 标准 Scala (.scl) 纯 Dart 高鲁棒解析与导出：支持纯律分数比率（`9/8`, `5/4`）、纯整数比例（如 `2` 自动解析为 `2/1`）、浮点小数音分（`100.0`）、单/多音阶连续流，以及 UTF-8 BOM 和 Windows CRLF 透明剥离。
    2. 元数据与音符名称深度解析：提取 `! version=...`, `! abbreviation=...`, `! description=...`，支持行内 `note=D`, `note=C#`, `note=F#/Gb`, `note=D+1` 等复杂变音与等音异名标注。
    3. Huygens-Fokker 键盘映射 (.kbm) 解析与导出：支持物理键数、参考音 MIDI、参考频率、中音键以及跳键 `'x'`。
    4. 双向往返序列化一致性：`ScalaSerializer.serializeScl` 导出的文件重新解析后与源数据结构 100% 吻合。
    5. `CustomTemperament` 领域实体多态支持：继承抽象基类 `Temperament`，直接承接 ScalaScale，支持动态切换根音，并与 `MusicalScaleFrequencies` 闭环集成。

---

- **切片 4.6: 预设乐器体系与琴弦音高模型 (Instrument Tunings)** (`VERIFIED`):
  - 文件: `lib/domain/instruments/instrument.dart`, `lib/domain/instruments/instrument_icon.dart`, `lib/domain/instruments/predefined_instruments.dart`, `lib/domain/instruments/sorted_and_distinct_instrument_strings.dart`, `lib/domain/instruments/target_note_auto_detection.dart`, `lib/domain/instruments/instrument_io.dart`
  - 测试: `test/domain/instrument_tuning_test.dart` (18 组测试全部通过)
  - 核心突破:
    1. 15 种标准乐器与变格定弦预设全量收录：覆盖吉他（标准 EADGBE, Drop D, DADGAD, Open D, Open G）、贝斯（4/5/6 弦）、提琴四重奏家族纯五度（小提琴、中提琴、大提琴、低音提琴）、尤克里里（高四弦重返调弦与次中音调弦）及自由半音模式。
    2. `SortedAndDistinctInstrumentStrings`: 提取琴弦在调音音阶内的离散音符索引，自动排序去重，非音阶音符折叠至末尾哨兵，提供毫秒级琴弦判定。
    3. `TargetNoteAutoDetection`: 带有智能迟滞（Hysteresis Band）的物理频率自动匹配状态机。相邻琴弦间 60% 迟滞带有效抑制临界点指针高频跳抖，极值琴弦向外保持无限无界覆盖，支持单弦乐器与 Chromatic 模式无缝调度。
    4. `InstrumentIO`: 兼容 Android Tuner 文本规范的乐器列表序列化与反序列化工具，支持特殊字符、换行符与未知音名的防御性解析。

---

### 2. 下一步规划：阶段 5 平台音频流采集与 Isolate 并发管道

乐理与算法层（阶段 3 与阶段 4 全部 13 个功能切片，166 项自动化单测）已全部固化并闭环验证。接下来启动【阶段 5：平台音频采集与多线程管道】：

- **切片 5.1: 音频输入源抽象与模拟流发生器 (AudioSource & MockAudioSource)**:
  - 文件: `lib/audio/audio_source_interface.dart`, `lib/audio/mock_audio_source.dart`
  - 完善 `AudioSource` 统一抽象（生命周期状态、采样率、声道数、`Stream<Float32List>` 样本流、start/stop/pause/resume/dispose）。
  - 实现纯 Dart 内存声学模拟发生器 `MockAudioSource`（支持生成纯正弦波、指定泛音衰减比例的复合谐波、弦乐刚度系数 $B$ 色散波形、白噪声与静音，且可配置推流帧率与采样点大小）。
  - 测试: 编写 `test/unit/audio_source_test.dart`（验证模拟流的时域连续性、振幅归一化与周期时间精度）。
- **切片 5.2: 无锁环形缓冲区与音频流消费提取 (AudioRingBuffer)**:
  - 文件: `lib/audio/ring_buffer.dart`
  - 纯 Dart 高性能定长环形队列（支持 Float32 连续写入、按时窗长度 $N$ 与步长 $L$ 提取重叠帧、多线程/异步消费安全、溢出与欠载统计、最新波形快照提取）。
  - 测试: 编写 `test/unit/ring_buffer_test.dart`（并发写入读取、回卷覆盖、重叠步长提取与快照完整性）。
- **切片 5.3: Isolate 后台计算并发隔离与消息通信总线 (AudioProcessingIsolate)**:
  - 文件: `lib/audio/audio_processing_isolate.dart`, `lib/audio/audio_messages.dart`
  - 基于 Dart `Isolate.spawn` 搭建独立的后台音频与 DSP 运算线程；
  - 建立强类型双向通信消息总线（主线程发送参数配置变更、音频数据帧；Isolate 计算完成后回传轻量级 `PitchAssessment`、自相关波形快照与 FFT 功率谱数据）；
  - 主线程设置 UI 节流器（30~60 FPS 刷新上限），保证 UI 绝对零卡顿。
  - 测试: 编写 `test/unit/audio_isolate_test.dart`。
- **切片 5.4: 平台真实麦克风硬件驱动集成 (MicrophoneAudioSource)**:
  - 文件: `lib/audio/microphone_audio_source.dart`
  - 集成 `record` 插件，实现低延迟 16-bit PCM 持续录音流与浮点归一化转换；
  - 处理动态权限申请、被拒降级与提示引导；
  - 结合 `WidgetsBindingObserver` 监听应用生命周期（前台恢复唤醒、退火锁屏休眠释放麦克风）。
  - 测试: 编写 `test/unit/microphone_audio_source_test.dart`。

---

## 四、新会话启动提示词 (Prompt for Next Session)

在新会话启动时，请直接发送以下提示词，即可无缝承接当前进度并安全启动阶段 5 开发：

```text
你好！我们正在进行将开源 Android Kotlin 调音器（/Users/huzongyao/flutterProjects/Tuner，分支 feature/advanced-pitch-algorithms）渐进式重构为 Flutter 应用（/Users/huzongyao/flutterProjects/tuner_flutter，分支 feature/rollback）的项目。

在上一会话中，我们已经顺利完成了【阶段 4：乐理模型、19种律制与乐器体系 (Slices 4.1 ~ 4.6)】的全部开发与验证，全量 166 项自动化测试 100% 通过，工作区纯净。

请首先阅读以下关键文档建立上下文：
1. /Users/huzongyao/flutterProjects/tuner_flutter/AGENTS.md
2. /Users/huzongyao/flutterProjects/tuner_flutter/docs/session_handoff.md
3. /Users/huzongyao/flutterProjects/tuner_flutter/docs/migration_status.md
4. /Users/huzongyao/flutterProjects/tuner_flutter/docs/feature_matrix.md
5. /Users/huzongyao/flutterProjects/tuner_flutter/docs/architecture.md

在确认环境与 Git 状态纯净后，请严格遵循单切片渐进式原则，开始执行【阶段 5 / 切片 5.1：音频输入源抽象与模拟流发生器 (AudioSource & MockAudioSource)】的实现与单元测试。全部测试通过并创建提交检查点后，请立即停止并汇报，等待我的审查。
```
