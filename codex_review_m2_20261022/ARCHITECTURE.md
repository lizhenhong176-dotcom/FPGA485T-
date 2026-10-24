# ARCHITECTURE — 从 CLB 到 clock region（485T）

> 配套：`GLOSSARY.md`（术语）、`README.md`（当前进展）
> 目的：把"芯片长什么样"和"位流里怎么表示"对应起来，后面探针、标定、回写都靠这张图。

## 0. 一张图

```
芯片 XC7VX485T
├── 上下两个 half（top / bottom）          ← 帧基址在这里断开
└── clock region（时钟域，高 50 个 SLICE 行）
    ├── column 0   CLB 列
    ├── column 1   CLB 列
    ├── column 2   INT 列（布线）
    ├── ...        BRAM 列 / DSP 列 / IO 列 / GTX 列
    └── 每个 column 由若干 tile 纵向堆成
        └── tile（版图矩形单元）
            └── site（可放置位置，如 SLICE_X10Y10）
                └── BEL（槽位，如 A6LUT）
                    └── LUT6 / FF / CARRY4
```

自下而上记住三句话：

1. **BEL 是最小格子**：一个 site 里有很多槽位，`A6LUT` 只是其中一个。
2. **site 有坐标**：`SLICE_X10Y10` = 第 10 列、第 10 行的 slice。
3. **帧是配置存储器的寻址单位**：一个 site 的位，落在**固定的一组帧 + 固定的字 + 固定的位**上。

---

## 1. LUT6：一个 64 位的真值表

### 1.1 它到底是什么

一个 6 输入 LUT 就是一张 **64 项真值表**：

```
输入 a5..a0 = 0..63  →  第 i 项 = INIT 的第 i 位
输出 = INIT[i]
```

所以 `INIT = 64'h0000_0000_0000_0001` 表示"只有输入全 0 时输出 1"，
`INIT = ...0002` 表示"只有输入等于 1 时输出 1"。你 sweep 的 `0x1 → 0x2`，
本质上就是**把真值表里的两个最小项换了个位置**。

### 1.2 LUT6_2

7 系列的 LUT 可以拆成两个 5 输入 LUT（共享输入），叫 LUT6_2：

- `O6` 用 6 个输入，取 INIT[63:0]
- `O5` 只用 5 个输入，取 INIT 的高半部分（INIT[63:32]）

这解释了为什么同一个 LUT 的 64 位会分布在**多个帧**里：硬件把 LUT 存储阵列切成了若干段，
每段落在不同的 minor 帧。

### 1.3 你在位流里看到的

X10Y10 / A6LUT 的 64 位 INIT，分布在 **4 个连续帧（31748..31751）的 word 20**，
每帧 16 位。这不是"4 个 LUT"，而是**同一个 LUT 的存储被切成了 4 段**。

> 记住这条，后面标定时才不会把"4 帧"误认成"4 个资源"。

---

## 2. SLICE：4 个 LUT + 8 个 FF + 进位链

### 2.1 组成

一个 slice 里有：

| 资源 | 数量 | 说明 |
|---|---|---|
| LUT6 | 4 | 分别是 A/B/C/D 四个槽位 |
| FF | 8 | 每个 LUT 配 2 个（FF/LATCH 可配） |
| CARRY4 | 1 | 4 位进位链，纵向跨 slice 连成一条长链 |
| 宽多路器 | — | F7AMUX / F7BMUX / F8MUX，用于把 LUT 拼成 7/8 输入函数 |

### 2.2 BEL 命名

Vivado 里一个 slice 的槽位名是固定的：

```
A6LUT  A5LUT  AFF  AFF2
B6LUT  B5LUT  BFF  BFF2
C6LUT  C5LUT  CFF  CFF2
D6LUT  D5LUT  DFF  DFF2
```

你探针里的 `--bel A6LUT` 就是"这个 slice 的 A 号 LUT"。

### 2.3 SLICEL 与 SLICEM

| 类型 | 能力 | 去向 |
|---|---|---|
| **SLICEL** | 纯逻辑：LUT + FF + 进位 | 大多数逻辑 |
| **SLICEM** | 额外能当**分布式 RAM**（RAM32M/RAM64X1D）和**移位寄存器**（SRL16/SRL32） | 小存储、移位 |

M 的额外能力意味着**同一组位有第二种解释**：当你看到"某片位在 RAM 模式下有值"时，
不要急着当成 LUT INIT——先确认该 slice 的类型和模式位。

### 2.4 位流里的投影

一个 slice 的逻辑位集中在一组连续 4 个 minor 帧里（一个 LUT 的 64 位 INIT
分在这 4 帧），但**帧号由 X/Y 决定，word 由 Y 决定**：

```
frame = region_base[Y // 50] + column_offset(X)
word  = 2 * (Y % 50) + (1 if Y % 50 >= 25 else 0)
```

`SLICE_X10Y10` 是 word 20，`SLICE_X0Y0` 是 word 0，`SLICE_X10Y20` 是
word 40，`SLICE_X219Y35` 是 word 71——这些差异来自行号，不是 BEL。
BEL（A6LUT/B6LUT/FF...）在帧内的偏移还没有系统测量。

---

## 3. CLB：两个 slice

### 3.1 组成

一个 CLB = 2 个 slice，二者 Y 坐标相邻，进位链上下贯通。

CLB 的类型按两个 slice 的组合分：

| 类型 | 组成 |
|---|---|
| **CLBLL** | 两个 SLICEL |
| **CLBLM** | 一个 SLICEL + 一个 SLICEM |
| **CLBMM** | 两个 SLICEM（少见） |

### 3.2 为什么要关心

- 进位链是**跨 slice 纵向**的：CARRY4 的输出 `COUT` 接到上面一个 slice 的 `CIN`。
  探进位时，改一个 slice 会影响上下相邻的链。
- 一个 CLB 的两个 slice 在版图上同属一个 tile，但在位流里是**不同的帧组**。

---

## 4. site：可放置的位置

### 4.1 坐标含义

```
SLICE_X10Y10
       │  └── Y：行号（同一 clock region 内从 0 开始）
       └───── X：列号（从器件左边数）
```

- `X` 对应**列**：同一 X 的所有 slice 在版图上是纵向一列；
- `Y` 对应**行**：同一 Y 的一排 slice 横穿整个器件。

### 4.2 与 LOC 的关系

```tcl
set_property LOC SLICE_X10Y10 [get_cells lut]   ;# 定到格子
set_property BEL A6LUT       [get_cells lut]    ;# 定到格子里的槽位
```

只给 `LOC` 不给 `BEL`，Vivado 可以把你放到 A/B/C/D 任意一个 LUT 槽位，
所以必须同时固定 `BEL` 并用 `PROBE_BEL` 校验。注意：sweep 里出现的
word 0/40/61/81 **主要来自行号 Y**，不是 BEL 造成的；BEL 偏移仍待测。

### 4.3 其它资源的 site 命名

| 资源 | site 名 | 备注 |
|---|---|---|
| 逻辑 | `SLICE_XnYm` | 本文主角 |
| 块 RAM | `RAMB36_XnYm` / `RAMB18_XnYm` | 一个 36K 可拆两个 18K |
| DSP | `DSP48_XnYm` | 乘法累加 |
| IO | `IOB_XnYm` | 引脚缓冲 |
| 时钟 | `MMCM_XnYm` / `PLL_XnYm` | 时钟管理 |

---

## 5. tile：版图上的矩形单元

### 5.1 tile ≠ site

这是最容易混的一对：

- **tile** 是版图切分的矩形，带行列坐标，属于"物理版图"；
- **site** 是 tile 内部可以放东西的位置，属于"逻辑资源"。

一个 tile 可以含 0 个、1 个或多个 site；也可以一个 site 都不含（纯布线 tile）。

### 5.2 tile 的类型

| tile 类型 | 内容 |
|---|---|
| `CLBLL_L` / `CLBLL_R` / `CLBLM_*` | 逻辑 |
| `INT_L` / `INT_R` | 布线（PIP、开关盒） |
| `BRAM_L` / `BRAM_R` | 块 RAM |
| `DSP_L` / `DSP_R` | DSP |
| `LIOB33` / `RIOB33` / `LIOI3` / `RIOI3` | IO |
| `HCLK_*` / `CLK_*` | 时钟 |
| `VBRK` / `VFRAME` | 分界/框架 |

### 5.3 为什么 tile 重要

prjxray 的整个数据库都是以 tile 为单位的：

- `tilegrid.json`：tile 名 → (row, column)
- `segbits_<tile类型>.db`：该类型 tile 的位语义
- `tileconn.json`：tile 之间的连线

你现在缺的正是这张"tile 表"——没有它，帧号只是序号，不是坐标。

---

## 6. column：列宽不等的纵列

### 6.1 列的构成

器件从左到右是一列一列拼起来的：

```
[IO] [CLB] [CLB] [INT] [BRAM] [CLB] [DSP] [CLB] [INT] ... [IO]
```

同一类型的 tile 纵向堆叠成一列；列的**宽度不一样**：
CLB 列窄，BRAM/DSP 列宽，IO/GTX 列更特殊。

### 6.2 这直接解释了你的观察

你扫 X 方向时帧号步长不是常数：以 Y=160 为例，相对 X10 的 208 列步长
依次出现 208、472、544、442、418、416……（完整表见 `README.md`）。
原因就是：**帧号按列推进，列与列之间隔的帧数取决于这一列的宽度和类型**。

> 结论：不要试图用 `frame = a*X + b` 拟合 X 方向。必须建"列序表"。

### 6.3 列与帧的关系（直觉模型）

一列在纵向有若干行，每一行占若干 minor 帧。于是：

```
帧号 ≈ 该列之前所有列的总帧数 + 行号 × 2 + minor(0..3)
```

这个式子里的量都要靠标定拿到：行步长是 **2**（一个 LUT 的 4 个 minor
帧跨两行），列偏移不是常数。

---

## 7. clock region：50 行一个时钟域

### 7.1 是什么

clock region 是**时钟布线的基本分区**：每个区域有自己的时钟主干、水平时钟行（HROW），
跨区域的时钟要经过专门的缓冲。

### 7.2 你的器件上的数字

从 Y 方向 sweep 看：`Y0..Y49` 是同一个 clock region，`Y50` 起换区，
`Y100`、`Y150`、`Y200` 又各自换区。485T 上 clock region 高 **50 个
SLICE 行**，X0 列的基址大约为：

| Y 范围 | X0 基址 |
|---|---|
| 0..49 | 31,748 |
| 50..99 | 26,502 |
| 100..149 | 272（SLICE 只存在于 140..149） |
| 150..199 | 5,518 |
| 200..249 | 10,764 |
| 250..349 | 待批量结果补齐 |

所以 `Y10/Y20/Y40` 的 word 分别是 20/40/80（同一区内按行偏移），
而 `Y60/Y80` 的帧基址跳到 26,5xx 一带。

### 7.3 top / bottom 半区

Virtex-7 大器件在物理上分上下两个 half，配置流也按半区组织。
你的数据里 `26504 < 31748` 说明**下半区（或上半区）的帧基址更小**，
两个半区不是简单连续的——标定时必须把"半区"当成一级坐标。

```
half(top)    → 帧基址 A
half(bottom) → 帧基址 B
```

哪边是 A、哪边是 B，要用探针实测（Y=0 和 Y=最大 各打一个点）。

---

## 8. 位流里的投影：从坐标到 (frame, word, bit)

### 8.1 四层坐标

```
(column, row, minor)  ←→  frame            （帧号是这三维的线性化）
(frame, word, bit)    ←→  某个门/触发器    （帧内位置）
```

### 8.2 一个 LUT 的完整路径

以你已验证的 X10Y10 / A6LUT 为例：

```
LOC = SLICE_X10Y10
  ↓  X=10 → column_offset(10)（相对 X10 为 0）
  ↓  Y=10 → clock region 0，frame = 31748 + 0
  ↓  word = 2*10 + 0 = 20
  ↓  BEL=A6LUT → 64 位 INIT 分散在 4 个 minor 帧
  ↓
帧 31748..31751，word 20，bit 0..15 / 16..31 / 32..47 / 48..63
```

### 8.3 校验表

| 你改的东西 | 预期变化范围 | 实测 |
|---|---|---|
| 一个 LUT 的 1 个 INIT 位 | 1 个 frame 的 `word=2*row+half` + 该帧 word 50（ECC） | ✅ |
| 整个 64 位 INIT | 4 个 frame 的同一 word + 各自 ECC | ✅ |
| 换一个 X（同 Y） | 帧号整体平移，步长 = 列宽 | ✅ 步长不等（208/472/544/…） |
| 换一个 Y（同 X） | 帧号按 `2*(Y%50)+half` 变 word，跨 50 行换基址 | ✅ Y40→Y60 跳变 |

---

## 9. 常见误区

1. **把 tile 当 site**：`CLBLL_L_X2Y0` 是 tile，`SLICE_X0Y0` 是 site，两者编号体系不同。
2. **以为 1 帧 = 1 个资源**：一个 LUT 的 64 位跨 4 帧；一帧里还混着别的资源。
3. **以为帧号线性于 X**：列宽不等，必须查列序表。
4. **忽略 top/bottom**：跨半区时帧基址会跳，公式失效。
5. **把 word 50 当数据**：它是 ECC，跟着数据变，不是你在改的逻辑位。
6. **只看 LOC 不看 BEL**：LUT 可能落到别的槽位，导致 word 号对不上。

---

## 10. 下一步该测什么

| 目标 | 实验 | 产出 |
|---|---|---|
| 列序表 | 固定 Y，沿 X 每 1 列打一个点 | `column → 帧基址` 表 |
| 行步长 | 固定 X，Y 从 0 到 49 逐行 | 每行 minor 帧数（预期 4） |
| 半区边界 | Y=0 与 Y=最大 各一个点 | top/bottom 的基址 |
| BEL 差异 | 同一 site 的 A/B/C/D 四个 LUT | 每个 BEL 的 word/bit 模板 |
| FF | 同一 site 改 FF 属性 | FF 控制位的位置 |
| 布线 | 同一 DCP 改一条线的走法 | PIP 的位形态 |
