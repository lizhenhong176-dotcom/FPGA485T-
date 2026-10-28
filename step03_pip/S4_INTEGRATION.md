# S4 集成回归：decode_law.py 统一 INT + CLB 解码

日期：2026-10-28。提交：见文末。

## 目标

把 S2/S3/S4-FF 的 CLB site 布局收编进主解码器 `v7re/export/decode_law.py`，
与 P0a 的 INT PIP 路径共用一个 CLI / 位矩阵 / 差分接口。

## 数据通路

- `law_db.py` 重建 `E:\v7work\model\v7_law.sqlite`，新增三表：
  - `clb_cells`：site_cells.json 全量 3,884 行（tile_type / family / src_wire /
    frame_off / bit / sense / parity）；
  - `clb_blocks`：763 个 CLB 块（gridCol×band → 基帧）；
  - `clb_tiles`：75,900 个 SLICE（tile_type / grid_col / inst / y）。
- `decode_law.py`：`load_clb()` + `decode_clb_matrix()`，CLB 特征按
  `frame = clb_block[(gridCol, Y//50)] + frame_off`、`word = word_of(Y, parity)`
  读出；INT 路径不变。输出行 pattern=`CLB_SET`，`src` 列写位位置 `foff_bit`。

## 修掉的三个 bug

1. **clb_cells 主键塌缩**：原 `PRIMARY KEY (tile_type, family, src_wire)` 把
   多 bit 编码（AFFMUX 四 bit）折叠成单行（3,884→2,702）。改为
   `(tile_type, family, src_wire, frame_off, bit)` 后恢复全量。
2. **--ref 差分折叠**：CLB_SET 行原不带位位置，同 (slice,feat) 不同 bit 的行
   在差分时互相抵消（o5 的 38 行里 6 条 AFFMUX 假性消失）。修法：行内带
   `foff_bit`。
3. **CLB 解码 133s → 32s**：逐 slice×feature 双循环改按 (tileType, inst) 分组、
   每特征一次 fancy index，输出与逐行版逐字节一致（o5 134 行 identical=True）。

## 回归结果

- **INT 12/12（100%）**：tilepipe 12 变体 EXACT 命中预期 (INT_L_X6Y11, IMUX_Lx,
  SRC)，EXACT=1–2 / 变体，与 P0a 一致；CLB_SET=126–132 为环境位（时钟网、
  列边 tie），与解码无关。
- **CLB FF 差分（3 对）**：
  - ff_o5 − ff_ax → AFFMUX 位 {30_0, 30_3}（6 src 各 2 行）+ 32 INIT：与
    decode_clb.py 逐条一致；
  - ff_o6 − ff_ax → {30_3}；
  - ff_f7c − ff_ax → {30_0}（F7 码 b0+b1 减去 ax 的 b1）。
  - 位值全部落在 31746 = 基帧 31716 + 30，word 40 = word_of(20, 0)，0 假阳性。

## 用法

```
python v7re\export\decode_law.py design.bit --ref ref.bit --out pips.csv
```

差分行 = 真实配置变化；CLB_SET 的 `src` 列是 `frame_off_bit`。

## 诚实限制

- AFFMUX 行列出"置 1 的码位"，源判定需按码表合参（如 {0,3}=O5、{0,1}=F7、
  {1}=AX）；未做自动 mux 解码。
- CLB 表 2,702 对是 artix7 迁移值 + 少量 V7 实测锚点；AFFMUX 的 CY/XOR 仍是
  表值（AX/O5/O6/F7 有实测）。
- 长线族（LV/NN6 等）block 规则未定（P0b）。

## 提交

`<本次提交>`：law_db 主键修复 + decode_law CLB_SET 位描述 + S4_INTEGRATION.md
