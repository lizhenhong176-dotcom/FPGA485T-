# P0a 全器件解码器 — 首轮实测（2026-10-27）

## 组件

| 文件 | 作用 | 结果 |
|---|---|---|
| `v7re/export/law_db.py` | 规律灌库 → `E:\v7work\model\v7_law.sqlite` | law_cells 24,336 行 / far_bands 896 / law_tiles 62,625 |
| `v7re/export/decode_law.py` | 向量化解码器 | 6.2 万 tile × 344 实例 = 2,150 万次预测，**16 秒** |

## 修掉的关键 bug

`law_tiles` 的坐标曾经误用 `grid_x/grid_y`（布局网格坐标，X6→grid17、Y11→grid352），
导致全部预测打偏。已改为**从 tile 名解析 X/Y**（与 `pip_law.parse_tile` 一致）。

## 判据（修正版）

- 只看 `sense=1` 的格子：**全部为 1** 判定启用；
- `cells1 >= 4` → **EXACT**（强证据）；`cells1 < 4` → **WEAK**（2~3 格小掩码，有随机命中可能）；
- 不再输出 8,500 万行 SUB（旧判据把 sense=0 的随机 0 也算匹配，无意义）。

## 两个设计的实测

| 设计 | EXACT | WEAK | 用时 |
|---|---|---|---|
| `ref_X8Y11_A6LUT_A1.bit` | 1 | 38 | 15.6 s |
| `codex_review_overhead/a.bit`（旧设计，对照组） | 4 | 70 | 16.9 s |

**真路由命中验证**（ref 设计，实际路由 GFAN0→IMUX）：

```
INT_L_X6Y10, IMUX_L1/L2/L4/L7/L8/L11, GFAN0/GFAN1/NW2END_S0_0   ← 设计真实使用的 tile
INT_L_X6Y10/Y11, GFAN0/GND_WIRE                                  ← 时钟馈入
```

对照组 a.bit 的 EXACT 落在 `INT_R_X7Y10 IMUX1/4/11` —— 与该旧设计的布线区域吻合，**说明
EXACT 检出的是真实路由而非全局默认态**。

## 假阳性率

- 2 格掩码（WEAK）的假阳性：每个位流约 30–40 条（2,150 万候选中），**<0.0002%**；
- 4 格掩码（EXACT）：两个设计的 EXACT 集合不重叠且各自落在本设计布线区 → 目前没有观察到
  确定的假阳性。

## 限制（诚实声明）

1. `law_cells` 只有 344 个 (family, src) 实例、平均 2 格掩码 —— **覆盖还很薄**。全器件
   实际 PIP 种类约 3,737 条/列类型；当前表主要来自 prjxray artix7 segbits 的迁移。
2. 长线族（LV/NN6/NW6…）的 block 规则未定（见 `SWEEP_DIAGNOSIS.md`），这批族目前也走
   CLB 列规则 → 它们的 WEAK 输出不可信。
3. 尚未做“空设计全 EMPTY”的终极校准（需要远端再出一个删光 PIP 的位流）。

## 下一步

1. 远端出一份“空路由”位流做 FP 终极校准；
2. 用 tilepipe 系列（900 位流 + 已知每条 PIP）做解码器回归：解码出的 EXACT 集合与
   每个变体删掉的那条 PIP 逐一比对；
3. 补长线族 block 规则后重灌 law_cells。
