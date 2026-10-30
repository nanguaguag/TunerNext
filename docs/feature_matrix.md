# 双端全量功能对照矩阵 (Feature Traceability Matrix)

> **基线分支**: Kotlin: `feature/advanced-pitch-algorithms` (`d570fa9`) | Flutter: `feature/rollback` (`e58c406`)  
> **审计原则**: 以实际代码调用链和自动化测试为事实依据，杜绝纸面完成。  
> **状态枚举**: `NOT_STARTED`, `IN_PROGRESS`, `IMPLEMENTED`, `TESTED`, `VERIFIED`, `BLOCKED`

---

## 1. 页面与导航系统 (Navigation & Pages)

| ID | 功能名称 | Kotlin 源码位置及行为 | Flutter 对应文件/方法 | 实现度 | 依赖项 | 测试文件/用例 | 测试结果 | 尚未完成工作 | 最终验收标准 | 当前状态 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **NAV-01** | 主导航切换 (侧栏/底部栏) | `MainActivity.kt`, `MainGraph.kt`: 支持在乐器调音与科学示波器间无缝切换，保留音频流状态。 | 无 | 0% | 无 | 无 | 未测试 | 需在 M3 NavigationBar/NavigationDrawer 中搭建路由并持久化页面索引。 | 页面平滑切换且后台音频处理不中断。 | `NOT_STARTED` |
| **NAV-02** | 乐器调音主界面 | `ui/screens/InstrumentTuner.kt`: 集中渲染音高历史波形、琴弦列表与音分偏差指示器。 | 无 | 0% | NAV-01, UI-01, UI-02 | 无 | 未测试 | 迁移 `InstrumentTunerScreen` 布局与响应式布局适配。 | 竖屏与横屏下琴弦与仪表盘正常渲染。 | `NOT_STARTED` |
| **NAV-03** | 科学调音界面 | `ui/screens/ScientificTuner.kt`: 集中渲染 FFT 功率谱、互相关波形与示波器。 | 无 | 0% | NAV-01, UI-05, UI-06 | 无 | 未测试 | 迁移三图联动视图与手势缩放控制。 | 60 FPS 实时更新频谱与自相关波形。 | `NOT_STARTED` |
| **NAV-04** | 乐器选择与编辑导航图 | `navigation/InstrumentEditorGraph.kt`: 乐器列表、增删改自定义琴弦。 | 无 | 0% | INST-01~05 | 无 | 未测试 | 建立乐器管理二级路由及对话框流。 | 可自定义增删乐器并立即作用于主页。 | `NOT_STARTED` |
| **NAV-05** | 律制总览与编辑器导航图 | `navigation/TemperamentEditorGraph.kt`: 预设 19 种律制选择与自定义律制音分编辑。 | 无 | 0% | THEORY-03~06 | 无 | 未测试 | 建立律制编辑二级路由与 Scala 文件导入交互。 | 律制切换即时反馈至调音目标频率。 | `NOT_STARTED` |
| **NAV-06** | 延展调音 (Railsback) 导航图 | `navigation/StretchTuningEditorGraph.kt`: 钢琴多项式延展曲线图与自定义散点编辑。 | 无 | 0% | THEORY-07 | 无 | 未测试 | 建立延展调音图表编辑界面。 | 散点拟合曲线平滑渲染与持久化。 | `NOT_STARTED` |
| **NAV-07** | 偏好设置导航图 | `navigation/PreferenceGraph.kt`: 分组 Material 偏好设置页面及弹窗。 | 无 | 0% | PREF-01~22 | 无 | 未测试 | 搭建 M3 偏好设置列表路由。 | 所有设置项均能正常弹出与保存。 | `NOT_STARTED` |

---

## 2. 用户交互与视图组件 (UI & Views)

| ID | 功能名称 | Kotlin 源码位置及行为 | Flutter 对应文件/方法 | 实现度 | 依赖项 | 测试文件/用例 | 测试结果 | 尚未完成工作 | 最终验收标准 | 当前状态 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **UI-01** | 琴弦侧边栏与高亮 | `ui/screens/InstrumentTuner.kt`: 根据当前检测音高自动高亮最近琴弦，并绘制不同粗细弦线。 | 无 | 0% | INST-01, THEORY-01 | 无 | 未测试 | 自定义 RenderObject 或 Canvas 绘制琴弦厚度与动态高亮。 | 自动定位匹配琴弦，支持触摸反馈。 | `NOT_STARTED` |
| **UI-02** | 音分偏差表盘与读数 | `ui/screens/InstrumentTuner.kt`: 动态平滑指针显示 $\pm 50$ 音分偏差与精确数值文本。 | 无 | 0% | THEORY-08 | 无 | 未测试 | 实现 M3 风格刻度表盘与阻尼动画。 | 音分读数无抖动，超限平滑截断。 | `NOT_STARTED` |
| **UI-03** | 三态调准指示圆点 | `ui/screens/InstrumentTuner.kt`: 音分偏差在容限内显绿，偏低显橙，偏高显紫，并带指示箭头。 | 无 | 0% | UI-02, PREF-14 | 无 | 未测试 | 实现带迟滞效应（Hysteresis）的状态圆点。 | 准音时绿色亮起且在临界点不闪烁。 | `NOT_STARTED` |
| **UI-04** | 对数音高历史曲线 | `ui/tuning/PitchHistory.kt`: 带有半音网格背景的对数时间轴音高轨迹实时滚动。 | 无 | 0% | DSP-16 | 无 | 未测试 | 实现双缓冲 Canvas 滚动绘制与静音断裂渲染。 | 实时滑动无 GC 卡顿，静音段不连线。 | `NOT_STARTED` |
| **UI-05** | 实时 FFT 功率谱图 | `ui/tuning/FrequencyPlot.kt`: 渲染 0-20kHz 频谱峰值，对数/线性切换，谐波标记。 | 无 | 0% | DSP-01, DSP-06 | 无 | 未测试 | Canvas 绘制频域曲线与谐波序号标注。 | 准确定位主频及谐波位置。 | `NOT_STARTED` |
| **UI-06** | 归一化自相关波形图 | `ui/tuning/CorrelationPlot.kt`: 渲染 0-20ms 时域自相关序列，带零延迟基线。 | 无 | 0% | DSP-03, DSP-04 | 无 | 未测试 | Canvas 绘制波形图与首峰滞后标记。 | 周期波形清晰稳定，峰值与音高对应。 | `NOT_STARTED` |
| **UI-07** | 时域示波器原始波形 | `ui/screens/ScientificTuner.kt`: 实时绘制音频采样的真实时域振幅波形。 | 无 | 0% | AUDIO-06 | 无 | 未测试 | 循环缓冲波形平滑绘制组件。 | 显示清晰的声波震荡波形。 | `NOT_STARTED` |
| **UI-08** | Gonville 矢量五线谱 | `ui/notes/NoteStaff.kt`: 渲染高音/低音谱号、音符符头及升降调号。 | 无 | 0% | THEORY-01 | 无 | 未测试 | 引入 Gonville 字体或 SVG 路径解析渲染五线谱。 | 正确展示各音域音符及变音记号。 | `NOT_STARTED` |
| **UI-09** | 手动锁定目标琴弦 | 点击琴弦进入固定频率检测模式，抑制自动跳转。 | 无 | 0% | UI-01 | 无 | 未测试 | 状态机集成目标锁定模式。 | 锁定后只计算与锁定弦的目标偏差。 | `NOT_STARTED` |
| **UI-10** | 自动/锁定模式切换 | 触摸空白处或再点击解锁，恢复全局自由音高捕捉。 | 无 | 0% | UI-09 | 无 | 未测试 | 状态机解锁逻辑与 UI 动效。 | 解锁后立即恢复全音域实时跟踪。 | `NOT_STARTED` |
| **UI-11** | 历史曲线时窗缩放 | 支持通过设置或双指缩放调整历史观察时长 (1s-10s)。 | 无 | 0% | UI-04, PREF-11 | 无 | 未测试 | 手势识别与时间轴重新映射。 | 缩放流畅，时间刻度自动对齐。 | `NOT_STARTED` |
| **UI-12** | WAV 录音导出与分享 | `misc/WaveWriter.kt`, `misc/ShareData.kt`: 将环形缓冲区音频写入 16-bit PCM WAV。 | 无 | 0% | AUDIO-07, PLAT-03 | 无 | 未测试 | 编写纯 Dart WAV 编码器与分享通道。 | 导出的 WAV 文件可正常播放。 | `NOT_STARTED` |

---

## 3. 设置项与持久化 (Preferences & Persistence)

| ID | 功能名称 | Kotlin 源码位置及行为 | Flutter 对应文件/方法 | 实现度 | 依赖项 | 测试文件/用例 | 测试结果 | 尚未完成工作 | 最终验收标准 | 当前状态 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **PREF-01** | 基准音 A4 频率调节 | `ReferenceNoteDialog.kt`: 范围 390.0 - 490.0 Hz，步长 0.1 Hz，默认 440.0 Hz。 | 无 | 0% | THEORY-02 | 无 | 未测试 | `SharedPreferences` 存储与全局 Provider 联动。 | 修改后全局目标频率全部重算。 | `NOT_STARTED` |
| **PREF-02** | 律制选择 | `TemperamentDialog2.kt`: 12-EDO 及 19 种历史律制选择。 | 无 | 0% | THEORY-03,05 | 无 | 未测试 | 律制列表持久化与切换逻辑。 | 切换后所有音符基准音分即时更新。 | `NOT_STARTED` |
| **PREF-03** | 自定义律制与 Scala | `ui/temperaments/`: 导入 .scl 文件或手动编辑音分比率。 | 无 | 0% | THEORY-06 | 无 | 未测试 | 文件选择器集成与自定义律制数据库。 | 正确解析合法 scl 文本并持久化。 | `NOT_STARTED` |
| **PREF-04** | 调式主音 Root Note | `RootNoteDialog.kt`: C 到 B 12 个半音作为律制基准主音。 | 无 | 0% | THEORY-01 | 无 | 未测试 | 主音切换状态机。 | 非十二平均律下主音切换影响各级音高。 | `NOT_STARTED` |
| **PREF-05** | 音符记谱法系统 | `NotationDialog.kt`: 国际通用 (C, D, E)、唱名 (Do, Re, Mi)、北欧式 (C, D...H) 等。 | 无 | 0% | THEORY-01 | 无 | 未测试 | NoteNameFormatter 格式化器。 | UI 上所有音符名称按所选体系显示。 | `NOT_STARTED` |
| **PREF-06** | 音高算法引擎选择 | `PitchAlgorithmDialog.kt`: Classic, Hybrid Jacobsen, MPM, TWM, pYIN。 | `lib/domain/models/dsp_enums.dart` | 20% | DSP-07~12 | 无 | 未测试 | 在 Pipeline 中建立动态多态策略工厂。 | 切换算法引擎即时生效，无需重启应用。 | `NOT_STARTED` |
| **PREF-07** | FFT 窗函数选择 | `WindowingFunctionDialog.kt`: Tophat, Hanning, Hamming。 | `lib/domain/models/dsp_enums.dart` | 20% | DSP-02 | 无 | 未测试 | 窗函数参数接入 DSP 流。 | 窗函数动态更换且重新计算积分衰减。 | `NOT_STARTED` |
| **PREF-08** | 时窗大小 Buffer Size | 1024, 2048, 4096, 8192 采样点切换。 | `lib/core/constants/acoustic_constants.dart` | 20% | AUDIO-03, DSP-01 | 无 | 未测试 | 动态重建 FFT 内部查表与缓冲区大小。 | 变更大小后不发生内存越界。 | `NOT_STARTED` |
| **PREF-09** | 重叠率 Overlap | 0%, 25%, 50%, 75% 步长控制。 | 无 | 0% | AUDIO-03 | 无 | 未测试 | 环形缓冲区提取步长动态调节。 | 帧率随着重叠率增加而相应提升。 | `NOT_STARTED` |
| **PREF-10** | 频域声学计权模式 | None, A-weighting, C-weighting。 | `lib/domain/models/dsp_enums.dart` | 20% | DSP-06 | 无 | 未测试 | 计权曲线应用至频谱与谐波统计。 | A计权下50Hz工频分量显著削弱。 | `NOT_STARTED` |
| **PREF-11** | 历史曲线时长 | 1s 至 10s 滑动调节。 | 无 | 0% | UI-04 | 无 | 未测试 | 历史缓冲区容量与时间缩放绑定。 | 历史图时间跨度与设置精确一致。 | `NOT_STARTED` |
| **PREF-12** | 滑动平滑采样数 | 1 至 10 次滑动窗口平均。 | `lib/core/constants/acoustic_constants.dart` | 20% | DSP-16 | 无 | 未测试 | 控制器动态更新平滑器阶数。 | 设置为1时响应最快，大值时最稳定。 | `NOT_STARTED` |
| **PREF-13** | 频率检测上下限 | 默认 16.0 Hz - 20000.0 Hz。 | `lib/core/constants/acoustic_constants.dart` | 20% | DSP-07~11 | 无 | 未测试 | 门限拦截器集成。 | 超出范围的频率直接判为静音。 | `NOT_STARTED` |
| **PREF-14** | 调准容限范围 | 默认 $\pm 3.0$ 音分 (可调 1-10 cents)。 | `lib/core/constants/acoustic_constants.dart` | 20% | UI-03 | 无 | 未测试 | 准音判定阈值配置化。 | 绿色指示灯严格在设定音分内点亮。 | `NOT_STARTED` |
| **PREF-15** | 八度跳变门控使能 | 防止泛音混淆导致的突发翻倍。 | 无 | 0% | DSP-15 | 无 | 未测试 | 门控使能开关。 | 开启后单帧八度跳变被折叠。 | `NOT_STARTED` |
| **PREF-16** | 中值滤波使能 | 3-tap 中值滤波消除尖刺噪声。 | 无 | 0% | DSP-14 | 无 | 未测试 | 滤波使能开关。 | 开启后单采样脉冲噪声被滤除。 | `NOT_STARTED` |
| **PREF-17** | 应用主题模式 | System, Light, Dark, Pure Black (OLED)。 | `lib/core/theme/tuner_theme.dart` | 80% | UI 主题规范 | `test/widget_test.dart` | 通过 | 持久化并在设置页提供三态单选。 | 纯黑模式下背景 `#000000` 无发光。 | `TESTED` |
| **PREF-18** | 屏幕常亮 Wakelock | 调音期间保持屏幕常亮不熄屏。 | 无 | 0% | PLAT-01 | 无 | 未测试 | 集成 `wakelock_plus` 插件并监听偏好。 | 开关开启时屏幕不进入休眠。 | `NOT_STARTED` |
| **PREF-19** | 应用多语言切换 | 强制指定或跟随系统 (16 语言)。 | 无 | 0% | I18N-01 | 无 | 未测试 | 接入 `flutter_localizations` 与 arb。 | 切换语言后所有 UI 文本即时更新。 | `NOT_STARTED` |
| **PREF-20** | 延展调音使能与系数 | 开启钢琴延展曲线及刚度系数 $B$。 | 无 | 0% | THEORY-07 | 无 | 未测试 | 延展算法接入目标频率计算链路。 | 极低音微降，极高音微升。 | `NOT_STARTED` |
| **PREF-21** | 次谐波容差与峰值比 | 设定 subharmonicsTolerance 与 ratio。 | 无 | 0% | DSP-07 | 无 | 未测试 | 算法参数暴露至专家设置项。 | 严格按设定比率判定次谐波。 | `NOT_STARTED` |
| **PREF-22** | 恢复默认设置 | 弹出警告对话框并全量清空重置。 | `ui/preferences/ResetDialog.kt` | 0% | PREF-01~21 | 无 | 未测试 | 还原默认值并刷新全局状态。 | 所有设置项回归标准基线。 | `NOT_STARTED` |

---

## 4. 音频采集与生命周期 (Audio & Lifecycle)

| ID | 功能名称 | Kotlin 源码位置及行为 | Flutter 对应文件/方法 | 实现度 | 依赖项 | 测试文件/用例 | 测试结果 | 尚未完成工作 | 最终验收标准 | 当前状态 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **AUDIO-01** | 麦克风动态权限与拒绝处理 | `TunerApplication.kt`, `MainActivity.kt`: 请求 `RECORD_AUDIO`，被拒提示并引导打开设置。 | 无 | 0% | `permission_handler` | 无 | 未测试 | 编写权限处理状态机与引导对话框。 | 拒绝权限时提示友好且不崩溃。 | `NOT_STARTED` |
| **AUDIO-02** | 硬件音频流采集 (PCM 16-bit) | `AudioRecord` 初始化为 44100Hz 单声道低延迟流。 | `lib/audio/audio_source_interface.dart` (接口定义) | 10% | 平台音频驱动 | 无 | 未测试 | 采用 `record` 插件流式读取原始字节或编写平台通道。 | 音频稳定以 44.1kHz 持续推入。 | `NOT_STARTED` |
| **AUDIO-03** | 无锁环形缓冲区 | 生产者推入音频流，消费者按窗口大小提取帧。 | 无 | 0% | AUDIO-02 | 无 | 未测试 | 纯 Dart 实现定长环形 Float32 队列。 | 高负载下不发生内存分配与卡顿。 | `NOT_STARTED` |
| **AUDIO-04** | 应用生命周期休眠与唤醒 | App 退火至后台或锁屏时暂停 AudioRecord，返回前台恢复。 | 无 | 0% | `WidgetsBindingObserver` | 无 | 未测试 | 绑定 AppLifecycleState 控制采集启停。 | 后台运行时麦克风占用指示灯熄灭。 | `NOT_STARTED` |
| **AUDIO-05** | 音频外设插拔与硬件重连 | 蓝牙耳机、有线耳机插拔广播监听及采样重置。 | 无 | 0% | AUDIO-02 | 无 | 未测试 | 监听路由切换事件并平滑重启音频源。 | 外设切换时无死锁且自动恢复调音。 | `NOT_STARTED` |
| **AUDIO-06** | 浮点归一化与直流偏置消除 | 将 16-bit PCM 转换为 $[-1.0, 1.0]$ 并减去直流分量均值。 | 无 | 0% | AUDIO-02 | 无 | 未测试 | 向量化时域样本预处理。 | 消除零漂移，振幅保持线性。 | `NOT_STARTED` |
| **AUDIO-07** | 科学波形快照缓冲 | 保持最新的 4096 采样供时域波形图与 WAV 写入共享。 | 无 | 0% | AUDIO-03 | 无 | 未测试 | 线程安全快照克隆。 | UI 获取最新波形不阻断音频流。 | `NOT_STARTED` |

---

## 5. DSP 信号处理与音高检测引擎 (DSP & Pitch Algorithms)

| ID | 功能名称 | Kotlin 源码位置及行为 | Flutter 对应文件/方法 | 实现度 | 依赖项 | 测试文件/用例 | 测试结果 | 尚未完成工作 | 最终验收标准 | 当前状态 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **DSP-01** | 实数/复数 Radix-2 FFT/IFFT | `notedetection/FFT.kt`: 原版含结合过程。重构版需消除 `FORK-NEW-02` 原地覆盖缺陷。 | 无 (已回滚待重写) | 0% | 无 | 无 | 未测试 | 编写纯 Dart 高性能 `FFT` 类，消除原地读写冲突。 | NumPy 向量差分比对误差 $< 10^{-5}$。 | `NOT_STARTED` |
| **DSP-02** | 窗函数及数值积分 | `notedetection/Windowing.kt`: Tophat, Hanning, Hamming 窗口及能量积分因子。 | 无 | 0% | 无 | 无 | 未测试 | 纯 Dart 实现向量加窗与面积积分。 | 窗函数能量衰减补偿与理论一致。 | `NOT_STARTED` |
| **DSP-03** | 零填充自相关计算器 | `notedetection/Correlation.kt`: 零填充至 $2N$，通过 FFT/IFFT 快速计算离散互相关。 | 无 | 0% | DSP-01, DSP-02 | 无 | 未测试 | 移植 `CorrelationComputer` 并支持位反转直充。 | 与时域直接相关比对误差 $< 10^{-4}$。 | `NOT_STARTED` |
| **DSP-04** | 归一化自相关波形缓冲 | `AutoCorrelation.kt`: 将自相关序列归一化至 $[0.0, 1.0]$ 供 UI 曲线渲染。 | 无 | 0% | DSP-03 | 无 | 未测试 | 计算零延迟最大值与动态范围重映射。 | 波形垂直居中且动态缩放稳定。 | `NOT_STARTED` |
| **DSP-05** | 三点抛物线极值精修 | `MaximumOfPolynomialFit.kt`: 连续二次插值求极值点与峰值。 | 无 | 0% | 无 | 无 | 未测试 | 实现带零分母保护与边界截断的抛物线拟合。 | 对称二次曲线极值恢复误差为 0。 | `NOT_STARTED` |
| **DSP-06** | IEC 61672-1 声学计权滤波 | `AcousticWeighting.kt`: A-weighting 与 C-weighting 频响公式。 | 无 | 0% | 无 | 无 | 未测试 | 实现计权因子计算与 1000Hz 归一化。 | 50Hz 工频交流电衰减 $> 30\text{ dB}$。 | `NOT_STARTED` |
| **DSP-07** | 经典自相关检测器 (Classic) | `CorrelationBasedFrequency.kt`: 首个极小值搜索、全局最大值与次谐波惩罚判决。 | 无 | 0% | DSP-03, DSP-05 | 无 | 未测试 | 移植经典检测状态机，集成 15% 零延迟能量门限。 | 440Hz 纯音测量误差 $< 0.2\text{ Hz}$。 | `NOT_STARTED` |
| **DSP-08** | 复数 3-bin Jacobsen 插值 | `AccurateSpectrumPeakFrequency.kt`: 利用复频谱实部虚部插值突破 FFT 频率分辨率限制。 | 无 | 0% | DSP-01 | 无 | 未测试 | 移植 Jacobsen 公式，确保偏移量符号准确。 | 偏离 Bin 中心频率时准确纠偏。 | `NOT_STARTED` |
| **DSP-09** | 帧间相位差分 Phase Vocoder | `AccurateSpectrumPeakFrequency.kt`: 利用两帧间相位旋转度与时间差超精确求解。 | 无 | 0% | DSP-01 | 无 | 未测试 | 实现对称相位展开与整周数折叠。 | 连续音频帧频率解析精度 $< 0.01\text{ Hz}$。 | `NOT_STARTED` |
| **DSP-10** | McLeod Pitch Method (MPM) | `McLeodPitchMethod.kt`: 计算 NSDF，通过首峰阈值比（0.85）抑制八度倍频。 | 无 | 0% | DSP-03, DSP-05 | 无 | 未测试 | 移植 MPM 算法，实现清晰度判定与阈值过滤。 | 小提琴高音 E6 绝不误判为翻倍八度。 | `NOT_STARTED` |
| **DSP-11** | Two-Way Mismatch (TWM) | 预测谐波与测量谱峰双向失配误差度量，刚度系数 $B$ 非谐性补偿。 | 无 | 0% | DSP-01, DSP-05 | 无 | 未测试 | 实现 Maher & Beauchamp TWM 与旁瓣抑制。 | 缺失基频谐波信号正确锁定真实基频。 | `NOT_STARTED` |
| **DSP-12** | Probabilistic YIN (pYIN) | 差分函数、累积均值归一化差分（CMNDF）与隐马尔可夫 Viterbi 路径解码。 | 无 | 0% | 无 | 无 | 未测试 | 实现 pYIN 观测概率计算与状态平滑转移。 | 高噪声弱信号下提供最高跟踪置信度。 | `NOT_STARTED` |
| **DSP-13** | ACOUSTIC-01 静音门限 | 双层静音防护：时域 RMS $< 10^{-4}$ + 自相关峰值 $< 0.15 \times R_{xx}(0)$。 | 无 | 0% | AUDIO-06, DSP-03 | 无 | 未测试 | 在管线头部与自相关判决处植入双重防护。 | 静音环境下绝不发生 G1-D3 乱跳。 | `NOT_STARTED` |
| **DSP-14** | 三阶时域中值滤波 | `PitchTemporalFilter.kt`: 维护最近 3 帧输出，取中值消除孤立脉冲。 | 无 | 0% | 无 | 无 | 未测试 | 实现 `PitchMedianFilter` 循环队列。 | 单帧极值噪声被彻底剔除。 | `NOT_STARTED` |
| **DSP-15** | 八度跳变门控 (Jump Gate) | `PitchTemporalFilter.kt`: 识别 8% 八度跳跃并要求持续 2 帧才确认切换。 | 无 | 0% | 无 | 无 | 未测试 | 实现 `OctaveJumpGate` 折叠状态机。 | 瞬态破音跳度被平滑吸附。 | `NOT_STARTED` |
| **DSP-16** | 离群点剔除平滑器 | `OutlierRemovingSmoother.kt`: 多缓冲区循环平均，自动剔除偏离过大的噪点。 | 无 | 0% | 无 | 无 | 未测试 | 纯 Dart 移植多环形平滑队列。 | 调音指示平稳收敛且不牺牲瞬态响应。 | `NOT_STARTED` |
| **DSP-17** | 琴弦非谐性系数估算 | `Inharmonicity.kt`: 分析高次谐波偏离理想整数倍的曲率，提取刚度系数 $B$。 | 无 | 0% | DSP-05 | 无 | 未测试 | 移植非谐性最小二乘拟合器。 | 正确输出钢琴与低音提琴真实 $B$ 值。 | `NOT_STARTED` |

---

## 6. 乐理模型、律制与延展调音 (Musical Theory & Temperaments)

| ID | 功能名称 | Kotlin 源码位置及行为 | Flutter 对应文件/方法 | 实现度 | 依赖项 | 测试文件/用例 | 测试结果 | 尚未完成工作 | 最终验收标准 | 当前状态 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **THEORY-01**| 音符实体与音名表示 | `musicalscale/MusicalScale.kt`: 八度、音级、半音偏置、变音记号。 | `lib/domain/models/musical_note.dart` | 80% | 无 | `test/domain/musical_note_test.dart` | 通过 | 支持多种语言变音符号 (♯, ♭, ♮) 与 Unicode 兼容输出。 | 完整覆盖 C-1 到 B9 范围音符与音名。 | `TESTED` |
| **THEORY-02**| 频率与音符转换公式 | $f = f_{A4} \cdot 2^{(n - 69)/12}$，支持反向求最近音符与音分偏差。 | 无 | 0% | THEORY-01 | 无 | 未测试 | 实现高精度对数音符映射器。 | 440Hz 对应 A4 (0 cents)，差分 $< 10^{-5}$。 | `NOT_STARTED` |
| **THEORY-03**| 十二平均律 (12-EDO) | 标准 100 cents/半音均匀分布。 | 无 | 0% | THEORY-02 | 无 | 未测试 | 封装标准平均律基类。 | 纯八度频率严格为 2.0 倍。 | `NOT_STARTED` |
| **THEORY-04**| 微分音等分律制 (EDO 5-72) | 支持 19-EDO, 24-EDO, 31-EDO, 41-EDO, 53-EDO 等。 | 无 | 0% | THEORY-02 | 无 | 未测试 | 支持动态分段等分八度。 | 任意等分数下音分间隔严格相等。 | `NOT_STARTED` |
| **THEORY-05**| 19 种欧洲历史良律与纯律 | 纯律、毕达哥拉斯律、1/4逗音中庸律、Werckmeister III、Kirnberger III 等。 | 无 | 0% | THEORY-01 | 无 | 未测试 | 移植 19 组历史音分偏移基准数组。 | 与 Kotlin 版本音分表逐音符一致。 | `NOT_STARTED` |
| **THEORY-06**| Scala (.scl) 格式解析与导出 | 支持读取标准 Huygens-Fokker Scala 音阶定义文本。 | 无 | 0% | 无 | 无 | 未测试 | 编写纯 Dart `.scl` 解析器与序列化器。 | 成功解析包含纯律分数与小数音分的 scl。 | `NOT_STARTED` |
| **THEORY-07**| Railsback 延展调音曲线 | 钢琴低音下沉、高音抬升的经验五次多项式模型。 | 无 | 0% | THEORY-02 | 无 | 未测试 | 移植多项式求值器与散点插值器。 | A0 延展约 -30 cents，C8 延展约 +35 cents。| `NOT_STARTED` |
| **THEORY-08**| 音分偏差对数计算 | $\text{cents} = 1200 \times \log_2(f_{\text{actual}} / f_{\text{target}})$。 | 无 | 0% | 无 | 无 | 未测试 | 实现数值安全（防零防负）音分转换函数。 | 频率翻倍严格输出 1200.0 音分。 | `NOT_STARTED` |

---

## 7. 预设乐器与自定义琴弦 (Built-in Instruments & Tunings)

| ID | 功能名称 | Kotlin 源码位置及行为 | Flutter 对应文件/方法 | 实现度 | 依赖项 | 测试文件/用例 | 测试结果 | 尚未完成工作 | 最终验收标准 | 当前状态 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **INST-01** | 吉他系列预设 | 标准 EADGBE, Drop D, DADGAD, Open G, Open D 等 10+ 种调弦。 | 无 | 0% | THEORY-01 | 无 | 未测试 | 建立乐器预设数据库。 | 琴弦音高与名称严格符合乐理标准。 | `NOT_STARTED` |
| **INST-02** | 贝斯系列预设 | 4弦标准 (EADG), 5弦标准 (BEADG), 6弦标准。 | 无 | 0% | THEORY-01 | 无 | 未测试 | 录入贝斯低音音符模型。 | 正确映射至低八度目标频率。 | `NOT_STARTED` |
| **INST-03** | 提琴家族预设 | 小提琴 (GDAE), 中提琴 (CGDA), 大提琴, 低音提琴。 | 无 | 0% | THEORY-01 | 无 | 未测试 | 录入提琴纯五度传统调弦。 | 准确覆盖弓弦乐器全系调弦。 | `NOT_STARTED` |
| **INST-04** | 尤克里里预设 | 标准高音 GCEA 与低音 Baritone DGBE。 | 无 | 0% | THEORY-01 | 无 | 未测试 | 录入尤克里里预设。 | 正确支持高四弦重返调音（Re-entrant）。 | `NOT_STARTED` |
| **INST-05** | 自定义乐器创建与增删改 | `ui/instruments/InstrumentEditor.kt`: 自定义琴弦数量、指定任意音符与选择图标。 | 无 | 0% | INST-01, DATA-01 | 无 | 未测试 | 乐器编辑表单组件与本地 SQLite/JSON 持久化。 | 新增乐器即时可用，支持重命名与删除。 | `NOT_STARTED` |

---

## 8. 多语言国际化与无障碍 (I18N & Accessibility)

| ID | 功能名称 | Kotlin 源码位置及行为 | Flutter 对应文件/方法 | 实现度 | 依赖项 | 测试文件/用例 | 测试结果 | 尚未完成工作 | 最终验收标准 | 当前状态 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **I18N-01** | 16 种系统语言本地化 | EN, DE, FR, ES, IT, JA, ZH, RU, PL, PT, TR, NL, CS, HU, UK, AR 文本资源。 | 无 | 0% | `flutter_localizations` | 无 | 未测试 | 提取原版 xml 字符串，转换为 Flutter `.arb` 结构。 | 16 种语言界面文本完整对齐无缺失。 | `NOT_STARTED` |
| **I18N-02** | 记谱法多语言映射 | 欧洲特定国家（德语区将 B 称为 H，B♭ 称为 B）自动适配。 | 无 | 0% | THEORY-01 | 无 | 未测试 | 记谱本地化转换字典。 | 德语环境下正确显示 H 与 B。 | `NOT_STARTED` |
| **I18N-03** | 屏幕阅读与语义标签 | TalkBack 旁白朗读当前音高、偏差方向与锁定状态。 | 无 | 0% | 无 | 无 | 未测试 | 为表盘与圆点附加 `Semantics` 辅助信息。 | 盲人模式下能通过无障碍语音顺利调音。 | `NOT_STARTED` |

---

## 9. 平台系统与服务交互 (Platform & Services)

| ID | 功能名称 | Kotlin 源码位置及行为 | Flutter 对应文件/方法 | 实现度 | 依赖项 | 测试文件/用例 | 测试结果 | 尚未完成工作 | 最终验收标准 | 当前状态 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **PLAT-01** | 屏幕常亮唤醒锁 | `FLAG_KEEP_SCREEN_ON` 控制。 | 无 | 0% | `wakelock_plus` | 无 | 未测试 | 集成常亮插件。 | 调音界面亮屏，切后台恢复系统省电。 | `NOT_STARTED` |
| **PLAT-02** | 系统音量与静音提示 | 检测设备麦克风被硬件静音或占用时的警告弹窗。 | 无 | 0% | AUDIO-01 | 无 | 未测试 | 平台音频异常状态监听。 | 麦克风无法输入时给出明确诊断提示。 | `NOT_STARTED` |
| **PLAT-03** | 系统原生分享面板 | `ShareData.kt`: 通过系统 ActionSend 分享导出的 WAV 与 Scala 文件。 | 无 | 0% | `share_plus` | 无 | 未测试 | 集成分享插件。 | 一键调起 Android/iOS 原生分享面板。 | `NOT_STARTED` |
| **PLAT-04** | 屏幕旋转与状态保留 | 旋转屏幕（横竖屏切换）时不丢失当前检测历史与音频采集。 | 无 | 0% | Riverpod | 无 | 未测试 | 状态与 UI 生命周期解耦。 | 旋转屏幕 0 卡顿，波形图平滑连续重绘。 | `NOT_STARTED` |

---

## 汇总统计数据 (Empirical Statistics)

- **Kotlin 原项目审计功能总数**: **85** 项
- **Flutter 当前已实现功能总数 (`e58c406`)**: **4** 项（M3 主题色彩系统、基础常量、音符实体模型、基础数据类型）
- **Flutter 当前已验证功能总数 (`e58c406`)**: **2** 项（`MusicalNote` 基础模型测试、M3 主题脚手架烟囱测试）
- **完全缺失功能总数**: **79** 项
- **当前存在实现度但未验证/待重写项**: **4** 项
