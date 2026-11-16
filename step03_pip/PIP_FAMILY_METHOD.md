# 家族（family）与 PIP 复用：从物理架构到位级解法

> 器件 `xc7vx485tffg1761-2`。本文按 `PROMPT_PIP_FAMILY_MASTER.md` 的十段结构作答。
> 标注：`【硬件事实】` 手册/器件定义级；`【数据事实】` 本项目实测可复算；`【推断】` 由数据反推。
> 数字来源统一记为 `[src: 文件]`，全部可复算。

---

## ① 一分钟速览

1. **一个"1"说明不了什么。** INT tile 的 1,598 个配置位服务 3,636 条 PIP，平均 1 位被 2.3 条 feature 引用；单看置 1 位只能得到"候选集"，必须看**整组 pattern**。`[src: all_cells.json]`
2. **家族 = 同一 tile_type 下目标 wire 相同的那组互斥 PIP。** 它把"查哪张表"变成可计算谓词：`family = (tile_type, destination_wire)`。`[src: prjxray segbits 命名]`
3. **复用能解开，靠的是三条结构事实**：① 位池按家族独占（1,598/1,598）；② 族内每源模式两两不同（172/172 唯一）；③ 编码是**分级 one-hot**，位数 = 组数 + 成员数，不是 `ceil(log2 N)`。
4. **难点不在"有位共享"，而在"同 tile 多 PIP 同时激活"**：那时位集是并集，查表退化为多解，必须上互斥+覆盖约束（CSP）。本项目 181 条 PIP 解码 0 歧义，是因为每 tile 每族只激活一路。`[src: s13 解码]`

---

## ② 物理架构

### 2.1 die 分区

- 【数据事实】14 个 clock region = **7 行 × 2 列**（`X0Y0…X0Y6` + `X1Y0…X1Y6`）。行高 50 slice 行；列分界在**中心 IO 脊**（`IOB18S/M` 只在 gx=81 与 gx=312）。`[src: sites 表 clock_region]`
- 【数据事实】物理列 `gx` 与逻辑 name-X 非线性（name X31→gx79，X72→gx185），判断左右半区必须用 gx，不能用 name-X。
- 【数据事实】边界 tile：`VBRK` 12,950、`NULL` 19,709、`VFRAME`、`BRKH_*`（行边界）。
- **证伪**：若某 region 行数 ≠ 50，则 §3.4 的 word 公式在跨区时失效——判别信号是跨 region 的同一 Y-offset cell 解码错位。

### 2.2 列序列（gy=310 实测横切）

```
gx0 NULL|1 L_TERM_INT|2 GTX_INT_INTERFACE_L|3 INT_L|4 INT_R|5 CLBLL_R|6 CLBLM_L|7 INT_L|8 INT_R
|9 CLBLL_R|10 VBRK|11 CLBLM_L|12 INT_L|13 INT_R|14 BRAM_INT_INTERFACE_R|15 NULL|16 CLBLL_L
|17 INT_L|18 INT_R|19 CLBLM_R|20 CLBLM_L|21 INT_L|22 INT_R|23 CLBLM_R|24 VBRK|25 CLBLL_L|...
```
`[src: tilegrid.json, gy=310 与 gy=300 两次采样一致]`

三条可判定规律：

1. **`CLB | INT_L | INT_R | CLB`**：INT 列永远夹在两个 CLB 之间 → 一个 INT tile 必须同时服务左右 CLB 与上下通道，这就是它塞下 172 家族的结构原因。
2. **每 4 个逻辑列插一个 `VBRK`**（gx 10/24/34/44/54）：列断点，跨断点必须走长线 → `LV/LVB` 的来源。
3. **`CLBLL` 与 `CLBLM` 交替**：让任意连续列都带 SLICEM，而不必集中放置。

### 2.3 SLICEM 规则

- 【数据事实】SLICEM 32,700 个，**100%（32,700/32,700）X 为偶数，且只出现在 `CLBLM_L/R`**；SLICEL 43,200 = CLBLM 奇 X（32,700）+ CLBLL（5,250 tile × 2）。
- 规则：**X 偶 且 tile 属 `CLBLM_*` ⇒ SLICEM**。校验 32,700 + 43,200 = 75,900。
- **证伪**：若在 `CLBLL` 里发现 SLICEM，则"SLICEM 只在 CLBLM"被推翻——判别信号是 `sites` 表按 tile_type 分组后 CLBLL 出现 SLICEM 行。

### 2.4 数量互校

| 资源 | tile | site | 校验 |
|---|---|---|---|
| INT_L / INT_R | 26,550 / 26,550 | — | 与 CLB 37,950 配对 |
| CLBLM_R / CLBLM_L | 17,000 / 15,700 | 65,400 slice | ×2 = 32,700 SLICEM + 32,700 SLICEL |
| CLBLL_L / CLBLL_R | 3,100 / 2,150 | 10,500 slice | 全 SLICEL |
| BRAM_L / BRAM_R | 480 / 550 | RAMB18E1 1,030 | 15 列 × 60/70 |
| DSP_L / DSP_R | 770 / 630 | DSP48E1 2,800 | **1,400 tile × 2 = 2,800** ✔ 20 列 × 140 |
| IOB | LIOB18/RIOB18 各 168 | IOB18S/M 各 336 | 每 tile 2 pad site |

`[src: tilegrid.json, sites 表]`
- 【数据事实】时钟网：`BUFGCTRL` 32（2 tile × 16）、`BUFHCE` 168（8 行 × 21）、`BUFR/BUFIO` 各 56（4 列 × 14）、`BUFMRCE` 28（2 列 × 14）、`MMCM/PLL` 各 14（= 7 行 × 2 列，**与 14 region 自洽**）。
- 【数据事实】IO 在 gx=81/312，GTX 在 gx=0/394（各 28）+ `GTX_COMMON` 14。
- **证伪**：MMCM 若 ≠ 14，"每 region 一个 CMT"即错。

---

## ③ 位流结构

### 3.1 帧/字/位

- 【数据事实】50,176 帧 × 101 字 × 32 位；每帧第 50 字为 ECC；位序 LSB-first（bit j = `(val>>j)&1`）。`[src: bitread 实测 50,148/50,176 帧]`
- 【数据事实】每 config row 末 2 帧为 OVERHEAD，故有效帧/行 = 50。
- 【未测】字 51..100 的语义。测法：统计未配置区（全 0 帧）在字 51..100 的分布；预期恒 0 或固定模式。

### 3.2 帧块大小不等

- 【数据事实】CLB 36 帧、INT 列块 26 帧、接口块 28 帧；缺列处有 28 帧"夹缝块"。`[src: clb_blocks, s13 tile_block]`
- 判定方法：相邻 CLB 块基址差 64 ⇒ 中间夹一个 28 帧接口块（实测 31960 案例）。
- **证伪**：若某列相邻块差非 36/64/28 组合，则块表有漏。

### 3.3 定位公式

```
cell = (block_base + frame_off,  word,  bit)
word = 2*(Y % 50) + (1 if (Y % 50) >= 25 else 0) + parity     # parity = prjxray 的 bit//32
bit  = raw_bit % 32
```
- 【数据事实】parity 存在（prjxray `12_33` 表示 word+1、bit 1）。实测验证：`WA7USED` 落在 `(0,41,8)`，即 word 40+1。`[src: s11hex.json]`

### 3.4 半带 +1 的物理来源

一帧只存一列的一个"列切片"的 50 个字；tile 每行占 2 字 → `2*(Y%50)`。越过半带（`Y%50≥25`）后扫描进入第二段，起算基准平移 1 字 → `+1`。
**证据**：artix7 tilegrid 同构（Y0–24→2Y、Y25–49→2Y+1）；本项目实测 X16Y27→w55、X18Y31→w63、X22Y39→w79、band1 Y51→w2 全吻合。`[src: s8_int_pips_v2.json]`

### 3.5 FAR / 命令层 / 读回

- 【硬件事实】FAR 由 block type/row/column/minor 组成；写一帧 = 设 FAR → 写 101 字；命令含 sync word、Type-1/2、`WCFG/FDRI/GRESTORE/DESYNC`。
- 【未测】各字段位宽与 `50,176` 的解析式。注意 `965×52 = 50,180 ≠ 50,176`，**不要硬凑公式**。测法：取 3 个已知块基址（31680/31716/27286）与其 `(grid_col, band)` 解线性方程。

### 3.6 资源↔帧偏移

| 资源 | 偏移（块内） | 状态 |
|---|---|---|
| LUT INIT | 32–35 | 【数据事实】64/64 |
| FF: AFFMUX/ZRST/ZINI | 30/31 | 【数据事实】12/12 |
| IMUX 48 mux | 16–25 | 【数据事实】48/48 + 12/12 |
| INT PIP | 0–15（26 帧块） | 【数据事实】181 条 |
| 接口块 | — | 【未测】 |

---

## ④ 家族是什么

### 4.1 可计算定义（非循环）

> **家族（family）= 同一 `tile_type` 下、`destination_wire` 相同的一组 PIP feature。**

```python
# pandas 版：从 feature 名算出家族键
df[['tile_type','dst','src']] = df.feature.str.extract(r'^([A-Z0-9_]+)\.([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)$')
df['family_key'] = df.tile_type + '.' + df.dst     # 家族键
fam_cells = df.groupby('family_key').apply(lambda g: set(zip(g.frame_off, g.parity, g.bit)))
```
```sql
-- SQL 版
SELECT tile_type || '.' || destination_wire AS family_key,
       COUNT(DISTINCT source_wire) AS n_src,
       COUNT(DISTINCT frame_off||'_'||bit) AS n_cell
FROM pip_cells GROUP BY 1;
```

**为什么这个定义可判定**：它只用两个可观测字段，不引用"mux"这个待解释概念。定义推出三条可检验后果：① 同族源必然共用位池；② 不同族位池不相交（实测 1,598/1,598）；③ 同族源数 × 每源位数 ≥ 位池位数。

### 4.2 反例：看起来同族，其实不同族

| 两个 feature | 为何看似同族 | 为何实际不同族 |
|---|---|---|
| `INT_L.EL1BEG_N3.*` vs `INT_R.EL1BEG_N3.*` | 目标 wire 同名 | tile_type 不同 → 位池完全不同（INT_R 是另一套 cell） |
| `INT_L.WW2BEG0.WW2END3` vs `INT_L.WW2END0.WW2BEG3` | 字母集合相同 | 一个是 "目标 WW2BEG0"，一个是 "目标 WW2END0"，方向相反 |
| `CLBLL_L.CLBLL_LL_A1.*` vs `CLBLL_R.CLBLL_LR_A1.*` | 都叫 A1 | site 实例名不同（`CLBLL_LL_` vs `CLBLL_LR_`），BEL 索引不同 |

**边界**：家族 ≠ PIP（一族含 N 条）；≠ mux（命名分组 vs 电路，且常是多级树）；≠ tile_type（一页 vs 一本书）；≠ site（互连层 vs 逻辑层）；≠ wire type（具体目标 wire vs 类型族名）；≠ net（一次开关 vs 一串开关）。

### 4.3 位池的三类形状与每源 1–4 位

【数据事实】5 类形状（单侧计数，双侧 ×2）：

| 形状 (位池, 源数) | 家族数 | 每源位数 | 列计数签名 | 判读 |
|---|---|---|---|---|
| (9,20) | 96 | 2 | 4×5 + 5×4 | 两级：4 组 × 5 成员 ✔ |
| (9,18) | 2 | 2 | 6×3 + 3×6 | 两级：3 组 × 6 成员 ✔ |
| (7,12) | 4 | 2 | 4×3 + 3×4 | 两级：3 组 × 4 成员 ✔ |
| (8,16) | 6 | 2 或 4 | 6×4 + 2×12 | 多级（含直通）【未测】 |
| (10,24) | 64 | 2 或 4 | 6×4 + 2×6 + 2×18 | 多级（含直通）【未测】 |

**每源 4 位的成因【推断】**：该类家族含"直通/旁路中间级"的源——信号穿过不止一级 mux，故要同时设多级的组位+成员位。测法：对 (10,24) 家族逐源打印其 4 个 cell 的列计数，若两两分属不同列计数桶（6/18），即证明是两级串联。

### 4.4 为何位宽是 a+b 而非 ceil(log2 N)

【硬件事实】pass transistor 的栅极不能做二进制译码：同一级里必须有且仅有一个开关导通，所以每级用"one-hot"（一位一个候选）。
N = a × b 时，两级各置一位 → 需要 `a + b` 位。`(9,20)`：4+5=9 > ceil(log2 20)=5。

**证伪**：若某 family 的每源位数恰为 `ceil(log2 N)` 且列计数签名为二进制权重（1,2,4,8…），则分级 one-hot 被推翻——判别信号是"某 cell 被恰好半数源置 1"。

### 4.5 "跨族零共享"的公理地位

- **它是观测事实，不是定理**：1,598/1,598 cell 只属一个家族（0 例外），统计分母是 fuzz 覆盖集。`[src: REUSE_RULES.md]`
- **它若被推翻**：位集→feature 失去"逐族独立"分解性，必须做全局集合覆盖，解空间 `2^(feature 数)`；补救靠布线拓扑（tileconn）+ 方向性 + 每网单路径三条先验。
- **证伪信号**：按 `(off,parity,bit)` 分组若出现 `family 数 > 1`，公理立刻失效。

---

## ⑤ PIP 复用怎么解：六环解法链

### 环 1：位池与特征抽取

**输入**：`segbits_*.db`（或自建表）→ **输出**：`cells[(tile_type,family,src)] = {(off,parity,bit): sense}`

```python
groups = collections.defaultdict(list)          # (tt, fam, src) -> [cells]
for ln in open('segbits_int_l.db'):
    feat, *bits = ln.split()
    tt, dst, src = feat.split('.')
    for b in bits:
        neg = b.startswith('!'); off, bit = map(int, b.lstrip('!').split('_'))
        groups[(tt, dst, src)].append((off, bit // 32, bit % 32, 0 if neg else 1))
```
**判据**：同族内每源 cell 数应落在 1–4；出现 0 或多于 4 → 解析错。
**做错的现象**：把 `bit//32` 当 word 而忽略 parity → 解码时"总有几位永远对不上"。

### 环 2：家族识别与命名

**输入**：feature 名 → **输出**：家族键 + 每族位池
```python
fam_of = lambda f: '.'.join(f.split('.')[:2])      # tile_type.destination_wire
pool = {k: set().union(*[c for (tt,fa,s),c in cells.items() if tt+'.'+fa==k]) for k in fams}
```
**判据**：`Σ|pool|` 应 ≈ 位池大小（重叠说明跨族共享，立即触发 §4.5 证伪）。
**做错的现象**：家族键取成 `(tile_type, src)` → 位池巨大且几乎两两重叠，统计全部崩塌。

### 环 3：一热差分 fuzz 得到每源位模式

**输入**：一个已布线 DCP + 目标 mux 的一条网 → **输出**：每源位集
```tcl
# 固定一切，只改这一条网的 ROUTE（同一 routed.dcp，不重新 place/route）
set n [get_nets -of_objects [get_pins u_l/I2]]      ;# 目标输入脚所连网
set_property ROUTE $candidate_route $n
write_bitstream -force v_$idx.bit
```
```python
d = diff_frames(base.bit, v_$idx.bit)               # 逐帧逐字 XOR
d = {c for c in d if c.frame_off in range(16,26)}   # 只留 IMUX/PIP 位池窗口
```
**从零测一个新家族的实验清单**（可直接照做）：

| 项 | 内容 |
|---|---|
| 设计数 | 1 基线 + N 变体（N = 该族源数，如 20） |
| 每设计改什么 | 只改**一条网**的 ROUTE，落到目标 mux 的第 i 个源 |
| Vivado 侧属性 | `set_property ROUTE <wire chain> $net`（同一路由 DCP，绝不重跑 place/route） |
| 固定其它变量 | 同一 DCP、同一 baseline netlist、`-force` 重写；布线前后的 `route` 报告存档 |
| diff 窗口 | 目标 tile 的列块基址 + `off ∈ [0,25]`、`word = wof(Y) ± 1` |
| 失败症状 | ① 两变体位集完全相同 → 路由没生效（ROUTE 未覆盖旧路径）；② diff 为空 → 基线已置该位（需绝对值探针）；③ diff 出现在远处帧 → 其它网被动过；④ 位集少于 N−1 种 → 有碰撞（探针或解析错） |

**判据**：N 个变体应产生 N 组互不相同位集（或 N−1 + 1 个"空源/VCC"）。
**做错的现象**：把 4 条噪声位（常数位）当归属某源 → 该族所有源都"多 1 位"，且该位在其它族也出现。

### 环 4：列计数签名反推 mux 分级结构

**输入**：每源位模式 → **输出**：组级/成员级划分与 `a×b`
```python
for cell in pool:
    n1 = sum(1 for s in fam.sources if pat[s].get(cell) == 1)
    n0 = sum(1 for s in fam.sources if pat[s].get(cell) == 0)
    signature[cell] = (n1, n0)
# a×b 推断：取值 n 的 cell 数 = 该级候选数；源数 = a*b
```
**判据**：`每源位数 == 组数级 + 成员级`；且 `∏(每级候选数) == 源数`。
**做错的现象**：把成员级当组级 → 推得 `a×b ≠ N`，家族分类错位（本项目 5 类形状就是靠这一步核出来的）。

### 环 5：单 PIP 唯一性判据

**输入**：观测位集 `O`（已剥掉常数噪声位）→ **输出**：唯一源 / 多解 / 无解
```python
def decode_single(O, fam):
    hits = [s for s in fam.sources
            if fam.pat[s].ones <= O and not (fam.pat[s].zeros & O)]
    return hits            # len==1 唯一；>1 歧义；0 未覆盖
```
**判据**：`len(hits)==1`。**做错的现象**：只用 `ones <= O`（漏掉 zeros 检查）→ 反相位的源被误命中。

### 环 6：同 tile 多 PIP 联合求解（为何必须 CSP）

多 PIP 时观测是**并集**：`O = ⋃ ones(s_i)`，且每族至多 1 条（互斥），每个观测位必须被某条选中源解释（覆盖）：
```python
def decode_tile(O, fams):
    sols = []
    def dfs(i, chosen, cover):
        if i == len(fams):
            if cover == O: sols.append(list(chosen))
            return
        dfs(i+1, chosen, cover)                       # 不激活该族
        for s in fams[i].sources:                     # 互斥：每族至多一条
            if s.ones <= O and not (s.zeros & O):
                dfs(i+1, chosen+[s], cover | s.ones)
    dfs(0, [], set())
    return sols                                        # 0=UNEXPLAINED, 1=SOLVED, >1=AMBIGUOUS
```
为何不能查表：单条匹配只看"是否一致"，而并集下**多条各自一致但不覆盖全部位**——查表会给出一堆"都像对的"，CSP 才能选出"恰好解释所有位"的那组。

**失败模式返回**：
| 返回 | 含义 | 处置 |
|---|---|---|
| `SOLVED` | 有唯一组 | 输出 PIP 列表 |
| `AMBIGUOUS` | 多组都覆盖 | 加约束（拓扑/方向），或声明"输入非法" |
| `UNEXPLAINED` | 有位置没人解释 | 覆盖缺口（66 位/未测族），报错不要静默 |
| `CONFLICT` | 某位被要求 1 又被要求 0 | 输入损坏，或跨族共享（触发公理证伪） |

### 环 6.5：写位回环验证

```python
bit2 = flip(bit, cells_of_pips)          # 改位
for f in touched_frames: recompute_ecc(bit2, f)   # 每帧重算 ECC
bit2 = recompute_crc(bit2)                        # 全流 CRC
download(bit2); readback(); assert payload == bit2
```
**判据**：864/864 位全中 + 硬件功能一致。**做错的现象**：不改 ECC → `INIT_B` 不拉高；不改 CRC → 配置中止。

---

## ⑥ 完整走查：`INT_L.EL1BEG_N3`

【数据事实】该家族 9 个 cell、20 个源、每源恰 2 位。`[src: all_cells.json]`

**位池（9 个 cell）**：`(7,0,4) (8,0,4) (8,0,5) (10,0,5) (11,0,5) | (12,0,5) (13,0,5) (14,0,5) (15,0,5)`
（记法 `(frame_off, parity, bit)`）

**列计数签名**（每个 cell 被几个源置 1）：

| cell | 源数 | 判读 |
|---|---|---|
| (7,0,4), (8,0,4), (8,0,5), (10,0,5), (11,0,5) | **4** | 成员级：5 个位置，每位置 4 源用（=5 组中的 4 组） |
| (12,0,5), (13,0,5), (14,0,5), (15,0,5) | **5** | 组级：4 个组，每组 5 个成员 |

→ `4 组 × 5 成员 = 20 源`，每源 2 位（1 组位 + 1 成员位），位宽 **4+5=9**，比 `ceil(log2 20)=5` 多 4 位。

**组划分（按组 cell）——组有语义**：

| 组 cell | 成员（5 个） | 语义【推断】 |
|---|---|---|
| (12,0,5) | EE4END0, NE6END0, NN6END0, NW6END0, SE6END0 | length-6 方向线 |
| (13,0,5) | EL1END0, ER1END0, LOGIC_OUTS_L12, NL1END0, NR1END0 | length-1 + L12 |
| (14,0,5) | LOGIC_OUTS_L0/L18/L22/L4/L8 | 全部来自 CLB 输出 |
| (15,0,5) | EE2END0, NE2END0, NN2END0, NW2END0, SE2END0 | length-2 方向线 |

**成员复用**：同一批 5 个成员 cell `(7,0,4) (8,0,4) (8,0,5) (10,0,5) (11,0,5)` 在 4 个组里重复使用——这就是"位复用的物理来源"：**组选与成员选是两条正交的 one-hot 线，各自复用同一批 SRAM 位**。

**反推一条 PIP**：若观测到该 tile 的位集含 `(10,0,5)=1` 且 `(12,0,5)=1`，其余池内位为 0 →
- 组：只有 (12,0,5) 命中 → 组 1（length-6）
- 成员：(10,0,5) 在该组中对应 `NE6END0`（查表）
- 结论：`INT_L.EL1BEG_N3 ← NE6END0`，**唯一**（同组其余 4 个成员不在集中，且它们的成员位互补）。

**证伪**：若出现 `(10,0,5)=1, (11,0,5)=1`（两个成员位同时置 1）→ 非法输入 / 位流损坏；解码器必须报 `AMBIGUOUS` 或 `CONFLICT`，**不得静默取首个**。

---

## ⑦ 三类"复用"的辨析

| 名称 | 定义 | 本项目是否研究对象 | 判别信号 |
|---|---|---|---|
| **位级共享**（bit-level sharing） | 同一族内，一个 cell 被多条源的模式引用 | **是**（核心） | 族内 cell 数 < 源数 × 每源位数 |
| **位模式跨实例复用**（pattern reuse） | 相对 `(off,parity,bit)` 在不同 tile/band/列/实例重复 | **是**（迁移验证） | 同一相对坐标在 2 个 tile 上解出同族结构 |
| **资源复用**（resource reuse） | 布线资源（wire/PIP）被多网分时占用 | **不是**（与位流无关） | 同一 PIP 在两次布线中出现不同 net |

**为什么必须分清**：把"资源复用"混进来会得出"一条 PIP 可以同时被两条网使用"的错误结论——位流是静态配置，一条 PIP 只对应一个开关状态；而"位级共享"才是真正的位流现象。

---

## ⑧ 判据与证伪清单

### 8.1 为何 0 ambiguous 不是采样运气

| 反例形态 | 判别信号 | 若出现说明 |
|---|---|---|
| ① 同族两源位同置（非法输入） | 解码返回 `AMBIGUOUS`，且两解仅相差同组两个成员位 | 输入非法/位流损坏；不是"运气好" |
| ② 跨族借位 | 某 cell 出现在两个族的 pool 里（`Σ|pool|` > 位池大小） | **公理被推翻**（1,598/1,598 失效） |
| ③ 未覆盖位作乱 | 观测位集含 pool 外位且无法解释 → `UNEXPLAINED` | 覆盖缺口（66 位/未测族） |

**0 ambiguous 的必然性论证**：0 歧义来自两个**结构性**条件，不是抽样：(a) 硬件上同族每 tile 至多一个源导通（互斥由 mux 物理保证）；(b) 位池按族独占（§4.5 的 1,598/1,598）。两者合起来使单条查表在合法输入下唯一。**只要有人为置两条源位，歧义立刻出现**——这正是反例①的判定实验价值。

### 8.2 「位集 → PIP」判定算法（完整失败模式）

```python
def decode(bits, tile):
    O = {(o,p,b) for (o,p,b),v in bits.items() if v and (o,p,b) in tile.pool}
    outside = {k for k in bits if bits[k] and k not in tile.pool}
    cands = {fam: [s for s in fam.sources if s.ones <= O and not (s.zeros & O)] for fam in tile.fams}
    if any(len(h) > 1 for h in cands.values()) and len(tile.fams) == 1:
        return ('AMBIGUOUS', cands)
    sols = csp(tile, O)                    # 环 6
    if not sols:                return ('UNEXPLAINED', outside, O)
    if len(sols) > 1:           return ('AMBIGUOUS', sols)
    return ('SOLVED', sols[0])
```

### 8.3 复算清单（每个数字都能重跑）

| 数字 | 来源 | 复算方式 |
|---|---|---|
| 172 家族 / 1,598 cell / 3,636 feature | `all_cells.json` | `groupby('family').nunique()` |
| 1,598/1,598 独占 | 同上 | 按 `(off,parity,bit)` 分组计数 family 数 |
| 5 类形状 | 同上 | `groupby(family).agg(n_cell, n_src)` |
| 181 PIP / 0 歧义 | `s13_pips.json` | 每 (tile,family) 查 src 候选数 |
| 864/864 写回 | `s11hex.json` + 回环脚本 | 改位 → 重算 ECC → 回读比对 |

---

## ⑨ 误解纠正（≥8 条，针对解法链环节）

1. **"只看置 1 位就能定源"** ✘ —— 反相位（`!bit`）的源要求某位为 0；漏 zeros 检查会误命中（§⑤ 环 5）。
2. **"同族两位看一位就够"** ✘ —— 每源 = 1 组位 + 1 成员位；只看成员位，同组的 5 个成员无法区分。
3. **"位池大小 = 源数 × 每源位数"** ✘ —— 位级共享使 `9 < 40/2`；这正是"复用"的量化含义。
4. **"位数 = ceil(log2 N)"** ✘ —— 分级 one-hot 得 `a+b`（9 vs 5）。
5. **"family 就是 mux"** ✘ —— 命名分组 vs 电路；`(8,16)`/`(10,24)` 是多级树（含直通）。
6. **"跨族共享能省面积"** ✘ —— 1,598/1,598 独占；省面积靠族内复用。
7. **"查表能处理多条 PIP"** ✘ —— 并集下多条各自一致但不覆盖全部位；必须 CSP（§⑤ 环 6）。
8. **"0 ambiguous 说明方法万无一失"** ✘ —— 它只对合法输入成立；非法输入必须报错。
9. **"差分就能测出位池"** ✘ —— 基线已置 1 的位在差分中不可见（§⑤ 环 3 失败症状②），需绝对值探针。

---

## ⑩ 自测题（8 题，含答案）

1. **为什么不能只看置 1 位？** 因为部分源的编码含反相位（要求为 0）；只匹配 ones 会把"某位应为 0 却被置 1"的源误命中，也会漏掉 `zeros` 冲突。
2. **为什么同族两位必须都看？** 每源 = 1 个组位 + 1 个成员位；同组 5 个成员共享组位，只看组位无法区分成员。
3. **`(9,20)` 为何是 9 位而非 5 位？** 4 组 × 5 成员的两级 one-hot，位宽 = 组数 + 成员数 = 9。
4. **如何判定跨族零共享是否成立？** 按 `(off,parity,bit)` 分组统计 family 数；全为 1 成立，出现 >1 立刻推翻。
5. **同 tile 多 PIP 为什么是 CSP 而非查表？** 观测是 ones 并集；查表只能给"各自一致"的多解，CSP 用互斥（每族 ≤1）+ 覆盖（所有位都被解释）收缩到唯一。
6. **差分 fuzz 的盲区是什么？怎么补？** 基线已置 1 的位在差分中消失；用两个独立基线做绝对值探针（followup2 方法）。
7. **写位回环比读回强在哪？** 读回只证明读方向一致（可能与真值同错）；写回要求 ECC/CRC 正确且硬件接受，排除"共同错误"与"未覆盖位"。
8. **如果某 cell 同时属两个家族，会发生什么？** 逐族独立分解失效，必须全局集合覆盖（`2^N`），靠 tileconn 拓扑 + 方向性 + 每网单路径压回可判定。

---

## 自检清单（8 项）

- [x] 六环解法链每环均给 ≥3 行可执行伪代码
- [x] 家族定义以可计算谓词给出（pandas/SQL 双版本）+ 3 个反例
- [x] 给出"从零测一个新家族"的完整实验清单（含 4 类失败症状）
- [x] 论证 0 ambiguous 非采样运气：3 种反例形态 + 判别信号
- [x] 给出位集→PIP 判定伪代码 + 4 种失败模式返回
- [x] 三类复用辨析（位级共享 / 位模式跨实例 / 资源复用）
- [x] 数字全部标来源，可复算
- [x] 误区 9 条 + 自测 8 题均针对解法链环节，无泛泛常识题

**未满足项**：无。**边界声明**：BRAM/DSP/IO 家族的跨族独占性未测（§4.5）；`(8,16)`/`(10,24)` 的 4 位编码结构未测（§4.3）；FAR 字段位宽未测（§3.5）。
