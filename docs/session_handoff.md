# 会话交接备忘录 (Session Handoff & Context Continuity)

> **交接时间**: 2026-10-31  
> **会话状态**: 【阶段 4 / 切片 4.3：纯律与历史古典律制】已 100% 完成并验证，全量 121 项自动化测试全部通过，工作区纯净。下一切片为【阶段 4 / 切片 4.4：延展调音曲线 (Stretch Tuning)】。

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
   - 当前最新检出 Commit: `7a01bea` ("feat(dsp): implement temporal filters, outlier-removing smoother and DSP pipeline facade (slice 3.7)")
   - 工作区状态: 零未提交改动 (`working tree clean`)，静态分析 `flutter analyze` 零告警 (0 issues)，自动化测试 **78 项用例 100% 全部通过**。
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
│   ├── widget/                        # 组件与视图渲染测试 (M3 主题及烟雾测试)
│   ├── integration/                   # 端到端测试
│   └── regression/                    # 回归测试
└── lib/
    ├── core/                          # 基础常量、主题扩展、语义颜色
    ├── domain/                        # 乐理模型、律制与调音实体
    └── dsp/                           # 纯 Dart DSP 多引擎架构 (已全量实现)
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

- **切片 4.3: 纯律与历史古典律制 (Just Intonation, Pythagorean, Meantone, Werckmeister)** (`VERIFIED`):
  - 文件: `lib/domain/temperaments/chain_of_fifths.dart`, `lib/domain/temperaments/chain_of_fifths_temperament.dart`, `lib/domain/temperaments/rational_temperament.dart`, `lib/domain/temperaments/predefined_temperament.dart`
  - 测试: `test/domain/historical_temperament_test.dart` (15 组测试全部通过)
  - 核心突破:
    1. 沿五度链折叠算法 `ChainOfFifths`：向上向下双向相生并自动归一化折叠至 `[1.0, 2.0)`，实现闭合五度圈校正。
    2. 纯分数有理数律制 `RationalTemperament`：精确承载纯律 (Just Intonation) 与 Werckmeister VI 单弦物理弦长比率。
    3. 全量 19 种历史律制目录 `PredefinedTemperaments`：毕达哥拉斯律 (407.82c 大三度)、纯律 (386.31c 大三度)、中庸律家族 (1/4、15音扩展、1/3、1/5)、魏克迈斯特良律 (III/IV/V/VI)、基恩贝格 (I/II/III)、奈德哈特 (I/II/III)、瓦洛蒂与杨氏第 2 律。
    4. 动态根音切换：支持以任意主音为基准，实时重构律制频率与音阶。

---

### 2. 下一步规划：阶段 4 延展调音曲线 (Stretch Tuning)

在下一任务中，推进【切片 4.4】：

- **切片 4.4: 延展调音曲线 (Stretch Tuning)**:
  - 对应 Kotlin: `stretchtuning/StretchTuning.kt`, `stretchtuning/Railsback.kt`
  - 移植 Railsback 经验曲线模型与非谐性多项式微调模型。
  - 测试: 编写 `test/domain/stretch_tuning_test.dart`。
- **切片 4.4: 延展调音曲线 (Stretch Tuning)**:
  - 移植 Railsback 曲线与刚度系数 $B$ 对高低频琴键的微调偏移。
- **切片 4.5: Scala 文件解析器 (.scl & .kbm)**:
  - 实现纯 Dart Scala 格式读取与自定义微音程律制导入。
- **切片 4.6: 乐器预设与琴弦音高模型体系 (Instrument Tunings)**:
  - 定义吉他、贝斯、小提琴、中提琴、大提琴、尤克里里标准定弦与常用变格降调。

---

## 四、新会话启动提示词 (Prompt for Next Session)

在新会话启动时，请直接发送以下提示词，即可无缝承接当前进度并安全启动阶段 4 开发：

```text
你好！我们正在进行将开源 Android Kotlin 调音器（/Users/huzongyao/flutterProjects/Tuner，分支 feature/advanced-pitch-algorithms）渐进式重构为 Flutter 应用（/Users/huzongyao/flutterProjects/tuner_flutter，分支 feature/rollback）的项目。

在上一会话中，我们已经顺利完成了【阶段 4 / 切片 4.3：纯律与历史古典律制 (Just Intonation, Pythagorean, Meantone, Werckmeister)】的实现与验证，全量 121 项自动化测试 100% 通过，工作区纯净。

请首先阅读以下关键文档建立上下文：
1. /Users/huzongyao/flutterProjects/tuner_flutter/AGENTS.md
2. /Users/huzongyao/flutterProjects/tuner_flutter/docs/session_handoff.md
3. /Users/huzongyao/flutterProjects/tuner_flutter/docs/migration_status.md
4. /Users/huzongyao/flutterProjects/tuner_flutter/docs/feature_matrix.md
5. /Users/huzongyao/flutterProjects/tuner_flutter/docs/algorithm_specification.md

在确认环境与 Git 状态纯净后，请严格遵循单切片渐进式原则，开始执行【阶段 4 / 切片 4.4：延展调音曲线 (Stretch Tuning)】的实现与单元测试。全部测试通过并创建提交检查点后，请立即停止并汇报，等待我的审查。
```
