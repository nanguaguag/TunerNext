# 迁移基线与阶段开发状态 (Migration Status)

> **更新时间**: 2026-11-03  
> **当前可信 Git 基线**: feature/rollback (HEAD commit `8d61dc1`)  
> **工作区状态**: 格式化校验通过，`flutter analyze` 零告警 (0 issues)，自动化测试 100% 通过 (391/391 项)。
> **最新修复状态**: 
> - 核心声学与波形图连续性缺陷 P0-01 (`d559380`)、P1-02 (`49d0d53`)、P1-03 (`dfbd11b`) 已依次通过单切片测试与门禁并提交。
> - 用户反馈缺陷切片 1: 安静状态底噪跳变修复 (`9dbf03a`)，对数能量门控联动动态灵敏度，底噪 100% 滤除为静音。
> - 用户反馈缺陷切片 2: 科学模式频谱多峰与自相关曲线修复 (`cf22c62`)，废除频点抽稀，平方功率谱提升谐波峰辨识度，连续 Path 消除简笔画与折线感。
> - 用户反馈缺陷切片 3: 波形图手势与平滑过渡动画 (`1160cb4`)，支持单指拖动垂直平移 (Pan)、双指捏合缩放 (Pinch-to-zoom)、轻触复位，音高坐标切换通过 AnimationController 260ms 平滑插值过渡。
> - 用户反馈缺陷切片 4: 简体中文本地化全量补齐 (`59109d6`)，补齐 127 个残留英文词条（19 种律制名称/释义、乐器操作、五线谱谱号等）。
> - 用户反馈缺陷切片 5: 律制体系全量补齐 (`92195c9`)，内置 5-EDO 到 72-EDO（68 种等律）与 18 种历史古典律制（共 86 种），弹窗支持折叠分组与多语种检索。
> - 用户反馈缺陷切片 6: 基准频率修复与麦克风实时识别 (`16e160d`)，消除 G44 重复八度拼接，弹窗支持点击麦克风实测频率直接填入及一键重置默认。
> - 用户反馈缺陷切片 7: 设置项与各偏好弹窗全量汉化 (`9696b90`)，将所有设置项 subtitle 与弹窗彻底绑定多语种资源，清除写死英文。
> - 用户反馈缺陷切片 8: 底层 DSP 算法深度排查与加窗加权优化 (`a4e9aa0`)，频域自相关接入真实 IEC 61672-1 声学计权（压制 50Hz 工频底噪 30dB），Isolate FFT 接入 Hanning 窗消除频谱旁瓣泄漏。
> - 口哨与垂直线条缺陷切片 1: TWM 候选谱峰按振幅降序排序与高频纯音次谐波陷阱抑制 (`f9e1344`)，解决 1600Hz 口哨漏检候选池导致的误判低频。
> - 口哨与垂直线条缺陷切片 2: Outlier 异常值平滑器防漏值与均值保持 (`1e62044` / 当前)，稳态平滑均值抵御单帧异常毛刺。
> - 口哨与垂直线条缺陷切片 3: PitchHistory 动态音高视口全音域展开与跨视口纵贯垂直条纹消除 (`e7167ed`)，彻底破除 4 半音钳位，断开 >3.5 半音跨越式杂音连线与视口外无谓裁切线。
> - 口哨与垂直线条缺陷切片 4: 调音主屏与科学调音静音期时间轴真实推移 (`b653c55`)，在无声帧推入哑音断点，波形向左自然流逝并断开非连续音符。
> - 口哨与垂直线条缺陷切片 5: 实测口哨音频端到端流水线与平滑渲染回归测试覆盖，全量 366 项自动化测试 100% 通过。
> - 交互与多语言切片 1: 延展调音函数图视口负高度缩放与垂直拖拽方向修正 (`f5c0857`)，解决向上/下拖拽反向问题。
> - 交互与多语言切片 2: 首页波形图视口变化重绘触发及 macOS 触控板/滚轮交互支持 (`e5e4155`)，补齐 shouldRepaint 遗漏的 midiMin/Max，支持双指平移捏合与滚轮缩放。
> - 交互与多语言切片 3: 底栏延展调音图标优化 (`6fb21ea`)，1:1 接入 Android 原版 ic_stretch 矢量图标，彻底替代冗长 "No Stretch Tuning" 文本。
> - 交互与多语言切片 4: 14 种多语言各 34 词条全量补齐及延展调音全链路汉化国际化，370 项自动化测试 100% 通过。
> - UI升级与五线谱移植切片:
>   - 首页 UI 空间与仪表盘重构: 增加顶部 `TuningIndicatorBanner` 动态音高仪表盘（大音符徽章、音分偏差条、实时频率），琴弦转为紧凑侧边栏（宽度 76dp）与全尺寸可缩放平移 `PitchHistory` 波形图并列，消除整行横跨浪费。
>   - 科学模式示波器与五线谱升级: 频谱图与自相关图增加实时顶栏读数、虚线目标/谐波线与平滑渐变填充；引入 Gonville 矢量字体 assets 与完整五线谱引擎（`NoteStaff` / `NoteStaffPainter` / `SvgPathParser`），385 项自动化测试 100% 通过。
> - 科学示波器高密波峰、导出WAV与音频导入分析切片:
>   - 科学调音频谱波峰重构: 引入 `SpectrumPlot`（0~4000Hz 1024 频点高密度密集波峰图、渐变面积填充）与 `AutocorrelationPlot`，彻底移除 6 点粗糙假折线。
>   - 导出 WAV 按钮移至右上角 AppBar actions，移除左下角浮动按钮。
>   - 首页音高徽标字号调整与 FittedBox 单行居中缩放，彻底消除换行现象。
>   - 音频导入与离线全曲分析器落地 (`AudioFileLoader` + `OfflineAudioAnalyzer` + `AudioAnalysisScreen`)，提供全览静态波形图、时间轴 Scrubber 与播放控制，全量 391 项自动化测试 100% 通过。

---

## 一、当前整体迁移进度一览

| 阶段编号 | 阶段名称 | 计划状态 | 代码状态 | 自动化测试状态 | 最终结论 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **阶段 1** | 全面代码审计与迁移设计方案 | 已完成 | 审计白皮书完备 | 189 项 Kotlin 单测验证通过 | **VERIFIED** |
| **阶段 2** | Flutter 独立工程脚手架与 M3 主题 | 已完成 | `e58c406` 提交 | M3 主题与 Note 模型单测通过 | **VERIFIED** |
| **阶段 3** | 纯 Dart DSP 算法引擎与基准测试 | 已完成 | `7a01bea` 提交 | 全量 78 项测试通过 | **VERIFIED** |
| **阶段 4** | 乐理模型、19种律制与 Scala IO | 已完成 | 全切片 4.1~4.6 完成 | 166 项单测全部通过 | **VERIFIED** |
| **阶段 5** | 平台音频流采集与 Isolate 并发管道 | 已完成 | 全切片 5.1~5.4 完成 | 61 项音频单测全部通过 | **VERIFIED** |
| **阶段 6** | 乐器调音主界面 (琴弦/表盘/历史图) | 已完成 | 全切片 6.1~6.4 完成 | 28 项 UI/Widget 测试全部通过 | **VERIFIED** |
| **阶段 7** | 乐器系统与科学调音 (五线谱/示波器) | 已完成 | 全切片 7.1~7.3 完成 | 32 项 Widget/单测全部通过 | **VERIFIED** |
| **阶段 8** | 偏好设置、16语种国际化与常亮适配 | 已完成 | 全切片 8.1~8.4 完成 | 41 项 Widget/单测全部通过 | **VERIFIED** |
| **阶段 9** | 端到端集成验收与真机声学调优 | 进行中 | 待真机验收 | 全量 370 项测试 100% 通过 | **IN_REVIEW** |

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
12. **阶段 4 / 切片 4.5: Scala (.scl & .kbm) 音阶与键盘映射解析与导出**:
   - 文件: `lib/domain/scala/scala_scale.dart`, `lib/domain/scala/keyboard_mapping.dart`, `lib/domain/scala/scala_note_helper.dart`, `lib/domain/scala/scala_parser.dart`, `lib/domain/scala/scala_serializer.dart`, `lib/domain/temperaments/custom_temperament.dart`
   - 完整支持 Huygens-Fokker 标准 Scala (.scl) 音阶解析与导出，涵盖纯律分数比率、纯整数比例、浮点小数音分、单/多音阶流、元数据注释提取与音符标注绑定。
   - 完整支持 Huygens-Fokker 键盘映射 (.kbm) 解析与导出，包含基准物理键、参考频率、中音键与非连续跳键（'x'）映射。
   - 实现 `CustomTemperament` 领域实体并接入抽象基类 `Temperament`，提供音阶频率与八度倍频计算，完全闭环接入调音评估管线。
   - 测试: `test/domain/scala_parser_test.dart` 17 组测试全部通过。
13. **阶段 4 / 切片 4.6: 预设乐器体系与琴弦音高模型 (Instrument Tunings)**:
    - 文件: `lib/domain/instruments/instrument.dart`, `lib/domain/instruments/instrument_icon.dart`, `lib/domain/instruments/predefined_instruments.dart`, `lib/domain/instruments/sorted_and_distinct_instrument_strings.dart`, `lib/domain/instruments/target_note_auto_detection.dart`, `lib/domain/instruments/instrument_io.dart`
    - 完整收录 15 种标准乐器与变格定弦预设库（半音模式、吉他标准/Drop D/DADGAD/Open D/Open G、贝斯 4/5/6 弦、提琴四重奏家族纯五度、尤克里里高四弦重返调弦与次中音调弦）。
    - 实现 `SortedAndDistinctInstrumentStrings`（琴弦去重排序与非音阶哨兵拦截）与 `TargetNoteAutoDetection`（双向迟滞门限防跳抖、极值弦向外无界判定与单弦乐器匹配）。
    - 实现与 Android Tuner 文本格式 100% 兼容的 `InstrumentIO` 序列化与反序列化工具。
    - 测试: `test/domain/instrument_tuning_test.dart` 18 组测试全部通过。

14. **阶段 5 / 切片 5.1: 音频输入源抽象与模拟流发生器 (AudioSource & MockAudioSource)** (`VERIFIED`):
    - 文件: `lib/audio/audio_source_interface.dart`, `lib/audio/mock_audio_source.dart`
    - 完善 `AudioSource` 统一生命周期抽象与状态流（`idle`, `recording`, `paused`, `error`, `disposed`）及强类型硬件错误分级体系。
    - 纯 Dart 实现高保真声学模拟发生器 `MockAudioSource` 与多波形体系（`MockSilenceSignal`, `MockSineWaveSignal`, `MockHarmonicSignal`, `MockWhiteNoiseSignal`, `MockFrequencySweepSignal`, `MockCustomSignal`），支持钢琴/弦乐刚度非谐性系数 $B$ 色散计算与 Nyquist 防镜像保护。
    - 严格保证跨帧连续时间步进与跨 `pause()`/`resume()` 相位连续性（Phase Continuity），杜绝接缝截断咔哒声，支持实时定时推流与单元测试确定性手动推流。
    - 测试: `test/unit/audio_source_test.dart` 19 组测试全部通过。
15. **阶段 5 / 切片 5.2: 无锁环形采样缓冲队列 (AudioRingBuffer)** (`VERIFIED`):
    - 文件: `lib/audio/audio_ring_buffer.dart`, `lib/audio/ring_buffer.dart`
    - 纯 Dart 高性能定长环形队列，支持 `Float32List` 底层块写入与 `Int16List` 零内存分配浮点归一化写入（`1.0 / 32768.0`）。
    - 完整支持重叠滑动分析时窗提取（`read(destination, windowSize, stride)`），支持任意重叠率步长推进与欠载零拷贝防护。
    - 提供非破坏性最新波形快照提取（`getLatestSnapshot`），自动跨越回卷边界并以前置静音平滑补齐，供 UI 示波器与 WAV 录音器安全共享，绝不阻断 DSP 消费读指针。
    - 支持灵活的溢出保护策略（默认覆盖最老采样保证实时低延迟，或拒绝溢出）与丢包、溢出次数完整诊断统计。
    - 测试: `test/unit/ring_buffer_test.dart` 23 组测试全部通过。
16. **阶段 5 / 切片 5.3: Isolate 后台计算并发隔离与消息通信总线 (AudioProcessingIsolate)** (`VERIFIED`):
    - 文件: `lib/audio/audio_processing_isolate.dart`, `lib/audio/audio_messages.dart`
    - 基于原生 Dart `Isolate.spawn` 搭建独立的后台音频与 DSP 运算线程，将加窗、自相关、FFT、MPM/TWM 多引擎计算及平滑滤波 100% 移出 UI 主线程。
    - 建立强类型双向通信消息总线（`AudioDataMessage`, `ConfigureDspMessage`, `ResetDspMessage`, `DisposeWorkerMessage` $\leftrightarrow$ `WorkerReadyMessage`, `AudioAnalysisResult`, `WorkerErrorMessage`），支持实时动态热更测频算法、声学计权与时窗参数。
    - 主线程集成高精度零延迟时间戳 UI 节流器（`setThrottleFps`，默认 60 FPS），有效平抑高频重绘负载，彻底杜绝 UI 掉帧卡顿；同时保留直通全速流（`unthrottledResultStream`）以保障科学示波与单测精度。
    - 后台 Worker 集成实时 FFT 频域幅值谱计算，为后续科学示波界面提供开箱即用的高精数据。
    - 测试: `test/unit/audio_isolate_test.dart` 7 组测试全部通过。
17. **阶段 5 / 切片 5.4: 平台真实麦克风硬件驱动集成 (MicrophoneAudioSource)** (`VERIFIED`):
    - 文件: `lib/audio/microphone_audio_source.dart`
    - 封装 `MicrophoneDriver` 硬件驱动门面，基于 cross-platform `record` 插件实现 44.1kHz 低延迟单声道 16-bit PCM 采集，显式关闭系统级人声降噪、回声消除与自动增益（AGC/AEC/ANS），完整保留乐器微弱高次泛音。
    - 实现对齐与非对齐容错的 16-bit PCM 字节到 Float32List 归一化转换器（`pcm16BytesToFloat32`），防御性处理奇数字节偏移与截断。
    - 集成 `WidgetsBindingObserver` 生命周期管理：后台/锁屏状态下自动暂停释放麦克风硬件并熄灭系统隐私指示灯，回到前台无感自动唤醒恢复。
    - 完整支持权限拒绝降级（`PermissionDeniedError`）与硬件流异常恢复（`MicrophoneUnavailableError`）。
    - 测试: `test/unit/microphone_audio_source_test.dart` 12 组测试全部通过。
18. **阶段 6 / 切片 6.1: 乐器专属矢量图标库 (15 种全覆盖) 与顶部乐器卡片 (InstrumentButton)** (`VERIFIED`):
    - 文件: `lib/ui/plot/plot_window_outline.dart`, `lib/ui/instruments/instrument_icons.dart`, `lib/ui/instruments/instrument_button.dart`
    - 1:1 严格对标 Kotlin `app/src/main/res/drawable/ic_*.xml` 矢量资源，纯 Dart 实现全量 15 款乐器矢量图标库（吉他、电吉他、贝斯、低音提琴、大提琴、小提琴、尤克里里、钢琴、小号、萨克斯、长笛、竖琴、塔尔琴、塞塔尔琴、卡曼恰琴），彻底杜绝用通用占位符或简省图标糊弄过关的问题。
    - 1:1 严格对标 Kotlin `InstrumentButton.kt` 实现 Material 3 大号卡片 `InstrumentButton`，封装 `PlotWindowOutline` 边框参数，支持当前乐器图标、名称自适应居中与截断防溢出、点击事件、以及律制不兼容时的 `errorMessage` 错误警示态（自动切换为 `error` 边框与 `errorContainer` 语义底色）。
    - 测试: `test/unit/plot_window_outline_test.dart` (3 组单测), `test/widget/instrument_icons_test.dart` (3 组测试), `test/widget/instrument_button_test.dart` (4 组交互与布局测试)，全量 10 项新增测试 100% 通过。

---

## 四、当前阶段与全量交付状态

- **当前进展**: 阶段 6、7、8 全部功能切片已施工完成，并完成用户反馈的 4 项核心 Bug 深度修复（律制体系补齐至 5-72 EDO、设置项全量汉化、基准频率实时填充与 G44 格式修复、DSP 频域加窗与声学计权优化及 100% 测试加固）。
- **当前状态**: 全量 361 项自动化测试 100% 通过（361/361），静态分析零 warning 零 error，代码格式 100% 符合规范，准备交由用户验收。
