# P0b 长线族位规则（LV/LH 驱动位）——实测定论

日期：2026-10-28 · 提交：见 git log（P0b 系列）

## 问题

全片抽样回归（SWEEP ②，24 设计 × 4 列 × 7 行带，606 PIP / 1150 位观测）中，
Y ≥ 61 的 17 个设计全部判 MIX：258 个 pred1_missing + 262 个 extra 位。
定位（SWEEP_DIAGNOSIS.md）：长线族（LV/LH）的位不在本 tile 的 CLB 列块
16–25 偏移区，而是落在另一组块（块列 4、行 1 等）。

## 方法

`longline_dump.py`：对 24 个 sweep 设计重算 obs（diff(ref, design)），
obs − pred1 − pred0 = extra 位 = 长线真实落点。
262 个 extra 位 **262/262 全部归因成功**（100% 一致，无矛盾样本）。

## 规律（100% 实测，非迁移）

```
frame = block_start(col, Y) + off        # off ∈ {0, 1}
word  = 2*(Y%50) + (Y%50 >= 25)          # 与 CLB site 公式同，parity=0
```

- 即：**长线驱动位与 CLB 族共用同一个块**（该 tile 所在 CLB 列块），
  只是帧偏移在块内 **0/1**（CLB 族在 16–25）。
- LV 驱动（`LV_L0->LV_L18` / `LV0->LV18`）= (off0, bit9) + (off1, bit6)
- LH 驱动（`LV_L0->LH0` / `LV0->LH0`）= (off0, bit2) + (off1, bit6)
- 块带映射 `BAND_BY_REGION = [6,5,0,1,2,3,4]` 与 pip_law 既有结论一致。

## 与 artix7 的关系（方向坑）

prjxray feature 命名 = `DST.SRC`（已用 IMUX/NR1BEG 双向核对）。
artix7 segbits：

| feature（= PIP DST←SRC） | artix7 cells | V7 实测 |
|---|---|---|
| `LV_L18.LV_L0`（LV_L0→LV_L18） | 01_00 01_01 | **00_09 01_06** |
| `LV_L0.LV_L18`（LV_L18→LV_L0） | 00_09 01_06 | 未实测 |
| `LH0.LV_L0`（LV_L0→LH0） | 01_56 01_58 | **00_02 01_06** |
| `LV_L0.LH0`（LH0→LV_L0） | 00_02 01_06 | 未实测 |

V7 把 artix7 赋给"反方向"的 cells 用在了正方向上（或等价地：两方向互换）。
**反方向在 V7 的真实 cells 未经测量**，且其 artix7 迁移值恰与实测正方向
重复——正方向 PIP 置位时必然产生反向假阳性解码行，故已从 law_cells 删除，
待反向布线实验补测后回填。

INT_R 对称：`LV18.LV0` / `LH0.LV0`（正方向，实测）；
`LV0.LV18` / `LV0.LH0`（反方向，已删）。

## 验证

1. **远端 24/24 EXACT**（`out_sweep2.json`，`v_bits.py sweep`，23.1 s）：
   606 PIP / 558 INT PIP，`pred1 == obs` 全等，MIX/EXTRA 归零；
   no_shape 仍为 2（EE2/EE4BEG3 相关，已知覆盖缺口）。
2. **本地解码器**（law_db LL_OVERRIDE + LL_DELETE，重建 v7_law.sqlite）：
   - INT 回归 12/12 HIT 保持 100%；
   - S_8_161：4 条 `LV_L18.LV_L0` EXACT（X6Y34/52/70/88）；
   - S_8_211：8 条 LV + 1 条 `NN6BEG3.LV_L18`（artix7 迁移值在 V7 正确）EXACT，
     0 假阳性（反方向删除后 26→22 行，恰好减去 4 条反向重复）。

## 覆盖率状态

- 实测长线 PIP：LV→LV18 / LV→LH0（INT_L/INT_R 各 2）= 4 条正方向；
- 反方向 4 条：删除待测；
- 其余长线 PIP（LV_L9→LH0 等 artix7 迁移条目）：未实测，沿用迁移值
  （其中 `NN6BEG3.LV_L18` 已被 S_8_211 间接证实）。

## 修改的文件

- `v7re/export/law_db.py`：LL_OVERRIDE（8 行实测）+ LL_DELETE（4 个反方向键）
- `E:\v7work\model\v7_law.sqlite`：law_cells 24,328 行（重建）
- 远端 `/opt/lzh/verify/step03_pip/pip_law.py`：LL_OVERRIDE（同步，
  patch_pip_law.py 注入）
- `step03_pip/out_sweep2.json`：24/24 EXACT 证据
