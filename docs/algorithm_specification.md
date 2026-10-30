# 核心声学与信号处理 (DSP) 算法数学规格书

> **目的**: 明确调音器核心算法的数学定义、离散化公式、边界条件以及缺陷规避措施，作为跨平台移植的唯一权威计算基准。

---

## 1. 快速傅里叶变换 (FFT / IFFT) 与时窗系统

### 1.1 实数与复数 Radix-2 Cooley-Tukey 变换
- **定义**: 长度 $N = 2^m$ 的时域序列 $x[n]$ 转换为频域序列 $X[k] = \sum_{n=0}^{N-1} x[n] e^{-j 2\pi k n / N}$。
- **实数 FFT 特殊结合算法 (Real FFT Packing)**:
  对于纯实数输入序列 $x[n]$（长度 $N$），可将其成对打包为 $N/2$ 个复数 $z[m] = x[2m] + j x[2m+1]$，执行一次 $N/2$ 阶复数 FFT，再通过对称性解包为 $N/2 + 1$ 个正频率分量。
- **`FORK-NEW-02` 原地覆盖缺陷规避**:
  在解包循环中，$k_1$ 与 $k_2$ 分别从两端向中间逼近。当 $i = N/4$ 时，$k_{1\text{re}} == k_{2\text{re}}$，原版直接对同一数组原地赋值会导致后半段计算读取了已被覆盖的新值。重构实现必须使用四个局部变量 `outK1Re, outK1Im, outK2Re, outK2Im` 暂存计算结果，再执行写回。

### 1.2 窗函数与能量归一化
- **Tophat (矩形窗)**: $w[n] = 1.0$。
- **Hanning 窗**: $w[n] = 0.5 \cdot (1.0 - \cos(2\pi n / N))$。
- **Hamming 窗**: $w[n] = 0.54 - 0.46 \cdot \cos(2\pi n / N)$。
- **能量积分归一化**: 频域幅度谱计算时，乘以补偿因子 $K = \frac{2}{N \cdot \int_0^1 w(t) dt}$，确保加窗前后正弦波实测幅度严格保持一致。

---

## 2. 快速时域互相关与自相关计算 (Autocorrelation)

- **维纳-辛钦定理 (Wiener–Khinchin Theorem)**:
  $$R_{xx}[\tau] = \sum_{n=0}^{N-1-\tau} x[n] x[n+\tau] = \mathcal{F}^{-1}\left\{ |\mathcal{F}\{x_{\text{padded}}\}|^2 \right\}$$
- **零填充机制**: 必须将长度 $N$ 的输入向量在尾部补零至 $2N$，否则频域乘积将退化为时域“圆周自相关”（Circular Correlation），在大切换滞后量处产生虚假反射能量。
- **位反转直充优化**: 在前向实数 FFT 开始前，直接将输入样本按位反转顺序写入零填充缓冲区的偶数位，消除独立的输入克隆耗时。

---

## 3. McLeod Pitch Method (MPM) 算法规格

### 3.1 归一化平方差函数 (NSDF)
MPM 不使用容易受信号能量衰减影响的传统自相关，而是构建归一化函数 $n[\tau]$：
$$n[\tau] = \frac{2 \sum_{t=0}^{W-1} x_t x_{t+\tau}}{\sum_{t=0}^{W-1} x_t^2 + \sum_{t=0}^{W-1} x_{t+\tau}^2} \approx \frac{2 R_{xx}[\tau]}{R_{xx}[0] \cdot 2 \frac{N-\tau}{N}}$$
取值范围严格位于 $[-1.0, 1.0]$，其中 $1.0$ 代表理想周期信号。

### 3.2 首峰阈值选择机制 (First-Peak Thresholding)
- **八度倍频缺陷机制**: 小提琴等弓弦乐器发声初期，二次谐波能量往往瞬时超过基频，导致传统自相关全局最大值落在 $\tau/2$，从而导致音高显示突发翻倍（例如 A4 突跳为 A5）。
- **MPM 解决机制**:
  1. 搜索所有正向局部极大值点（$n[\tau] > 0$ 且大于两侧相邻值）。
  2. 获取所有候选峰中的全局最大值 $n_{\max}$。若 $n_{\max} < 0.45$，直接判定为非周期噪声或静音。
  3. 设定阈值 $T_{\text{cut}} = 0.85 \times n_{\max}$。
  4. **从左至右选择第一个满足 $n[\tau] \ge T_{\text{cut}}$ 的极大值峰**，彻底消除八度倍频误判。

---

## 4. Two-Way Mismatch (TWM) 双向谐波失配算法

### 4.1 双向失配目标函数
Maher & Beauchamp (1994) 提出的 TWM 算法同时评估：
1. **预测到测量误差 (Predicted-to-Measured $Err_{p\to m}$)**:
   $$Err_{p\to m} = \frac{1}{\sum w_n} \sum_{n=1}^N \Delta f_n \cdot w_n, \quad w_n = \frac{1}{\sqrt{n}}$$
   其中 $\Delta f_n = \frac{\min_k |f_{\text{pred}, n} - f_{\text{meas}, k}|}{f_{\text{pred}, n}}$（若偏离 $> 8\%$ 则视为未匹配，赋予惩罚常数 1.0）。
2. **测量到预测误差 (Measured-to-Predicted $Err_{m\to p}$)**:
   $$Err_{m\to p} = \frac{1}{\sum a_k} \sum_{k=1}^K \Delta f_k \cdot a_k$$
   强力惩罚测量频谱中未被预测模型解释的高能量孤立谐波。
3. **综合失配度**: $Err_{\text{total}} = Err_{p\to m} + \rho \cdot Err_{m\to p}$（推荐 $\rho = 1.0$）。

### 4.2 非谐性 (Inharmonicity) 刚度系数补偿
真实琴弦（特别是钢琴低音弦与大提琴弦）由于物理刚度存在色散效应，高次谐波频率公式为：
$$f_n = n \cdot f_0 \sqrt{1 + B n^2}$$
TWM 在评估候选基频时引入参数 $B$，大幅提升重度非谐琴弦的音高锁定能力。

---

## 5. 精度插值与 Phase Vocoder 相位修正

### 5.1 复数 3-bin Jacobsen 插值
在频谱主峰位置 $k$，利用相邻复数谱分量 $X(k-1), X(k), X(k+1)$ 计算亚 Bin 频率偏移量 $\delta$：
$$\delta = \text{Re}\left( \frac{X(k+1) - X(k-1)}{2 X(k) - X(k-1) - X(k+1)} \right)$$
修正后谱峰频率为 $f = (k + \delta) \cdot \Delta f$。

### 5.2 帧间相位差分 (Phase Vocoder)
当存在上一帧频谱 $X_{t-1}$ 时，两帧间时间差为 $\Delta t$。谱峰相位旋转量为：
$$\Delta \theta = \text{unwrap}(\arg X_t(k) - \arg X_{t-1}(k))$$
整周数由频率种子估算：$M = \text{round}\left( f_{\text{seed}} \Delta t - \frac{\Delta \theta}{2\pi} \right)$。
最终高精频率为：
$$f_{\text{accurate}} = \frac{M + \frac{\Delta \theta}{2\pi}}{\Delta t}$$
测量精度可突破 $0.001\text{ Hz}$。

---

## 6. 声学痛点根除与滤波架构 (ACOUSTIC-01)

1. **双层物理静音门限**:
   - 第一层：时域样本 $\text{RMS} = \sqrt{\frac{1}{N}\sum x[n]^2} < 10^{-4}$（约 $-80\text{ dBFS}$）立即判为静音。
   - 第二层：自相关最大峰值必须满足 $\max_{\tau > 0} R_{xx}[\tau] \ge 0.15 \cdot R_{xx}[0]$，彻底过滤 50Hz 工频交流电背景底噪，杜绝静音时 G1-D3 乱跳。
2. **三阶时域中值滤波 (`PitchMedianFilter`)**:
   滑动窗口长度为 3，消除麦克风敲击产生的单采样毛刺。
3. **八度跳度门控 (`OctaveJumpGate`)**:
   频率突发出现 $2.0 \times$ 或 $0.5 \times$ 跳跃时，若处于 $\pm 8\%$ 容差内，必须连续保持 2 帧以上才确认真实八度切换，否则强制吸附于基准八度。
4. **自适应离群点剔除平滑器 (`OutlierRemovingSmoother`)**:
   采用多环形队列，滑动平均时计算方差并剔除偏离过大的瞬时点，确保指针平稳收敛。
