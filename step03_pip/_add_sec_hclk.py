# -*- coding: utf-8 -*-
"""追加 STATUS 一节（自动取 max+1）：HCLK_CMT 跨类型验证（阶段 A）。"""
import io, re, os

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(P, encoding="utf-8").read()
nums = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\.", txt, re.M)]
n = max(nums) + 1

body = f"""
## {n}. HCLK_CMT 跨类型验证（阶段 A）：时钟列没有自己的 FAR col（2026-11-09）

**目标**：判定 D 类最大一族（`HCLK_CMT`，42 mux / 982 PIP / 23.4 源每族）的 PIP 选择位能否像 INT 一样闭式公式化，并回答「编码律能否跨 tile 类型迁移」。

**文档**：`step03_pip/HCLK_CMT_LAW.md`（位池 / 结构 / 逐源表 / 六维对照 / 缺口）。

### 结论三条

1. **时钟 tile 没有自己的帧列。** `HCLK_CMT`/`CMT_TOP` 各 14 个实例（`grid_x` 88、305 各 7），但 `far_bands` 的 154 个 FAR 列里没有对应列；它们的配置位落在**相邻逻辑列块的尾部帧** `minor 26..29`（逻辑资源用 `0..25`）。证据：hclk5 观测帧 22144/22145/22147 FAR 解码 = `block0 top0 row4 col33 minor26/27/29`；hclk4 = `top1 row1 col33 minor26..29`。`grid_x` 88/305 不在任何 FAR col 的取值集合里。
2. **位池可表达**：cell 仍是 `(frame_off, word, bit)`，`frame_off ∈ {{26,27,28,29}}`，与 INT 的 `0..25` 不冲突。
3. **「源 → 槽位」不可公式化（本轮）**：`MUX_CLK_13` 48 源实测 13 个（MMCM 7 + PLL 6）。每个源 = 1 组槽位格 + 2–4 码字格；MMCM 组槽位在 `off29` word 27..30、PLL 组在 `off28` word 76..79，均为 8 个一热槽位（高半 `bit 25`、低半 `bit 9`）；码字在 `off26/27` word 51，MMCM 占 bits 25..31、PLL 占 bits 4..6。**槽位到源名的对应无规律**（`MMCM8→(w27,高)`、`MMCM9→(w30,低)` 相邻编号跳到两端），只能查表。

### 与 INT 的差异（六维）

| 维度 | INT | HCLK_CMT |
|---|---|---|
| 源数/族 | 24（6 行 × 4 码） | 48 |
| 位池帧区间 | `frame_off 16..25` | `frame_off 26..29` |
| 槽位结构 | 行号 = 帧偏移（6 行 × 4 码） | 组槽位 8 一热 + 码字分区 |
| 合法码字 | 只有 `{{1,2,7,11}}` | 未见非法码概念 |
| 名字→槽位 | **100%**（1,024/1,024） | **否**（13/48 已测且无规律） |
| 与实例关系 | 全 26,550 实例相同 | 两个实例（X88Y338 / X88Y26）逐字节复现 |

### 器件核对

远端 hclk4/5/6 的 rpt/log 里 part 全是 **`xc7vx485tffg1157-3`**，本仓库是 `ffg1761`；但 14 个 `HCLK_CMT` 实例的 `grid_x/grid_y` 与远端逐条对应、差分落点解码后全落在合法段内 → 同 die、同 CRAM 布局（**间接证据**，待同一 dcp 在 ffg1761 重新 bitgen 做直接实证）。

### 过程记录（可能误导，故记录）

- 远端 python3.8 **无 numpy**，差分改为纯 python 大整数 XOR（自找 SYNC `aa995566` + Type2 count=5,067,776）。
- 差分里必然出现一批 `word == 50` 的格（hclk5 每源 4–22 格）：那是 **ECC 字随数据重算的副作用**，必须排除；排除后每源只剩 4–6 个数据格。
- `hclk6` 的 `c_b` 对 `c_a` 有 416 格、`p_i` 对 `c_a` 有 1,254+ 格且横跨 200+ 帧 → **`p_i` 对 `c_a` 不是受控差分**（两个设计本身不同），必须 `p_i` vs `p0`。

### 待办

- 剩 35 源（`CK_BUFHCLK*` 12、`CK_IN*` 10、`CCIO*` 4、MMCM 未测 7、PLL 未测 2）远端补测；判据：能否排成「6 组 × 8 槽」且组由源名前缀决定。
- 换一个 dst（如 `MUX_CLK_5`）测 1 个源，验证 14 个 dst 是否共用一套布局。
- ffg1761 直接实证（同 dcp 重新 bitgen）。

数据：`out/hclk_diff_raw.json`、`out/hclk_regions.json`、`out/hclk_mux13_cells.json`；脚本：`hclk_cells.py`、`_q_hclk_mux13.py`、`_q_hclk_a1c.py`、`_q_hclk_a1h.py`、`_remote_hclk_{{diff,regions,pips}}.sh`。
"""

txt = txt.rstrip("\n") + "\n" + body
io.open(P, "w", encoding="utf-8").write(txt)

# 校验
t2 = io.open(P, encoding="utf-8").read()
nums2 = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\.", t2, re.M)]
print("节数", len(nums2), "max", max(nums2), "重号", len(nums2) - len(set(nums2)))
print("行数", t2.count("\n") + 1, "替换符", t2.count("\ufffd"))
print("新节", n)
