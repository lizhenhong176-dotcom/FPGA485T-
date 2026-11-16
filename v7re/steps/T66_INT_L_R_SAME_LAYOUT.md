# INT_L 与 INT_R 是否同一套布局

日期：2026-11-10　数据：`v7_law.sqlite` 的 `law_cells`（sense=1）+ `verify_all_pip.py` 实测

## 结论：是同一套布局，只有线名不同

| 检查 | 结果 |
|---|---|
| family 数 | INT_L 172 / INT_R 172 |
| feature 数 | 各 3,634 |
| 格宇宙大小 | 各 **1,598** 格，且两个集合**完全相等** |
| 每源格数分布 | 两侧都是 `{2: 2818, 4: 816}` |
| family 名去 `_L/_R` 后配对 | **172 / 172 全部配上** |
| 配对后**格集合相同** | **172 / 172** |
| 配对后源集合相同（源名也去后缀） | 168 / 172 |
| 同名 `(family, source)` 的格集合相同 | **3,586 / 3,586，0 不同** |

即：**同一条 PIP 在 INT_L 和 INT_R 落的是同一批格，位坐标一个不差。**

## 唯一的 4 个差异：时钟树的 EAST/WEST

差的是 `CLK0`、`CLK1`、`GFAN0`、`GFAN1` 四个 family 的源集合：

```
INT_L: GCLK_B0, GCLK_B1, GCLK_B10_WEST
INT_R: GCLK_B0_EAST, GCLK_B10, GCLK_B11
```

这是时钟主干线在左半/右半器件的物理走向不同（`WEST`/`EAST` 后缀），
不是布局差异 —— 同一名源（去掉方向后缀后）的格集合仍相同。

## 命名差异（这是唯一需要处理的东西）

- family：`IMUX_L34` ↔ `IMUX34`、`BEG0_L` ↔ `BEG0_R` 等，右侧常去掉 `_L`；
- source：`LOGIC_OUTS_L4` ↔ `LOGIC_OUTS4`；
- 统一做法：解码前对两侧同时做「去掉 `_L` / `_R`」归一化。

## 位流侧实测（不是查表恒等）

`verify_all_pip.py --tile-type INT_R --normalize`：
`mux 336 命中 / 0 不符`、`beg 408 命中 / 0 不符`。

这比「格集合相同」更强：它是拿 INT_L 的定律去预测 **INT_R 位流里的实际置位**，零反例。

`fasm2bit.py --decode` 在 `_full8.bit` 上一次解出 190 条 PIP，横跨 76 个 INT tile，
其中 6 个是 INT_R，与 Vivado 真实路由对账 190 命中 / 0 误判。

## 边界

- 未覆盖的 INT_R family 是因为**线名对不上**（`LOGIC_OUTS0` 等 INT_R 独占命名），不是结构不同；
  归一化后 172/172 全配。
- 单独验证过 INT_R 的只有 336 + 408 条 feature（归一化能对上的部分），
  剩余部分依赖「格集合相同 + 线名归一」的推断，未逐条位流对账。

## 复现

```python
# 断言两侧 172 family 的格集合逐族相同
python - <<'PY'
import sqlite3, collections
con = sqlite3.connect(r"file:E:\v7work\model\v7_law.sqlite?mode=ro", uri=True)
def load(tt):
    d = {}
    for fam, src, fo, par, bit in con.execute(
        "select family,src_wire,frame_off,parity,bit from law_cells where tile_type=? and sense=1", (tt,)):
        d.setdefault(fam, {}).setdefault(src, set()).add((fo, par, bit))
    return d
L, R = load("INT_L"), load("INT_R")
nf = lambda n: n.replace("_L", "").replace("_R", "")
Lb = {nf(k): k for k in L}; Rb = {nf(k): k for k in R}
assert set(Lb) == set(Rb)
for b in Lb:
    assert set().union(*L[Lb[b]].values()) == set().union(*R[Rb[b]].values()), b
print("INT_L / INT_R 布局相同：172/172")
PY
```
