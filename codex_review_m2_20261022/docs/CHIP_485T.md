# XC7VX485T 结构与资源（实测口径）

数据来源：RapidWright 2026.1 设备模型 + 本项目扫描结果
（`tiles.csv.gz` 150,380 行、`edges_exact` 39,923,710 行、115 个 tile 模板）。
器件：Virtex-7 `xc7vx485tffg1761-2`，封装 FFG1761。

## 1. 资源总量

| 资源 | 数量 | 说明 |
|---|---|---|
| 逻辑单元（LUT6） | 303,600 | SLICEL 43,200 + SLICEM 32,700，共 75,900 个 slice，每 slice 4 个 6 输入 LUT |
| 触发器（FF） | 607,200 | 每 slice 8 个 FF |
| 分布式 RAM | 8.4 Mb | 仅 SLICEM 的 LUT 可作 64×1 / 32×2 分布式 RAM |
| SRL（移位寄存器） | 32,700 × 4 | SLICEM 的 LUT 可作 32 位移位寄存器 |
| Block RAM | 1,030 块 × 36 Kb = 37,080 Kb（约 4.5 MB） | RAMB36/RAMBFIFO36 各 1,030；RAMB18 1,030（与 36K 同块拆分） |
| DSP | 2,800 个 DSP48E1 | 25×18 乘法器 + 48 位累加器 |
| 用户 I/O | 700 | IOB18S 336 + IOB18M 336 + IOB18 28 |
| 高速收发器 | 56 通道 / 14 quad | GTXE2_CHANNEL 56、GTXE2_COMMON 14 |
| 时钟 | MMCM 14、PLL 14、BUFG 32、BUFH 168、BUFR 56、BUFIO 56 | |
| PCIe | 4 个 PCIE_2_1 硬核 | Gen2 x8 |
| 其他 | ICAP 2、BSCAN 4、DCI 14、IDELAYCTRL 14 | |

## 2. 层级

```
器件 device
└─ clock region（14 个：X0/X1 两列 × Y0..Y6 七行）
   └─ 列 column（每列一类资源：CLB / BRAM / DSP / I/O / GTX / 时钟）
      └─ tile（150,380 个，配置位与布线的最小容器，115 种类型）
         └─ site（53 种：SLICE / RAMB36 / DSP48E1 / IOB / MMCM / GTXE2_CHANNEL …）
            └─ BEL（LUT6、FF、CARRY8、RAMB36E1 的 BRAM 口 …）
               └─ 配置位（frame / word / bit）
```

- 器件网格：412 列 × 365 行 = 150,380 个 grid 单元，**一个 grid 单元恰好一个 tile**。
- clock region：14 个（X0Y0..X0Y6、X1Y0..X1Y6），每个约 50 行高。
- 一个 clock region 内，同一行的水平顺序（实测 `X145Y180` 附近，grid 坐标）：
  `CLBLL_L(370) → INT_L(371) → INT_R(372) → CLBLM_R(373)`。

## 3. tile 是什么

tile 是**布局布线与配置位的容器**，不是逻辑资源本身：

- 它拥有若干 **wire**（导线）和 **PIP**（可编程互连点），构成局部布线资源；
- 它拥有若干 **site**（真正的逻辑资源，如 slice、BRAM、DSP、IOB）；
- 它在 bitstream 里对应一段**固定地址的配置位**（frame/word/bit）。

一个 INT tile 有 600 根 wire、3,737 个 PIP，但只有 1 个 TIEOFF site；
一个 CLBLM tile 只有 315 根 wire、151 个 PIP，却有 2 个 slice。

## 4. CLBLM_R / INT_R 到底是什么

这两个名字都带 `_R`/`_L`，但含义不同：

- **CLBLM_R**：CLB 类型的 tile，`_R` 表示它位于该 CLB 列的右半（east half）。
  `CLBLM` = 该 tile 的两个 slice 中至少一个可作存储器（SLICEM），
  实测 `CLBLM_R_X145Y180` 含 `SLICE_X208Y180`（SLICEM）与 `SLICE_X209Y180`（SLICEL）。
- **CLBLL_L**：CLB 类型，`_L` 左半，两个 slice 都是纯逻辑（SLICEL），
  实测 `CLBLL_L_X144Y180` 含 `SLICE_X207Y180`、`SLICE_X206Y180`。
- **INT_L / INT_R**：互连 tile（interconnect），左右各一，夹在 CLB 列两侧；
  `INT_L` 与 `CLBLL_L` 同名号（X144），`INT_R` 与 `CLBLM_R` 同名号（X145）。
  它们不含逻辑资源，只有 wire/PIP 和一个 TIEOFF。

所以「CLBLM_R 和 INT_R 有什么区别」的答案是：**前者是逻辑资源容器（2 个
slice，可配置成 LUT/FF/CARRY/分布式 RAM），后者是纯布线容器（600 根线、
3,737 个交叉开关）**；两者在硅片上相邻，各自对应 bitstream 中不同的位段。

## 5. 115 种 tile 家族（按数量）

| 家族 | 实例数 | 作用 |
|---|---|---|
| INT_L / INT_R | 26,550 + 26,550 | 主互连（水平/垂直/长线/时钟馈线） |
| NULL | 19,709 | 占位/填充 tile（无逻辑功能，仍有位段） |
| CLBLM_R / CLBLM_L | 17,000 + 15,700 | 含 SLICEM 的 CLB |
| CLBLL_L / CLBLL_R | 3,100 + 2,150 | 纯 SLICEL 的 CLB |
| VBRK | 12,950 | 垂直断裂/边界（clock region 之间的连接） |
| INT_INTERFACE_L/R | 4,550 + 3,850 | CLB 列与 BRAM/DSP 列交界处的互连 |
| BRAM_INT_INTERFACE_L/R | 2,400 + 2,750 | BRAM 列内部接口 |
| BRAM_L / BRAM_R | 480 + 550 | Block RAM 列 |
| DSP_L / DSP_R | 770 + 630 | DSP 列 |
| HCLK_CLB / HCLK_L / HCLK_R | 765 + 529 + 529 | 水平时钟布线 |
| BRKH_* | 若干 | BRAM 列上/下的断裂 tile |
| GTX_INT_INTERFACE、IO_INT_INTERFACE、PCIE_NULL … | 若干 | 专用列接口 |

## 6. 布线层规模

| 项 | 值 |
|---|---|
| wire 总数 | 56,847,864 |
| PIP 总数（tile 内） | 207,253,149 |
| 跨 tile 边（精确表） | 39,923,710 |
| 有外部连接的 wire | 11,857,917 |

wire 按意图码分：`SINGLE`（单长线）、`DOUBLE`、`VQUAD`/`HQUAD`、`VLONG`/`HLONG`、
`PINFEED`、`BOUNCEIN`、`OUTBOUND` 等；跨 tile 边由 corridor 规则表或
`edges_exact` 表给出，逐实例 0 误差。

## 7. 配置位层

| 项 | 值 |
|---|---|
| frame 数 | 50,176 |
| 每 frame 字数 | 101 |
| 每 frame 字节 | 404 |
| 每字位数 | 32 |
| 总配置位 | 50,176 × 101 × 32 ≈ 162.2 Mb（约 20.3 MB） |

frame 地址 = (block type, row, column, minor)，一个 tile 的位段落在它所在列的
若干净 frame 上；LUT 的 64 位 INIT 在 4 个连续 frame 各占 16 位（已实测：
`SLICE_X10Y20/A6LUT` → frame 31748..31751，全部 word 20）。

## 8. 与本项目数据库的对应

| 层 | 数据 | 位置 |
|---|---|---|
| tile + site 布局 | 150,380 行 CSV | `out_routing/tiles.csv.gz` |
| tile 内 wire/PIP | 115 个模板 | `out_routing/templates/<TYPE>.json` |
| 跨 tile 边 | 39,923,710 行 | `v7_routing.db` 的 `edges_exact` |
| corridor 规则 | 804,680 行 | `step02/rules.db` |
| LUT INIT → 位 | 4 帧组 + 置换公式 | `v7re` 的 probe / db |
| site → frame | 仅采样 | 待 STEP03/STEP04 补全 |
