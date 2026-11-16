# S18 —— “线长 → 列码”迁移到 BRAM/DSP/HCLK 的通用性检验（2026-11-08）

数据源：`E:\v7work\db\prjxray\xc7vx485t\tileconn.json`（17,928 条定长连接）
方法：对每条 `tileconn` 条目（`tile_types` + `grid_deltas` + `wire_pairs`），把它实例化到所有真实 tile 位置，
把 **grid 坐标差** 与 **tile 名坐标差**（名字里的 `X<n>Y<m>`）都算出来，按 `(src_type → dst_type, wire 类)` 统计。

## 1. INT ↔ INT（基线，标准 fabric 行）

| wire | 主导 grid delta → 名 delta | 样本 | 备注 |
|---|---|---|---|
| `EE2` | (4,0) → **(2,0)** | 160 | 名 delta = 长度 ✓ |
| `EE4` | (9,0) → **(4,0)** | 320 | ✓ |
| `WW2` | (-5,0) → **(-2,0)** | 160 | ✓ |
| `WW4` | (-10,0) → **(-4,0)** | 160 | ✓ |
| `NN2` | (0,-1) → **(0,1)** | 342 | ✓（grid y 与名字 Y 反向） |
| `NW6` | (0,-1)/(0,-2)… → (0,1)/(0,2)… | — | 见 §3 |

结论 1：**在标准 fabric 行里，名 delta 的绝对值 = 线长数字**（2/4），grid delta 不是——grid 里每列跨
4/9/14/18 个 grid 单位（含 NULL/VBRK/BTERM 列），完全不规则。**“线长”是名字坐标量，不是 grid 量。**

## 2. INT → BRAM / DSP / HCLK（要检验的部分）

| 目标 | wire | 主导 grid → 名 delta | 名 delta 变体数 | 判断 |
|---|---|---|---|---|
| `BRAM_INT_INTERFACE_L` | `EE4` | (4,0) → **(4,0)** | 1 | 长度规则成立 |
| `BRAM_INT_INTERFACE_R` | `EE4` | (2,0) → **(2,0)** | 1 | 成立 |
| `BRAM_INT_INTERFACE_L` | `WW4` | (-2,0) → **(-2,0)** | 1 | **不成立**（4 → 2） |
| `BRAM_INT_INTERFACE_R` | `WW4` | (-4,0) → **(-4,0)** | 1 | 成立 |
| `BRAM_L` | `EE4` | (4,-3) → (4,-3) 等 5 种 | 5 | **Δy ≠ 0** |
| `BRAM_R` | `WW4` | (-4,-4) 等 5 种 | 5 | **Δy ≠ 0** |
| `DSP_L` | `EE4` | (3,-3) 等 5 种 | 5 | **Δx=3 ≠ 4，Δy≠0** |
| `DSP_R` | `EE2` | (1,-3) 等 5 种 | 5 | **Δx=1 ≠ 2** |
| `HCLK_L` | `NN6` | (227,10) 等 13 种 | 13 | **完全不可用** |
| `HCLK_R` | `SS6` | (13,8) 等 10 种 | 10 | **完全不可用** |
| `VBRK` | `WW4` | (225,8) 等 5 种 | 5 | 不可用 |
| `PCIE_INT_INTERFACE_L` | `EE4` | (4,0) → (4,0) | 1 | 成立 |

## 3. 结论：**不通用，但失效方式是可解释的**

1. **标准 fabric 列（INT↔INT、INT↔interface）**：名 delta = ±长度，可直接用名字算。
2. **BRAM / DSP 列**：名 delta 的 X 分量等于“长度 −1 或 −2”（块列比 INT 列更靠近/更远一格），
   且 **Δy ≠ 0（-1…-4）**——BRAM/DSP tile 的 Y 行与 INT 的 Y 行不是同一套行网格。
   所以 `EE4 → +4 列` 的直觉在这里错 1–2 列、错 1–4 行。
3. **HCLK / VBRK / BTERM**：名 delta 动辄 (227,10) 这种量级——这些 tile 在名字坐标里根本不在同一个
   二维网格上（HCLK 在 grid x≈227 的时钟脊），**任何基于 tile 名的算术都失效**。
4. 每个 (类型对, wire) 的“主导 delta”只占 20–40%，**其余 4–12 种变体来自特殊行**（PCIE 行、
   feedthrough 行、终端行、以及东西半区原点偏移）。

## 4. 对解码器/走线器的直接影响

- **必须用 grid 坐标锚定**（`tilegrid.json` → `grid_x/grid_y`），不能拿 tile 名做加减；
  我们现有的 `name2pos` + `tileconn` 落地过滤之所以能跑通 6/6、181 PIP，正是因为一直走的 grid 路径。
- 但 **grid delta 本身也不等于线长**（EE2 = 4 grid 单位，EE4 = 9），它只表示“两个 tile 之间隔了多少列”
  ——因此 walk 时**不要用长度做猜测**，只能靠 `land_b/land_f` 查表落地（现有实现正确）。
- BRAM/DSP 的 Δy 偏移必须在表里显式存：`BRAM_R_X5Y0` 与同一行的 `INT_R_X5Y0` 名字 Y 相同，但
  tileconn 给的落地行会偏 1–4 行。

## 5. 一句话回答

“线长→列码”只在**标准 fabric 行内的 INT↔INT/接口**成立；迁移到 BRAM/DSP 后 X 偏移 −1~−2、Y 偏移 ±1~4；
迁移到 HCLK/VBRK 后完全失效（不在同一命名网格）。**方法本身（差分 + tileconn + grid 锚定）可复用，
但“线长即列码”这条捷径不可复用。**
