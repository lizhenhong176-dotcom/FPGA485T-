# Virtex-7 家族 / mux / 物理单元：完整讲解

> 标注约定：**【硬件事实】**= 7 系列体系结构或 UG470/UG472/UG473/UG475/UG476/UG479 可查证；**【数据事实】**= 本项目实测（来源：`E:\v7work\db\prjxray\xc7vx485t\tilegrid.json` 的 tile 普查、`E:\v7work\model\v7_model.sqlite` 的 site 普查、`STATUS.md`）；**【推断】**= 由数据反推、未直接证实。
> 器件：`xc7vx485tffg1761-2`。凡无数据处标「未测」。

---

## ① 一句话定义

**家族 = 同一 tile_type 下、目标 wire 相同的一组互斥 PIP，其多个源共用同一小组配置位编码区分。**
（三个要素：目标 wire 定边界、互斥定语义、编码定数据形态。）

---

## ② 命名速查（先命名，后概念）

### 表 1 · PIP feature 名

```
INT_L.NL1BEG1.NN6END2 07_32 12_33
└tile_type┘└ 目标wire ┘└ 源wire ┘ └ offset_bit ┘
```

| 形式 | 含义 |
|---|---|
| `<tile_type>.<目标wire>.<源wire> <off>_<bit> …` | prjxray segbits 记法；无前缀=该位须为 1 |
| `!<off>_<bit>` | 该位须为 **0**（负 sense） |
| `TILE/TILE_TYPE.SRC->>FAM` | 本项目记法（源→目标），与上者等价 |
| 家族 | 同一 `<tile_type>`、同一 `<目标wire>` 的全部 PIP |

### 表 2 · wire 名

| 片段 | 含义 |
|---|---|
| `NN/SS/EE/WW` + `1/2/4/6` | 单方向线：北/南/东/西，长度 1/2/4/6 |
| `NE/NW/SE/SW` + `1/2/4/6` | 对角方向线，同上 |
| `BEG<n>` / `END<n>` | 线段起点/终点编号；`BEG→END` 落点由 tileconn 固定决定（**不是 mux**） |
| `LV` / `LVB` | 跨 clock region 长竖线 |
| `GFAN` | 全局扇出 |
| `ER` / `R` | 短线 |
| `LOGIC_OUTS` | CLB 输出进入布线 |
| `IMUX` / `BYP` / `CTRL` / `CLK` | CLB 输入侧 mux 的输出 wire |

### 表 3 · tile_type（485T 实测数量，共 150,380）

| tile_type | 数量 | 含义 |
|---|---|---|
| `INT_L` / `INT_R` | 26,550 / 26,550 | 布线开关盒（家族所在） |
| `INT_INTERFACE_L` / `_R` | 4,550 / 3,850 | INT↔BRAM/DSP/IO 接口 |
| `INT_FEEDTHRU_1` / `_2` | 525 / 600 | 直通 |
| `CLBLM_R` / `CLBLM_L` | 17,000 / 15,700 | 逻辑块（含 SLICEM+SLICEL） |
| `CLBLL_L` / `CLBLL_R` | 3,100 / 2,150 | 逻辑块（两 SLICEL） |
| `BRAM_L` / `BRAM_R` | 480 / 550 | 块存储 |
| `BRAM_INT_INTERFACE_L` / `_R` | 2,400 / 2,750 | BRAM 接口 |
| `DSP_L` / `DSP_R` | 770 / 630 | DSP |
| `LIOB18` / `RIOB18` | 168 / 168 | IO 缓冲 |
| `LIOI` / `RIOI` | 126 / 126 | IO 互连 |
| `IO_INT_INTERFACE_L` / `_R` | 350 / 350 | IO 接口 |
| `HCLK_*`（13 种） | 合计 3,338 | 时钟行 |
| `CLK_HROW_*` / `CLK_BUFG_*` / `CLK_FEED` | 7 / 30 / 247 | 时钟水平行、BUFG、时钟馈线 |
| `CMT_TOP_*`（12 种） | 各 7 | 时钟管理 |
| `GTX_CHANNEL_0..3` | 各 14 | 收发器通道 |
| `GTX_COMMON` | 14 | 收发器公共 |
| `PCIE_TOP/BOT/_LEFT` | 各 2 | PCIe 硬核 |
| `MONITOR_TOP/MID/BOT` | 各 1 | XADC / SYSMON |
| `CFG_CENTER_TOP/MID/BOT` | 各 1 | 配置逻辑 |
| `VBRK` / `NULL` / `VFRAME` | 12,950 / 19,709 / 350 | 垂直断裂/空 tile/帧边界 |

### 表 4 · site / BEL

| 名称 | 含义 |
|---|---|
| `SLICE_X<n>Y<m>` | slice 实例；`CLBLL_*` 两 slice 均 SLICEL，`CLBLM_*` 偶数列为 SLICEM |
| `IOB_X<n>Y<m>` / `IOI_X<n>Y<m>` | IO 缓冲 / IO 互连 |
| `SLICEL.A6LUT` / `SLICEM.A6LUT` | BEL：slice 内 LUT6（A/B/C/D 四份） |
| `SLICEL.AFF` / `SLICEM.AFF` | BEL：slice 内 A 侧触发器 |
| `IOB18S` / `IOB18M` | IOB site（S/M 两种变体） |

---

## ③ 层级模型

`die → clock region → column → tile → site → BEL → cell`

| 层 | 物理实体 | 位流可见性 | 家族在哪 |
|---|---|---|---|
| die | 芯片 | — | — |
| clock region | 485T 共 **14** 个【数据事实】 | 帧号分区 | — |
| column | CLB/BRAM/DSP/IO/时钟列 | 帧基址规律 | — |
| tile | 150,380 个【数据事实】 | 块基址 | **家族定义在 tile_type 层，实例化在 tile 层** |
| site | 86,022 个（本表口径，见 ⑥） | site 内位 | 无 |
| BEL | `SLICEL.A6LUT` 等 | BEL 专属位 | 无 |
| cell | LUT/FF/BRAM/DSP | BEL+属性位 | 无 |

**【推断】家族属于连线层，不属于逻辑层**——它回答"信号从哪条 wire 来"，不回答"逻辑做什么"。所以同一个 BEL 的输入由第 4 级（IMUX）决定，而 IMUX 的源由第 2 级（家族）决定，两者是串联关系。

---

## ④ mux 六级

| 级 | 名称 | 物理位置 | 控制位在哪 | 输入→输出 | 本项目状态 |
|---|---|---|---|---|---|
| 1 | 长线/全局线选择（`LV/LVB`、`GFAN`、`HROW`） | INT tile 边缘、`CLK_HROW_*`、`HCLK_*` | 布线帧 | 多→1 | 部分（`GFAN0←WW4BEG1` 已解，其余【未测】） |
| 2 | **INT tile 内布线 mux（= 家族）** | 每个 `INT_L/INT_R` tile | **该 INT tile 自己的 26 帧**（offset 0–15 内） | 2–24→1 | **已解**：181 PIP / 181 家族 / 0 ambiguous |
| 3 | 跨 tile wire 续接（`BEG→END`） | tile 边界 | **无控制位**：由 `tileconn` 固定连接 | 1→1 | 已建模（17,928 条 tileconn） |
| 4 | site 入口 mux（`IMUX_L/R0..11`、`BYP`、`CTRL`、`CLK`） | CLB tile 内，紧邻 site | **CLB tile 帧内 offset 16–25**，与 INT 帧物理分离 | 10–25→1 | **已解**（双侧 48/48） |
| 5 | BEL 内部 mux（`AFFMUX/AOUTMUX/BOUTMUX(F7/F8)/PRECYINIT/DI1MUX/WEMUX/CEUSEDMUX/SRUSEDMUX/CLKINV`） | CLB tile 帧 off 30/31 等 | CLB tile 帧 | 2–5→1 | 大部分已解；`CARRY4 CY0`、`CE/SR/CLKINV` **未测** |
| 6 | 硬块内部 mux（BRAM `WEMUX/EN*/RSTREG`、DSP `AREG/BREG/OPMODE`、IO `ILOGIC/OLOGIC`） | 硬块自己的帧 | 硬块帧 | 多→1 | 部分（BRAM 少数位已验证，DSP/IO 【未测】） |

**为什么第 2 级最贵（用数字论证）**
- 数量：INT tile 53,100 个（26,550×2），是第 4 级（CLB tile 35,000）的 1.5 倍，而每个 INT tile 内有 172 个家族。
- 密度：INT tile 位池 1,664 位，其中 1,598 位（**96%**）被 3,636 条 feature 占用【数据事实】——几乎没有空闲位可做"不相干基线"，差分必须精确对齐。
- 不可静态推断：第 4/5 级可从 site 结构（12 个 IMUX）反推候选集；第 2 级的候选与编码**只能靠 fuzz 实测**（`tilepipe` 900+300 个变体才测出 48/48）。

---

## ⑤ 物理单元九组清单

### A 配置与全局

| 单元 | 所在 tile_type | 可配置 | 配置位位置 | 可从位流恢复 | 难度 |
|---|---|---|---|---|---|
| 配置帧 / OVERHEAD | 全芯片 | 结构固定 | 每 config row 末 2 帧不属任何块 | 是（结构层） | 低 |
| `FRAME_ECC` | 每帧 word 50 | 计算生成 | 每帧第 50 字 | 是（可校验） | 低 |
| `ICAP` | `CFG_CENTER_MID` | 是 | 【未测】 | 否 | 高 |
| `STARTUP` / `BSCAN` / `DNA_PORT` / `USR_ACCESS` | `CFG_CENTER_TOP/BOT` | 是 | 【未测】 | 否 | 高 |
| `SYSMON/XADC` | `MONITOR_TOP/MID/BOT`（各 1） | 是 | 【未测】 | 否 | 高 |
| `EFUSE` | 【未测】 | 一次性 | — | 否 | — |
| 读回 / `MFWR` / `FAR` | 命令层 | — | 不占 fabric 位 | — | — |

### B 时钟

| 单元 | 所在 tile_type | 可配置 | 配置位位置 | 可恢复 | 难度 |
|---|---|---|---|---|---|
| clock region（14） | — | 结构 | 帧号分区 | 是 | 低 |
| `HROW` | `CLK_HROW_TOP_R`(3)/`BOT_R`(4) | 是 | 【未测】 | 部分 | 高 |
| `MMCM`（14）/ `PLL`（14） | `CMT_TOP_*`（12 种，各 7） | 是 | 【未测】 | 否 | 高 |
| `BUFG`/`BUFGCTRL`（32） | `CLK_BUFG_TOP_R`/`BOT_R`/`REBUF` | 是 | 【未测】 | 否 | 中 |
| `BUFHCE`（168）/ `BUFR`（56）/ `BUFIO`（56）/ `BUFMRCE`（28） | `HCLK_*`、`BUFIO` site | 是 | 【未测】 | 否 | 中 |
| `GCLK`/`GCLK_B`/`CC` 引脚 | 命名网络 | 否（布线结果） | 无专属位 | 是（靠拓扑） | 中 |
| `GFAN` | INT tile | 是 | INT 帧 | 是（`GFAN0←WW4BEG1` 已解） | 中 |
| GT 参考时钟 `IBUFDS_GTE2`（28） | `GTX_COMMON` 侧 | 是 | 【未测】 | 否 | 高 |

### C 可编程逻辑

| 单元 | 所在 tile_type | 可配置 | 配置位位置（已实测） | 可恢复 | 难度 |
|---|---|---|---|---|---|
| `SLICE`（75,900） | `CLBLM_*`/`CLBLL_*` | — | — | — | — |
| `LUT6`（303,600） | 同上 | 是 | X0: off 32–35；X1: off 26–29 | **是** | 低 |
| `MUXF7`（151,800）/`MUXF8`（75,900） | 同上 | 是 | off 30 位 22/23 等（F8 已验） | 是 | 低 |
| `CARRY4`（75,900） | 同上 | 是 | `PRECYINIT` 已解（off 30 位 12/13/14）；`CY0` 族 **未测** | 部分 | 中 |
| `FDRE/FDSE/FDCE/FDSRE`（607,200 FF） | 同上 | 是 | off 30/31（`AFFMUX`/`ZRST`/`ZINI`） | **是** | 低 |
| `LD` latch | 同上 | 是 | off 46/47 位 0 等 | 是 | 中 |
| 分布式 RAM（仅 SLICEM 32,700） | `CLBLM_*` 偶列 | 是 | `ALUT.SRL`/`DLUT.RAM`/`WA7USED`/`WA8USED` 已验 | 是 | 中 |
| `SRL16E/SRLC32E` | SLICEM | 是 | 同 RAM 位域 | 是 | 中 |
| `AFFMUX/AOUTMUX/BOUTMUX` | 同上 | 是 | off 30 | 是（`A5Q` 位在 V7 退化为无位） | 中 |
| `WEMUX` | SLICEM | 是 | off 40 位 23（已验） | 是 | 中 |

### D 互连

| 单元 | 所在 tile_type | 可配置 | 配置位位置 | 可恢复 | 难度 |
|---|---|---|---|---|---|
| `INT` tile（53,100） | `INT_L/INT_R` | — | — | — | — |
| wire（全类型） | INT | 结构 | 无专属位 | 是（靠名字表） | 低 |
| `PIP`（3,636 feature / tile_type 对） | INT | 是 | INT 帧 offset 0–15 | **是**（181 已解，写回 864/864） | 中 |
| 家族（172 / tile_type 对） | INT | — | 位池互斥划分 | 是 | 中 |
| `tileconn`（17,928 条） | tile 边界 | **否** | 无位（固定连接） | 是（查表） | 低 |
| `BRK/VBRK/NULL/VFRAME` | 12,950 / 350 / 19,709 | 否 | 无位 | 是（拓扑） | 低 |
| 长线 `LV/LVB` | INT 边缘 | 是 | 【未测】 | 部分 | 高 |

### E IO

| 单元 | 所在 tile_type | 可配置 | 配置位位置 | 可恢复 | 难度 |
|---|---|---|---|---|---|
| `IOB`（`IOB18S` 336 + `IOB18M` 336 + `IOB18` 28） | `LIOB18`/`RIOB18` | 是 | 【未测】 | 否 | 高 |
| `IOI`（126+126） | `LIOI`/`RIOI` | 是 | 【未测】 | 否 | 高 |
| `IO_INT_INTERFACE`（350+350） | 同名 tile | 是 | IO 列块（非 CLB 块） | 部分（入口 PIP 已解） | 中 |
| `ILOGICE2`/`OLOGICE2`（各 700） | IOI | 是 | 【未测】 | 否 | 中 |
| `ISERDES/OSERDES` | 内嵌 ILOGIC/OLOGIC | 是 | 【未测】 | 否 | 中 |
| `ISERDES`（56） | IOI | 是 | 【未测】 | 否 | 中 |
| `IDELAYE2`/`ODELAYE2`（各 700） | IOI | 是 | 【未测】 | 否 | 中 |
| `IN_FIFO`/`OUT_FIFO`（各 56）、`PHASER_IN/OUT_PHY`（各 56） | `CMT_FIFO_*` 等 | 是 | 【未测】 | 否 | 高 |
| `IBUF/OBUF/IOBUF/IBUFDS` | 由 cell 决定，无 site | 是（属性） | IOB 帧 | 部分 | 中 |
| bank / `VREF` / `DCI` / `RIU`/`ORP` | IOB | 是 | 【未测】 | 否 | 高 |
| `PAD`（1,760 pin） | 封装引脚 | — | 无 fabric 位 | 是（查表） | 低 |

### F 存储

| 单元 | 所在 tile_type | 可配置 | 配置位位置 | 可恢复 | 难度 |
|---|---|---|---|---|---|
| `RAMBFIFO36E1`（1,030） | `BRAM_L`/`BRAM_R` | 是 | 【未测】（未系统解） | 否 | 高 |
| `RAMB18E1`/`FIFO18E1`（各 1,030） | 同上（36K 拆分） | 是 | 【未测】 | 否 | 高 |
| `BRAM_INT_INTERFACE`（2,400+2,750） | 同名 tile | 是 | 接口块帧 | 部分 | 中 |
| 级联链 | `BRAM_*` | 是 | 【未测】 | 否 | 高 |

### G DSP

| 单元 | 所在 tile_type | 可配置 | 配置位位置 | 可恢复 | 难度 |
|---|---|---|---|---|---|
| `DSP48E1`（2,800） | `DSP_L`(770)/`DSP_R`(630) | 是 | 【未测】 | 否 | 高 |
| `DSP_INT_INTERFACE` | 同名 tile | 是 | 接口块帧 | 否 | 高 |
| pre-adder / 级联 / `AREG/BREG/OPMODE` | DSP48E1 内 | 是 | 【未测】 | 否 | 高 |

### H 高速与硬核

| 单元 | 所在 tile_type | 可配置 | 配置位位置 | 可恢复 | 难度 |
|---|---|---|---|---|---|
| `GTXE2_CHANNEL`（56） | `GTX_CHANNEL_0..3`（各 14） | 是 | 【未测】 | 否 | 极高 |
| `GTXE2_COMMON`（14） | `GTX_COMMON` | 是 | 【未测】 | 否 | 极高 |
| PCIe Gen2 x8（`PCIE_2_1`） | `PCIE_TOP/BOT(_LEFT)`（各 2） | 是 | 【未测】 | 否 | 极高 |
| `XADC` | `MONITOR_*`（各 1） | 是 | 【未测】 | 否 | 高 |

### I 调试与测试

| 单元 | 所在 tile_type | 可配置 | 配置位位置 | 可恢复 | 难度 |
|---|---|---|---|---|---|
| `BSCAN` | 【未测】（CFG 侧） | 是 | 【未测】 | 否 | 中 |
| JTAG 边界扫描 | — | — | 非 fabric 位 | — | — |
| `ILA`/`VIO` | **软逻辑**（占用 SLICE/BRAM，无专属物理单元） | — | 普通 CLB/BRAM 位 | 是（当逻辑解） | — |

---

## ⑥ 485T 计数表（每项标来源）

| 项 | 数值 | 来源 |
|---|---|---|
| tile 总数 | 150,380 | 【数据事实】tilegrid |
| `INT_L` + `INT_R` | 53,100 | 【数据事实】tilegrid |
| `CLBLM_R`+`CLBLM_L`+`CLBLL_L`+`CLBLL_R` | 37,950 | 【数据事实】tilegrid |
| SLICE 总数 | 75,900（SLICEL 43,200 / SLICEM 32,700） | 【数据事实】site 表 |
| LUT6 数 | 303,600（4/slice） | 【硬件事实】UG474 |
| FF 数 | 607,200（8/slice） | 【硬件事实】UG474 |
| `MUXF7` / `MUXF8` | 151,800 / 75,900 | 【硬件事实】UG474（2/1 per slice） |
| `CARRY4` | 75,900 | 【硬件事实】UG474 |
| BRAM36 | 1,030 | 【数据事实】site 表 `RAMBFIFO36E1` |
| BRAM tile | 1,030（`BRAM_L` 480 + `BRAM_R` 550） | 【数据事实】tilegrid |
| DSP48E1 | 2,800（`DSP_L` 770 + `DSP_R` 630 × 2） | 【数据事实】site 表 |
| `GTXE2_CHANNEL` | 56 | 【数据事实】site 表 |
| `MMCM` / `PLL` | 14 / 14 | 【数据事实】site 表 |
| `BUFGCTRL` | 32 | 【数据事实】site 表 |
| `BUFHCE` / `BUFR` / `BUFIO` / `BUFMRCE` | 168 / 56 / 56 / 28 | 【数据事实】site 表 |
| `ILOGICE2`/`OLOGICE2`/`IDELAYE2`/`ODELAYE2` | 各 700 | 【数据事实】site 表 |
| `IOB18S` + `IOB18M` + `IOB18` | 336 + 336 + 28 | 【数据事实】site 表 |
| clock region | 14 | 【数据事实】RW 导出 |
| package pin | 1,760 | 【数据事实】RW 导出 |
| site 总数 | 86,022（本表口径）/ 141,634（RW 口径） | 【数据事实】两口径不同，差异为部分 IO/配置类 site |
| 位流 | 50,176 frame × 101 字 × 32 bit | 【数据事实】实测解析 |

---

## ⑦ 四个咬合问题

**Q1 家族与 IMUX 都是 mux，为什么一个在 INT 层、一个在 CLB 层？会抢同一批位吗？**
【数据事实】不会。INT 帧与 CLB 帧是**不同块**：以 `SLICE_X8Y11` 为例，CLB 块基址 31,680，IMUX 位在 off 16–25；其 `INT_L_X6Y11` 的 PIP 位在另一个块内。实测 181 条 PIP 的 cell 与 48 个 IMUX 的 cell 无交集。
【推断】物理上也合理：IMUX 是"进 site 前最后一级"，必须在 site 旁边布线；家族是"wire→wire"，在开关盒里。两者被帧地址分开，正是逆向时能分别求解的前提。

**Q2 哪些单元根本没有配置位？**
【硬件事实】① `tileconn` 的 `BEG→END` 落点（固定金属连接）；② wire 名字表与 tile 拓扑；③ clock region / column / tile 的位置（由 die 布线决定）；④ package pin 与 PAD 的对应；⑤ `FRAME_ECC` 的值（由数据算出）。
【数据事实】本项目走线恢复正是靠这五类"无位线索"完成 6/6 输入网对账。

**Q3 哪些有配置位但还没解码？按 数量 × 位池密度 × 影响 排序：**
1. **BRAM**（1,030 块，每块帧位池密集，直接影响存储型设计）——【未测】
2. **DSP48E1**（2,800 个，位池最复杂）——【未测】
3. **IO/ILOGIC/OLOGIC**（700×4 site，影响所有外部接口）——【未测】
4. **CARRY4 `CY0` 族 + `CE/SR/CLKINV` mux**（75,900 slice，影响算术与时钟使能）——部分
5. **长线 `LV/LVB` 选择**（跨 region 走线）——部分

**Q4 只给一个 .bit 能恢复到什么程度？**
- **能**：CLB 单元（LUT INIT + FF 类型/INIT + 部分 mux）、INT 层 PIP（181/tile_type）、IMUX 选择、走线链（含 IO 入口）、slice 位置与端口身份。
- **不能**：BRAM/DSP/IO 内部配置、时钟网络（BUFG/MMCM/PLL）、GTX/PCIe/XADC、多数 BEL 内部 mux（CE/SR/CLKINV）。
- **需要额外假设**：pin 映射（需要 tileconn + PAD 表）、未覆盖的 66 位（需要 fuzz 补测）、多网同 tile 的联合归因（需要 CSP）。

---

## ⑧ 常见误解纠正

| # | 错在哪 | 正确是什么 |
|---|---|---|
| 1 | "一个源对应一个开关位" | 一个源对应**编码字**（1–4 位），多源共用同一组位 |
| 2 | "家族就是一个 mux 门" | 家族常是**多级 mux 树**（实测 20 源 = 4×5 两级） |
| 3 | "位数 = ceil(log2 N)" | 位数 = 各级选择数之和（`4+5=9` > `ceil(log2 20)=5`） |
| 4 | "配置位会跨家族共用省面积" | INT tile 内 **0 例**（1,598/1,598 独占）；BRAM/DSP/IO 【未测】 |
| 5 | "位全 0 = 没选任何源" | 全 0 通常是**默认源**的合法编码 |
| 6 | "family 是 Xilinx 官方术语" | UG470/UG472 无此词，是项目工程叫法 |
| 7 | "cell 用 `(frame_off, bit)` 就能定位" | 必须 `(frame_off, parity, bit)`，漏 parity 会合并两个不同物理位 |
| 8 | "`BEG→END` 也是一种 mux" | 是 **tileconn 固定连接**，无配置位 |
| 9 | "跨 tile_type 同名 wire 属同一家族" | 家族命名空间是 `(tile_type, 目标wire)`；形状相同不等于同一家族 |

---

## ⑨ 自测题

**Q1** 某家族 9 位、20 源，每源恰 2 位，列计数为"5 位各被 4 源置 1 + 4 位各被 5 源置 1"。结构？为什么不是 5 位？
**A** 4 组 × 5 成员两级 mux；位宽 = 组数 + 成员数 = 9，每级各置一位，不做二进制压缩。

**Q2** 位池 9 位全 0，非法吗？
**A** 不非法，通常是默认源编码。判定依据是编码表里是否存在全 0 源（本项目每族恰 1 个空源）。

**Q3** 为什么 `parity` 不能省？
**A** prjxray 把行内两字打包进 bit 字段（0..63），`bit ≥ 32` 表示第二字；缺 parity 会把两个物理位当成一个。

**Q4** 家族位与 IMUX 位分别在哪个块？如何证明不冲突？
**A** 家族在 INT tile 的 26 帧（off 0–15），IMUX 在 CLB tile 帧 off 16–25；实测 181 条 PIP 的 cell 与 48 个 IMUX 的 cell 无交集。

**Q5** 只给 .bit，能否确定某个 LUT 的输入来自哪根 IO 引脚？
**A** 能，只要 IO 入口段可解。本项目做法：走线链终点落在 `INT_L_X32Y50..55`，按行号映射到 `i[row-50]`（207 节点映射 0 冲突）。

**Q6** 若 ILA 出现在位流里，它是什么？
**A** 软逻辑：占用 SLICE/BRAM 的普通配置位，没有专属物理单元；按常规 CLB/BRAM 解码即可，不需要单独的 ILA 位表。
