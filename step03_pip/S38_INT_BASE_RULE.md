# S38 INT tile 基址全量派生规则

## 规则

INT tile 与其相邻 CLB 列**共用同一个 36 帧配置块**：

```
INT_L_Xn  (tilegrid grid_x = gx)  ->  frame_blocks 中 kind='clb' 且 grid_col = gx-1 的块
INT_R_Xn  (tilegrid grid_x = gx)  ->  frame_blocks 中 kind='clb' 且 grid_col = gx+1 的块
（该 gc 不存在时，取 |gc - 目标| 最近的 clb 块）
```

`block = (base_frame, frame_count=36, band = nameY//50)`；单元格地址仍按

```
frame = base + frame_off
word  = 2*(Y%50) + (1 if Y%50>=25 else 0) + parity
bit   = raw_bit % 32
```

## 验证（7 个独立锚点，全部命中）

| INT tile | grid_x | 预测 base | 真值 base | 真值来源 |
|---|---|---|---|---|
| INT_L_X6Y11 | 17 | 31680 | 31680 | S24 走线 6/6 token 一致 |
| INT_R_X7Y12 | 18 | 31716 | 31716 | S24 走线 6/6 token 一致 |
| INT_L_X28Y51 | 72 | 27186 | 27186 | S13 全芯片解码 |
| INT_R_X31Y51 | 78 | 27286 | 27286 | S13 全芯片解码 |
| INT_L_X10Y11 | 26 | 31824 | 31824 | S13 全芯片解码 |
| INT_L_X12Y19 | 31 | 31888 | 31888 | S13 全芯片解码 |
| INT_R_X25Y40 | 62 | 32332 | 32332 | S13 全芯片解码 |

## 结果

- **53,100 个 INT tile 全部派生（0 miss）**，写入 `tile_blocks`，`source='derived_gc'`。
- 与旧 144 条 `measured`：重叠 142 条，**仅 73 条一致** → 旧实测表约一半是歧义解码（空片 ±28 不可分辨，见 S33/S31 T4c）。
- 结构自洽：同一 Y 上 `INT_L_Xn` 与 `INT_R_Xn+1` 的基址差分布
  `36:12100 / 64:10150 / 0:3250 / 108:700 / 66:250 / 72:100`。
  解释：36 = 两侧各占相邻 clb 块；64 = 中间隔一个 gap28；0 = 两侧共用一块（gap 列）；108/72/66 = io72/pcie 插入。

## 遗留

1. 每 band「INT 列数 − 块数」不闭合（band0/3/4/6 各 154−150、band1 148−144；band2 144−144、band5 150−150），少量列共享块的情形未逐一定性；派生规则按 `grid_col` 就近取值，不依赖列计数，故不受影响。
2. 66 个 offsets 0..3 的未覆盖 cell 仍未命中（与本规则无关）。
3. 84 个落块清单外的非零帧仍未定性（0.66%）。
