# 迁移基线与阶段开发状态 (Migration Status)

> **更新时间**: 2026-10-30  
> **当前可信 Git 基线**: `e58c40605916b59c7b558c7a0a34a27c3422ef98` (分支: `feature/rollback`)  
> **归档参考分支**: `main` (包含历史探索代码，供查阅设计教训，不可直接盲信)  
> **工作区状态**: 纯净无改动 (`working tree clean`)，`flutter analyze` 零告警，自动化测试 100% 通过。

---

## 一、当前整体迁移进度一览

| 阶段编号 | 阶段名称 | 计划状态 | 代码状态 | 自动化测试状态 | 最终结论 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **阶段 1** | 全面代码审计与迁移设计方案 | 已完成 | 审计白皮书完备 | 189 项 Kotlin 单测验证通过 | **VERIFIED** |
| **阶段 2** | Flutter 独立工程脚手架与 M3 主题 | 已完成 | `e58c406` 提交 | M3 主题与 Note 模型单测通过 | **VERIFIED** |
| **阶段 3** | 纯 Dart DSP 算法引擎与基准测试 | 已完成 | `7a01bea` 提交 | 全量 78 项测试通过 | **VERIFIED** |
| **阶段 4** | 乐理模型、19种律制与 Scala IO | 进行中 | 切片 4.4 已完成 | 131 项单测全部通过 | **IN_PROGRESS** |
| **阶段 5** | 平台音频流采集与 Isolate 并发管道 | 待启动 | 待实现 | 待实现 | **NOT_STARTED** |
| **阶段 6** | 乐器调音主界面 (琴弦/表盘/历史图) | 待启动 | 待实现 | 待实现 | **NOT_STARTED** |
| **阶段 7** | 科学调音界面 (示波器/FFT谱/波形) | 待启动 | 待实现 | 待实现 | **NOT_STARTED** |
| **阶段 8** | 偏好设置、16语种国际化与状态持久化 | 待启动 | 待实现 | 待实现 | **NOT_STARTED** |
| **阶段 9** | 端到端集成验收与真机声学调优 | 待启动 | 待实现 | 待实现 | **NOT_STARTED** |

---

## 二、当前真正 VERIFIED 的功能列表

基于 `e58c406` 实际代码与测试执行结果，目前仅认定以下内容为 **VERIFIED**:
1. **基础常量与声学参数配置 (`AcousticConstants`)**:
   - 文件: `lib/core/constants/acoustic_constants.dart`
   - 包含基准采样率 44100Hz、默认窗口 4096、A4 频率 440.0Hz、静音阈值与算法枚举。
2. **Material Design 3 调色板与主题系统 (`TunerColors`, `TunerTheme`)**:
   - 文件: `lib/core/theme/tuner_colors.dart`, `lib/core/theme/tuner_theme.dart`
   - 支持浅色、深色与纯黑 (PureBlack OLED) 三种模式，且通过 ThemeExtension 扩展了声学调音语义色（准音绿、偏低橙、偏高紫）。
   - 测试: `test/widget_test.dart` 验证通过。
3. **音符领域基础实体模型 (`MusicalNote`)**:
   - 文件: `lib/domain/models/musical_note.dart`
   - 支持半音偏移、变音记号、八度表示与标准频率计算。
   - 测试: `test/domain/musical_note_test.dart` 验证通过。
4. **基础数学与 FFT/IFFT 引擎 (`FFT`, `bitReverse`)**:
   - 文件: `lib/dsp/fft/fft.dart`
   - 支持实数与复数 Radix-2 Cooley-Tukey 变换，彻底消除 `FORK-NEW-02` 原地解包覆盖缺陷，修正了逆变换相位符号。
   - 测试: `test/unit/fft_test.dart` (14 组用例 100% 通过，涵盖 NumPy 标准向量差分比对、复数与实数往返高精重构、Dirac Delta 冲击响应、Nyquist/2 原地覆盖回归与边界长度防御)。
5. **窗函数与能量补偿 (`Windowing`)**:
   - 文件: `lib/dsp/windowing/windowing.dart`
   - 支持 Tophat / Hamming / Hanning 窗系数生成、解析积分与频域幅值补偿因子。
   - 测试: `test/unit/windowing_test.dart` (5 组测试 100% 通过)。
6. **零填充自相关计算器与数据缓冲 (`Correlation`, `AutoCorrelationData`)**:
   - 文件: `lib/dsp/correlation/correlation.dart`, `lib/dsp/correlation/auto_correlation.dart`
   - 维纳-辛钦频域自相关算法，零填充 $2N$ 规避圆周反射，实现位反转直充与频域谱直接导出；提供自相关序列归一化与零点映射。
   - 测试: `test/unit/correlation_test.dart` (6 组测试 100% 通过，与 Kotlin `CorrelationTest.kt` 基准向量误差 $< 10^{-4}$)。
7. **三点抛物线极值精修 (`MaximumOfPolynomialFit`)**:
   - 文件: `lib/dsp/pitch/polynomial_fit.dart`
   - 实现三点连续二次极值插值，具备零分母退化（共线/平坦）防护与数组边界安全截断。
   - 测试: `test/unit/polynomial_fit_test.dart` (5 组测试 100% 通过)。
8. **IEC 61672-1 声学计权滤波 (`AcousticWeighting`)**:
   - 文件: `lib/dsp/filters/acoustic_weighting.dart`
   - 实现 A 计权（人耳等响度模拟）与 C 计权（高声压/宽带模拟），严格执行 1000Hz 归一化与 50Hz 工频交流电衰减（$> 30\text{ dB}$）。
   - 测试: `test/unit/acoustic_weighting_test.dart` (5 组测试 100% 通过)。
9. **McLeod Pitch Method (MPM) 引擎 (`McLeodPitchDetector`)**:
   - 文件: `lib/dsp/pitch/mcleod_pitch_method.dart`
   - 实现归一化平方差函数 (NSDF)，首峰 0.85 阈值比率选择机制彻底根除弓弦起奏二次谐波翻倍跳跃，集成抛物线插值与 RMS 静音门限。
   - 测试: `test/unit/mcleod_pitch_method_test.dart` (6 组测试 100% 通过，小提琴强泛音场景与纯正弦波高精度锁定)。
10. **Two-Way Mismatch (TWM) 引擎 (`TwoWayMismatchDetector`)**:
   - 文件: `lib/dsp/pitch/two_way_mismatch.dart`
   - 实现 Maher & Beauchamp (1994) 双向谐波失配算法与琴弦刚度非谐性色散补偿，攻克低音大提琴粗弦基频缺失 (BUG-05/ACOUSTIC-03) 虚拟音高锁定。
   - 测试: `test/unit/two_way_mismatch_test.dart` (5 组测试 100% 通过，理想谐波、基频缺失虚拟音高与刚度系数 B 适配验证)。
11. **频谱数据结构 (`FrequencySpectrum`)**:
   - 文件: `lib/dsp/fft/frequency_spectrum.dart`
   - 承载复数傅里叶谱、平方幅度谱、物理频率网格与归一化绘图缓冲。
12. **经典自相关音高检测 (`ClassicPitchDetector`, `findCorrelationBasedFrequency`)**:
   - 文件: `lib/dsp/pitch/classic_pitch_detector.dart`
   - 包含首个局部极小值绕行、全局极值搜索、次谐波 division 多重惩罚及 ACOUSTIC-01 双层静音门限防护。
   - 测试: `test/unit/classic_pitch_detector_test.dart` (8 组测试 100% 通过，完全对齐 Kotlin 基准)。
13. **Jacobsen 3-bin 插值与 Phase Vocoder 相位修正 (`AccurateSpectrumPeakFrequency`)**:
   - 文件: `lib/dsp/pitch/accurate_spectrum_peak.dart`
   - 实现 Jacobsen 复数 3-bin 二次插值与跨帧相位展开折叠计算，扫频相对误差严格 $< 1.0\%$。
   - 测试: `test/unit/accurate_spectrum_peak_test.dart` (4 组测试 100% 通过)。
14. **三阶中值滤波与八度跳变门控 (`PitchMedianFilter`, `OctaveJumpGate`)**:
   - 文件: `lib/dsp/filters/pitch_temporal_filter.dart`
   - 消除瞬态单帧突刺噪声，抑制起奏摩擦导致的 2x~4x 及 1/2~1/4 泛音跳跃。
   - 测试: `test/unit/pitch_temporal_filter_test.dart` (8 组测试 100% 通过)。
15. **多缓冲离群点剔除平滑器 (`OutlierRemovingSmoother`)**:
   - 文件: `lib/dsp/filters/outlier_removing_smoother.dart`
   - 环形缓冲、动态容差校验与多候选队列并发平滑。
   - 测试: `test/unit/outlier_removing_smoother_test.dart` (3 组测试 100% 通过)。
16. **统一调音管线门面 (`TunerDspPipeline`)**:
   - 文件: `lib/dsp/pipeline/tuner_dsp_pipeline.dart`
   - 串联静音门控、声学计权、多引擎调度 (MPM/TWM/Classic)、八度门控、中值滤波与平滑输出。
   - 测试: `test/unit/tuner_dsp_pipeline_test.dart` (5 组测试 100% 通过)。

---

## 三、待按切片逐步实施的任务路线图

后续开发必须严格采用**最小可验证功能切片**，严禁跨阶段一次性堆叠：

1. **切片 3.1: 基础数学与 FFT/IFFT 引擎** (`VERIFIED`):
   - 已实现实数/复数 Radix-2 Cooley-Tukey 变换，彻底修复 `FORK-NEW-02` 原地覆盖 Bug。
   - 测试: `test/unit/fft_test.dart` 14 组测试 100% 通过。
2. **切片 3.2: 窗函数与自相关计算器** (`VERIFIED`):
   - 已实现 Tophat / Hanning / Hamming 及其数值积分，实现零填充频域互相关计算器。
   - 测试: `test/unit/windowing_test.dart` 与 `test/unit/correlation_test.dart` 11 组测试 100% 通过，与 Kotlin `CorrelationTest.kt` 基准向量对齐。
3. **切片 3.3: 抛物线拟合与声学计权曲线** (`VERIFIED`):
   - 已实现三点二次极值拟合（带零分母与边界安全拦截），实现 IEC 61672-1 A/C 计权。
   - 测试: `test/unit/polynomial_fit_test.dart` 与 `test/unit/acoustic_weighting_test.dart` 10 组测试 100% 通过。
4. **切片 3.4: McLeod Pitch Method (MPM) 引擎** (`VERIFIED`):
   - 已移植 NSDF 与首峰 0.85 阈值比率算法，防范小提琴高把位八度倍频。
   - 测试: `test/unit/mcleod_pitch_method_test.dart` 6 组测试 100% 通过。
5. **切片 3.5: Two-Way Mismatch (TWM) 引擎** (`VERIFIED`):
   - 已实现 Maher & Beauchamp 双向谐波失配与刚度非谐性补偿，解决缺失基频问题。
   - 测试: `test/unit/two_way_mismatch_test.dart` 5 组测试 100% 通过。
6. **切片 3.6: 经典自相关、Jacobsen 插值与 Phase Vocoder** (`VERIFIED`):
   - 已实现经典自相关检测器、次谐波惩罚多重遍历、双层静音门限 (`ACOUSTIC-01`)、Jacobsen 3-bin 插值与 Phase Vocoder 跨帧相位折叠。
   - 测试: `test/unit/classic_pitch_detector_test.dart` 与 `test/unit/accurate_spectrum_peak_test.dart` 12 组测试 100% 通过。
7. **切片 3.7: 时域滤波、平滑器与调音管线门面 (Facade)** (`VERIFIED`):
   - 已整合 `PitchMedianFilter`, `OctaveJumpGate`, `OutlierRemovingSmoother` 到 `TunerDspPipeline`，支持运行时算法与计权切换、双重静音与全链条平滑。
   - 测试: `test/unit/pitch_temporal_filter_test.dart`, `test/unit/outlier_removing_smoother_test.dart`, `test/unit/tuner_dsp_pipeline_test.dart` 16 组测试 100% 通过。
8. **阶段 4 / 切片 4.1: 对数音符与频率双向映射器 (Frequency-to-Note Converter)** (`VERIFIED`):
   - 文件: `lib/domain/tuning/tuning_math.dart`, `lib/domain/tuning/musical_scale_frequencies.dart`, `lib/domain/tuning/frequency_to_note_converter.dart`, `lib/domain/models/musical_note.dart`
   - 实现高精度对数音符映射公式 $f = f_{A4} \cdot 2^{(n-69)/12}$，支持 A4 基准频率可调、音分偏差计算与调准状态评估 (`TuningState`)。
   - 纯 Dart 移植 Kotlin `MusicalScaleFrequencies`，支持全音域二分查找、连续对数插值与几何外推；并在目标音符吸附中集成 0.6 迟滞门控 (Hysteresis)，彻底消除临界半音抖动。
   - 测试: `test/domain/pitch_frequency_converter_test.dart` 13 组测试全部通过。
9. **阶段 4 / 切片 4.2: 律制体系架构与十二平均律 (12-EDO)** (`VERIFIED`):
   - 文件: `lib/domain/temperaments/rational_number.dart`, `lib/domain/temperaments/fifth_modification.dart`, `lib/domain/temperaments/temperament_circle_of_fifths.dart`, `lib/domain/temperaments/temperament.dart`, `lib/domain/temperaments/equal_temperament.dart`
   - 建立高精度有理数分数运算体系 (`RationalNumber`)、微音差修正项 (`FifthModification`) 与五度相生圈模型。
   - 封装抽象律制基类 `Temperament`，实现十二平均律 (`EqualTemperament.edo12`) 与通用任意等分微分音音阶 ($N$-EDO，如 19/24/31-EDO)。
   - 测试: `test/domain/equal_temperament_test.dart` 15 组测试全部通过。
10. **阶段 4 / 切片 4.3: 纯律与历史古典律制 (Just Intonation, Pythagorean, Meantone, Werckmeister)** (`VERIFIED`):
   - 文件: `lib/domain/temperaments/chain_of_fifths.dart`, `lib/domain/temperaments/chain_of_fifths_temperament.dart`, `lib/domain/temperaments/rational_temperament.dart`, `lib/domain/temperaments/predefined_temperament.dart`
   - 完整移植原版全部 19 种历史律制目录（纯律、毕达哥拉斯律、1/4 逗音、扩展 1/4 逗音 15 音阶、1/3 逗音、1/5 逗音、Werckmeister III/IV/V/VI、Kirnberger I/II/III、Neidhardt I/II/III、Vallotti、Young II）。
   - 实现沿五度链折叠算法（`ChainOfFifths`）与纯有理数比率（`RationalTemperament`），严格支持任意根音（Root Note）动态切换。
   - 测试: `test/domain/historical_temperament_test.dart` 15 组测试全部通过。
11. **阶段 4 / 切片 4.4: 延展调音曲线 (Stretch Tuning)**:
   - 文件: `lib/domain/stretch_tuning/stretch_tuning.dart`, `lib/domain/stretch_tuning/predefined_stretch_tunings.dart`
   - 完整实现 32 散点 Railsback 钢琴延展曲线（A0 约 -35.95 cents，C8 约 +32.07 cents，A440 严格为 0 cents）。
   - 实现高精度对数线性插值、几何外推、不可变增删改控制点与单调性校验，并闭环集成 `MusicalScaleFrequencies`。
   - 测试: `test/domain/stretch_tuning_test.dart` 10 组测试全部通过。
12. **阶段 4 / 切片 4.5: Scala (.scl) 音阶解析与导出** (下一任务):
   - 编写标准 Huygens-Fokker Scala 音阶文件格式解析器与导出器。
   - 测试: 编写 `test/domain/scala_parser_test.dart`。

---

## 四、当前阻塞条件与后续准入

- **当前任务**: 阶段 4 / 切片 4.4 开发与验证已完成，全量 131 项自动化测试 100% 通过。
- **下一步准入要求**: 等待用户代码审查确认后，方可启动【切片 4.5：Scala (.scl) 音阶解析与导出】。
