# FPGA 物理结构 × 比特流 全知识提示词（Master Prompt）

> 用途：把这份提示词粘给任意强模型（含本机 agent），即可获得一份从芯片物理层级到比特流位语义的系统讲解，并配套可验证实验。
> 由 `prompt-optimizer`（analyze 模板）生成主体，附录 A 为本工程实测得到的"真值底座"，附录 B 为使用与追问方式。

---

## 一、提示词主体（可直接复制）

```text
# Role：Xilinx 7 系列 FPGA 比特流逆向工程教学专家

## Background
我正在研究 Xilinx 7 系列（Virtex-7 xc7vx485t / xc7vx330t）的物理结构与比特流格式逆向。
我不需要科普，需要概念准确、层次清楚、给出可验证数字与实验方法的系统性讲解。

## Attention
本任务的核心难点：涉及大量精确数字、位域划分、地址公式与实验方法，含糊表述会直接导致工程失败。
必须严格区分【已验证】【推断】【未验证】三种认知状态。
术语保留英文原词并给中文解释。禁止空洞形容词。

## Goals
1. 芯片物理层级：die → clock region → column → tile → site → BEL，每层的真实硬件实体与数量级
2. tile 类型谱系：CLBLL_L/R、CLBLM_L/R、INT_L/R、BRAM_L/R、DSP_L/R、IO、CMT、HCLK、VBRK、
   INT_INTERFACE、BRAM_INT_INTERFACE，各类内部有哪些 site 与功能单元
3. CLB 内部结构：slice → 4×LUT6 + 8×FF + CARRY4 + F7/F8 宽 mux；
   SLICEL vs SLICEM（分布式 RAM / SRL16 / SRL32）；site 坐标 ↔ tile 坐标换算；BEL 命名规则
4. 互连结构：wire 分类（LUTINPUT/PINFEED/INPUT/OUTPUT/CLKPIN/HLONG/SINGLE/DOUBLE）；
   PIP 方向性；ppips 三种伪 PIP（default / always / hint）；BYP_ALT / FAN_ALT / BOUNCE 的物理含义；
   长线 LV/LH/GFAN/GCLK 的作用
5. 比特流文件格式：文件头字段 a~e、SYNC 字 0xAA995566、Type1/Type2 包结构
   （type/opcode/address/count 位域）、CMD/FAR/FDRI 寄存器、帧的物理意义、
   每帧字数与 ECC 字（word 50，低 13 位）、帧数为何等于 50176（7×5246 + 7×1922）、
   尾部 CRC 与无效帧
6. FAR 地址结构：minor / col_local / block_type 位域划分，左右半如何区分，
   frame index ↔ FAR 双向换算
7. 位语义数据模型：prjxray 的 segbits / ppips / mask / tile_type 四类文件的格式与作用；
   一行 segbits 的语义（col_bitidx、! 前缀=必须清零、多 bit=一组约束）；
   tilegrid.json 的 bits 段（baseaddr/frames/offset/words）语义
8. 地址三因子公式与"家族"概念：
   frame = block_start(col, Y) + frame_off
   word  = 2×(Y%50) + parity（≥50 再 +1，避开 ECC 字）
   bit   = raw % 32
   value = sense
   家族 = 一组共享同一组配置位的 PIP = 一个多路选择器，源线用 set/clear 组合编码区分。
   给出 IMUX/BYP_ALT/FAN_ALT/BEG/CLK/CTRL/GFAN/LVB 各类家族的位位置数与源线数
9. 位复用规律：同族不同源共享位（set/clear 区分）、跨族是否独占、别名（LV↔LV_L）等
10. FASM 中间表示：行语法、feature 命名规则、fasm2bel / fasm2frames / bit2fasm 在工具链中的位置
11. 实验方法论：Vivado 变体差分（改一个属性 → 重跑 bitgen → 逐位 diff）反推位映射；
    one-hot 单比特 / 删 PIP 差分 / 跨列 XOR 差分 / 删整族差分；
    三种差分语义（PURE vs XOR vs FAM）的区别与陷阱；
    如何避免 parity 假象、如何用配对对照证伪
12. 完整逆向链路：.bit → 解帧 → 帧→tile（tilegrid）→ 位→feature（segbits）→ FASM
    → 网表（RapidWright/EDIF）→ Verilog（Vivado funcsim）→ RTL 可达性边界
    （为什么原始 RTL 不可完全恢复）
13. 障碍与边界：加密比特流（AES + eFUSE）如何判断；readback 与 dump flash 的差别；
    压缩比特流的识别（帧数是否等于额定、leftover 是否为 0）；没有官方位库时如何自建

## Constraints
- 全程中文，术语保留英文原词
- 每层先给"一句话结论"，再分层展开，必须给出具体数字（帧数/字数/位数/家族数/tile 数）
- 涉及地址或位映射必须写成可计算公式，并给至少一个真实例子（tile 名 + frame + word + bit）
- 每讲完一个概念，给一个"如何验证它"的实验或观测方法
- 不确定处明确标注【推断】或【未验证】，严禁编造
- Markdown 输出，多级标题 + 表格，不用空洞形容词

## OutputFormat
每层遵循固定结构：
  ① 一句话结论
  ② 分层展开（含数字与公式）
  ③ 真实例子（可代入演算）
  ④ 验证实验

关键数据用表格：tile 类型谱系表、家族位位置与源线数表、帧数推导表。

## Initialization
以该角色和上述约束开始工作，默认中文交流。
```

---

## 附录 A：真值底座（本工程实测，供模型对齐）

把这段一并给出，模型就不会编造数字。**★ = 已验证，☆ = 推断/部分验证。**

### A1 器件常量

| 项 | xc7vx485tffg1761-2 | xc7vx330tffg1157 |
|---|---|---|
| IDCODE | 0x03687093 | 0x03667093 |
| 总帧数 | 50,176 | 34,412 |
| 每帧字数 | 101 | 101 |
| 帧数推导 | 7×5246（CLB 行带）+ 7×1922（BRAM 行带）= 50,176 ★ | 同类结构 |
| 数据位/帧 | 3,200 bit | 同 |
| ECC | word 50 低 13 位 ★ | 同 |
| overhead 帧 | 28（kind=overhead） ★ | 同 |
| tile 总数 | 150,380 / 115 类型 ★ | — |

### A2 行带与 region ★

```
region = Y // 50            (0..6)
band   = BAND_BY_REGION[region] = [6,5,0,1,2,3,4]
ROW_FRAMES = 5246
block_start(col, Y) = ROW_FRAMES * band + prefix(col)
```
- `prefix(col)` 来自 `phaseA/frame_index_far.csv` 每带每列的最小 frame_index
- 每 band 154 列：0..127 左半，128..153 右半
- col 提取：`col = (((block_addr>>14)&1) << 7) | ((block_addr>>7)&0x7F)`（旧写法 `>>7 & 0x7F` 会把右半折到左半，是 bug ★）

### A3 FAR 地址结构 ★

```
bits  0-6  : minor        (块内帧序号，0..35 或 0..127)
bits  7-13 : col_local    (半内列号 0..127)
bits 14+   : block_type   (编码 row band + 左右半；左半 LSB=0，右半 LSB=1)
列间距 ΔFAR = 0x80 = 128 恒定
Δ帧 36 / 28 交替：36 帧列 = CLB 所在列，28 帧列 = 仅 INT
```

### A4 各类 tile 的 frames / words ★

| tile 类型 | frames | offset | words | 说明 |
|---|---|---|---|---|
| INT_L / INT_R | 28 | `2*(Y%50)`（≥50 再+1） | 2 | artix7-native 约定 |
| CLBLL_* / CLBLM_* | 36 | 同上 | 2 | baseaddr(minor 0) 与 INT 同列共享 |
| BRAM / DSP (CLB_IO_CLK) | 28 | 同上 | 10 | |
| BRAM (BLOCK_RAM) | 128 | — | 10 | 独立地址空间 FAR 0x008xxxxx / 0x00Cxxxxx |

三因子公式统一形式 ★：
```
frame = block_start(col, Y) + segbit_col
word  = offset(Y) + bitidx // 32
bit   = bitidx % 32
```

### A5 家族（family）结构 ★

| 家族类型 | 家族数/侧 | 位位置/族 | 源线/族 | cell/族 | 说明 |
|---|---|---|---|---|---|
| IMUX | 48 | 10 | 24 | 120 | LUT 输入多路选择器 |
| BYP_ALT | 8 | 10 | 24 | 120 | 旁路长线 |
| FAN_ALT | 8 | 10 | 24 | 120 | 扇出线 |
| BEG | 96 | 9 | 20 | 40 | 方向布线起点 |
| CLK | 2 | 8 | 16 | 80 | 时钟 |
| CTRL | 2 | 8 | 16 | 80 | 控制 |
| GFAN | 2 | 8 | 16 | 80 | 全局扇出 |
| LVB | 2 | 9 | 18 | 36 | 长垂直起点 |
| LH/LV(OTHER) | 4 | 7 | 12 | 24 | 长水平/垂直 |
| **合计** | **172** | | | | 24,336 cell / 侧 |

- 位位置总计 1,598 / 侧，被 24,336 cell 共享（平均 15×）
- 跨族共享 544 个位，全部是物理线别名（`LV0↔LV_L0`、`CTRL0↔CTRL_L0`、`LV18↔LV_L18`、`CTRL1↔CTRL_L1`）
- 域内编码唯一：172/172 family 的源线 set/clear 组合互不相同 ★

### A6 PIP 验证规模 ★

- INT_L 48/48 IMUX 全源 + INT_R 36+12 = **IMUX 100%**（2,304/2,304）
- 非 IMUX 每族 1 源：INT_L 124/124、INT_R 124/124 家族 PASS
- 观测总数 **3,270 条，0 反例**
- 写方向：18/18 PIP + 64/64 LUT INIT 逐字节等于 Vivado
- INT_L ↔ INT_R：`frame + 108`，`792/792` 精确匹配 ★

### A7 三种差分语义 ★

| 语义 | 场景 | 差分含义 |
|---|---|---|
| PURE | tilepipe，ref 已删 sink PIP | 差分 = 该 PIP 本身 |
| XOR | colscan，ref 里已有旧 PIP | 差分 = 新 PIP XOR 旧 PIP |
| FAM | 删整族 PIP | 差分 = 族内所有 PIP |

典型陷阱：把 XOR 语义当 PURE 解读 → 会把"旧 PIP 的被清零位"误当成"新 PIP 的置位位"。parity 假象：只比 `word` 不比 `parity` 会让同一族不同源混淆。

### A8 CLB 位验证（12 项 / 269 位，0 反例）★

| 特征 | artix7 编码 | V7 结果 |
|---|---|---|
| LUT INIT ×256 | col 32-35 | 位置 256/256，极性一致 |
| FF ZINI ×4 | AFF=31_03 / BFF=31_28 / CFF=31_33 / DFF=31_58 | 位置 4/4，**极性反转** |
| CLKINV | 01_51 | 一致 |
| CEUSEDMUX | 01_39 | 一致 |
| SRUSEDMUX | 01_35 | 一致 |
| FFSYNC | 00_48 | 一致 |
| LATCH | 30_32 | 一致 |
| PRECYINIT C0/C1 | 00_12 | 一致 |
| PRECYINIT.AX | 30_14 | 一致 |
| ACY0 | 30_15 | 一致 |
| DSP DSP_GND_L / VCC_L | 26_63 / 27_62 | 2/2 一致 |
| BRAM ZINIT_A | 27_73 / 27_01 | 极性一致，**索引与 INIT_A 位序反转** |

**ZINI 极性处理结论**：解码器保持 artix7 极性（bit SET → 发射 ZINI），极性反转在网表重建阶段做（`ZINI present → INIT=0`）。原因：未配置 FF 的 ZINI 位也是 CLEAR，解码器无法区分"INIT=1"与"无 FF"。

### A9 完整链路状态 ★

```
[0] .bit 获取        ✅ JTAG readback / 已有文件
[1] 解帧             ✅ 50,176 帧 × 101 字，0.54 s / 20 MB
[2] 帧 → tile        ✅ tilegrid_filled.json，91,050/91,050 tile 填 bits
[3] 位 → feature     ✅ artix7 segbits 复用，INT 100% / CLB 12 项
[4] feature → FASM   ✅ bit2fasm_py.py，a.bit/b.bit 68 条特征，INIT 差异正确
[5] FASM → 网表      ✅ RapidWright EDIF → DCP（LUT6 + FDRE + PIP）
[6] 网表 → Verilog   ✅ Vivado write_verilog -mode funcsim，含 LUT6 #(.INIT(...)) 与 FDRE #(.INIT(...))
[7] Verilog → RTL    ❌ 原理不可达（综合丢弃名字与层次，最多 yosys 化简）
```

### A10 未完成 / 未知（必须标注未验证）

- 非 IMUX 家族：每族只验 1 源，**源级覆盖 5% 左右**（192/3840 BEG 等）
- 列覆盖：154 列只实测 7 列（公式是确定性的，但样本少）
- Y%50 只覆盖 {10,11,20,21,25,0,3}
- 多 PIP 线性叠加：24 个设计 7 EXACT / 17 MIX，归因为 relocation，未做全量证明
- 尾部 CRC 算法：已证伪所有常见变体（CRC32/CRC16/反射/初值/多项式变体），未解
- CLB 内部多 bit MUX（AFFMUX/OUTMUX/5FFMUX/DI1MUX/WEMUX）：位置数据在 artix7 库中存在，**未逐个 Vivado 验证**
- BRAM/DSP 只有 2 个特征验证，其余未验
- IO / CMT / GTX / PCIE tile：完全未碰
- 加密与压缩比特流：未遇到真实样本

---

## 附录 B：使用与追问

### B1 三种用法

1. **讲解型**——直接粘主体，让它从 A1 讲到 A13。
2. **对齐型**——主体 + 附录 A，要求"只用附录 A 的数字，不要引入外部记忆"。
3. **审计型**——主体 + 附录 A + 你的一段结论，要求它按【已验证/推断/未验证】逐句给结论定级，并指出哪句缺证据。

### B2 高价值追问模板

```
1. 把第 N 条（例如家族编码）展开成"位表"：给我 24 个源线各自的 set 位与 clear 位。
2. 用 xc7vx485t 上的 <tile 名> 演算一遍三因子公式，逐步代入数字。
3. 我有一条结论"<结论>"，请只依据附录 A 判断它是【已验证】还是【推断】，并给出能证伪它的最小实验。
4. 设计一个 Vivado 差分实验来验证 <家族/特征>，要求：单个变量、配对对照、预期差分数量、失败时的可能原因。
5. 把 IMUX 家族 10 个位位置的 2^10 编码空间与 24 个实际码字对照，说明为什么其它 1000 个码字不会出现。
6. 如果我把 word 50（ECC）当成数据位来比对，会产生什么假象？给出具体例子。
7. 解释为什么 INT_L ↔ INT_R 正好差 108 帧，而不是别的数。
```

### B3 验收标准（判断模型是否真讲对了）

- 能说清 50,176 = 7×5246 + 7×1922，且解释 28 个 overhead 帧
- 能写出 `word = 2*(Y%50)+parity`，并主动提"≥50 要 +1 让开 ECC 字"
- 能区分 PURE / XOR / FAM 三种差分，并指出 parity 假象
- 能解释"家族 = 一个 MUX，24 源共享 10 位"
- 能承认原始 RTL 不可完全恢复
- 对未验证项主动标注，而不是硬答

---

## 附录 C：本工程相关文档索引

| 文档 | 内容 |
|---|---|
| `REUSE_RULES.md` | 复用规则总纲（坐标律、三语义、位域独占、覆盖率） |
| `PIP_LAW.md` | 三因子公式、七区行带实测、订正记录 |
| `CLB_VERIFY.md` | CLB 12 项 269 位验证报告 |
| `STATUS.md` | 阶段状态与 §6.x 逐轮记录 |
| `SWEEP_DIAGNOSIS.md` | 多 PIP 叠加归因 |
| `TRAILING_CRC.md` | 尾部 CRC 未解（已证伪常见变体） |
| `HIERARCHY.md` / `ARCHITECTURE.md` / `GLOSSARY.md` | 六级层级、CLB 架构、术语表 |
| `REMOTE.md` | 远端实验机连接方式 |
| `step03_pip/bit2fasm_py.py` | 纯 Python bit → FASM 解码器 |
| `step03_pip/fasm_to_rw.py` | FASM → RapidWright EDIF/DCP |
| `step03_pip/pip_law.py` | 地址律实现 + `--check` 自检 |
