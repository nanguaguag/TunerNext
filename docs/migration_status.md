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
| **阶段 3** | 纯 Dart DSP 算法引擎与基准测试 | 重新规划中 | 待以单切片重构 | 待构建纯 Dart 基准套件 | **NOT_STARTED** |
| **阶段 4** | 乐理模型、19种律制与 Scala IO | 待启动 | 待实现 | 待实现 | **NOT_STARTED** |
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
4. **切片 3.4: McLeod Pitch Method (MPM) 引擎** (下一任务):
   - 移植 NSDF 与首峰 0.85 阈值比率算法，防范小提琴高把位八度倍频。
   - 测试: 编写 `test/unit/mcleod_pitch_method_test.dart`。
4. **切片 3.4: McLeod Pitch Method (MPM) 引擎**:
   - 移植 NSDF 与首峰 0.85 阈值比率算法，防范小提琴高把位八度倍频。
   - 测试: 编写 `test/unit/mcleod_pitch_method_test.dart`。
5. **切片 3.5: Two-Way Mismatch (TWM) 引擎**:
   - 实现 Maher & Beauchamp 双向谐波失配与刚度非谐性补偿，解决缺失基频问题。
   - 测试: 编写 `test/unit/two_way_mismatch_test.dart`。
6. **切片 3.6: 经典自相关、Jacobsen 插值与 Phase Vocoder**:
   - 实现经典自相关检测器，集成双层静音门限 (`ACOUSTIC-01`) 与相位细化。
   - 测试: 编写 `test/unit/classic_pitch_detector_test.dart`。
7. **切片 3.7: 时域滤波、平滑器与调音管线门面 (Facade)**:
   - 整合 `PitchMedianFilter`, `OctaveJumpGate`, `OutlierRemovingSmoother` 到 `TunerDspPipeline`。
   - 测试: 编写 `test/unit/pitch_detectors_benchmark_test.dart` 全场景声学基准套件。

---

## 四、当前阻塞条件与后续准入

- **当前任务**: 会话基线固化与交接文档建立（已完成）。
- **下一步准入要求**: 新会话启动后，必须阅读 `AGENTS.md` 与本 `migration_status.md`，经审查确认后方可开启【切片 3.1】开发。
