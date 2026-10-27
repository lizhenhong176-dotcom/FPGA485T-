# law_cells 覆盖率审计（任务 1 结论：表已完整，无需再灌）

日期：2026-10-27 · 起因：P0 计划任务 1「把 law_cells 从 344 实例扩到 ~3500」。
审计结果：**不需要灌**。之前「344」是 family-instance 计数口径误差；按
`(tile_type, family, src_wire)` 对计数，表已是全量。

## 数字

| 项 | 数值 |
|---|---|
| law_cells 行数 | 24,336 |
| (tile_type, family, src) 对 | **7,272**（INT_L 3,636 + INT_R 3,636） |
| V7 模板 tile_type_INT_L/INT_R.json PIP 对 | 各 3,737 |
| 覆盖（segbits 语义） | 3,629 / 3,737 = **97.1%** |
| 伪 PIP（ppips 语义，无配置位） | 108 / 3,737 = 2.9% |
| 合计 | **3,737 / 3,737 = 100%** |

## 108 个“缺口”全部是伪 PIP（与 artix7 官方口径一致）

- 64 × `default`：`IMUX_L0..47 / BYP_ALT0..7 / FAN_ALT0..7 ← VCC_WIRE`
  ——VCC 常连，无配置位（实测 NR1END0 式默认源掩码为空，与此吻合）。
- 44 × `always`：`BYP_BOUNCE/BYP_L ← BYP_ALT`、`FAN_BOUNCE/FAN_L ← FAN_ALT`
  （缓冲器常开）+ 12 × `GCLK_L_B*_{EAST,WEST} ← GCLK_L_B*`（时钟脊）。

程序验证：108/108 逐条命中 `prjxray_ref/artix7/ppips_int_l.db`（default 64 + always 44）。
即 law_cells 的 3,629 对 = artix7 segbits 的全部 INT 位控 PIP，一条不缺。

## V7 实测吻合度（不依赖 artix7 假设的独立验证）

- `tilepipe.json`（INT_L，36 sink × 24 源）vs law_cells：**864/864 一致，0 分歧**
  （归一化 BASE=31680，parity=word−22）。
- `tp2.json`（INT_R，BASE=31788）同样 **864/864**。
- 差分解码回归（S_40_11 − ref）：7/7 PIP 与 Vivado 路由报告一致；
  12 变体回归 12/12 HIT（本次重建库后复跑仍 100%）。

## 已落地的变更

- `v7re/export/law_db.py`：新增 `law_ppips` 表（tile_type, family, src_wire,
  kind=default|always|hint），从 artix7 ppips 迁移，216 行（两类型各 108）。
  解码器遇到这些对时不再报“表里没有”，可解释为“无配置位”。
- `E:\v7work\model\v7_law.sqlite` 已重建（law_cells/far_bands/law_tiles 不变，
  回归 12/12 验证无破坏）。

## 剩下的真缺口（与 law_cells 无关）

覆盖率 100% ≠ 解码 100%：长线族（LV/NN6/NW6/NE6…）的 **block 映射规则**未定
（见 `SWEEP_DIAGNOSIS.md`：位落在块列 4 / 行 1，word=14+12k）——即 P0b。
