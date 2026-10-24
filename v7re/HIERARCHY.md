# HIERARCHY — Xilinx FPGA 的六级物理层级（BEL → Device）

> 适用：7 系列（含 **XC7VX485T**）为主，UltraScale 差异单独标注
> 配套：`GLOSSARY.md`（术语）、`ARCHITECTURE.md`（CLB/slice/tile 细节）、`README.md`（进展）
> 一句话：**BEL 组成 Site，Site 构成 Tile，Tile 阵列形成 Clock Region，Clock Region 组成 SLR（仅多 die），最终构成 Device。**

## 0. 六层总览

```
┌──────────────────────────────────────────────────────────────┐
│ L6  Device        整颗芯片（单 die 或多 SLR）                 │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ L5  SLR       一颗硅片/die（只有 SSIT 多 die 器件才有） │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │ L4  Clock Region / FSR   时钟域（485T 实测 50 SLICE 行高）│  │  │
│  │  │  ┌────────────────────────────────────────────┐  │  │  │
│  │  │  │ L3  Tile   版图网格单元（含 0..n 个 Site） │  │  │  │
│  │  │  │  ┌──────────────────────────────────────┐  │  │  │  │
│  │  │  │  │ L2  Site   功能容器（SLICE/BRAM/DSP）│  │  │  │  │
│  │  │  │  │  ┌────────────────────────────────┐  │  │  │  │  │
│  │  │  │  │  │ L1  BEL  原子单元（LUT/FF/MUX）│  │  │  │  │  │
│  │  │  │  │  └────────────────────────────────┘  │  │  │  │  │
│  │  │  │  └──────────────────────────────────────┘  │  │  │  │
│  │  │  └────────────────────────────────────────────┘  │  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

每一层在**位流里都有对应的坐标表示**，这是这张表对逆向工作的全部意义：

| 层级 | 物理含义 | 位流里的表示 |
|---|---|---|
| L1 BEL | 最小可配置单元 | `(frame, word, bit)` 的具体位点 |
| L2 Site | 一组 BEL | 一组连续 minor 帧（如 SLICE 的 4 帧） |
| L3 Tile | 网格地块 | `tilegrid` 的 (row, col)；`segbits` 的命名空间 |
| L4 Clock Region | 时钟域 | 帧地址里的"块"边界 |
| L5 SLR | 硅片 | 分隔的 FDRI 段 / 不同基址 |
| L6 Device | 芯片 | 帧总数（485T = 50,176） |

---

## 1. L1 · BEL —— 原子单元

### 1.1 定义

**BEL（Basic Element of Logic）** 是 FPGA 架构中最小的、不可再分的物理组件。
它是真实存在的电路元件，也是 `place_design` 的最终落点：网表里的 **leaf cell**（叶子单元）
必须被精确映射到某个 BEL 上。

> 注意：BEL 不是"逻辑门"，而是"可配置单元"。一个 LUT6 BEL 内部是一张 64 项真值表，
> 不是 64 个门。

### 1.2 两类 BEL

| 类别 | 例子 | 作用 |
|---|---|---|
| **Logic BEL** | `A6LUT`、`A5LUT`、`AFF`、`AFF2`、`CARRY4`、`DSP48E1`、`RAMB36E1` | 执行实际逻辑/存储/运算 |
| **Routing BEL** | site 内部的 `F7AMUX`、`F7BMUX`、`F8MUX` 等 | site 内部的信号选择与路由 |

Routing BEL 是很多人忽略的一层：**site 内部也有多路器**，它们同样由配置位控制，
同样占位流里的位。你以后解"宽逻辑函数"（7/8 输入）时一定会碰到 F7/F8MUX。

### 1.3 命名规律

一个 slice 内的 BEL 名字是固定的：

```
A6LUT  A5LUT  AFF  AFF2
B6LUT  B5LUT  BFF  BFF2
C6LUT  C5LUT  CFF  CFF2
D6LUT  D5LUT  DFF  DFF2
CARRY4
```

`A6LUT` = A 号 6 输入 LUT；`A5LUT` = 它的 5 输入半部；`AFF`/`AFF2` = 两个触发器。

### 1.4 位流里的投影

一个 BEL 的配置位**不一定是连续的**，也不一定只在一个字里。以 LUT6 为例（你已实测）：

```
A6LUT 的 64 位 INIT
  → 4 个连续 minor 帧
  → 每帧 word 20 的 16 个位
  → 外加每帧 word 50 的 13 位 ECC（跟着变，不是你改的逻辑位）
```

**这就是为什么"BEL 级逆向"必须先是"帧级 + 位级"**：一个 BEL 的语义天然跨多帧。

---

## 2. L2 · Site —— 功能容器

### 2.1 定义

**Site** 是一组相关 BEL 及其内部连线的集合，是**具有完整逻辑功能的最小物理单元**。
它有自己的唯一坐标，可以被 `LOC` 直接指定。

### 2.2 常见 Site 类型

| Site 类型 | 内含 | 坐标示例 |
|---|---|---|
| `SLICEL` | 4 LUT6 + 8 FF + CARRY4 | `SLICE_X10Y10` |
| `SLICEM` | 同上 + 分布式 RAM / 移位寄存器 | `SLICE_X10Y110` |
| `DSP48E1` | 乘法器 + 累加器 + 预加器 | `DSP48_X0Y10` |
| `RAMB36E1` / `RAMB18E1` | 36Kb / 18Kb 块 RAM | `RAMB36_X0Y10` |
| `IOB33` / `IOB33M` | 引脚缓冲 | `IOB_X0Y10` |
| `MMCME2_ADV` / `PLLE2_ADV` | 时钟管理 | `MMCM_X0Y0` |
| `GTXE2_CHANNEL` | 高速收发器 | `GTXE2_CHANNEL_X0Y4` |

### 2.3 CLB 与 Slice 的关系（7 系列 vs UltraScale）

| 架构 | 1 个 CLB 含 | 说明 |
|---|---|---|
| **7 系列** | **2 个 Slice** | 一个 CLB tile 里放两个 slice site |
| **UltraScale** | **1 个 Slice** | slice 变大：8 个 LUT6 + 16 个 FF |

这条差异很关键：**在 7 系列上说"一个 CLB 有两个 slice"是对的，在 UltraScale 上就错了。**

### 2.4 坐标

```
SLICE_X10Y10
       │  └── Y：行号
       └───── X：列号
```

- `X` 递增 = 向右移动一列；
- `Y` 递增 = 向上移动一行；
- 同一个 `X` 的所有 site 构成纵向一列；
- 同一个 `Y` 的所有 site 构成横向一排。

### 2.5 与约束的关系

```tcl
set_property LOC SLICE_X10Y10 [get_cells lut]   ;# 定 Site
set_property BEL A6LUT       [get_cells lut]    ;# 定 Site 内的 BEL
```

**只给 LOC 不给 BEL，工具可以在该 site 内任选 BEL。** 这会让"同一个 LOC、不同次运行"
落到不同槽位，位点自然对不上——这是探针数据最常见的污染源。

---

## 3. L3 · Tile —— 物理网格单元

### 3.1 定义

**Tile** 是比 Site 高一级的物理"地块"，是构成 FPGA fabric 的基础网格单元。
整个芯片可以看作 tile 组成的二维阵列，每个 tile 有 `TILE_ROW`、`TILE_COLUMN`、`TILE_TYPE`。

### 3.2 Tile 与 Site 的数量关系

- 一个 tile 可以含 **0 个、1 个或多个** site；
- 含多个 site 时，可以是同类型（两个 slice = 一个 CLB），也可以是不同类型；
- **纯布线 tile（INT）一个 site 都没有**，但含有大量 PIP。

所以：**tile ≠ site，也不总是一一对应。**

### 3.3 7 系列常见 tile 类型

| Tile 类型 | 内容 | 有无 site |
|---|---|---|
| `CLBLL_L/R` | 两个 SLICEL | 有（2 个） |
| `CLBLM_L/R` | 一个 SLICEL + 一个 SLICEM | 有（2 个） |
| `INT_L/R` | 布线、开关盒 | 无 |
| `BRAM_L/R` | 块 RAM | 有 |
| `DSP_L/R` | DSP | 有 |
| `LIOB33` / `RIOB33` / `LIOI3` / `RIOI3` | IO | 有 |
| `HCLK_*` / `CLK_*` | 时钟 | 视类型 |
| `VBRK` / `VFRAME` | 分界/框架 | 无 |

### 3.4 为什么 tile 是逆向的"主键"

prjxray 的整套数据库都以 tile 为单位：

```
tilegrid.json      tile 名 → (row, column)
tile_type_*.json   该类型 tile 的 site、wire、PIP
segbits_*.db       该类型 tile 的位语义
tileconn.json      tile 之间的连接
```

**你现在的缺口正是 tile 这一级**：只有帧号，没有 tile 表，帧号就只是序号。

---

## 4. L4 · Clock Region / FSR —— 时钟域

### 4.1 定义

**Clock Region**（一些文献/工具里写作 **FSR, Fabric Sub Region**）是由一片 tile 组成的
二维区域，是**时钟资源分配的基本粒度**。相邻区域之间通过专用时钟网络连接和分发。

> 术语提醒：Xilinx 官方文档基本只用 "clock region"；"FSR" 更多出现在研究论文和
> 部分工具里。两者指同一个东西，写文档时建议以 clock region 为准，FSR 作为别名注明。

### 4.2 高度（485T 已实测）

用 `E:\v7work\db\site_enum\sites.csv`（75,900 个 slice site 的枚举结果）统计：

| 项 | 485T 实测值 |
|---|---|
| slice site 总数 | **75,900**（SLICEL 43,200 + SLICEM 32,700） |
| X 范围 | 0..221（**222 个不同 X**） |
| Y 范围 | 0..349（**350 个不同 Y**） |
| clock region 数 | **14**（纵向 7 个 × 横向 2 个） |
| 每个 clock region 高 | **50 个 SLICE 行** |

逐区分布：

```
X0Y0: Y 0..49      X1Y0: Y 0..49
X0Y1: Y 50..99     X1Y1: Y 50..99
X0Y2: Y 100..149   X1Y2: Y 100..149
X0Y3: Y 150..199   X1Y3: Y 150..199
X0Y4: Y 200..249   X1Y4: Y 200..249
X0Y5: Y 250..299   X1Y5: Y 250..299
X0Y6: Y 300..349   X1Y6: Y 300..349
```

> 口径说明：Xilinx 文档常用"每个 clock region 含 50 个 CLB"来描述 7 系列。
> 在这颗器件上，按 **site 枚举**得到的是 50 个 SLICE 行；写数据库时以 site 表为准，
> 不要混用 "CLB 行" 和 "SLICE 行" 两种口径。

### 4.2b 与 UltraScale 的差异

| 架构 | 每个 clock region 高 |
|---|---|
| **7 系列（485T 实测）** | **50 个 SLICE 行** |
| **UltraScale / UltraScale+** | **60 个 CLB** |

宽度都可以不同（不同列类型占的宽度不一样；485T 横向只有 2 个 region）。

### 4.3 位流里的表现

clock region 是帧地址分块的自然边界：

- 同一列内，跨 clock region 时帧基址会跳（485T 每 50 个 SLICE 行一个边界）；
- 你观测到的 `Y40 → Y60` 帧基址从 `31748` 跳到 `26504`，正好跨过 Y49/Y50 的边界，
  这是"块边界"信号——**边界在 50 行**（已由 §4.2 核实）；
- 但 `Y10 / Y20 / Y40` 同属 X0Y0 区却拿到同一组帧，属于**行内地址异常**，
  见 §11，与区域高度无关。

### 4.4 为什么重要

- 时钟必须经区域内的 HROW 分发，跨区要过缓冲；
- 布局布线工具按区域平衡资源；
- 逆向时，区域边界会打断"帧号 = f(Y)"的线性假设。

---

## 5. L5 · SLR —— 硅片（仅多 die）

### 5.1 定义

**SLR（Super Logic Region）** 只存在于**多 die（SSIT, Stacked Silicon Interconnect Technology）**
器件中。一颗物理硅片对应一个 SLR：

- 单 die 器件：**没有 SLR 这一层**，clock region 直接构成 device；
- 多 die 器件：n 颗 die = n 个 SLR，SLR 之间通过硅中介层（interposer）上的专用互连通信。

### 5.2 典型例子

| 器件 | SLR 数 | 说明 |
|---|---|---|
| **XC7VX485T** | **1（单 die，无 SLR 层）** | 你的目标器件 |
| XC7V2000T | 4 | 业界较早的 SSIT 器件 |
| VU9P / VU13P 等 | 3~4 | UltraScale+ SSIT |

### 5.3 在 Vivado 里怎么看

```tcl
get_slrs                      ;# 单 die 器件返回空
get_property SLR_INDEX [get_cells ...]
```

### 5.4 不要和"上下半区"混淆

Virtex-7 的配置流在物理上分 **top / bottom 两个 half**（配置架构决定），
这**不是 SLR**，也不是两颗 die。它只影响**位流的组织方式**（两段 FDRI、两个基址），
不影响物理层级。

```
half（配置半区）  → 位流概念，V7 单 die 也有
SLR（逻辑区域）   → 物理概念，仅多 die 器件有
```

---

## 6. L6 · Device —— 完整芯片

- **单 die**：多个 clock region 直接组成 device；
- **多 die**：多个 SLR 组成 device，SLR 间通过专用互连通信。

对逆向而言，device 层提供两个关键常数：

| 常数 | 485T 实测值 |
|---|---|
| 帧总数 | **50,176** |
| 每帧字数 | 101（= 404 字节） |
| IDCODE | `0x03687093` |
| 器件串 | `7vx485tffg1761` |

---

## 7. 485T 上的逐层对照

| 层级 | 在 485T 上的形态 | 命名/数量 | 查询命令 |
|---|---|---|---|
| L1 BEL | `A6LUT`、`AFF`、`CARRY4`、`F7AMUX`… | 每 slice 4 LUT + 8 FF + 1 CARRY4 | `get_bels -of [get_sites ...]` |
| L2 Site | `SLICEL`/`SLICEM`/`DSP48E1`/`RAMB36E1`/`IOB33`/`MMCME2_ADV` | `SLICE_XnYm` | `get_sites` |
| L3 Tile | `CLBLL_L`/`CLBLM_R`/`INT_L`/`BRAM_L`/`DSP_R`/`LIOB33`… | `CLBLL_L_X2Y0` | `get_tiles` |
| L4 Clock Region | 时钟域 | `X0Y0`… | `get_clock_regions` |
| L5 SLR | 无（单 die） | — | `get_slrs`（空） |
| L6 Device | `xc7vx485tffg1761-2` | 50,176 帧 | — |

---

## 8. 这套层级怎么映射到位流

### 8.1 一条完整路径

```
leaf cell (LUT6)
  ↓ place_design
BEL      A6LUT
  ↓ 属于
Site     SLICE_X10Y10
  ↓ 属于
Tile     CLBLL_L_X?Y?
  ↓ 位于
Clock Region  X?Y?
  ↓ 位于
Device   xc7vx485t
  ↓ write_bitstream
位流     frame 31748..31751 / word 20 / bit ...
```

### 8.2 每一级能回答的问题

| 问题 | 需要哪一级 |
|---|---|
| 这个 bit 控制哪个 LUT 的哪一位？ | BEL + Site |
| 这个 frame 属于哪一列、哪一行？ | Tile + Clock Region |
| 这个 tile 里还有哪些 site？ | Tile |
| 跨区为什么帧号跳？ | Clock Region |
| 两个 half 的基址为什么不同？ | Device（配置组织） |

### 8.3 逆向工作的顺序（由下往上）

1. **BEL 级**：固定 `(LOC, BEL)`，扫 INIT，拿到 `(frame, word, bit)`；
2. **Site 级**：换 BEL（A/B/C/D）和换 LOC，归纳 site 内的位模板；
3. **Tile 级**：把同类 site 的模板推到一个 tile 类型上，形成 `segbits`；
4. **Clock Region 级**：建立"列 → 帧基址"和"行 → 帧偏移"，处理跨区跳变；
5. **Device 级**：拼出整张 `tilegrid`，得到完整帧地址模型。

---

## 9. 三个最容易混的概念

| 易混 | 区别 |
|---|---|
| **Site vs Tile** | Site 是"能放东西的位置"，Tile 是"版图上的地块"；一个 tile 可含 0..n 个 site |
| **CLB vs Tile** | 7 系列一个 CLB tile 里恰好是一个 CLB（2 个 slice）；但 tile 是物理概念，CLB 是逻辑概念 |
| **SLR vs half** | SLR 是物理 die（仅多 die）；half 是 V7 配置流的上下半区（单 die 也有） |

---

## 10. 这些数字是怎么来的（可复核）

上面 §4.2 的数字来自 `scripts/enumerate_sites.py` 生成的
`E:\v7work\db\site_enum\sites.csv`（75,900 行，列：site / type / tile / clock_region / row / column / bels）。

本机 Vivado 批处理直接 `link_design` 查 485T 时启动阶段长时间无输出，已终止；
改用站点枚举这条路，结果一致且更快。要复核或换器件时，跑这四条：

```tcl
link_design -part xc7vx485tffg1761-2

# 1) clock region 的 row/col 范围
foreach cr [get_clock_regions] {
    puts "$cr rows=[get_property ROW_RANGE $cr] cols=[get_property COLUMN_RANGE $cr]"
}

# 2) 一个 CLB tile 里到底有几个 slice site
set t [lindex [get_tiles -filter {TILE_TYPE =~ CLBLL*}] 0]
puts "sites of $t: [get_sites -of_objects $t]"

# 3) slice 的 Y 与 tile row 的换算关系
puts "tile_row=[get_property TILE_ROW $t]"
foreach s [get_sites -of_objects $t] { puts "  $s slice_y=[get_property SLICE_Y $s]" }

# 4) 单 die 确认
puts "slrs=[get_slrs]"
```

**结果已由站点枚举拿到，不用再跑**：见 §4.2。485T 是 14 个 clock region、
每个 50 个 SLICE 行（Y 0..349），不是 "50 CLB = 100 slice 行"。

---

## 11. 你这批数据里的一个待解异常

`sweep/results.json` 里：

| LOC | 差异帧 |
|---|---|
| `SLICE_X10Y10` | 31748..31751 |
| `SLICE_X10Y20` | 31748, 31750 |
| `SLICE_X10Y40` | 31748, 31750 |
| `SLICE_X10Y60` | 26504 |
| `SLICE_X10Y80` | 26504, 26505 |

**Y10、Y20、Y40 落在同一组帧**，这与"帧号随行号变化"直接矛盾。

用 `sites.csv` 对照：这三个点都在 **clock region X0Y0**（Y 0..49），但分别在不同行。
如果 50 行 × 4 个 minor 帧铺满一个 region，相邻行应相差 **4 帧**——实测没有。
两种可能：

1. `LOC` 没真正生效（LUT 被放到了别处），或 `BEL` 没锁住导致落点漂移；
2. 这三个点确实同属一个"块"，但那样 Y 就不是按 1 行 = 固定帧数递增的。

**验证方法**：对每个 sweep 的 `routed.dcp` 查实际落点

```tcl
open_checkpoint routed.dcp
puts [get_property LOC  [get_cells lut]]
puts [get_property BEL  [get_cells lut]]
puts [get_property SITE [get_cells lut]]
```

只有 `SITE` 与请求一致的点，才允许进入数据库。这条校验不做，后面所有"列序表""行步长"
都会建立在错误样本上。

---

## 12. 小结

- 六级：**BEL → Site → Tile → Clock Region → SLR（仅多 die）→ Device**；
- 7 系列：1 CLB = 2 slice；UltraScale：1 CLB = 1 slice；
- clock region 高度：**485T 实测每区 50 个 SLICE 行、共 14 区（7×2）、Y 0..349**；
  UltraScale 文档值 60 CLB；
- 485T 单 die，**没有 SLR 层**，但配置流有 top/bottom 两个 half；
- 逆向时按 **BEL → Site → Tile → Region → Device** 由下往上爬，每一级都对应位流里的一层坐标。
