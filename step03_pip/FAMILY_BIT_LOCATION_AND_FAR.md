# 每个 PIP 族的配置位藏在哪：FAR 与"找位"全流程

> 讲三件事：FAR 到底是什么、每个族的位在比特流里怎么定位、对应真实结构长什么样
> 标注：**【硬件事实】**｜**【数据事实】**｜**【推断】**｜**【未测】**
> 复算入口见 §9；术语定义见 `INT_EXPERIMENT_GUIDE.md` §2

---

## 1. 一句话

**一个族的配置位 = `base_frame(该 tile 的 band/col) + frame_off` 这一帧里、`word = 2*(Y%50)+parity` 这一行、若干 bit 列**；而 `frame_off` 正好就是 **FAR 的 minor 字段**——这不是约定，是 36,708 个逻辑帧逐条验过的恒等式。

---

## 2. FAR 是什么

【硬件事实】FAR = Frame Address Register，配置逻辑的帧地址寄存器，26 位有效：

| 位段 | 字段 | 本项目含义 | 取值范围（485T） |
|---|---|---|---|
| `[25:23]` | block type | 逻辑块 / BRAM-DSP 块 | 0 / 1 |
| `[22]` | top/bottom | 上半 / 下半 | 0 / 1 |
| `[21:17]` | row | 块内行段 | 0..4 / 0..1 |
| `[16:7]` | column | 列（= 本项目 `far_bands.col`） | 0..153（逻辑块） |
| `[6:0]` | minor | **列内偏移（= `frame_off`）** | 0..41 |

### 2.1 三个反直觉点（必须分开记）

**① FAR ≠ 帧号。** FAR 是"坐标"，帧号是"线性序号"。前者换算成后者要查列起点表：`frame = far_bands[(band, col)].start_frame + minor`。

**② `.bit` 文件里的 FAR 不可用。** 【数据事实】44 个本地位流（含 `ref.bit`、`_c0..c5`、`_full8`）里 FAR 只**写一次**、值恒为 `0x00000000`，随后是一个 Type2 FDRI 突发写满 **5,067,776 字 = 50,176 帧**。也就是说比特流是"从第一个帧开始顺序灌"，而不是逐帧写地址。**所以想逐帧定位，必须自己有地址表**。

**③ `word` 与族无关，只与 tile 的 Y 有关。** `word = 2*(Y%50) + parity`（≥50 再 +1 跳过 word 50 的 ECC）。同一个 tile 里 172 个族共用**同一对 word**。

### 2.2 逐字段拆解（真实值）

| 例子 | FAR | block | top | row | col | minor | 含义 |
|---|---|---|---|---|---|---|---|
| `frame 31752` | `0x00420400` | 0 | 1 | 1 | **8** | **0** | `INT_L_X8Y20` 的基址（Y=20 → region0 → band6） |
| `frame 31768` | `0x00420410` | 0 | 1 | 1 | 8 | **16** | 同 tile，`frame_off = 16`（mux 区第一个帧） |
| `frame 6510` | `0x00021280` | 0 | 0 | 1 | **37** | **0** | `INT_R_X37Y199` 的基址（Y=199 → region3 → band1） |
| `frame 6521` | `0x0002128b` | 0 | 0 | 1 | 37 | **11** | 同 tile，`frame_off = 11`（`SS6END0` 的第一格） |
| `frame 22144` | `0x00021100`+26 | 0 | 0 | 4 | **33** | **26** | 时钟列尾帧（`HCLK_CMT` 位池） |

### 2.3 恒等式（全局验证）

【数据事实】对 `frame_map` 全部 50,176 帧检查 `minor == frame_index − start_frame(band, col)`：

- **block 0（逻辑块）：36,708 / 36,708 全部成立，0 例外**（`_q_far_minor_identity.py`）
- block 1（BRAM/DSP 块）：13,440 帧，**不在** `far_bands` 表内（该表只覆盖逻辑块 7×154），未建模
- 28 个 overhead 帧：`far` 为 NULL（每段末尾 2 帧 × 14 段）

⇒ **`frame_off` 不是我们自己发明的坐标，它就是 FAR 的 minor 字段。**

---

## 3. FAR 是怎么拿到的

| 路径 | 可行性 | 结论 |
|---|---|---|
| 从 `.bit` 逐帧读 FAR | ✗ | 【数据事实】FAR 只写一次且 = 0（§2.1②） |
| 从 Vivado 报告取 | ✗ | Vivado 不导出逐帧 FAR |
| **从 RapidWright 器件模型推导** | ✓ | 【数据事实】`frame_map.far` 50,148 行 `frame_address_source='rapidwright-configarray'`、`confidence='confirmed'`；28 行 overhead unresolved |

**独立校验**（不然就是"信第三方"）：
1. 反解 FAR → `(band, col, minor)` → 算 `frame`；
2. 用该 frame 去读 `ref.bit`，把读到的位与 `pips_all.txt`（Vivado `get_pips` 真值）对账；
3. 结果：**1,155 / 1,263 = 91.45%** 的 INT 布线被正确解码（差异全是 2 格歧义族）。

---

## 4. 地址链（三段式）

```
① region = Y // 50            (0..6)
   band   = [6,5,0,1,2,3,4][region]        ← 是置换，不是恒等
   base   = far_bands[(band, col)].start_frame
② frame  = base + frame_off                 (INT: 0..25 / 时钟列: 26..29)
③ word   = 2*(Y%50) + parity;  if word >= 50: word += 1     ← 跳过 word 50 (ECC)
   bit    = 由族决定（见 §5）
```

**为什么 band 是置换**：band 跟随 CRAM 的写入顺序，不跟随 Y 顺序 ⇒ `band0` 装的是 `Y=100..149`、`band6` 装的是 `Y=0..49`。

**如果这一步算错，症状是什么**：
- band 用成 region → 只有部分 region 出错（因为置换），症状是"同一 tile 的 mux 族落到别的 tile 的帧里"；
- 漏 `≥50 则 +1` → 所有 `Y%50 ≥ 25` 的 tile 的 parity 1 位全部偏移 1 个 word，症状是"下半区的族位集合全错，上半区正常"；
- col 用 grid_x → 因为 154 列 vs 398 个 grid_x 是两套坐标，症状是"列的基址差 40–50 帧"。

---

## 5. 每个族的位在哪个区间（实测总表）

【数据事实】26 帧块按功能分区，三类互不重叠：

| 组 | 族数 | frame_off 区间 | 位集合（bit） | parity | 每族格数 | 覆盖 feature |
|---|---|---|---|---|---|---|
| 复合族（16 源） | 6 | **0..1** | 见下例：`CLK_L0` {20,21,22,24,25,26,28}、`GFAN0` {9,10,11,12,14,16,18}、`CTRL_L1` {0,1,2,4,5,9,10} | 0 或 1 | 8 | 96 |
| 长线族（18/12/10 源） | 6 | **0..1** | `LH0` {2,6,22,24,25,26,27,29}、`LVB_L0` {10,11,15,18,19,20,21,22} | 0 和 1 | 9 | 82 |
| BEG 纯净族（20 源） | 64 | **6..15** | **{6,7}** | 0 | 9 | 1,280 |
| BEG 变体族（20 源） | 32 | **2..7** | **{28,29,30,31}** | 0 | 9 | 640 |
| mux（24 源） | 64 | **16..25** | **{6,7}** | 0 或 1 | 10 | 1,536 |

**位池占用**：`1,598 / 1,664 = 96.0%`（每 tile 26 帧 × 2 word × 32 bit）。
**每帧实际用到的位数**：帧 0/1 → 47 位、帧 2/3 → 48 位、**帧 4..25 → 每帧 64 位（满装）**。

**为什么 BEG 要 14 帧而 mux 只用 10 帧**：mux 每族 24 源 = 6 行 × 4 码，行用 6 个格（帧 16..21）、码用 4 个格（帧 22..25），**10 帧恰好够且不留空位**；BEG 是 K(5,4) 的**边编码**（20 条边各占 2 格），需要 5 行 × 4 列的边表，纯族占 6..15、变体族另用 2..7，共 14 帧覆盖 96 族。

---

## 6. 三个族的完整追踪（照这个格式可以追任意族）

### 6.1 mux 族 `IMUX_L40`（`INT_L_X8Y20`）
| 步 | 做什么 | 真实数值 |
|---|---|---|
| 1 | 取 tile 的 (col, Y) | `INT_L_X8Y20` → col 8、Y 20 |
| 2 | region → band | `20//50 = 0` → `band = [6,5,0,1,2,3,4][0] = 6` |
| 3 | 查基址 | `far_bands[(6, 8)].start_frame = 31,752` |
| 4 | 族帧区间 | mux 族 → `frame_off 16..25` → 帧 **31,768..31,777** |
| 5 | word | `2*(20%50) + parity` → parity 0 用 **word 40**、parity 1 用 41；`IMUX_L40` 用 parity 0 |
| 6 | bit | `{6, 7}`（10 个格：`(16..21, 0, {6,7} 选 primary/配对)` + `(22..25, 0, 6)`） |

### 6.2 BEG 族 `EE2BEG0`（同 tile）
- 帧区间 `frame_off 6..15` → 帧 **31,758..31,767**；word 40；bit `{6,7}`；20 源 = 5 组 × 4 组，每源 2 格（一格在 A 侧、一格在 B 侧）。

### 6.3 时钟/长线族 `CLK_L0`（同 tile）
- 帧区间 `frame_off 0..1` → 帧 **31,752..31,753**；parity 0；bit `{20,21,22,24,25,26,28}`（8 个格）；16 源 = 4 组 × 4 源（core + drops + extras 组模型）。

### 6.4 变体族 `SS6BEG1`（同 tile）
- 帧区间 `frame_off 2..7`；bit `{28,29,30,31}`；这就是"32 个变体族用高 bit 区"的实证。

---

## 7. 真实结构长什么样（三层）

### 7.1 物理层
【硬件事实】一个 INT tile 是一片开关矩阵：600 根 wire 作为节点，3,737 条 PIP 作为可编程边。共用同一目的 wire 的一组 PIP 就是一个 mux（172 个），其余 44 条是"只有一个源"的直通。**族 = 一个 mux = 目的 wire + 全部候选源。**

### 7.2 CRAM 层
【硬件事实】一列配置帧 = 50 个器件行 × 2 个 word（每行两个 parity）+ 1 个 ECC 字 = 101 word。所以**帧是一条竖条，word 是条上的行号，bit 是行内的列**。172 个族的位就分布在这条竖条的 26 帧 × 2 word × 32 bit 池子里。

```
帧 31,752 ─┐  fo0  ┌── word 40 (parity 0) ── 32 bit ──┐  ← CLK_L0 / 长线族
帧 31,753 ─┤  fo1  │                                    │
           ...      │                                    │
帧 31,758 ─┤  fo6  ├── word 40 ─────────────────────────┤  ← EE2BEG0（BEG 纯净族）
   ...      │        │                                    │
帧 31,767 ─┤  fo15 │                                    │
帧 31,768 ─┤  fo16 ├── word 40 ─────────────────────────┤  ← IMUX_L40（mux）
   ...      │        │                                    │
帧 31,777 ─┘  fo25 └────────────────────────────────────┘
```

### 7.3 地址层（以 `INT_L_X8Y20` 为例）
| 量 | 值 |
|---|---|
| band / col | 6 / 8 |
| 基址帧 | 31,752 |
| FAR | `0x00420400`（block0 top1 row1 col8 minor0） |
| word（parity 0/1） | 40 / 41 |
| 位池 | 26 帧 × 2 word × 32 bit = 1,664 位 |

---

## 8. 怎么自己查任意族（可直接跑）

```sql
-- ① 某族的全部格（哪一帧、哪个 word、哪一位）
SELECT frame_off, parity, bit FROM law_cells
WHERE tile_type='INT_L' AND family='IMUX_L40' AND sense=1
GROUP BY frame_off, parity, bit ORDER BY frame_off, bit;

-- ② 某 tile 的基址
SELECT start_frame FROM far_bands WHERE band=6 AND col=8;   -- 31752

-- ③ 帧 → FAR
SELECT frame_index, far FROM frame_map WHERE frame_index=31768;  -- 0x00420410
```

```python
# ④ 把「族 + tile」换算成绝对地址
base = 31752; Y = 20
for (fo, par, bit) in cells:            # cells 来自 ①
    frame = base + fo
    word  = 2*(Y % 50) + par
    if word >= 50: word += 1
    print(frame, word, bit)             # → (31768, 40, 6) 等
```

---

## 9. 三分钟自查清单（8 条，每条可执行）

1. `SELECT count(*) FROM far_bands;` → **1,078**（7×154）。
2. `SELECT frame_index, far FROM frame_map WHERE frame_index=31752;` → `0x00420400`，解出 col=8 minor=0。
3. `python step03_pip/_q_far_minor_identity.py` → `data_frames_ok 36,708 bad 13,440`（bad 全是 block1，不在表内）。
4. `SELECT count(DISTINCT family) FROM law_cells WHERE tile_type='INT_L' AND sense=1;` → **172**。
5. `SELECT count(DISTINCT src_wire) FROM law_cells WHERE tile_type='INT_L' AND sense=1;` → 3,634 个 (family,src) 对（按 family 分组）。
6. 任取一族，验证 `frame_off` 落区间（mux 16..25 / BEG 6..15 或 2..7 / 时钟长线 0..1）。
7. `python step03_pip/_q_family_pool.py` → 位池 1,598/1,664 与每帧 47/47/48/48/64… 的分布。
8. `python step03_pip/_q_cover_tile.py` → 3,737 = 3,629 + 64 + 44。

---

## 10. 边界（别越界讲）

| 项 | 现状 |
|---|---|
| 开关矩阵物理版图 | 【未测】RapidWright `Tile` 无内部行列、`Site.getSitePIPs()` 只给 LUT 输出选择、Vivado 几何探针挂死 |
| block 1（BRAM/DSP 块） | 13,440 帧不在 `far_bands` 内，未建模 |
| 时钟列（grid_x 88/305） | **没有自己的 FAR col**；位存在相邻逻辑列块的尾帧 `minor 26..29` |
| 82 条长线族 | 两轴是物理到达端口，不是名字属性（见 `STATUS.md §183`） |
| `frame_map.tile_name` | 本库该列为 NULL（未回填），故"帧→tile"要靠 `law_tiles` 反查 |

---

## 11. 复算入口

| 想看什么 | 命令 / 表 |
|---|---|
| FAR 逐字段拆解 | `python step03_pip/_q_far_examples.py` |
| 恒等式全局验证 | `python step03_pip/_q_far_minor_identity.py` |
| 每族位池 | `python step03_pip/_q_family_pool.py` |
| 帧块分区 | `python step03_pip/_q_frame_partition.py` |
| tile 内四类分解 | `python step03_pip/_q_cover_tile.py` |
| 地址表全量 | `far_bands`（1,078 行）、`frame_map`（50,176 行） |
