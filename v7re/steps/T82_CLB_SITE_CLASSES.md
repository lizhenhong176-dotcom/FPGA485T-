# T82 CLB 站内四类（BYP/DMUX/SR/CLK）定性

日期：2026-11-11　器件：xc7vx485tffg1157-3　站点：SLICE_X12Y20（SLICEM.A6LUT + SLICEM.AFF，块基址 31752）

## 1 结论先行

| 类 | 真实性质 | 可配置位 | V7 实测 |
|---|---|---|---|
| BYP（`CLBLM_BYP0 -> CLBLM_L_AX`） | **纯连线**，非开关 | **0** | 无需测：`segbits_clblm_l.db` 703 行中 BYP 相关 **0 行** |
| DMUX（FF 的 D 选择） | `AFFMUX/BFFMUX/CFFMUX/DFFMUX` | **4 位 × 4** | 未测（本轮构造失败，见 §4） |
| SR | `SRUSEDMUX`（是否使用 SR）+ INT 侧 `CTRL_L*` 选源 | **1 位** | 已测到 7 格 CLB 变化，未分离 |
| CLK | `CLKINV/NOCLKINV`（反相）+ INT 侧 `CLK_L*` 选源 | **1 位** | **已定**：全芯片 1 位 |

即：T68「CLB 站内四类未判」的原因是当时用 `LOCK_PINS` 去 toggle，那只会重选 INT 侧 IMUX；四类里只有 DMUX/SR/CLK 有真实位，BYP 根本没有位。

## 2 CLK：posedge vs negedge，全芯片精确 1 位

- 两个设计逐字相同，仅 `always @(posedge clk)` / `@(negedge clk)`；
- 回读 `BEL SLICEM.A6LUT` / `SLICEM.AFF` 一致；
- 差分：`p_pos` 183 格、`p_neg` 184 格，**移除 0 / 新增 1**：

```
(帧 31753, word 41, bit 19)      ← 31753 = 块基址 31752 + 帧偏移 1
```

`negedge` = 该位置 1。这与 prjxray 的 `CLKINV 00_52` / `NOCLKINV !00_52` 一对取反关系一致（位号不同，A7 vs V7）。

## 3 SR：用 vs 不用，CLB 内 7 格

`s_unused`（`if (1'b0)` 被优化掉）→ 183 格；`s_used`（`.R(rst)`）→ 219 格；差分 31 移除 / 67 新增，其中落在 CLB 块（31752..31787）的 7 格：

```
(31753, 41, 2) (31753, 41, 3) (31753, 41, 9)
(31754, 40, 5) (31756, 40, 6) (31761, 40, 6) (31767, 40, 6)
```

前 3 格在帧偏移 1 / word 41，后 4 格是 word 40 bit 6 在帧偏移 2/4/9/15 重复出现（疑似共享的"使用"位，跨帧复用）。**未分离**：换 SR 源会同时动 INT 侧 CTRL 布线，需再用「源恒定为 1'b0 vs 1'b1」的对照。

## 4 DMUX：本轮构造失败，如实记录

三个设计（`v1_dlut` / `v2_dcout` / `v3_both`）全部构建失败：
- `v1` 的 tcl 里有 `set_property LOC ... [get_cells u_c4]`，但该设计没有 CARRY4 → `[Common 17-55] 'set_property' expects at least one object`；
- `v2` 反之（无 `u_lut`）；
- `v3` → `[Vivado 12-2285] Cannot set LOC ... Conflicting nets for physical connection A6LUT_O6`（LUT 的 O6 同时要驱动 FF 与 CARRY4 的 DI）。

修法（未执行）：tcl 用 `get_cells -quiet` 并在 cell 不存在时跳过；或用独立 slice 放 CARRY4，代价是引入跨 slice 变量。

## 5 CLB 可配置特征全表（prjxray A7 结构）

`segbits_clblm_l.db`：SLICEL_X1 58 条、SLICEM_X0 61 条。按类：

| 类 | 特征 | 位数 |
|---|---|---|
| LUT 模式 | `ALUT/BLUT/CLUT/DLUT` | 各 1 |
| FF D 选择 | `AFFMUX/BFFMUX/CFFMUX/DFFMUX` | 各 4 |
| LUT 输出选择 | `AOUTMUX/BOUTMUX/COUTMUX/DOUTMUX` | 各 4 |
| FF 属性 | `AFF/BFF/CFF/DFF`（INIT）、`A5FF/B5FF/C5FF/D5FF`、`A5FFMUX` | 各 1 |
| 使用标志 | `CEUSEDMUX`、`SRUSEDMUX`、`FFSYNC`、`LATCH`、`CARRY4` | 各 1 |
| 时钟 | `CLKINV` / `NOCLKINV` | 1（成对） |
| 进位 | `PRECYINIT` | 3 |
| 分布式 RAM（仅 SLICEM） | `WA7USED`、`WA8USED`、`WEMUX` | 各 1 |

## 6 边界

- 全部 V7 位号只定了 CLKINV 一个（`(块基址+1, 41, 19)`）；其余沿用 A7 结构，位号未测。
- SR 的 7 格未分离到「哪一位是 SRUSEDMUX」。
- BYP 的「0 位」来自 prjxray 结构证据，未做独立实测（也无从实测：没有开关可选）。
