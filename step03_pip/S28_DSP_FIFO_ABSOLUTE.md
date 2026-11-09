# S28 —— 批量项②：DSP 78 个三态家族全量验证 + FIFO18E1 属性位实测

日期：2026-11-09
目标（用户 m20174 "可以" 批准的 ②）：把 ROUTING_SELECTION.md 的四态表里"只验了 5/78"的 DSP 与"结构已定、位未逐位"的 BRAM/FIFO 补齐。

## 1. 方法：绝对态判读（不是逐族差分）

逐族差分要 78×2 个设计；绝对态判读只需**两个设计**：

| 设计 | 内容 |
|---|---|
| `dsp_all0` | 单个 DSP48E1 @ `DSP48_X0Y0`，**所有可选端口 tie 到 0**（D=0, INMODE=0, OPMODE=0, ALUMODE=0, CARRYINSEL=0, CE*=0, RSTD=0）|
| `dsp_all1` | 同上，**所有端口 tie 到 1**（D=25'h1FFFFFF, INMODE=5'h1F, OPMODE=7'h7F, ALUMODE=4'hF, CARRYINSEL=3'b100, CE*=1, RSTD=1）|
| `dsp2_all0/1` | 双 DSP（`DSP48_X0Y0` + `DSP48_X0Y1`），覆盖 `DSP_1_*` 家族 |

判读位置 = artix7 `segbits_dsp_l.db` 预测位（帧 = 31960 + frame_off，word 已含 `bit//32`）。
判据：`dsp_all0` 必须 **GND 小区全 1 / VCC 小区全 0**；`dsp_all1` 必须**完全相反**。

## 2. 结果：78/78 家族全部通过

| 设计 | GND 小区为 1 | VCC 小区为 1 | 结论 |
|---|---|---|---|
| `dsp_all0`（单 site） | **39/78**（= DSP_0 全部） | 0/78 | 全 0 tie → 每族选 GND |
| `dsp_all1`（单 site） | 0/78 | **39/78** | 全 1 tie → 每族选 VCC |
| `dsp2_all0`（双 site） | **78/78** | 0/78 | 两个 site 同规律 |
| `dsp2_all1`（双 site） | 0/78 | **78/78** | 同上 |

- 156 个 cell **零例外**（每族 GND/VCC 各 1 胞，互补）。
- 单 site 设计里 `DSP_1_*` 的 39 族全 0 → 说明这些位确实属于**第二个 DSP site**，不是"同 site 的备用源"，与 S21 的 `get_pips` 结论（同 tile 两个 DSP）一致。
- 由此 DSP 三态律（`{BYP(两胞全0), GND, VCC}`，offset 26/27，K=2，每源 1 胞）从 5/78 提升到 **78/78 实测**。

## 3. FIFO18E1：属性位实测（BRAM 块）

设计（`RAMB18_X3Y28` → tile `BRAM_R_X29Y70`，wof=40，控制帧 27249）：

| 设计 | EN_SYN | FWFT | ALMOST_EMPTY | ALMOST_FULL |
|---|---|---|---|---|
| `fifo_a` | FALSE | FALSE | 13'h0005 | 13'h0004 |
| `fifo_b` | **TRUE** | FALSE | 13'h0005 | 13'h0004 |
| `fifo_e` | FALSE | FALSE | 13'h0006 | 13'h0004 |
| `fifo_c` | FALSE | **TRUE** | 13'h0006 | 13'h0004 |
| `fifo_d` | FALSE | FALSE | 13'h1FFA | 13'h1FF9 |
| `fifo_f` | FALSE | FALSE | 13'h1FF8 | 13'h1FF8 |

实测（帧 27249）：

| 属性 | 位置 | 结论 | 证据 |
|---|---|---|---|
| `EN_SYN` | (word 45, bit 11) | **1 = TRUE** | a=0, b=1（其余属性全同）|
| `FIRST_WORD_FALL_THROUGH` | (word 45, bit 10) | **1 = TRUE** | e=0, c=1（其余全同）|
| `ZALMOST_EMPTY_OFFSET[0..12]` | words 49（bits 0,3,4,5,8,11,12,13,16,19,20,21,24） | **13/13 通过：存储值 = NOT(offset)（13 位取反）** | 5→0x1FFA；6→0x1FF9；0x1FFA→0x0005；0x1FF8→0x0007 |
| `ZALMOST_FULL_OFFSET[0..12]` | words 40/41 | **13/13 通过：存储 = NOT(FULL)（同步）/ NOT(FULL+1)（异步）** | 见下表 |

### 3.1 ZFULL 的模式偏置（第二轮 4 设计定死）

| 设计 | EN_SYN | ALMOST_FULL | 实测读值 | NOT(FULL) | NOT(FULL+1) |
|---|---|---|---|---|---|
| `fifo_a` | FALSE | 0x0004 | 0x1FFA | 0x1FFB | 0x1FFA ✓ |
| `fifo_e`/`fifo_c` | FALSE | 0x0004 | 0x1FFA | — | ✓ |
| `fifo_f` | FALSE | 0x1FF8 | 0x0006 | 0x0007 | 0x0006 ✓ |
| `fifo_d` | FALSE | 0x1FF9 | 0x0005 | 0x0006 | 0x0005 ✓ |
| `fz2` | FALSE | 0x0006 | 0x1FF8 | 0x1FF9 | 0x1FF8 ✓ |
| `fz3` | FALSE | 0x0007 | 0x1FF7 | 0x1FF8 | 0x1FF7 ✓ |
| `fz4` | FALSE | 0x0FFC | 0x1002 | 0x1003 | 0x1002 ✓ |
| `fifo_b` | TRUE | 0x0004 | 0x1FFB | ✓ | 0x1FFA |
| `fz1` | TRUE | 0x1FF9 | 0x0006 | ✓ | 0x0005 |

⇒ **律：`ZALMOST_FULL` 存储 = 8191 − FULL（`EN_SYN=TRUE`）/ 8190 − FULL（`EN_SYN=FALSE`）**。
物理解释：异步模式下写/读指针多一级同步，阈值以 2 个存储字为步长计数，故编码整体左移 1。`ZALMOST_EMPTY` 无此偏置（两种模式下都是 8191 − EMPTY）。

## 4. 构建坑（复现必读）

- `FIFO18E1` 在 2017.2 的 `unisim_comp.v` 里**没有** `IS_36_18` / `DATA_WIDTH` 参数（`Synth 8-3438`）；只写 4 个参数即可。
- DRC 边界：`ALMOST_EMPTY_OFFSET` ∈ [5,8186]（**但 EN_SYN=TRUE 时下界变 6**），`ALMOST_FULL_OFFSET` ∈ [4,8185]；`FIRST_WORD_FALL_THROUGH=TRUE` 且 `EN_SYN=TRUE` → `DRC AVAL-7` 拒绝。
- DSP：`CARRYINSEL=111` 需要 `PREG=1`（`DRC DPREG-5`），否则 bitgen 拒绝；本系列统一 `PREG(1)` 规避。
- 远端命令经 cmd.exe，**不能带管道**（`| head` 直接报"head 不是内部或外部命令"）；一律 tee 脚本 + `bash /path`。
- `.bit` 解析必须大端；自检 `FDRI burst = 5,067,776`。

## 5. 覆盖度更新

| 编码形态 | 家族数/侧 | 已实测 |
|---|---|---|
| A. INT 分级 one-hot | 172 | 172/172（写回 864/864）|
| B. site 边界 IMUX | 24/slice 实例 | 全部（inst0/inst1 迁移 2/2 + 6/6）|
| C. BRAM 三路 cascade | 60 | 60/60（S27）|
| D. DSP 两路 tie-off | 78 | **78/78（S28）** |
| 值编码 | BRAM 属性 | 2/30 正码 + FIFO 4 项（取反码）|

产物：`/opt/lzh/step07/br6/`（设计 `.v` + `build5/6.tcl` + `run5..9.sh` + `check6.py` + `cells.json`）；本地 `E:\v7work\br6\`。
