# 图表数据包（figs/）

> 由 `python make_fig_data.py` 从两个 SQLite 库与既有 json **自动生成**，不手工编辑。
> 全部数字的权威口径见 [SINGLE_SOURCE_OF_TRUTH.md](../SINGLE_SOURCE_OF_TRUTH.md)。
> 重生成：`python make_fig_data.py`（dry-run 加 `--check`，走临时目录不碰 `figs/`）

| 文件 | 行数 | 用途 | 数据源 |
|---|---|---|---|
| `fig1_frame_blocks.csv` | 1,183 | 全器件区块表（含 FAR block_type/top/row/col + band + clb_col） | `v7_law.sqlite:frame_blocks_full` |
| `fig2_fanin_families.csv` | 636 | 各 tile_type 每个 family 的 fan-in 与 cell 数 | `v7re/steps/tile_pip_lawscan.json` |
| `fig2_fanin_hist.csv` | 26 | fan-in 直方图（画「INT 的 24 源是特例」那张） | 同上 |
| `fig3_coverage.csv` | 7 | 覆盖率七行（五档指标 + 两行交叉校验） | `repro.py` 实测输出 |
| `fig4_family_shape.csv` | 178 | 族形状：mux 64 + BEG 101 + 长线 6 + 复合 7 | `beg_families.json` + 实测 |
| `fig5_clb_bits.csv` | 2,893 | CLB 位级规格（每个 cell 的语义与置信度）+ `provenance` 溯源列 | `v7_law.sqlite:clb_cells` + `v7re/steps/clb_manual_bits.json` |
| `fig6_cells_per_feature.csv` | 6 | 复用度量：每族占多少格 | `v7_law.sqlite:law_cells` |

## 字段说明

### fig1_frame_blocks.csv
`block_type, top_bottom, row_addr, far_col, far_band, clb_col, start_frame, end_frame, n_frames, class`

- `block_type=0` 是 `FAR_BLOCK_0`（1,078 块 / 36,708 帧），`=1` 是 `FAR_BLOCK_1`（105 块 / 13,440 帧）。
- `class` 由块内帧数决定：**36=CLB（777 块 / 111 列）、28=INT（245 / 35 列）、30=CLOCK（28 块 / 4 列：33/62/75/120）、32=BOUNDARY（14 / 2 列：0/153）、42=UNDETERMINED（14 / 2 列：32/121）、128=BT1（105 / 15 列）**。
- `far_band` 与 `clb_col` 只对能对上的块填写（`far_band` 1,078 块全有；`clb_col` 763/777）。
- `far_band → (top_bottom, row_addr)`：**0..4 → (0,0..4)，5 → (1,0)，6 → (1,1)**（由本表首次确定）。

> ⚠️ 这里的 `far_col`（FAR 列字段 0..153）**不是** Vivado 的 `grid_x`（0..411），也不是 `clb_col`（111 个）。

### fig2_fanin_hist.csv
`tile_type, sources, n_families` —— 26 行（非 45：只保留实际出现过的 (type, fan-in) 组合）。
直接能看出：INT_L/INT_R 的最大 fan-in 是 **24**，而 BRAM 有 **111**、DSP **280**、CLBLM **358**、CLBLL **338** 的超大 fan-in 族。

### fig3_coverage.csv
`metric, covered, total, pct, note` —— 7 行：五档指标（族 / feature / 可生成 / 实例 / 器件）+ 两行交叉校验用记录（`(feature,cell)` 记录 8,900、不同 cell 1,598），**后者不是覆盖率，不能并入条形图**。
**97.74% 与 100% 是不同口径，不是矛盾**（差集 82 = 6 个长线族）。

### fig4_family_shape.csv
`tile_type, kind, sources, axis_A, axis_B, edges, complete_product`
- `kind=mux`：**64** 行，`6×4=24` 满填；
- `kind=BEG`：**101** 行，**101/101 `complete_product=True`**（边集 = A×B 全笛卡尔积）；
- `kind=longline:*`：**6** 行（`LH0`/`LH12`/`LV_L0`/`LV_L18`/`LVB_L0`/`LVB_L12`），其中 3 个是完全乘积网格；
- `kind=composite:*`：**7** 行（`CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1`、`LV_L0`），只有 `kind/note`，`axis_*` 留空。
- 64 + 101 + 7 = **172**，与前文「每侧 172 family」一致。

> ⚠️ `beg_families.json` 里共 108 个 BEG 条目，其中 **7 个不是二分形状**（它们是上面的 composite），画形状图时必须单列，否则取 `v["A"]` 会 `KeyError: 'A'`。
> ⚠️ 101 个 `complete_product=True` 与真源表 §2.9 的「32/32」**不是同一统计对象**：后者是「32 个抽样族逐一做过位流重建验证」，前者是「101 个族的边集结构完全二分」。

### fig5_clb_bits.csv
`tile_type, frame_off, parity, bit, family, src_wire, meaning, confidence, provenance`

`confidence` 五档：`confirmed`（14 行，受控差分实测）、`confirmed(INIT)`（512 行，INIT 公式 256 格 × 2 型）、`strong-candidate`（1 行，CEUSEDMUX）、`candidate`（3 行，CE 目标）、`unknown`（2,363 行）。

`provenance`：`db:clb_cells`（2,875）或 `manual:T82-T87`（18，来自 `v7re/steps/clb_manual_bits.json`）。

> ⚠️ **本表没有 `word` 列，不是遗漏**：`word = 2*(y%50) + (1 if y%50>=25 else 0) + parity`，随站点 y 变化，**不是 tile_type 级常量**。要画「frame_off × word × bit」必须先指定具体实例（例如 `SLICE_X12Y20`），此时 `word` 可算。
> ⚠️ `frame_off` 是**块内偏移**；真实帧号 = `clb_blocks.base_frame + frame_off`（`SLICE_X12Y20` 的 base 是 **31752**）。INIT 表例外——它存的是**绝对帧号**。

### fig6_cells_per_feature.csv
`cells_per_family, n_families`
分布：20→1、24→3、36→2、**40→96（BEG）**、48→6、**72→64（mux）**。

> ✅ 交叉校验：`Σ(格数 × 族数) = 20×1 + 24×3 + 36×2 + 40×96 + 48×6 + 72×64 = 20+72+72+3,840+288+4,608 = **8,900**`，与 `fig3_coverage.csv` 的 `(feature,cell)` 记录数**逐位相等**。

## 画图注意事项

1. **不要混坐标系**：`far_col` / `grid_x` / `clb_col` 三套，基数 154 / 412 / 111。
2. **`word 50` 是 ECC**，任何位分布统计都应排除（fig5 已排除）。
3. **帧号 vs 块偏移**：结论一律回到全局 `frame_index`（0..50,175）。
4. `fig5` 的 2,893 行按 `tile_type` 分两型 CLB；画位图时分组，别混。
5. **fig1 已覆盖全器件**；`BT1` 类 13,440 帧恒为 0，画图时区分显示。
