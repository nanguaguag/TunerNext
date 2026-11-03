# 已知问题、声学物理缺陷与历史踩坑清单 (Known Issues & Bug Tracking)

> **原则**: 准确区分原版 Kotlin 代码客观存在的 Bug、物理声学规律引起的测量痛点，以及此前 Flutter 尝试中暴露的实现缺陷。

---

## 一、原版 Kotlin 项目已知缺陷与声学物理痛点

| 缺陷编号 | 缺陷名称 | 根因分析 | 影响表现 | 规避与修复方案 |
| :--- | :--- | :--- | :--- | :--- |
| **BUG-01** (FORK-NEW-01) | 环形缓冲区负数取模越界 | `SampleData.kt`: `(framePosition - offset) % size` 当差值为负时产生负下标。 | 在缓冲区回绕边缘可能触发 `ArrayIndexOutOfBoundsException` 崩溃。 | 严格采用 `((val % size) + size) % size` 数论正余数公式。 |
| **BUG-02** (FORK-NEW-02) | Real FFT 解包原地读写覆盖 | `FFT.kt`: `combineFFTResultForRealFFT` 中在 $i = N/4$ 处，$k_{1\text{re}} == k_{2\text{re}}$ 原地赋值破坏了后续计算。 | 实数变换结果中间频段存在细微数值误差，影响弱谐波检测。 | 引入四个中间局部变量暂存计算结果，彻底阻断自重写。 |
| **BUG-03** (ACOUSTIC-01) | 工频交流电静音乱跳 G1-D3 | 在极度安静环境下，麦克风底噪或 50Hz/60Hz 交流电干扰被自相关强行捕捉。 | 调音器在无人发声时屏幕疯狂闪烁乱跳低音音符（G1, D3）。 | 双层静音门限：时域 $\text{RMS} < 10^{-4}$ + 归一化自相关峰值 $\ge 0.15 \cdot R_{xx}(0)$。 |
| **BUG-04** (ACOUSTIC-02) | 弓弦乐器发声八度倍频 | 小提琴拉弦起奏瞬间，二次谐波能量剧烈膨胀超过基频。 | 高把位高音（如 E6 1318.51Hz）被误判为翻倍高八度（E7 2637Hz）。 | 引入 McLeod Pitch Method (MPM) 首峰阈值比率判定（0.85）。 |
| **BUG-05** (ACOUSTIC-03) | 粗琴弦基频缺失 (Missing Fund.) | 大提琴、低音提琴等低音琴弦由于腔体与刚度限制，基频能量极微，主要由高次谐波体现。 | 传统自相关在基频处峰值微弱，容易错误锁定到 $2f_0$ 或 $3f_0$。 | 引入 Two-Way Mismatch (TWM) 算法，通过谐波间距反推缺失基频。 |
| **BUG-06** (UI-Hysteresis) | 准音阈值临界点高频闪烁 | 调准指示圆点使用固定 $\pm 3.0$ cents 阈值，当读数在 2.99 与 3.01 震荡时剧烈闪烁。 | 调音指示灯在边缘状态下给用户造成极度视觉疲劳。 | 引入迟滞判定机制：进入绿灯需 $< 3.0$ cents，退出绿灯需 $> 3.5$ cents。 |
| **BUG-07** (Lifecycle) | 锁屏后台麦克风未及时释放 | `AudioRecord` 在某些定制 Android 系统退火时未显式 release。 | 后台耗电严重，系统常驻麦克风黄色录音提示灯。 | `WidgetsBindingObserver` 严格监听生命周期，切后台立即释放。 |

---

## 二、此前 Flutter 探索性开发暴露的问题与经验教训

| 问题编号 | 问题现象 | 产生原因 | 带来的危害 | 解决与整改措施 |
| :--- | :--- | :--- | :--- | :--- |
| **FLUTTER-01** | 音频采集阻塞 UI 掉帧 | 在 UI 主 Isolate 既处理麦克风流又计算 4096 阶 FFT 与 TWM 谐波遍历。 | 在低端机或调试模式下界面 FPS 跌至 20 左右，手势卡顿。 | **坚决将 DSP 全管线放入独立 Dart Isolate**，主线程仅接收节流后的结果。 |
| **FLUTTER-02** | 窗长切换触发越界异常 | 用户在设置中将 Buffer Size 从 4096 改为 8192 时，下游自相关数组未动态扩容。 | 切换时抛出 RangeError 并导致调音管线静默死锁。 | 在参数变更是由工厂动态销毁重建 DSP Pipeline 实例。 |
| **FLUTTER-03** | 科学调音界面设置不同步 | 在科学示波界面修改基准律制或音符记谱法时，示波器标注未刷新。 | 双模式状态独立，未统一汇聚到全局单一状态源。 | 使用全局单一 Riverpod StateProvider，多界面共享同一声学实体。 |
| **FLUTTER-04** | Scala (.scl) 容错能力低下 | 遇到带注释行（`!` 开头）、空行或纯律分数比（如 `3/2`）解析报错。 | 无法兼容标准 Huygens-Fokker 库中的微音程音阶文件。 | 编写健壮的逐行词法解析器，支持纯律分数与对数音分双格式。 |
| **FLUTTER-05** | 音高历史 Canvas 重绘消耗过高 | 每一帧都对过去 10 秒的所有采样点做 `Path.lineTo` 循环重建。 | 随时间推移 CPU 占用从 5% 飙升至 30%，内存频繁 GC。 | 采用双缓冲与增量环形时间切片，只绘制当前窗口可视像素点。 |
| **FLUTTER-06** | macOS/iOS 权限与沙箱缺失 | 在桌面端运行时缺少 Entitlements 与 Info.plist 说明导致无声。 | 启动后由于麦克风静默返回全 0 样本，无法进行任何调音。 | 在工程初始化时即完整配置各平台权限声明与沙箱音频描述。 |

---

## 三、用户反馈与关键缺陷排查及修复记录 (User Feedback & Critical Bug Fixes)

| 缺陷/问题编号 | 严重程度 | 问题现象与根因 | 修复方案与代码变更 | 验证状态与 Commit |
| :--- | :--- | :--- | :--- | :--- |
| **BUG-P0-01** | **Critical** | **波形图上下跳动不连续**：基频检测存在八度谐波误判与未加窗泄漏，导致历史音高点剧烈离散跳跃。 | 1. 接入 Hanning 窗消除频谱旁瓣泄漏；<br>2. 引入 3-tap 中值滤波与八度折叠保护；<br>3. 静音帧推入哑音标记，截断非连续连线。 | **VERIFIED**<br>Commit `d559380`, `b653c55` |
| **BUG-P1-02** | **High** | **安静状态工频底噪乱跳**：极安静环境下麦克风采集到微弱 50Hz 工频底噪或电路热噪声，被相关算法捕捉识别为 G1/D3。 | 接入 IEC 61672-1 声学 A 计权滤波，大幅衰减 100Hz 以下低频噪声达 30dB；增加能量与周期峰值联合双门限检测。 | **VERIFIED**<br>Commit `49d0d53`, `9dbf03a`, `a4e9aa0` |
| **BUG-P1-03** | **High** | **科学模式频谱自相关曲线失真**：频谱显示像简笔画缺少多峰，自相关曲线为折线段而非光滑波形。 | 废除粗粒度频点抽稀，采用连续 Path 曲线绘制；频谱改用平方功率谱渲染，增强谐波泛音峰值对比度。 | **VERIFIED**<br>Commit `dfbd11b`, `cf22c62` |
| **BUG-WHISTLE-01** | **High** | **口哨纯音高频次谐波误判与垂直条纹**：吹口哨（~1600Hz）时频率轨迹呈现垂直直上直下条纹。根因为 TWM 算法在低频生成过多虚假候选点，且高频纯音缺少泛音导致次谐波陷阱。 | 1. TWM 候选池按真实频谱振幅降序排序，保证强基频优先被测试；<br>2. 引入高频纯音次谐波抑制惩罚；<br>3. 离群值平滑器防漏值；<br>4. 波形图动态视口破除 4 半音钳位并断开跨视口跳跃点。 | **VERIFIED**<br>Commit `f9e1344`, `1e62044`, `e7167ed`, `b653c55` |
| **BUG-UI-STRETCH-01** | **Medium** | **New Stretch Tuning 函数图拖动方向反向**：向上拖拽曲线向下移，向下拖拽曲线向上移。根因为笛卡尔视口高度 $c_{\max} - c_{\min} = 15 - (-15) = 30$，而在 Flutter Rect 坐标系中 $y$ 向下递增使得 `height` 为负值，原代码额外乘 `-1` 产生双重变号。 | 移除多余的负号 `dyPlot = (dyPixels / size.height) * currentVp.height;`；在 `GestureBasedViewport.zoom` 中保留负高度符号，彻底解决拖拽与缩放反向。 | **VERIFIED**<br>Commit `f5c0857` |
| **BUG-UI-MACOS-PAN-01** | **Medium** | **macOS 首页波形图无法拖动/缩放**：在科学模式下可拖动缩放，但首页波形图无法手势操作。根因为 `_PitchHistoryPainter.shouldRepaint` 缺少 `midiMin/Max` 变化比对，导致平移缩放时不触发重绘；且未接入触控板/滚轮信号。 | 在 `shouldRepaint` 中补齐 `midiMin/Max` 与 `isUserInteracting`；外层 `Listener` 接入 `onPointerSignal`（鼠标滚轮与缩放）及 `onPointerPanZoomUpdate`（macOS 触控板平移与捏合手势）。 | **VERIFIED**<br>Commit `e5e4155` |
| **BUG-UI-STRETCH-ICON-01** | **Low** | **底栏“No Stretch Tuning”文本过长**：在未开启延展调音时展示冗长英文文本导致底栏拥挤甚至溢出。 | 1:1 提取 Android 原版 `ic_stretch.xml` 矢量资源，封装为专用矢量图标 `StretchTuningIconWidget` 并提供 Tooltip；开启延展调音时展示图标+精简名称。 | **VERIFIED**<br>Commit `6fb21ea` |
| **BUG-L10N-INCOMPLETE-01** | **Medium** | **14 种多语言各遗漏 34 个词条**：`flutter gen-l10n` 报 `cs, de, es, fr, hu, it, ja, pl, pt, ro, ru, sv, uk, vi` 各缺失 34 个条目；且延展调音页面多处写死英文。 | 全量补齐 14 语种 ARB 词条（`flutter gen-l10n` 告警清零）；延展调音总览、编辑、表格与对话框全量绑定 `AppLocalizations`。 | **VERIFIED**<br>Commit `2e15370` |
