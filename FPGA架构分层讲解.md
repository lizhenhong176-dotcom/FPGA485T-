# Virtex-7 FPGA 架构分层讲解（XC7VX485T）

> 配套图：一张总览 + L0→L4 五张分层详图，全部位于本目录 `.archify\` 下。
> 文中**所有数量**均来自本项目导出的实测数据（`tilegrid.json` / `physical_only_sites.json` / `summary.json`），非手册抄录。
> 视角：从「逆向比特流」出发——每一层都标注「它在比特流里对应什么」。

---

## 总览：一棵包含树 + 两条正交层

```
器件 Device
  └─ 时钟区 Clock Region (×14)
       └─ Tile (115 种 / 150,380 个)
            └─ Site (26 种 / 86,022 个)
                 └─ BEL (叶子：LUT / FF / MUX / 进位)

正交层 A：互连 INT —— 信号怎么在 Tile 之间“走”
正交层 B：比特流寻址 —— frame / word / bit 三维位图
```

- 总览图：`architecture-fpga-overview-20261025-213000\fpga-overview.html`
- 详细物理总图：`architecture-fpga-physical-detail-20261025-214000\fpga-physical-detail.html`

---

## L0 器件 Device —— 一张可重构的「开关矩阵网」

FPGA 不是「造好的电路」，而是**海量相同的逻辑单元 + 海量可编程开关**，靠配置比特决定「哪根线连哪根线、每个查找表存什么真值表」。

| 维度 | 实测数量 |
|---|---|
| Tile 总数 | **150,380**（115 种类型） |
| 功能 Site | **86,022**（26 种） |
| 非功能 Site | 55,612（TIEOFF 54,500 等） |
| 片内 wire | **56,847,864** |
| 片内 PIP（可编程开关） | **207,253,149** |
| 时钟区 | 14 |

**本质**：配置 = 给这 2 亿多个开关逐一写 0/1，再给每个 LUT 写 64 位真值表。比特流就是这份「开关位图 + 真值表」。

> 详图：`architecture-fpga-L0-device-20261025-215000\fpga-L0-device.html`

---

## L1 时钟区 Clock Region —— 比特流帧寻址的第一级

- 器件被划成 **14 个时钟区**，每区是 **5 列 × 2 行** tile 的网格。
- 为什么要分区：时钟树、全局布线、配置存储器都按区对称组织。
- **比特流落点**：`frame 号 = 区基址 + 列偏移`。在不同列打探针测出的帧号（如 X0Y0=31748、X10Y160 各列）就是这套区基址。

| 时钟区 | 说明 |
|---|---|
| X0Y0 … X0Y6 / X1Y0 … | 14 个区，跨整个 die 的列分组 |
| 每区 | 5 列宽 × 2 行高（行方向再按 50 SLICE 分块，见 L4/word 公式） |

> 详图：`architecture-fpga-L1-region-20261025-215000\fpga-L1-region.html`

---

## L2 Tile 大类 —— 芯片的「积木种类」

115 种 tile 类型，归成 7 大类（括号为实测个数）：

| 大类 | 数量 | 代表类型 | 作用 |
|---|---|---|---|
| **CLB 逻辑** | 37,950 | CLBLM_L/R、CLBLL_L/R | 装 SLICE，做组合/时序逻辑 |
| **INT 互连** | 53,100 | INT_L/R | 开关矩阵，搬运信号 |
| **BRAM 存储** | 1,030 | BRAM_L/R | 片上块 RAM（36Kb/块） |
| **DSP 乘加** | 1,400 | DSP_L/R | DSP48E1 硬核 |
| **IO 引脚** | — | LIOI/RIOI/LIOB/RIOB | 焊盘、串并、延迟 |
| **CMT/CLK 时钟** | — | CMT_*、HCLK_*、CLK_BUFG_* | MMCM/PLL、全局缓冲 |
| **GTX 串行** | 56 通道 | GTX_CHANNEL/COMMON | 高速收发（PCIe/SFP） |

> 另有 **54,722 空白/禁用 tile**、**19,709 NULL**——不是每格都有东西，布线要绕开。

> 详图：`architecture-fpga-L2-tile-20261025-215000\fpga-L2-tile.html`

---

## L3 Site —— tile 里的「功能单元」

一个 CLB tile 含 **2 个 SLICE**（37,950×2 = **75,900 SLICE**）。Site 共 26 种，主力：

| Site 类型 | 数量 | 所在 tile |
|---|---|---|
| SLICE | 75,900 | CLB |
| DSP48 | 2,800 | DSP |
| RAMB36 / RAMB18 | 1,030 / 2,060 | BRAM |
| IOB / ILOGIC / OLOGIC / IDELAY / ODELAY | 各 700 | IO |
| BUFHCE | 168 | 时钟 |
| GTXE2_CHANNEL / IN·OUT_FIFO / PHASER_* / BUFIO / BUFR | 各 56 | GTX/IO |
| BUFGCTRL | 32 | 时钟 |
| MMCM / PLL / PHY_CONTROL / GTXE2_COMMON / IDELAYCTRL | 各 14 | 时钟/IO/GTX |

**SLICEL vs SLICEM**：M 多两项能力——**分布式 RAM**（RAMD64/RAMS64，拿 LUT 当小 RAM）与 **移位寄存器 SRL**，并把 F7/F8 mux 当普通 mux 用。

> 详图：`architecture-fpga-L3-site-20261025-215000\fpga-L3-site.html`

---

## L4 BEL —— 叶子，比特真正落的地方

一个 **SLICEM** 含 8 个 BEL：

- **4× LUT6**（A6LUT…D6LUT）：6 输入 → **INIT[63:0]** 64 位真值表 → O6（可拆成 2 个 LUT5）。
  - 逆向里「一个 LUT 的 64 个 INIT 位」就是这 64 位，落在该 SLICE 的那对配置帧里。
- **8× FF**（AFF…DFF，每个可 FDRE/FDSE/FDPE/FDNE 或锁存）。
- **4× F7 mux（AMUX…DMUX）+ 1× F8 mux（EMUX）**：拼 7/8 输入宽函数。
- **进位链** CIN→A→B→C→D→COUT：快速加法。

> 详图：`architecture-fpga-L4-bel-20261025-215000\fpga-L4-bel.html`

---

## 正交层 A：互连 INT —— 信号怎么「走」

每个 INT tile **600 条 wire / 3,737 个 PIP**（115 种模板均统一）。PIP 家族：

- **IMUX**（12 输入复用）：把外部信号选进 SLICE 的 A1..A6；
- **OMUX**（8 输出）：把 SLICE 输出送上线；
- **BEG/END**：本地进出；**GFAN/GFS**：长/短线轨道（跨多 tile 的「高速公路」）。

一条网络的典型路径：`LOGIC_OUTS → BEG → 轨道 → END → IMUX → Site PIP → A1 → LUT`。
**一个 PIP 是否导通 = 配置里 1 个比特**，读出所有 PIP 位 = 还原整张布线图。

---

## 正交层 B：比特流寻址 —— frame / word / bit（已实测钉死）

配置存储器是三维位图：

- **frame（帧）= 区基址 + 列偏移** → 选哪一列 tile（CLB 与 INT 各占独立帧对）；
- **word（字）= 2·(row%50) + (row%50≥25 ? 1 : 0)** → 选哪一行；边界已在 **X10Y24/25/26** 探针验证；
- **bit = 特性位**（某 LUT 的某条真值表项 / 某 PIP 使能）；**word 50 = AUX 辅助帧**，排除。

**逆向总路线**：给定 BEL 坐标 → 算出 (frame, word, bit) → 在比特流里读/改那一位 → 改写这块硬件的真值表或某根连线。

---

## 图清单

| 层 | 文件 |
|---|---|
| 总览 | `.archify\architecture-fpga-overview-20261025-213000\fpga-overview.html` |
| 详细物理总图 | `.archify\architecture-fpga-physical-detail-20261025-214000\fpga-physical-detail.html` |
| L0 器件 | `.archify\architecture-fpga-L0-device-20261025-215000\fpga-L0-device.html` |
| L1 时钟区 | `.archify\architecture-fpga-L1-region-20261025-215000\fpga-L1-region.html` |
| L2 Tile 大类 | `.archify\architecture-fpga-L2-tile-20261025-215000\fpga-L2-tile.html` |
| L3 Site | `.archify\architecture-fpga-L3-site-20261025-215000\fpga-L3-site.html` |
| L4 BEL | `.archify\architecture-fpga-L4-bel-20261025-215000\fpga-L4-bel.html` |
