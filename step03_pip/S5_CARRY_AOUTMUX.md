# S5 CARRY4 / PRECYINIT / AOUTMUX 实测报告

日期: 2026-10-28 ｜ 远端: /opt/lzh/step03/s5 ｜ 本地: step03_pip/
站点: SLICE_X10Y20 (CLBLM_R, SLICEM_X0), 列基帧 base=31716, word=2*(20%50)=40, 奇偶 word=41。

## 结论

### 1. PRECYINIT — 4/4 全部验证（含 sense）
| CYINIT 来源 | 帧偏移:word:bit = 值 |
|---|---|
| C0 (1'b0)  | (0,40,12)=0 (30,40,13)=0 (30,40,14)=0 |
| C1 (1'b1)  | (0,40,12)=1 (30,40,13)=0 (30,40,14)=0 |
| AX (端口)  | (0,40,12)=0 (30,40,13)=0 (30,40,14)=1 |
| CIN (级联) | (0,40,12)=0 (30,40,13)=1 (30,40,14)=0 |

pre_c1−pre_c0 差分恰为 [31716,40,12] 单位。pre_cin 级联实验同时置位下片 Y19 的 (31716,38,12/14) —— 级联路径确认。

### 2. AOUTMUX @ (base+30, word 40) — 6/6 解码完成
| 源 | 置位 bit |
|---|---|
| O6 | ∅（默认全零；artix7 预测 bit11=1 在 V7 不成立,已修正 DB） |
| O5 | {6,11} |
| XOR | {8} |
| CY | {6,8} |
| F7 | {6,7} |
| A5Q | ∅ —— **[2026-10-28 更正: 本行原写 {12} 是错的]** |

隔离修复: 原设计 a_xor/a_cy 同时导出 O0+CO0 → 比特流完全相同。b_xor/b_cy 每个只导出一个输出后 XOR/CY 码型与预测完全吻合。
A5Q 验证（ZINI 对照）: b_a5q (FDRE INIT=0) 与 c_zini (INIT=1) 唯一差分为 (31747,40,3) —— 该位才是 FF ZINI 类状态位（反相 sense: INIT=0 时置位）。(30,40,12) 在两个 INIT 下均稳定置位 → **[更正] 当时误判为 AOUTMUX.A5Q。S6 实测 d_ffse(FDSE,Q悬空)=清 0、d_ffx(FDRE,Q悬空)=置位、LD=置位 → (30,40,12) = AFF.ZRST（复位族 FF/锁存器类型位,与 artix7 raw `SLICEM_X0.AFF.ZRST 30_12` 完全一致）。真正的 A5Q 编码 = ∅（见 S6_FF_OUTMUX.md 的 e_both 实验: 同一 slice 内 LUT O6→o1 与 FDRE Q→o2 可同时布线, AOUTMUX 无任何变化, FF.Q 走专用/默认路径, 无需 CLB 位）。**
AFFMUX 低位顺带确认: D=LUT O6 → (30,40,3); D=端口 AX → (30,40,1)。

### 3. LUT INIT 帧位布局确认
INIT=5555 的 A6LUT 位出现在 (base+34/base+35, word 40, bits 8-15) = 帧 31750/31751 —— 与 M3 锚点 (SLICE_X10Y10, 31750/31751, word 20/50) 的 off34/35 + word=2*(Y%50) 规律一致。早前 dump 只取 off0/1/30/31 导致 a_o6 显示全空 —— 是量测盲区,不是无效基线。

### 4. CARRY4 CY0 族 — 未触发
ACY0(30,40,15) / BCY0(1,40,15) / CCY0(30,41,16) / DCY0(30,41,17) 在全部 S5 设计（S 取自 LUT O6 / 直通端口, DI 取自 LUT O5 / 直通）中均未置位。artix7 语义假设不适用于这些探针; 需要不同实验（如 LUT6 双输出 O5+O6 同时使用、或 CYINIT 与 S 的组合）才能触发。未验证,保持原预测不动。

## 落库
- v7_law.sqlite.clb_cells: SLICEM_X0.AOUTMUX O6 bit11 1→0; A5Q bit7 1→0, 新增 (30,12,1,0)。**[2026-10-28 更正: (30,12) 行已删除 —— 该位是 AFF.ZRST; A5Q 行恢复 artix7 形状但 V7 实测 bit7=0（A5Q 无编码位）; 详见 S6_FF_OUTMUX.md]**
- 新表 v7_verified: 28 行实测记录（含 note 与日期）。
