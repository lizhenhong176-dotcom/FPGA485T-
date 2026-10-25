# 跨 tile 实例一致性（INT_L 同类型）

## 设计

| | tile1 | tile3 |
|---|---|---|
| 走线 tile | `INT_L_X6Y11` | `INT_L_X6Y21` |
| lut_b 位置 | `SLICE_X8Y11/A6LUT` | `SLICE_X8Y21/A6LUT` |
| 覆盖 mux | 36 个（6 BEL × 6 脚） | 6 个（A6LUT × A1–A6 → L7/L2/L1/L11/L8/L4） |
| 观测 | 900 | 150 |

对照组设计完全相同（同一份 `top_y20.v`、同样的 25 源、同样的差分方法），
只是 lut_b 的落点换了一行（Y11 → Y21），从而换了一个 `INT_L` 实例。

## 结果

对 6 个共有 mux、每个 25 条源，按「最小帧 / 最小 word / 最小 bit」归一化后逐条对比：

```
same = 150, diff = 0
```

**150/150 完全一致。**

## 结论

**mux 输入编码是 tile 类型级的静态属性**：

- 同一条 wire、同一个 mux 编号，在 `INT_L` 的不同实例上给出**完全相同的相对 cell 掩码**；
- 因此不需要对每个 `INT_L` tile 单独 fuzz——**fuzz 一块 tile 得到的映射表可推广到全部 `INT_L` tile**；
- 绝对帧号仍随行/列变化（由 `word = 22+((L//4)%2)`、帧窗口的列/行偏移负责），
  但「哪几个 cell」是类型常量。

## 意义

这条结论把"每个 tile 都要扫"的成本降下来了：V7 有 150,380 个 tile，但只有 115 种类型；
按类型 fuzz 即可，`INT_L` 一类已经完成（36 个 mux × 25 源）。

## 数据

- `tilepipe.json`（INT_L_X6Y11，900 观测）
- `tp3.json`（INT_L_X6Y21，150 观测）
- 对比脚本 `cross_tile.py`

## 待办

- `INT_R` 类型（tilepipe2，900 观测，进行中）作为跨类型对照；
- 第 7 层：把「(tile_type, mux, wire) → cell 集合」写进 `v7_model.sqlite` 并生成批量 PIP→bit 表。
