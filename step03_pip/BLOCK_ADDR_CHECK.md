# 块地址函数验证（第一步）

## 结论 1：块基址与列的关系成立

从 `frame_index_far.csv`（1,183 个 block）直接解 FAR 得到：

| tile | block addr | base frame |
|---|---|---|
| `INT_L_X6Y11`（col 6） | `0x420300` | **31680** |
| `INT_L_X8Y11`（col 8） | `0x420400` | **31752** |
| `INT_L_X10Y11`（col 10） | `0x420500` | **31824** |

规律：`base_frame(col) = 31680 + 36 × (col − 6)`，即 FAR 每加 `0x80`（col+1）帧号 +36。

## 结论 2：形状在块内的偏移是 +16 起

三次实测窗口（各自减去所在块基址）：

| 设计 | sink tile | 观测窗口 | base | 偏移 |
|---|---|---|---|---|
| SLICE_X8Y11/A6LUT/A5 | INT_L_X6Y11 | 31696–31705 | 31680 | +16…+25 |
| SLICE_X12Y11/A6LUT/A5 | INT_L_X8Y11 | 31768–31777 | 31752 | +16…+25 |
| SLICE_X16Y11/A6LUT/A5 | INT_L_X10Y11 | 31840–31849 | 31824 | +16…+25 |

**块内偏移一致**，列只平移块基址。这验证了「绝对帧号 = 块基址 + 形状偏移」。

## 结论 3（**已证伪**）：形状并不依赖 slice 类型

当初观察到：同一条 wire `GFAN0` 进入 `IMUX_L8`，col 6 只翻 2 个 cell，col 8/10 翻 4 个：

| 列 | 所在 slice | 归一化 cell（相对窗口起点） |
|---|---|---|
| col 6（INT_L_X6Y11） | CLBLL_L（`CLBLL_LL_A5`） | (5,0), (9,0) — 2 个 |
| col 8（INT_L_X8Y11） | CLBLM_L（`CLBLM_M_A5`） | (3,1), (5,0), (6,0), (8,0) — 4 个 |
| col 10（INT_L_X10Y11） | CLBLM_L（`CLBLM_M_A5`） | 同 col 8 |

**真因不是 CLB 类型，而是「差分的两种语义」**（见 `REUSE_RULES.md` §2）：

* `tilepipe.json` 的参考流由 `p6_make2.py` 写出的 `ref_$TAG.dcp` 生成，**sink PIP 已被删掉**
  → 差分 = 这一条 PIP 的位集（纯 PIP 差分）。
* `col_*.json` / `rep_*.json` / `t1*.json` 的参考流由**原始 dcp** 生成，路由器选好的 sink PIP
  仍在里面 → 差分 = `code(S0) △ code(w)`（**XOR**），S0 是基线源。

col 6 那次恰好 S0 与目标只差 2 格，col 8/10 差 4 格，于是被误读成「形状随 CLB 类型变」。

**证据**（`col_xor_model.py`，10 个列扫描文件全部命中且唯一）：

| 文件 | 真实列 | tile | mux | 还原出的基线源 S0 | 逐 wire 判定 |
|---|---|---|---|---|---|
| `rep_C6R.json` | 6 | INT_L_X6Y11 | IMUX_L8 | NR1END0 | 25/25 EXACT |
| `rep_C8R.json` | 8 | INT_L_X8Y11 | IMUX_L8 | NR1END0 | 25/25 EXACT |
| `t12.json` | 8 | INT_L_X8Y11 | IMUX_L8 | NR1END0 | 25/25 EXACT |
| `t16.json` | 10 | INT_L_X10Y11 | IMUX_L8 | NR1END0 | 25/25 EXACT |
| `col_11.json` | 12 | INT_L_X12Y11 | IMUX_L8 | NR1END0 | 25/25 EXACT |
| `t10.json` | 7 | INT_R_X7Y11 | IMUX8 | NE2END0 | 25/25 EXACT |
| `col_9.json` | 9 | INT_R_X9Y11 | IMUX8 | NE2END0 | 25/25 EXACT |
| `col_12.json` | 13 | INT_R_X13Y11 | IMUX8 | NE2END0 | 25/25 EXACT |
| `col_13.json` | 15 | INT_R_X15Y11 | IMUX8 | NE2END0 | 25/25 EXACT |
| `col_B1.json` | 6（Y61） | INT_L_X6Y61 | IMUX_L8 | NL1END0 | 25/25 EXACT |

XOR 还原出的 `code(w)` 与形状表里 sense=1 的格集合逐 wire 完全相同（25/25），
**跨 col 6/8/10/12（含 CLBLL_L 与 CLBLM_L）完全一致** → 形状与 CLB 类型无关。

> 顺带订正一个坑：这些实验脚本用 `SX=$((2*COL-4))` 由 SLICE_X 反推列，**是错的**——
> SLICE 编号会跳过非 CLB 列。真实映射（`sites.tile` 查得）：
> `SLICE_X8→CLBLL_L_X6(SLICEL)`、`X10→CLBLM_R_X7`、`X12→CLBLM_L_X8`、`X14→CLBLM_R_X9`、
> `X16→CLBLL_L_X10(SLICEL)`、`X18→CLBLM_L_X12`、`X20→CLBLM_R_X13`、`X22→CLBLM_R_X15`、
> `X24→CLBLM_L_X16`。所以 `col_11.json` 实际是第 12 列、`col_12.json` 是 13 列、
> `col_13.json` 是 15 列；`pip_law.py --check` 因为「搜索最佳列」而侥幸通过，并打印出真列号。

## 下一步（已更新）

1. ~~受控实验判定 CLB 类型分表~~ → **不需要**，已证伪。
2. 形状表按 `(tile_type, family, src_wire)` 组织即可（`all_cells.json`，每侧 172 family / 3,636 feature）。
3. 剩下真正未解的是**长线家族的块归属**（`SWEEP_DIAGNOSIS.md`）：`*BEG/*END/LV*` 的位不落在
   本 tile 的 CLB 列块里，需要「单段长线」对照实验才能拆开。

