# band / row / tile —— 三个概念的区分与换算

> 配套提示词：`step03_pip/PROMPT_BAND_ROW_TILE_V2.md`（V1 见同名 `_V1.md`，V2 末尾附改动清单）。
> 本文所有数字都可按 §8 的命令复算；标注沿用项目纪律：【硬件事实】/【数据事实】/【推断】。
> 坐标序约定：对外一律 `(frame_off, parity, bit)`；`(col, Y)` 是 tile 的名字坐标。

## 0 一句话

- **tile** 是配置阵列里的一个可配置块**实例**，由 `(tile_type, col, Y)` 唯一命名（`tile_name`）。
- **band** 是**帧地址上连续的 5,246 帧**，对应配置阵列的一条「50 个 tile 行」厚的带；它的编号是**帧地址分段序号**，不是 Y 的序号。
- **row** 有三个互不相同的含义：① tile 的 `Y` 坐标（0..349）；② band 内行号 `Y%50`（0..49，一行占 2 个 word）；③ 帧内部的 config row 结构（一帧 101 word）。

---

## 1 术语表

| 术语 | 含义 | 取值范围 | 归属层级 | 证据 |
|---|---|---|---|---|
| 帧 frame | 位流里一次突发写入的 101 word × 32 bit = 3,232 bit | 0..50,175 | 器件级地址 | `STATUS.md` 帧结构节 |
| word | 帧内第几个 32 bit 字 | 0..100（50 是 ECC） | 帧内 | `bitwriter.py:41-43` |
| bit | 字内第几位 | 0..31 | word 内 | 同上 |
| band | 帧地址上连续的 5,246 帧 | 0..6（7 条） | 器件 → band | `far_bands` 实测，§3 |
| region | `Y // 50`，器件纵向第几条 50 行带 | 0..6 | 器件 → region | `bitwriter.py:56` |
| `band_by_region` | region 号 → band 号的置换表 | `[6,5,0,1,2,3,4]` | 器件级常量 | `v7re\prompts\PIP_REUSE_LAW_PROMPT.md:23` |
| tile 的 Y | 器件纵向第几个 tile 行 | 0..349 | tile 坐标 | `law_tiles.y` |
| tile 的 col | tile 名里的 X，器件横向第几个 tile 列 | `law_tiles` 0..157；全 tilegrid 0..411 | tile 坐标 | §8 命令 |
| band 内行号 row | `Y % 50`，一行对应 2 个 word（parity 0/1） | 0..49 | band 内 | `bitwriter.py:42` |
| config row | 一帧内部的 101 word 结构（50 行 × 2 parity + 1 ECC） | 101 word | 帧内 | §6 辨析 3 |
| `frame_off` | 一个 tile 占用的帧在 band 内的偏移 | INT tile 0..25 | tile → 帧 | `T3_PIP_REUSE_LAW.md` |
| `start_frame` | `(band, col)` 的帧基址 | 见 `far_bands` | band × col | `far_bands` 表 |
| tile_name | `类型_X{col}Y{Y}`，如 `INT_L_X8Y20` | — | tile 实例 | `law_tiles.tile_name` |

---

## 2 坐标系怎么分层

**【数据事实】** 器件共 **50,176 帧 × 101 word × 32 bit**；其中 INT 类 tile 使用的帧空间是 **7 × 5,246 = 36,722 帧**，差额 **13,454 帧**属于非 INT 列（CLB/BRAM/DSP 等）。

```
器件 50,176 帧
└── band 0..6（每条 5,246 帧，帧地址连续）
    └── (band, col) → start_frame       ← far_bands 表，896 行 = 7 band × 128 列块
        └── frame = start_frame + frame_off   （INT tile: frame_off 0..25）
            └── word = 2*(Y%50) + parity（≥50 则 +1，跳过 word 50）
                └── bit 0..31
                    └── 语义 (family, src_wire)  ← law_cells 表
```

tile 一侧的分层：

```
器件 150,380 个 tile / 115 种 tile_type
└── 列 col（INT_L 占偶数列 0..152，共 77 列；INT_R 占奇数列）
    └── 行 Y（0..349，7 条 band × 50 行）
        └── (col, Y) 位置上可能并存多个 tile（见 §3 表末行）
            └── tile_name（类型 + col + Y）← 唯一标识
                └── 位域 (frame_off, parity, bit)
                    └── 语义 (family, src_wire)
```

---

## 3 「tile 靠什么被唯一区分」

| 层级 | 判据 | 取值范围 | 是否唯一 |
|---|---|---|---|
| 器件 | part 名 | `xc7vx485tffg1761` | 是 |
| band | 帧地址分段（`far_bands.band`） | 0..6 | 是 |
| tile 行 | tile 名里的 `Y` | 0..349 | 是（在器件内） |
| tile 列 | tile 名里的 `X` | `law_tiles` 0..157 | 是 |
| tile 类型 | `tile_type` | 115 种，INT_L/INT_R 各 26,550 个 | 是 |
| tile 实例 | `tile_name = 类型_X{col}Y{Y}` | 150,380 个 | **是（最终标识）** |
| 位域坐标 | `(tile, frame_off, parity, bit)` | 每 tile 1,664 位池（INT） | 是 |
| 语义 | `(family, src_wire)` | 每侧 172 family / 3,634 feature | 多对一（见 T30/T35） |

**【数据事实】** 同一 `(col, Y)` 上可以并存多个 tile：`col=20` 的 700 个 tile 全部是 `INT_L_X20Yn` 与 `INT_INTERFACE_L_X20Yn` 成对（350 行 × 2 类型）。所以 **`(col, Y)` 只能定位到「该位置的所有候选 tile」，唯一定位必须靠 `tile_name`**。

---

## 4 换算公式

```
region      = Y // 50                     # 0..6，物理纵向分段
band        = band_by_region[region]      # [6,5,0,1,2,3,4]
base        = far_bands[(band, col)].start_frame
frame       = base + frame_off            # INT tile: frame_off ∈ 0..25
row_in_band = Y % 50                      # 0..49
word        = 2 * row_in_band + parity    # ≥50 时 +1（跳过 word 50 的 ECC 字）
bit         = 位在 word 内的下标           # 0..31
```

反向（从帧号回推 band）：`band = frame // 5246`，`frame_off = frame % 5246 - (base - band*5246)`。

---

## 5 两个完整演算

### 演算 A：band 内部（`INT_L_X8Y20`）

| 步骤 | 计算 | 结果 |
|---|---|---|
| region | `20 // 50` | 0 |
| band | `band_by_region[0]` | **6** |
| base | `far_bands[(6, 8)].start_frame` | **31752** |
| frame_off = 16 | `31752 + 16` | **31768** |
| row_in_band | `20 % 50` | 20 |
| word（parity 0 / 1） | `2*20 + 0` / `2*20 + 1` | **40 / 41** |

校验：`IMUX_L40` 的 10 个 cell 全在 `parity=0 / frame_off 16..25 / bit 6 或 7`，与上表逐项吻合。

### 演算 B：跨 band 内边界（`INT_R_X37Y199`）

| 步骤 | 计算 | 结果 |
|---|---|---|
| region | `199 // 50` | 3 |
| band | `band_by_region[3]` | **1** |
| base | `far_bands[(1, 37)].start_frame` | **6510** |
| row_in_band | `199 % 50` | **49**（band 内最后一行） |
| `2*49 + 0 = 98` ≥ 50 → +1 | parity 0 用 **99**，parity 1 用 **100** | 99 / 100 |
| PIP `SS6END0→SS2BEG0` 的两个 cell `(11,0,10)`、`(13,0,10)` | `6510 + 11`、`6510 + 13` | frame **6521 / 6523**，word 99，bit 10 |

校验：`tamper\ref\ref.bit` 这两位均为 1，`tamper\ref\pips_all.txt` 含 `INT_R_X37Y199/INT_R.SS6END0->>SS2BEG0`。

**注意**：这里的「跨边界」是**band 内第 49 行**（`Y%50=49`，word 98→99 的跳变由 `≥50 则 +1` 造成），**不是**跨 band。跨 band 的行必然换帧（base 相差 5,246 帧），见 §6 辨析 2。

---

## 6 常见混淆辨析

1. **band 等于 region 吗？** 不等于。`region = Y//50` 是**物理**纵向分段；`band` 是**帧地址**分段序号，两者差一张置换表 `[6,5,0,1,2,3,4]`（`bitwriter.py:56`）。若二者相同，该表应为恒等映射，实测不是。
   【推断】band 号跟的是配置阵列的写入顺序，而 region 号跟的是器件物理摆放顺序——排除「表写错」的理由：band 与帧号在 7 条上完全连续（§8 命令 2），任何错位都会破坏连续性。

2. **同一 band 里的 50 个 tile 行共用帧吗？** 共用**帧**、不共用 **word**：一帧内 row 0..24 占 word 0..49、row 25..49 占 word 51..100。**跨 band 的行不共用帧**（base 相差 5,246）。

3. **row 等于 Y 吗？** 不等于。Y 是器件级（0..349）；row 是 band 内（0..49）；`frame` 内的「config row」又是另一层（一帧 101 word 的排布）。三者用 §4 的公式换算。

4. **band 号为什么不是按 Y 递增？** 因为 band 号是按帧地址分段编号的（band 0 = 帧 0..5245，对应 region 2 即 Y=100..149），而 region 号按器件纵向编号。可见 `bbr` 就是「帧顺序 ↔ 物理顺序」的置换。

5. **tile 类型与 tile 实例谁决定位形状？** 类型 + `inst`（同一个 `(tile_type, inst)` 组合）决定**位形状与索引顺序**（T23：SLICEM 与 SLICEL 的 INIT 顺序不同），实例（col/Y/band）只决定**这些位落在哪个帧与哪个 word**。

6. **同一个 `(col, Y)` 只有一个 tile 吗？** 不是。`col=20` 上 `INT_L` 与 `INT_INTERFACE_L` 每行并存，所以必须用 `tile_name` 定位。

---

## 7 自检清单

- [ ] 给定 `INT_L_X8Y20`，能算出 region=0、band=6、base=31752、word=40/41。
- [ ] 给定 `INT_R_X37Y199`，能算出 band=1、base=6510、`Y%50=49`、word=99/100。
- [ ] 给定 band 与 col，能说出帧基址从哪张表查（`far_bands`）、每个 band 有多少帧（5,246）。
- [ ] 能解释为什么 band 0 对应 Y=100..149 而不是 Y=0..49。
- [ ] 能解释同一帧里为什么能放 50 个 tile 行，而跨 band 的两行一定不同帧。
- [ ] 能说明 `(col, Y)` 为何不足以唯一标识一个 tile。
- [ ] 能说出 `word = 2*(Y%50)+parity` 里「≥50 则 +1」跳过的是什么（word 50 的帧级 ECC）。

---

## 8 复算命令

```python
# 1) 坐标与分桶
python -c "
import sqlite3
c=sqlite3.connect('file:E:/v7work/model/v7_law.sqlite?mode=ro',uri=True)
print(c.execute('select min(y),max(y),min(col),max(col) from law_tiles').fetchone())        # (0,349,0,157)
print(c.execute('select y/50,count(*) from law_tiles group by 1').fetchall())               # 7 桶
print(c.execute(\"select count(distinct col) from law_tiles where tile_type='INT_L'\").fetchone())  # 77
"

# 2) band ↔ 帧地址连续性
python -c "
import sqlite3
c=sqlite3.connect('file:E:/v7work/model/v7_law.sqlite?mode=ro',uri=True)
for b in range(7):
    print(b, c.execute('select min(start_frame),max(end_frame) from far_bands where band=?',(b,)).fetchone())
"   # 每条恰好 5246 帧，且首尾相接

# 3) 同 (col,Y) 多 tile
python -c "
import sqlite3
c=sqlite3.connect('file:E:/v7work/model/v7_law.sqlite?mode=ro',uri=True)
print(c.execute('select distinct tile_type from law_tiles where col=20').fetchall())        # INT_L + INT_INTERFACE_L
"

# 4) 全器件规模
python -c "
import json;g=json.load(open(r'E:/v7work/db/prjxray/xc7vx485t/tilegrid.json',encoding='utf-8'))
print(len(g));import collections;print(len(collections.Counter(v['type'] for v in g.values())))
"   # 150380 / 115
```
