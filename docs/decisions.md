# 架构与技术决策记录 (Architecture Decision Records - ADR)

---

## ADR-01: 核心 DSP 算法采用纯 Dart 实现，不依赖 C/C++ FFI 或原生库

- **状态**: 已接受 (Accepted)
- **上下文**:
  調音器依赖实数 FFT、离散自相关、MPM、TWM 与复数 Jacobsen 插值。原版使用 Kotlin 纯代码编写。若采用 C/C++ 通过 FFI 绑定，虽有细微理论性能优势，但会带来多架构编译复杂性（arm64-v8a, armeabi-v7a, x86_64, iOS, macOS, Web）、内存段安全风险以及跨平台打包负担。
- **决策**:
  全部 DSP 算法直接使用纯 Dart 编写，利用 `Float32List` 与 `Int32List` 定型数组进行内存对齐与 SIMD 优化。
- **后果**:
  - **优势**: 100% 跨平台统一行为（Android, iOS, macOS, Linux, Windows, Web 均无缝支持）；可在任意 Dart `Isolate` 中无缝运行，无原生内存泄漏风险；代码易于调试与编写单元测试。
  - **代价**: 需在 Dart 中精确移植位反转与数学向量计算，避免产生临时对象垃圾回收。

---

## ADR-02: 采用后台 Dart Isolate 隔离高频音频采集与 DSP 运算

- **状态**: 已接受 (Accepted)
- **上下文**:
  44.1kHz 音频流以 4096 点窗口计算时，50% 重叠率下每秒触发约 21 次至 43 次复杂傅里叶变换与多谐波扫描。若置于 UI 主线程，极易引发手势滑动丢帧。
- **决策**:
  主线程仅负责麦克风原始数据提取并将其写入无锁环形缓冲区，真正的加窗、FFT、自相关与音高检测全部分流到后台独立 `Isolate` 执行，计算完成后将轻量级 `PitchDetectionResult` 节流派发给 Riverpod 状态层。
- **后果**:
  保证无论低端机型还是高负载算法（TWM / pYIN），UI 始终稳定在 60 FPS / 120 FPS。

---

## ADR-03: 使用 Riverpod 进行全局单向状态管理与事件节流

- **状态**: 已接受 (Accepted)
- **上下文**:
  应用包含两套大屏（乐器调音与科学示波器）、琴弦高亮、音高历史记录以及多达 22 项偏好设置。各组件间需要高度解耦且共享声学实体。
- **决策**:
  采用 `flutter_riverpod` 构建单向数据流。在调音状态流输出端增设时间节流阀（Throttler），将 UI 刷新频率稳定钳制在 30Hz - 60Hz 之间。
- **后果**:
  杜绝组件内部直接调用音频流，消灭 `setState` 滥用引发的整页无谓重绘。

---

## ADR-04: 开源许可证与著作权继承 (GPL-3.0 & Gonville)

- **状态**: 已接受 (Accepted)
- **上下文**:
  原项目 `daniel-freiermuth/Tuner` 采用 GPL-3.0 许可证，且乐谱矢量字符来源于 Simon Tatham 的 Gonville 音乐字体。
- **决策**:
  Flutter 重构项目完整继承 GNU GPL-3.0 许可证，根目录放置 `COPYING`，所有衍生代码保留原始作者著作权声明，并合规注明重构说明。

---

## ADR-05: 确立 `e58c406` 为可信重构基线，历史探索代码归档至 `main`

- **状态**: 已接受 (Accepted)
- **上下文**:
  此前一轮开发推进速度过快，出现了功能简化、原版行为覆盖不充分、部分设置未真实起效等问题。
- **决策**:
  在 `feature/rollback` 分支将代码回滚至经过验证的清晰脚手架提交 `e58c406`，作为后续单切片开发的唯一权威起点。此前在 `main` 上的所有探索性实现保留于 Git 历史中作为对照与教训参考，严禁未经验证直接照搬。

---

## ADR-06: 律制体系采用不可变有理数模型与五度链折叠算法

- **状态**: 已接受 (Accepted)
- **上下文**:
  古代古典律制（纯律、毕达哥拉斯律、中庸全音律族、魏克迈斯特良律族等）依赖严格的纯大三度（5/4）与纯五度（3/2）频率比。浮点数多次累乘必然引发微音差精度丢失；同时，用户切换主音（Root Note）时，需要按调式规则重新相生并折叠至 `[1.0, 2.0)` 八度内。
- **决策**:
  实现纯 Dart 约简有理数模型 `RationalNumber`（最大公约数约简、不可变、重载大小比较与四则运算）；构建沿五度链折叠算法 `ChainOfFifths`，支持双向相生与自动八度折叠；基类 `Temperament` 统一抽象 `cents`、`ratios`、`rationalNumbers`，并支持动态切换根音生成 `MusicalScaleFrequencies`。
- **后果**:
  实现了 19 种历史律制与任意 N-EDO 微分音律制的无损精度表达，与原版 Kotlin 数据误差小于 $10^{-7}$ 音分。

---

## ADR-07: 延展调音 (Stretch Tuning) 采用对数尺度分段线性插值与几何外推

- **状态**: 已接受 (Accepted)
- **上下文**:
  真实钢琴琴弦受金属刚度系数 $B$ 影响产生泛音非谐性（Inharmonicity），低音泛音偏高需下沉、高音基频需抬升。Railsback 经验曲线在工程上以 32 个实测散点呈现，计算任意连续频率的偏离音分时，必须在对数频率空间保持平滑与单调。
- **决策**:
  `StretchTuning` 在 $\ln(f)$ 空间进行分段线性插值；在超出最低/最高散点时，沿边界对数斜率平滑外推；在任意指定参考频率（如 A440 或 A442）处，强制执行零偏移归一化，确保参考音处绝对不偏离。提供不可变增删改控制点与单调性校验 `isValid`。
- **后果**:
  不仅真实还原了经典 Railsback 曲线，还为用户自定义多点曲线编辑与音阶频率生成链路提供了极高的声学精度。

---

## ADR-08: 目标音符与琴弦识别采用双重迟滞门限 (Hysteresis Band) 与极值弦无界覆盖

- **状态**: 已接受 (Accepted)
- **上下文**:
  调音器在实时采集中，输入频率会因泛音震荡或物理振幅微动而在相邻琴弦或相邻半音的中点临界线波动。若采用纯最近邻算法，指示圆点与指针会剧烈跳闪，造成极差的用户体验。
- **决策**:
  实现 `TargetNoteAutoDetection` 与 `SortedAndDistinctInstrumentStrings`：
  1. 引入双向迟滞门限：在已追踪某一目标音（`previousNote`）时，设立 60% 偏向区间与 20 cents 最小安全带，只要物理频率不显著越过边界，稳定维持上一目标；
  2. 极值弦外延无界：最低琴弦向低频端拥有负无穷无界覆盖，最高琴弦向高频端拥有正无穷无界覆盖，超出乐器范围的超低音或超高音稳定指向边界弦，引导用户调高或调低。
- **后果**:
  彻底消除了临界点跳动 Bug，与原版声学手感完全一致。

---

## ADR-09: Huygens-Fokker 标准 Scala (.scl & .kbm) 纯 Dart 格式互通与序列化

- **状态**: 已接受 (Accepted)
- **上下文**:
  微音程与历史律制社区广泛使用 Huygens-Fokker 标准 `.scl` 音阶文件和 `.kbm` 键盘映射文件。同时 Android Tuner 原版在此基础上扩展了元数据注释（`! version=`, `! abbreviation=`, `! description=`）以及行内变音/等音异名音符绑定（`note=D`, `note=C#`）。
- **决策**:
  编写纯 Dart `ScalaParser` 与 `ScalaSerializer`，支持纯律分数、纯整数比例（如 `2` 解析为 `2/1`）、浮点小数音分、单/多音阶连续流、BOM 与 CRLF 透明过滤；支持标准 `.kbm` 映射解析与导出；实现 `CustomTemperament` 继承 `Temperament` 闭环接入调音系统。
- **后果**:
  应用可直接读取全球 5000+ 现成 Scala 音阶库，并在应用内进行无损导入导出。

---

## ADR-10: 纯 Dart 无锁定长环形采样缓冲队列 (AudioRingBuffer) 与重叠时窗提取

- **状态**: 已接受 (Accepted)
- **上下文**:
  硬件音频流与内存模拟流以不定大小的 PCM 块（如 256~2048 采样）持续推流，而 DSP 引擎需要固定大小的时窗（如 2048 或 4096 采样），且通常以 50%~75% 的重叠步长（Stride）滑动提取。同时，UI 示波器和未来的 WAV 录音器需要非破坏性地随时抓取最新一段波形快照。
- **决策**:
  实现纯 Dart 高性能定长环形队列 `AudioRingBuffer`：
  1. 读写指针解耦推进，提供块写入 `write(Float32List)` 与零内存分配浮点归一化写入 `writeInt16(Int16List, 1.0 / 32768.0)`；
  2. 提供 `read(destination, windowSize, stride)` 支持重叠滑动时窗推进，在数据欠载时自动以零拷贝补静音返回，杜绝管线饥饿与数组越界；
  3. 提供 `getLatestSnapshot(sampleCount)` 非破坏性只读快照方法，自动处理回卷边界与前置平滑零填充，完全不移动 DSP 消费读指针；
  4. 支持灵活的溢出保护策略（默认覆盖最老采样以维持实时低延迟，或严格拒绝溢出）。
- **后果**:
  消除了音频流与多引擎计算之间的内存频繁重分配与 GC 压力，实现稳定低延迟采样衔接。

---

## ADR-11: 独立 Dart Isolate 后台计算与双向强类型消息总线

- **状态**: 已接受 (Accepted)
- **上下文**:
  实时音高检测管线（包含加窗、自相关、实数 FFT、MPM 峰值搜索、TWM 谐波失配匹配与离群值中值平滑）在 44.1kHz 下每秒计算 20~40 次，单次耗时可达数毫秒至十余毫秒。若直接在 UI 主线程执行，会严重阻塞手势交互与 60/120 FPS 渲染。
- **决策**:
  基于 Dart 原生 `Isolate.spawn` 搭建独立的后台音频处理工作线程 `AudioProcessingIsolate`：
  1. 建立完全类型化的双向通信协议（UI $\to$ Worker: `AudioDataMessage`, `ConfigureDspMessage`, `ResetDspMessage`, `DisposeWorkerMessage`；Worker $\to$ UI: `WorkerReadyMessage`, `AudioAnalysisResult`, `WorkerErrorMessage`）；
  2. 支持在不重启 Worker 的情况下实时热更测频算法（Classic / MPM / TWM / Hybrid）、窗函数、声学计权与时窗大小；
  3. 主线程分发端口集成高精度基于微秒时间戳的 UI 节流器（`setThrottleFps`，默认 60 FPS），平抑重绘压力的同时提供直通全速流（`unthrottledResultStream`）以满足高精单测与专业示波需求。
- **后果**:
  UI 主线程 CPU 占用降至最低，即使复杂弦乐算法持续运算，界面依然丝滑满帧运行。

---

## ADR-12: 真实麦克风硬件驱动 (MicrophoneAudioSource) 乐器声学优化与生命周期绑定

- **状态**: 已接受 (Accepted)
- **上下文**:
  智能手机与桌面操作系统内置的麦克风驱动默认启用人声自动增益（AGC）、回声消除（AEC）与环境降噪（ANS）。这些算法专门针对人声语音通话设计，会严重抑制微弱的乐器谐波泛音，甚至将低音或弱延音判定为“持续背景噪音”而强制消噪切除；此外，麦克风硬件需要在应用切到后台或锁屏时主动释放，防止隐私指示灯长亮与无谓耗电。
- **决策**:
  1. 封装 `MicrophoneDriver` 抽象驱动门面，基于 `record: ^7.1.2` 实现低延迟 44.1kHz 单声道 16-bit PCM 采集；
  2. 在 `RecordConfig` 中显式设置 `autoGain: false, echoCancel: false, noiseSuppress: false`，获取最原始、无声学污染的纯净乐器振动信号；
  3. 实现容错转换器 `pcm16BytesToFloat32`，处理非字节对齐偏移（`offsetInBytes % 2 != 0`）与奇数字节截断；
  4. 混入 `WidgetsBindingObserver` 监听应用生命周期：切入后台或锁屏时自动暂停硬件流并释放通道，回到前台无感自动唤醒；
  5. 状态机在进入暂停/停止前立即同步变更状态，消灭异步等待间隙的状态竞态。
- **后果**:
  保证了高保真乐器泛音输入与系统级隐私、能耗规范的完全遵从。

---

## ADR-13: 16 语种全量 ARB 词条同步与延展调音全链路国际化

- **状态**: 已接受 (Accepted)
- **上下文**:
  在前期迭代中，部分非核心语言（`cs, de, es, fr, hu, it, ja, pl, pt, ro, ru, sv, uk, vi`）缺少了乐理五线谱、谱号及音分设置等新增词条，导致 `flutter gen-l10n` 频繁输出 untranslated 警告；同时，延展调音系列界面（总览列表、多项式编辑器、散点表格与修改对话框）存在部分未抽取为多语言资源的英文硬编码。
- **决策**:
  1. 为全部 16 种语言完整补齐 34 项未翻译词条与 16 项延展调音新增词条，严格对齐 Android 原版 strings.xml 的专业术语；
  2. 对 `StretchTuningOverviewScreen`、`StretchTuningEditorScreen`、`StretchTuningTable` 及 `ModifyStretchTuningLineDialog` 全量接入 `AppLocalizations` 动态多语言绑定，彻底消除硬编码文本；
  3. 增加单元测试与回归测试，保证 `flutter gen-l10n` 零警告，并在中英文环境下通过全屏 Widget 渲染校验。
- **后果**:
  实现跨平台 16 种语言无死角本地化，消除多语言编译期告警与界面混杂展示。

---

## ADR-14: 延展调音函数图负高度视口变换与手势坐标统一

- **状态**: 已接受 (Accepted)
- **上下文**:
  延展调音图（`StretchTuningGraph`）的纵轴为音分偏差，通常取值范围为 $[-15, +15]$ 音分。在数学笛卡尔坐标系中，$y$ 轴向上为正，因此视口上边界 $c_{\max} = +15$，下边界 $c_{\min} = -15$。在 Flutter 中，`Rect.fromLTRB(left, top, right, bottom)` 计算所得 `height = bottom - top = -15 - (+15) = -30` 为负值。在计算像素位移 $\Delta y_{\text{pixel}}$ 映射至视口位移 $\Delta y_{\text{plot}}$ 时，原实现额外乘以了负号，导致“负负得正”，引起向上拖拽手势曲线向下跑、向下拖拽曲线向上跑的上下反向缺陷；同时在缩放时由于 `Rect.fromLTWH` 默认 clamp 高度为正值，导致视口上下翻转颠倒。
- **决策**:
  1. 统一视口映射公式：`dyPlot = (dyPixels / size.height) * currentVp.height;`，自然依靠负高度抵消屏幕向下递增的像素坐标系；
  2. 在 `GestureBasedViewport.zoom` 中提取并显式保留高度符号 `heightSign`，防止在缩放边界钳制时将高度强制转为正值。
- **后果**:
  彻底修复了函数图在平移和缩放过程中的颠倒与反向问题，手势追踪精准自然。

---

## ADR-15: CustomPainter 动态重绘条件完备性与桌面端触控板/滚轮手势接入

- **状态**: 已接受 (Accepted)
- **上下文**:
  首页波形图（`PitchHistory`）与科学模式波形图需要支持平移（Pan）与缩放（Zoom）。在移动端依靠触摸双指捏合，而在 macOS / Windows / Linux 桌面端，用户主要依赖触控板双指滑动、捏合（`PointerPanZoomUpdateEvent`）或鼠标滚轮配合修饰键（`PointerScrollEvent`）。此前首页波形图在桌面端完全无法交互，且 `_PitchHistoryPainter.shouldRepaint` 遗漏了动态视口 `midiMin/Max` 与 `isUserInteracting` 的比较，导致状态变更时 Canvas 误判无需重绘。
- **决策**:
  1. 在 `_PitchHistoryPainter.shouldRepaint` 中补全所有影响几何变换与视口标尺的属性对比；
  2. 使用 `Listener` 包装交互区域，同时监听 `onPointerSignal`（处理滚轮垂直平移及带 Cmd/Ctrl 键的视口缩放）与 `onPointerPanZoomUpdate`（处理 macOS 原生触摸板平移与捏合缩放）。
- **后果**:
  实现跨平台（移动触摸 + 桌面触摸板/滚轮）无缝统一的平滑交互体验。

---

## ADR-16: 底栏常驻状态项自适应图标化与原版矢量资源 1:1 引入

- **状态**: 已接受 (Accepted)
- **上下文**:
  底部常驻快速状态栏（`QuickSettingsBar`）包含 4 个核心声学单元格（A4 基准音、律制、变音记号、延展调音）。在原版 Android 中，当未配置延展调音时，底栏空间紧张，如果渲染冗长文本 `"No Stretch Tuning"`，在小屏设备或多语言长文本下极易发生组件溢出（Overflow）与截断。
- **决策**:
  1. 1:1 提取 Android 原版 `res/drawable/ic_stretch.xml` 矢量资源，创建纯 Dart SVG 图标 `NotationIcons.stretchTuningSvg` 与专用组件 `StretchTuningIconWidget`；
  2. 当无延展调音时，渲染简洁的矢量图标，并配置 Tooltip 悬浮提示；当启用延展调音（如 Railsback 或自定义曲线）时，紧凑展示图标加曲线简名。
- **后果**:
  彻底消除了底部状态栏的文本过长拥挤与排版溢出问题，视觉语言严格对齐 Android 原版。

---

## ADR-17: 纯音口哨高频次谐波抑制与视口音高跳变平滑断点机制

- **状态**: 已接受 (Accepted)
- **上下文**:
  在吹口哨（单频纯正弦波，约 1000Hz~2000Hz）测试时，传统 TWM 算法在没有高次泛音支撑的纯音场景下容易产生次谐波陷阱（Subharmonic Trap），错误将 $f_0/2$ 或 $f_0/3$ 判定为基频；此外，音高历史波形图在遇到跳频杂音时将离散散点直接相连，导致画面出现贯穿上下的垂直虚假线条。
- **决策**:
  1. TWM 候选池按真实频谱振幅降序排序，确保真实高振幅主峰获得优先匹配与评估；
  2. 针对高频纯音引入次谐波惩罚项，当低频候选点缺少泛音能量支持时施加失配惩罚；
  3. 离群点平滑器增加均值保持与防漏值保护；
  4. 历史波形图突破 4 半音钳位限制，并在检测到静音帧或跨越 $>3.5$ 半音的突发不连续跃迁时主动断开连线，平滑时间轴自然推进。
- **后果**:
  彻底解决了吹口哨时波形图垂直拉线与基频翻倍/减半的物理声学顽疾，波形轨迹连续平滑。
