# 提示词：讲清「家族」、mux 在 FPGA 架构中的位置，以及全部 FPGA 物理单元

## 1. 你的角色与任务

你是同时做过**FPGA 体系结构（RTL/后端）**和**位流逆向 fuzz**的工程师：既知道 7 系列芯片里每一个物理单元长什么样、在哪、受什么控制；也知道这些单元在配置位流里留下什么痕迹。

一位工程师正在做 **Xilinx Virtex-7 (xc7vx485tffg1761-2) 位流逆向 → 网表** 的项目。请你完成三件事，必须**互相咬合**，不要分开写：

1. **讲清「家族（family）」**：它是什么、为什么这样划分、它对逆向意味着什么；
2. **讲清 mux 在 FPGA 架构中的位置**：从全局布线到 BEL 引脚，一共几级 mux、每级由什么控制、位流里能看到哪几级；
3. **穷举 Virtex-7 的全部 FPGA 物理单元**：按层级给出完整清单，标注每个单元「是否由配置位控制」「配置位落在哪里」「能否从位流恢复」「能否被逆向器识别」。

**硬性要求**：第 3 部分不能只列「CLB、BRAM、DSP、IO」四个词就完事。必须给出可执行的清单（判断标准：读者照你的清单能在 485T 的 tile 表里逐个找到对应 tile_type）。

## 2. 背景事实（项目实测，可直接采信）

- 器件 `xc7vx485tffg1761-2`：**150,380 个 tile**、**141,634 个 site**、**1,760 个 package pin**、**14 个 clock region**。
- 可编程逻辑：**SLICEL 43,200 + SLICEM 32,700 = 75,900 个 slice**；每个 CLB tile 含 2 个 slice（`CLBLL`/`CLBLM` 右侧列多为 SLICEM+SLICEL 组合）。
- 位流规模：**50,176 个 block frame × 101 字 × 32 bit**；每个 config row 末尾 2 帧是 OVERHEAD，**不属于任何用户块**。
- 定位公式（已实测）：配置单元 = `(块基址 + frame_off, word, bit)`，其中 `word = 2*(Y%50) + parity`，`bit = raw % 32`。
- 一个 **INT tile 的配置位池 = 1,664 位**（26 帧 × 2 字 × 32 位）；其中 **1,598 位**被 **3,636 条 PIP feature** 覆盖，66 位未覆盖。
- 位池按「家族」划分：**1,598/1,598 个 cell 只属于一个家族**，0 例跨家族共享。
- 家族内多个源共用同一组 cell：**3..18 个源共享一个 cell，平均 5.57，最大 18**；每条 PIP 编码占 **1–4 个 cell**。
- 家族形状只有 5 类：`(位池, 源数) = (9,20)×96 / (10,24)×64 / (8,16)×6 / (7,12)×4 / (9,18)×2`（单侧计数）。
- 已确认**两级 one-hot** 编码：`(9,20)` = 4 组 × 5 成员，位宽 = 4+5 = 9（而非 `ceil(log2 20)=5`）。
- 全芯片解码：**181 条 PIP / 181 个家族 / 0 ambiguous**；写位回环 864/864 一致。
- 已有位级结论：LUT INIT 的 FASM 索引是**普通二进制 A6(MSB)…A1(LSB)**，不做位反序；FF 的 `ZRST`/`ZINI`/`AFFMUX`/`BOUTMUX(F8)` 已定位并跨 tile_type 验证。

## 3. 命名规范（解释一切的地基，务必先讲这个）

- **PIP feature 名**（prjxray segbits 风格）：`INT_L.NL1BEG1.NN6END2 07_32 12_33`
  → 格式 `<tile_type>.<目标 wire>.<源 wire> <frame_off>_<bit> ...`，`!` 前缀表示该位须为 0。
- **本项目记法**：`TILE/TILE_TYPE.SRC->>FAM`（源 → 目标），与上面是同一件事的两种写法。
- **家族** = 同一 `<tile_type>` 下、`<目标 wire>` 相同的那一组互斥 PIP。
- **wire 名的语义**（必须解释）：`<方向><长度>BEG<n>` / `<方向><长度>END<n>`，
  方向 ∈ `N/S/E/W`（单方向）与 `NE/NW/SE/SW`（对角），长度 ∈ `1/2/4/6`；
  `LV`/`LVB` = 长竖线，`GFAN` = 全局扇出，`ER/R` = 短线，`LOGIC_OUTS` = CLB 输出进布线，`IMUX/BYP/CTRL/CLK` = CLB 输入侧 mux 输出。
- **tile_type 名的语义**：`INT_L/INT_R`（布线开关盒）、`CLBLL_L/CLBLM_R`（逻辑）、`BRAM_L/BRAM_R`、`BRAM_INT_INTERFACE_*`、`DSP_R/DSP_L`、`IOB/IOI/IO_INT_INTERFACE_*`、`HCLK_*`、`CMT_*`、`GTX*` 等。

## 4. 必须讲清的三层结构与「家族」的正确定位

给出这张表并解释每一格的关系（这是第 1、2 部分的核心）：

| 层 | 物理实体 | 位流里是否可见 | 家族在哪一层 |
|---|---|---|---|
| 芯片 | die | — | — |
| 时钟区域 | clock region（485T 有 14 个） | 有：帧号分区 | — |
| 列 | column（CLB/BRAM/DSP/IO/时钟列） | 有：帧基址规律 | — |
| tile | `INT_L_X6Y11` 等 150,380 个 | 有：块基址 | **家族定义在 tile_type 层，实例化在 tile 层** |
| site | `SLICE_X8Y11`、`IOB_X0Y50`… | 有：site 内的位 | 无（site 内是 IMUX 等另一套 mux） |
| BEL | `SLICEL.A6LUT`、`SLICEL.AFF` | 有：BEL 专属位 | 无 |
| cell | LUT/FF/BRAM/DSP 实例 | 有：由 BEL + 属性位确定 | 无 |

并且必须说清 **家族属于「连线」层，不属于「逻辑」层**：它刻画的是「信号从哪条 wire 来」，不是「逻辑做什么」。

## 5. mux 的分级（第 2 部分的主体）

必须从**源端到 sink 端**逐级列清，每级写：名称 / 物理位置 / 控制位在哪 / 每级输入输出数 / 是否已被本项目解码：

1. **长线/全局线选择**：`LV/LVB`、`GFAN`、`HROW` 上的 mux；
2. **INT tile 内的布线 mux（= 家族）**：每个 `<目标 wire>` 一棵 mux 树，实测两级（如 4×5=20 源），控制位在 INT tile 自己的 26 帧里；
3. **跨 tile 的 wire 续接**：`BEG -> END` 落点由 tileconn 决定（**不是 mux，是固定连接**，必须强调这个区别）；
4. **site 入口 mux**：`IMUX_L0..L11` / `IMUX_R0..R11`、`BYP`、`CTRL`、`CLK`，控制位**在 CLB tile 的帧里**（实测 offset 16–25），且与 INT 帧分离；
5. **BEL 内部 mux**：`AFFMUX`、`AOUTMUX`、`BOUTMUX(F7/F8)`、`PRECYINIT`、`DI1MUX`、`WEMUX`、`CEUSEDMUX`、`SRUSEDMUX`、`CLKINV`；
6. **硬块内部 mux**：BRAM 的 `WEMUX/EN**/RSTREG`、DSP 的 `AREG/BREG/OPMODE`、IO 的 `ILOGIC/OLOGIC` mux。

并回答一个关键判断题：**为什么「第 2 级（家族）」在逆向里最贵**？（答：数量最大、位池最密、且必须靠差分 fuzz 才能测出编码，不像第 4/5 级可以靠静态结构推断。）

## 6. 第 3 部分：Virtex-7 物理单元完整清单（逐类给出，不得省略）

按下列分组输出表格，列 = `单元 / 所在 tile_type / 是否可配置 / 配置位位置 / 能否从位流恢复 / 逆向难度`：

**A. 配置与全局**
配置帧/OVERHEAD/CRC-ECC、`ICAP`、`FRAME_ECC`、`STARTUP`、`BSCAN`、`DNA_PORT`、`USR_ACCESS`、`SYSMON/XADC`、`EFUSE`、`ICAP` 读回路径、`MFWR`、`FAR` 寻址。

**B. 时钟**
clock region、`HROW`、`CMT`（`MMCM`/`PLL`）、`BUFG`/`BUFGCE`/`BUFH`/`BUFR`/`BUFMR`/`BUFIO`、`GCLK`/`GCLK_B`、`GFAN`、`CC` 引脚、区域时钟网、GT 参考时钟。

**C. 可编程逻辑**
`SLICE`（`SLICEL`/`SLICEM`）、`LUT6/LUT5/LUT6_2`、`MUXF7/MUXF8`、`CARRY4`、`FDRE/FDSE/FDCE/FDSRE`、latch（`LD`）、分布式 RAM（`RAM32X1S/D`、`RAM64X1S/D`、`RAM128X1S/D`、`RAM256X1S`、`RAM64M`）、`SRL16E/SRLC32E`、`AFFMUX/AOUTMUX/BOUTMUX`、`WEMUX`。

**D. 互连**
`INT` tile、wire 类型全集、`PIP`、家族/mux 树、`tileconn` 落点、`BRK`/`VBRK`、`NULL`、长线、`GFAN` 扇出、空 tile。

**E. IO**
`IOB`、`IOI`、`IO_INT_INTERFACE`、`ILOGIC`/`OLOGIC`、`ISERDES/OSERDES`、`IDELAY/ODELAY`、`IN_FIFO/OUT_FIFO`、`IBUF/OBUF/IOBUF/IBUFDS`、bank、`VREF`、`DCI`、`PAD`、`RIU/ORP`。

**F. 存储**
`BRAM`（`RAMB18/RAMB36`、`FIFO18/FIFO36`）、`BRAM_INT_INTERFACE`、级联链。

**G. DSP**
`DSP48E1`、`DSP_INT_INTERFACE`、pre-adder、级联。

**H. 高速与硬核**
`GTP/GTX` quad（`*_CHANNEL`/`*_COMMON`）、参考时钟、`PCIE_2_1`、`XADC` 硬核。

**I. 调试/测试**
`BSCAN`、JTAG、ILA/VIO（软逻辑，**不在位流物理单元里**，必须点明）。

并单独给一张 **485T 计数表**：要求凡是给出数字的地方标注来源（本项目 site 表 / RW 导出 / 厂商手册），**没有数据的地方写「未测」，禁止凭记忆填数**。

## 7. 必须回答的四个「咬合」问题

1. **家族与 IMUX 的区别**：都是 mux，为什么一个是 INT 层的 1,598 位池、另一个是 CLB 层的独立位池？两者会不会抢同一批位？
2. **哪些物理单元「根本没有配置位」**，逆向器必须靠别的线索识别（例如 tileconn 落点、site 位置、PAD 表）？
3. **哪些单元是「有配置位但本项目还没解码」**，按投入产出比排序（用「数量 × 位池密度 × 对网表完整性的影响」估）。
4. **如果只给你一个 .bit**，你能恢复到什么程度？给出「能 / 不能 / 需要额外假设」三分类的具体清单。

## 8. 输出格式（严格按此九段）

1. 一句话定义「家族」（≤40 字，必须同时出现「目标 wire」「互斥」「编码」）；
2. 命名规范解码（tile_type / wire 名 / site / BEL 四张速查表）；
3. 层级表（芯片→region→column→tile→site→BEL→cell），并标出家族在哪一层；
4. mux 六级清单（含「控制位在哪」列）；
5. 物理单元完整清单（A–I 九组表格）；
6. 485T 计数表（标来源，未知写未测）；
7. 四个咬合问题的回答；
8. **常见误解纠正 ≥ 6 条**（每条写「错在哪 / 正确是什么」）；
9. **6 道自测题 + 答案**（至少 2 道要跨越「单元 ↔ 位」两个层面）。

## 9. 纪律约束

- **三色标注**：`【硬件事实】`（体系结构/手册级）、`【数据事实】`（本项目实测可复现）、`【推断】`（由数据反推的机理解释）。三者不得混写。
- **不许用「一般来说/通常/大致」代替数字**。凡涉及数量，要么给可核对数值，要么明确写「未测」。
- **不许把「家族」说成 Xilinx 官方术语**——UG470/UG472 里没有这个词；若你认为它等价于某个标准术语（select group / mux tree / feature group），必须明说对应关系与差异。
- **不许把 wire 续接（`BEG→END` 的 tileconn 落点）说成 mux**：那是固定连接，混淆这一点会让读者以为逆向能靠静态结构推出全部走线。
- 凡涉及「本项目已解码/未解码」的判断，以第 2 节给出的数字为准，不要臆造进度。
- 如果某个单元的配置位位置你不知道，就写「我不知道，可行验证办法是 X」，**不要编造偏移**。

## 10. 可参考的本地材料（如需具体数据）

- `E:\DEEPSEEK\FPGA比特流逆向\step03_pip\all_cells.json`：24,336 条 cell 记录（tile_type/family/src_wire/frame_off/parity/bit/sense）。
- `E:\DEEPSEEK\FPGA比特流逆向\step03_pip\fig_family_bitpool.png`：家族 × 位池实测图（4 组×5 成员结构、20×9 矩阵、五类形状签名）。
- `E:\v7work\db\site_table_xc7vx485tffg1761_2.json`：141,634 个 site。
- `E:\v7work\db\prjxray\xc7vx485t\tilegrid.json` / `tileconn.json` / `tile_type_*.json`：150,380 tile 的拓扑与 wire/PIP 清单。
- `E:\DEEPSEEK\FPGA比特流逆向\step03_pip\REUSE_RULES.md`：位池复用规则的最终版。
- `E:\DEEPSEEK\FPGA比特流逆向\STATUS.md`：已完成/未完成事项总表（第一手进度）。
