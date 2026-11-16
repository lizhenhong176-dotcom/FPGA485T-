# 物理架构 × 位流结构：深度版（xc7vx485tffg1761-2）

> 本文件是 `PROMPT_PIP_FAMILY_MASTER.md` 的第二次执行，专补上一版（`PIP_FAMILY_METHOD.md`）中偏薄的 **② 物理架构** 与 **③ 位流结构**。
> 标注约定：【实测】= 本仓库脚本算出、可复现；【推断】= 由实测外推、未单独验证；【未测】= 未验证，给了测法。
> 数据源：`E:\v7work\db\prjxray\xc7vx485t\tilegrid.json`（150,380 tile）、`E:\v7work\model\v7_model.sqlite`（sites / clb_blocks / law_*）、`E:\v7work\_s8v0.bit`（20,273,538 B）。

---

## ① 一分钟速览

| 问题 | 答案 |
|---|---|
| 器件骨架 | 412 列（gx 0..411）× 365 行（gy 0..364）；逻辑行名 Y 0..349，正好 7×50 |
| 时钟区域 | 14 个 = **7 行 × 2 列**，行高 50 个 CLB 行；列分界在 die 中心的 IO 脊（gx≈196） |
| 行型是否统一 | **不统一**：225 行有 111 个 CLB 列，100 行 105 个（PCIE 行），25 行 99 个（PCIE+feedthru），15 行 0 个（GTX/终端行） |
| 列签名种类 | **102 种**（把每行的 412 列类型串成签名统计） |
| 逻辑列规律 | CLB 列与 INT 列严格交替；长线（LV/LVB）由每 4 逻辑列一个 `VBRK` 提供；CLBLL/CLBLM 交替使任意连续列都有 SLICEM |
| IO | 700 个 pad site = 2 个 pad 列（gx 81、312）× 7 region × 50 行 → **每 region 每侧 50 pad = 一个 bank** |
| 帧总数 | 50,176；字 101；位 32 → 20,257,472 个有效配置位 |
| 帧号布局 | 按 clock region 分带，**每带恰好 5,180 帧**，带间距 66（起始 pitch 5,246）；fabric 带止于 36,688，之后 13,488 帧属于 IO/GTX/CFG 一侧 |

---

## ② 物理架构

### 2.1 die 骨架（三层坐标）

```
die
├── 14 clock region = 7 行 (Y0..Y6) × 2 列 (X0, X1)      【实测：sites.clock_region = X{0,1}Y{0..6}】
│     └── 50 个逻辑行（CLB name-Y）
│           └── 一行的 412 个列位置（gx 0..411）——但整行并非都有 tile【实测：行型见 2.2】
└── tile（150,380 个）→ site（86,022 个 fabric site）→ BEL（SLICE 内 A6LUT/AFF/CARRY4…）→ cell
```

三条坐标必须分清，混用会直接算错帧号：

| 坐标 | 含义 | 取值 | 用途 |
|---|---|---|---|
| `name X/Y` | tile 名字里的逻辑坐标（`INT_L_X6Y11`） | X 0..? / Y 0..349 | 逻辑定位、行内 word |
| `grid_x/grid_y` | tilegrid 里的几何坐标 | 0..411 / 0..364 | 邻接计算（tileconn 的 dx,dy 用这个） |
| 帧号 | 位流里的物理地址 | 0..50,175 | 找位 |

两个已知的坐标错位（踩过坑）：
- **east 半区 gy 与 name-Y 差 2**：`INT_L_X72Y51` = (gx 185, gy 310)，而西半区 `INT_L_X6Y11` = (17, 352)【实测】
- **gy 234 不存在**（半带边界上被跳过）【实测】

### 2.2 行型不统一（上一版漏掉的事实）

把每一行（gy）的 412 个列类型拼成签名，全芯片有 **102 种不同的行签名**【实测】。按"该行有多少个 CLB 列"归类：

| 行型 | 行数 | CLB 列数 | 特征差异（相对 111 列标准行） |
|---|---|---|---|
| 标准 fabric 行 | **225** | 111 | 无 |
| PCIE 行 | **100** | 105 | gx 14..20 变为 `PCIE_INT_INTERFACE_R` / `PCIE_NULL` / `PCIE_INT_INTERFACE_LEFT_L`；gx 81/82（`LIOB18_SING`/`LIOI_SING`）、gx 87（`CMT_PMV`）、gx 192（`CLK_FEED`）、gx 306（`CMT_PMV_L`）为 `NULL` |
| PCIE + feedthru 行 | **25** | 99 | 同上，再加 gx 146/147 = `INT_FEEDTHRU_1/2`（CLB 与 INT 换成直通） |
| 终端行 | **15** | 0 | 255 个 `NULL` + 154 个 `T_TERM_INT` + `TERM_CMT`/`CLK_TERM`（die 上下边界） |

推论（【推断】）：**block 基址不能按"列号 × 常数"算**，必须按 (grid_col, band) 查表——这正是 `clb_blocks` 表存在的原因；行型变化也会改变该行某些列的 tile_type，从而改变该列 block 的尺寸（36 / 28 帧）。

### 2.3 列序列与三条规律

标准 fabric 行（gy=310 采样）的列类型序列（节选，完整 412 列见 `s13_pips.json` 同目录脚本输出）：

```
gx0 NULL | 1 L_TERM_INT | 2 GTX_INT_INTERFACE_L | 3 INT_L | 4 INT_R | 5 CLBLL_R
| 6 CLBLM_L | 7 INT_L | 8 INT_R | 9 CLBLL_R | 10 VBRK | 11 CLBLM_L | 12 INT_L | 13 INT_R
| 14 BRAM_INT_INTERFACE_R | 15 NULL | 16 CLBLL_L | 17 INT_L | 18 INT_R | 19 CLBLM_R
| 20 CLBLM_L | 21 INT_L | 22 INT_R | 23 CLBLM_R | 24 VBRK | 25 CLBLL_L | ...
```

三条规律【实测】：

1. **INT 永远夹在两个 CLB 之间**：`CLB · INT_L · INT_R · CLB` 是基本节奏（个别处为单 INT 或 BRAM/PCIE 接口列打断）。
2. **每 4 个逻辑列插一个 `VBRK`**：VBRK 是长竖线（LV/LVB）的物理起点——这解释了为什么 A3 的走线里出现 `LV_L18`（跨 clock region 的长竖线只在 VBRK 列起飞）。
3. **CLBLL 与 CLBLM 交替**：CLBLM = SLICEM + SLICEL，CLBLL = SLICEL + SLICEL，交替排布使**任意横向连续的若干列里必有一个 SLICEM**（这就是为什么 S9 补 INT_L 缺失 mux 时，只有 `SLICE_X8Y11` 这种偶 X 位置能提供 C/D LUT）。

### 2.4 SLICEM 规则（100% 可判定）

由 `sites` 表 75,900 个 slice 反查【实测】：

| 事实 | 数量 | 判据 |
|---|---|---|
| SLICEM 全部是**偶 X** 且全部落在 `CLBLM_L` / `CLBLM_R` | 32,700 | `X mod 2 == 0` 且 tile_type 以 `CLBLM` 开头 |
| SLICEL = CLBLM 的奇 X（32,700）+ CLBLL 的 X0/X1（10,500） | 43,200 | 其余 |
| CLBLM tile 总数 | 32,700（R 17,000 + L 15,700） | = SLICEM 数 |
| CLBLL tile 总数 | 5,250（L 3,100 + R 2,150） | ×2 = 10,500 SLICEL |

**可直接用作逆向算法的先验**：给定 slice 名 `SLICE_XnYy`，若 `n` 为偶数 ⇒ 该 slice 是 SLICEM，其 C/D LUT 可做 RAM/SRL，且其 C/D 输入 mux 只能由本 tile 的 IMUX 名（`_L*` 或 `_R*`）驱动——这一条在 S9/S10 里直接决定了可达性判断。

### 2.5 资源普查与互校

| 资源 | 数量 | 分布 | 互校 |
|---|---|---|---|
| SLICEL / SLICEM | 43,200 / 32,700 | 见 2.4 | 合计 75,900 slice；理论 LUT 上限 303,600（每 slice 4×LUT6），FF 上限 607,200 |
| DSP48E1 | **2,800** | **20 列**（gx 14,20,26,36,42,47,53,66,72,78,84,89,95,100,106,111,117,127,133,139）× 140 | 1,400 tile × 2【实测】 |
| RAMB18E1 / RAMBFIFO36E1 / FIFO18E1 | 各 **1,030** | **15 列**（gx 5,11,23,29,39,50,69,81,92,103,114,124,130,142,148），每列 60–70 | BRAM tile 1,030（L 480 + R 550）【实测】 |
| IOB（pad site） | **700** | 2 列（gx 81, 312）× 7 region × 50 行 | = 350 行 × 2 侧【实测】 |
| BUFGCTRL | **32** | `CLK_BUFG_BOT_R_X192Y204` 16 + `CLK_BUFG_TOP_R_X192Y209` 16 | 上/下半区各 16 |
| BUFHCE | **168** | `CLK_HROW_{BOT,TOP}_R` 8 行 × 21 | 每 region 行一条 HROW |
| BUFR / BUFIO | 各 **56** | 4 列 × 14（= 每 region 一组） | 与 region 数自洽 |
| BUFMRCE | **28** | 2 列 × 14 | |
| MMCME2_ADV / PLLE2_ADV | 各 **14** | `CMT_TOP_{L,R}_*` | = 7×2 region 数 |
| GTXE2_CHANNEL | **56** | gx 0 与 gx 394 各 28；`GTX_COMMON` 14 | 28 quad |
| PCIE | 8 tile | 集中在 gx 14..20 的 PCIE 行 | |
| XADC（MONITOR） | 3 tile | | |
| 配置（CFG_CENTER） | 3 tile | | |

口径差异必须并列：`sites` 表 86,022（fabric 口径，只含可放 cell 的 site）vs RapidWright 导出 141,634（含 IO/配置/特殊 site），两者差 55,612，差额主要是 `NULL`/`VBRK`/`T_TERM_INT` 等不可放 cell 的位置上的"伪 site"【实测】。

### 2.6 时钟网络（逆向时最容易漏的一层）

| 层级 | 单元 | 位流可见性 |
|---|---|---|
| 全局 | `BUFGCTRL`（32）→ `GCLK_*` | 配置位在 `CLK_BUFG_*` tile 的帧块内【未测：未定位位池】 |
| 行级 | `BUFHCE`（168）→ `HCLK_*` | 在 `CLK_HROW_*` tile【未测】 |
| 区域级 | `BUFR`/`BUFIO`（各 56） | 在 `CMT_*` tile【未测】 |
| 扇出到 CLB | `GFAN0` / `FAN_ALT7` / `FAN_L7` / `CLK_L1` | 已在 INT tile 帧内解出（`GFAN0←WW4END1` 等，见 `s13_pips.json`）【实测】 |

已实测的一条：`A5 = GFAN0` 走的就是"INT 全局扇出线"——这意味着**时钟网与数据网在 INT 层共用同一套 PIP 位池**（`GFAN0` 是 INT tile 的一个 family），跨族独占性因此必须包含时钟族；目前只测了数据族【边界】。

### 2.7 IO 结构

```
pad site (IOB18_S/M)  →  ILOGICE2 / OLOGICE2（ISERDES/OSERDES）  →  IOI（LIOI/RIOI）  →  INT_INTERFACE（IOI_LOGIC_OUTS→INT）
   gx 81 / 312            gx 82 / 311                              gx 82 / 311            gx 83 / 310
```

关键数字【实测】：`ILOGICE2` / `OLOGICE2` / `IDELAYE2_FINEDELAY` / `ODELAYE2` 各 **700**（= pad 数，1:1 对应）；`IBUFDS_GTE2` 28（GTX 参考时钟）。

逆向含义：**一个 pad 的输入路径终点是 `INT_INTERFACE_LOGIC_OUTS_L{n}` 这条 wire**，而这条 wire 的编号 n 与 pad 的物理位置强相关（本项目实测 6 条输入链分别落在 `INT_L_X32Y50..55`，行号 − 50 = 端口序号 i[0..5]）——这条规律是"位流里没有名字，但端口名可以纯解码恢复"的关键【实测，6/6】。

---

## ③ 位流结构

### 3.1 三层容量

| 层 | 数量 | 说明 |
|---|---|---|
| 帧 | **50,176** | 每帧 1 个 FAR 地址 |
| 字 | **101** | 100 个字（3,200 位用户配置）+ 1 个 ECC 字 |
| 位 | 32/字 | 有效配置位 50,176 × 101 × 32 = **20,257,472** |
| 文件 | 20,273,538 B | 差额 = 头部（同步字/命令/FAR/DMA）+ 尾部 |

### 3.2 帧号布局（本仓库实测的唯一可靠口径）

用 `clb_blocks`（763 个 CLB 块）反推【实测】：

| band（clock region 行） | 块数 | base 范围 | 带跨度 | 带内 36×n | 余量（28 帧接口块等） |
|---|---|---|---|---|---|
| 0 | 111 | 31,508 .. 36,652 | 5,180 | 3,996 | 1,184 |
| 1 | 105 | 26,262 .. 31,406 | 5,180 | 3,780 | 1,400 |
| 2 | 104 | 32 .. 5,176 | 5,180 | 3,744 | 1,436 |
| 3 | 111 | 5,278 .. 10,422 | 5,180 | 3,996 | 1,184 |
| 4 | 111 | 10,524 .. 15,668 | 5,180 | 3,996 | 1,184 |
| 5 | 110 | 15,770 .. 20,914 | 5,180 | 3,960 | 1,220 |
| 6 | 111 | 21,016 .. 26,160 | 5,180 | 3,996 | 1,184 |

结论【实测】：
- **每个 band 恰好 5,180 帧**（7 × 5,180 = 36,260），band 起始 pitch **5,246**（相邻带之间空 66 帧）。
- fabric 部分止于 **36,688**，其后 **13,488 帧**属于 IO/GTX/CFG 一侧的块（`INT_L_X32Y5x`、`INT_R_X33Y5x`、`LIOI/RIOI`、`CLK_BUFG` 等）。
- 块内步长 **36 帧 = 1 个 CLB tile 的完整配置空间**（含 4 组字段：INIT/FF/IMUX/PIP）。
- 块间出现 **gap 64**（= 36 + 28，中间夹一个 28 帧的 `*_INT_INTERFACE_*` 块）与 **gap 72**（只出现在 band 2 / band 5，那两带多一个更宽的接口块）。

### 3.3 定位公式（可直接写进解码器）

```
给定 slice 名 SLICE_XnYy：
  band      = y // 50
  grid_col  = gx_of(slice_name)                 # 由 clb_tiles 表反查，不能用 n 直接算
  base      = clb_blocks[(grid_col, band)]      # 36 帧块的基址
  row_word  = 2*(y % 50) + (1 if (y % 50) >= 25 else 0)   # 半带 +1
  frame     = base + frame_off                  # frame_off 来自家族表的 (frame_off, parity)
  word      = row_word + parity                 # parity = artix7 segbits 的 bit//32
  bit       = raw_bit % 32
```

半带 +1 的物理原因【实测 + 推断】：CRAM 的列扫描在一个 clock region 内不是简单线性——前半区 25 行占 50 个字（每行 2 字），后半区 25 行同样 50 字，但**起始字偏移 +1**。证据：artix7 tilegrid 的 INT offset 显示 Y0–24 = 2Y、Y25–49 = 2Y+1；V7 侧 `INT_L_X16Y27 → w55`、`X18Y31 → w63`、`X22Y39 → w79`、`X26Y47 → w95`、band1 的 `Y51 → w2` 全部吻合【实测】。

### 3.4 帧 → tile 的对应（块表，不是公式）

| 块类型 | 帧数 | 何时出现 |
|---|---|---|
| CLB tile | **36** | 每个 `CLBLL_*` / `CLBLM_*` 列 |
| INT tile | **28** | 每个 `INT_L` / `INT_R` 列 |
| BRAM / 接口列 | **28** | `BRAM_INT_INTERFACE_*`、`INT_INTERFACE_*`、VBRK/NULL 夹缝 |
| IO / CMT / GTX | 28 或 36 | 见 2.5 分布 |

坑：同一段帧空间**可能被两个 tile 名同时"认领"**（S13 曾出现 `INT_L_X32` 与 `INT_R_X33` 双映射 ghost）——判定方法是比较 base 差：`INT_R` 的块基址 = 其西侧 CLB 块 + **68**，`INT_L` = + **36**；若两者算出同一个 base，说明规则用错【实测】。

### 3.5 命令层与完整性（本节大部分【未测】）

| 项 | 状态 |
|---|---|
| 同步字 / 包类型（type1/type2） | 【未测】本仓库未解析命令流，只做帧级读写 |
| FAR 寄存器字段切分 | 【未测】已知 FAR = 块地址 + 行 + 列，但位宽切分未做；实测到 `FAR 0x00420320` 对应 `CLBLL_L_X6Y10`，未反推字段边界 |
| CRC | 【未测】写位回环时用 Vivado 重新生成整帧（迂回绕过） |
| ECC（word 50） | 【实测】存在且逐帧独立；本项目只验证了 IMUX 字段的 1,600 位 ECC，**未做全帧 ECC 表** |
| 读回（readback） | 【未测】无板卡；靠 Vivado 生成对照 bitstream 代替 |

**边界声明**：本项目的"位流结构"知识止于**帧级读写 + 块表 + 定位公式**；命令层、FAR 位域、全帧 ECC 都未解。任何"可以直接构造任意位流"的说法都超出当前证据。

---

## ④ 家族是什么（一句话 + 新证据）

**家族 = 同一 tile_type 下、目标 wire 相同的一组互斥 PIP；它们的源由同一小组配置位编码区分。**

新证据（本轮补测，`PIP_FAMILY_METHOD.md` §5 已展开）：`INT_L.EL1BEG_N3` 的 9 个 cell 分两层——**组选线 4 位**（`(12,0,5)` length-6 方向线 / `(15,0,5)` length-2 / `(13,0,5)` length-1+L12 / `(14,0,5)` CLB 输出）+ **成员选线 5 位**（被 4 组复用）；每位源恰 2 位 = 1 组位 + 1 成员位，位宽 4+5=9 ≫ ceil(log2 20)=5。

→ 位复用的物理机制：**两条正交 one-hot 总线**，不是压缩编码。

---

## ⑤ PIP 复用解法链（六环，详见 `PIP_FAMILY_METHOD.md` §5）

| 环 | 动作 | 关键坑 |
|---|---|---|
| 1 | 位池抽取 | `bit//32` 当 parity；raw bit 取 `%32` |
| 2 | 家族键 | 必须 `(tile_type, destination_wire)`；用 `(tile_type, src)` 会立刻崩塌 |
| 3 | 一热 fuzz | 四种失败症状：空 pattern / 全 1 / 多族同 pattern / 源不可达 |
| 4 | 列计数推结构 | 组列恒 a、成员列恒 b ⇒ 位宽 a+b，源数 a×b |
| 5 | 单 PIP 反解 | `ones ⊆ O ∧ zeros ∩ O = ∅` |
| 6 | 多 PIP CSP | 互斥（每族 ≤1）+ 覆盖（每个观测位被解释）→ SOLVED/AMBIGUOUS/UNEXPLAINED/CONFLICT |

---

## ⑥ 三类"复用"辨析（防止概念混淆）

| 名称 | 含义 | 本项目状态 |
|---|---|---|
| **A. 位级共享**（用户说的"PIP 复用"） | 一个 SRAM cell 被同族多条 PIP 的编码共用 | 已量化：1,598 cell / 172 族 / 3..18 源每 cell【实测】 |
| **B. 位模式跨实例复用** | 同一源的相对位偏移在 tile/band/列/slice 实例间不变 | 已证：181 PIP 0 ambiguous；inst0/inst1 迁移 2/2 与 6/6【实测】 |
| **C. 布线资源复用**（EDA 语境的 reuse） | 同一 PIP 被多条 net 复用（时间/空间） | **不是本命题**；位流是静态配置，一条 PIP 只有一种状态 |

---

## ⑦ 判据与证伪

| 判据 | 表达 | 失败模式 |
|---|---|---|
| 族独占 | `∀ cell: family(cell)` 唯一 | 跨族共享 ⇒ 反解歧义爆炸 |
| 族内可辨 | 任两源存在一格取值相反 | 两源 pattern 相同 ⇒ 不可反解 |
| 覆盖 | 观测中每个置 1 位都被某源解释 | 有剩余 ⇒ UNEXPLAINED（通常是基线噪声位或未测族） |
| 互斥 | 每族至多一条被选 | 违反 ⇒ CONFLICT（可能是 ECC 坏或位被写错） |

三条可立刻执行的证伪实验：① 造"同族两源位同置"的非法帧 → 解码器必须报 AMBIGUOUS；② 按 `(frame_off, parity, bit)` 跨族分组 → 必须 0 共享；③ 直接改位不重算 ECC → 必须被硬件拒绝（无板卡时用 Vivado 读回代理）。

---

## ⑧ 常见误解（≥8）

1. "一个源一位" —— 错，每位源 2 位（组 + 成员）。
2. "家族 = 一个 mux 门" —— 错，家族常是多级 mux 树（如 EL1BEG_N3 = 4×5 两级）。
3. "位数 = ceil(log2 N)" —— 错，是 a+b；20 源要 9 位。
4. "跨族共用位能省面积" —— 硬件上可行，但 485T 的 INT tile 未这样做（1,598/1,598 独占）【限 INT tile】。
5. "全 0 = 无选择" —— 错，源选择是"组位 + 成员位各置 1"，全 0 通常非法。
6. "family 是 Xilinx 官方术语" —— 不是，UG470/UG472 无此词。
7. "有 `(frame_off, bit)` 就能定位" —— 不够，必须带 `parity` 与 tile 的 `base`。
8. "同名目标 wire 就是同一族" —— 错，`INT_L.X` 与 `INT_R.X` 位池完全不同。
9. "行型是统一的，列号 × 常数 = 块基址" —— 错，见 2.2（102 种行签名、带宽 5,180 与带距 66）。

---

## ⑨ 自测（6 题）

1. 给 `SLICE_X47Y51`，写出它的 band、base、row_word。
   （答案：band = 51//50 = **1**；base = **27,286**（`clb_blocks[(79,1)]`）；row_word = 2×(51%50) = **2**，与实测 `word 2` 一致）
2. `INT_R_X33` 的块基址用 `+36` 还是 `+68`？为什么错一个就会 ghost 双映射？
3. 为什么 A3 的走线里会出现 `LV_L18`，而 A2 没有？
4. 700 个 pad 与 86,022 个 fabric site、1,760 个 package pin 三者的差值各来自哪里？
5. 每带 5,180 帧这个数字，能否由 `412 列 × ? ` 推出来？如果不能，说明什么？
6. 若把 word 规则误写成 `2*(Y%50)`（去掉半带 +1），哪一类 tile 会解错、错多少？

---

## ⑩ 结论与下一步

**已闭环**：帧级定位（公式 + 块表）、CLB 位语义（INIT/FF/AFFMUX）、IMUX 位表跨实例复用、INT PIP 位池与家族结构、位流→网表（2 个 slice、含重综合位级验证）。

**明确缺口（按优先级）**：
1. **命令层 / FAR 位域 / 全帧 ECC**（3.5）——决定"能否构造任意位流"；
2. **跨族独占性**：BRAM / DSP / IO / 时钟族未测（2.6）——决定 ⑤ 的公理边界；
3. **4 位源结构**：`(8,16)`/`(10,24)` 的直通中间级（《PIP_FAMILY_METHOD》§5）——决定多级 mux 的图像；
4. **行型变化的块表外推**：PCIE 行/终端行的块尺寸【未测】——决定全芯片扫描能否覆盖 100%。
