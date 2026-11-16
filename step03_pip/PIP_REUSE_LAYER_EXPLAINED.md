# PIP 复用发生在哪一层 · family 是什么 · 为什么两者绑死

> 驱动提示词：[`PROMPT_PIP_REUSE_LAYER_V1.md`](PROMPT_PIP_REUSE_LAYER_V1.md)（经 prompt-optimizer MCP 生成）
> 数据基准：`E:\v7work\model\v7_law.sqlite` 表 `law_cells`（24,328 行）；
> 交叉核验表：`step03_pip\all_cells.json`（24,336 行，24,336 = 2 侧 × 12,168）。
> 标注：`【硬件事实】`= 由物理结构决定、不依赖测量；`【数据事实】`= 本文件内可复算的查询结果；`【推断】`= 解释性推论。
> 器件：xc7vx485tffg1761-2（Virtex-7 / VC707）。

---

## 0. 一句话结论

**复用发生在「配置 SRAM 位」这一层：同一个 mux 的 N 个候选输入共享一小撮 CRAM 位（cell），
靠「哪些位置 1」的 pattern 区分选的是哪个输入。** 复用的不是连线、不是 wire，而是**位**。
`family` = 一个 mux（或一条长线驱动器）的输出 wire；位池按 family 私有，因此离开 family 就无法讨论复用。

【数据事实】INT_L 一侧：172 个 family、1,598 个不同 cell、3,636 个 feature（见 §2 核对表）。

---

## 1. 三层定位：位 → 栅极 → wire

| 层 | 物理对象 | 在本项目的对应名 | 位流里的表现 |
|---|---|---|---|
| L0 | 配置 SRAM 单元（1 bit） | `cell` = `(frame_off, parity, bit)` | `.bit` 里的一个可寻址位 |
| L1 | pass transistor 栅极（一个开关的通断） | 一位控制一个开关 | 置 1 / 清 0 |
| L2 | mux 树输出 wire（N 个输入选 1 个） | `family` | 该 wire 的全部候选输入的开关位都归它管 |
| L3 | 一条具体连线（输入 wire → 输出 wire） | `feature` = `(family, src_wire)` | 一组置 1 的位 |

【硬件事实】7 系列的布线 mux 不是二进制译码器：它是 pass transistor 树，某个输入的开关由**该输入专属的几位**驱动，
所以「选第 k 个输入」= 「把 k 号 pattern 的那几位一起置 1」，而不是「把 k 写成二进制」。
这就是「复用」的物理来源：**N 个输入共用 k 个位，k 远小于 N，靠 pattern 而不是靠位号区分**。

【数据事实】INT_L 的 1,598 个 cell 服务 3,636 条 feature：平均 **一个 cell 被 7.61 个 feature 置 1**（最小 3，最大 24）；
平均 **一条 feature 置 3.35 个 cell**（只有两种取值：2 或 5，见 §4.3）。
这两个数字是同一件事的两面 —— 每条 PIP 只点亮几个位，而每个位被一堆 PIP 共用。

---

## 2. 「讨论中的说法 vs 数据库实测」核对表

| # | 讨论中的说法 | 数据库实测 | 裁决与出处 |
|---|---|---|---|
| 1 | `IMUX_L40` 的 10 个 cell 是 `(0,0,6)(1,0,6)…(9,0,6)`，即 frame_off 0..9 | frame_off = **16..25**，parity 恒 0，bit = `[6,6,7,7,6,6,6,6,6,6]` | **不一致**。0..9 是「mux 行号 r」，物理帧偏移是 16+r。见 §3 |
| 2 | 每 cell 被 src 共用数 = `[4,4,4,4,4,4,6,6,18,18]` | `[4,4,4,4,4,4,24,24,24,24]` | **不一致**。后 4 个 cell 是**全族 24 个 src 共用**，不是 6/18 |
| 3 | 24 个源只用 10 个物理位 | 是：10 个 cell，24 个 src | **一致** |
| 4 | 每源置几个 cell（未明说） | 每个 src 恰好 **5** 个（24×5 = 120 行） | 补充事实 |
| 5 | 形状组合 5 类 | `(9,20)×96`、`(10,24)×64`、`(8,16)×6`、`(7,12)×4`、`(9,18)×2` = 172 | **一致**（以此表 `all_cells.json` 口径） |
| 6 | 跨族共享为零（1,598/1,598 独占） | `all_cells.json`：**0 例**跨族；`law_cells`：**3 例** | **两表不一致**，见 §6 脚注 |
| 7 | 每 feature 平均置位 2.45 格 | **3.35 格**（12,168 / 3,636） | **不一致**：2.45 = 8,904/3,636，8,904 这一分子在本库无对应查询 |
| 8 | 每 cell 被 3..18 个 src 共用，均值 5.57 | **3..24，均值 7.61** | **不一致**：18 与 5.57 是旧口径（`REUSE_RULES.md:98`） |
| 9 | 「域内编码唯一 172/172」 | **102/172 唯一；70 个族存在 4 源同 pattern** | **不一致，且是 §4.4 的核心发现** |
| 10 | INT_L 3,636 feature | `all_cells` 3,636；`law_cells` **3,634** | 差 2 条 feature，第二个表覆盖略少 |

> 结论：讨论里的**物理图像是对的**（复用位、family 私有、pattern 编码），
> 但**数字来自旧文档**（`PROMPT_PIP_REUSE.md:29-38`、`REUSE_RULES.md:94-99`、`PIP_LAW.md:216-217`），
> 与当前库不一致；尤其第 9 条不是笔误，而是把「pattern 两两不同」当成了结论。

---

## 3. 逐层拆一个具体例子：`INT_L.IMUX_L40`

【数据事实】`IMUX_L40`：24 个 src、10 个 cell、120 行（每 src 5 行）。
10 个 cell = `(16,0,6) (17,0,6) (18,0,7) (19,0,7) (20,0,6) (21,0,6) (22,0,6) (23,0,6) (24,0,6) (25,0,6)`。

按「每 cell 被多少 src 置 1」拆开：

| 分组 | cell | 每 cell 被几个 src 用 | 含义【推断】 |
|---|---|---|---|
| A（6 位） | frame_off 16..21 | 各 4 个 | 「选哪一组」——6 位对应 6 个候选组 |
| B（4 位） | frame_off 22..25 | 各 24 个 | 「组内公共位」——全族任何 src 都置这 4 位 |

于是每个 src 的 pattern = **B 的 4 位全置 + A 的 1 位置 1**，共 5 个 cell。
24 个 src ÷ 6 个 A 位 = **每组 4 个 src**，这 4 个 src 的 pattern **完全相同**。

【数据事实】实测该族 24 个 src 只有 **6 种不同 pattern**，每种 4 个 src：

```
(20,0,6)+B : BYP_BOUNCE_N3_2, BYP_BOUNCE_N3_6, FAN_BOUNCE2,   FAN_BOUNCE7
(21,0,6)+B : LOGIC_OUTS_L0,   LOGIC_OUTS_L12,  LOGIC_OUTS_L22, GFAN0
(16,0,6)+B : SR1END_N3_3,     EE2END0,         NL1END0,        SE2END0
(19,0,7)+B : WW2END_N0_3,     ER1END0,         NW2END0,        WL1END0
(18,0,7)+B : EL1END0,         SS2END0,         SW2END0,        WR1END0
(17,0,6)+B : NE2END0,         NN2END0,         NR1END0,        SL1END0
```

这就是「复用」的可视化：**同一族 24 个候选，只用了 10 个物理位**；位池用满，pattern 只有 6 种。

---

## 4. 为什么 family 与复用绑得这么紧

### 4.1 位池按 family 私有
【数据事实】按 `(frame_off, parity, bit)` 分组统计它被几个 family 用到：`all_cells.json` 下 **0 个 cell 跨族**，
即 1,598 个 cell 里没有一个同时属于两个 mux 树。所以「复用」的边界正好是 family 的边界。

### 4.2 位池大小由 mux 树结构决定，不是由「源数」决定
【数据事实】172 个族的 `(cell 数, src 数)` 只有 5 种组合：`(9,20)` 96 族、`(10,24)` 64 族、`(8,16)` 6 族、
`(7,12)` 4 族、`(9,18)` 2 族。若用二进制编码，20 个源只要 5 位、24 个源只要 5 位；
但实测要 9 位或 10 位 —— 因为它是**分级 one-hot**：位数 = 组数 + 组内成员数，不是 ceil(log2 N)。

### 4.3 两种编码形状
【数据事实】
- `(9,20)`：每 src 占 **2** 个 cell（一个「组位」+ 一个「成员位」），**20 种 pattern 全不同** → 可唯一反解。
- `(10,24)`：每 src 占 **5** 个 cell（4 个公共位 + 1 个组位），只有 **6 种 pattern** → 4 源共享一个 pattern。
- `(8,16)`：每 src 占 5 个 cell，只有 **4 种 pattern** → 4 源共享一个 pattern。

【推断】`(9,20)` 是「2 级各 1 位」的两段式编码；`(10,24)`/`(8,16)` 多出来的公共位不是用来区分源的
（它被全族点亮），真正做区分的只有 1 位 —— 说明这些 mux 的**组内选择发生在别处**（邻居 tile 的 mux 或 wire 别名），
本 tile 的 CRAM 只记录「选哪一组」。

### 4.4 「编码唯一」是错的，而这正好解释了 2 格歧义
【数据事实】按 pattern 是否两两不同统计：**102/172 族唯一，70 族不唯一**（64 个 `(10,24)` 族 + 6 个 `(8,16)` 族，
每族固定 4 源撞同一个 pattern）。

【推断】这条事实与 `T6B_DISAMBIGUATION.md` 的「mux 是否被配置可判、选了哪个源在 2 格下不可判」是**同一个原因**：
pattern 层面本来就存在 4 对 1 的合并。所谓「2 格歧义」不是抽样不够，而是**这些族的位池里没有足够信息**。

---

## 5. 为什么统计必须用 `(frame_off, parity, bit)` 三元组

【数据事实】`IMUX_L0` 的 10 个 cell 是 `(16..25, parity 0)`、bit 序列 `[1,1,0,0,1,1,1,1,1,1]`；
`IMUX_L4` 的 bit 序列**完全相同**，但 parity = **1**。

【推断】INT tile 每个 frame_off 有 2 个 word（parity 0/1 各一个），是两个物理 SRAM 列。
只按 `(frame_off, bit)` 分组会把 L0 与 L4 看成「同一批位」，直接得出「两个族共享位池」的假结论，
进而推翻 §4.1 的私有性。**parity 是列的第三个坐标，不是修饰位。**

---

## 6. 对解码与写入的后果

1. 【推断】**单个 1 不携带可解释信息**：任一位置 1 只能把候选集缩小到「用过这一位的 src 集合」（IMUX_L40 里 4 或 24 个）。必须看整组 pattern。
2. 【数据事实】pattern → src 是多对一：`(10,24)` 族 4:1，`(8,16)` 族 4:1，`(9,20)` 族 1:1。
   所以「反向解码」的精度上限由位池形状决定，不由算法决定。
3. 【推断】写入方向反而简单：要选某个 src，就把它的 pattern 位置 1、同组其他位清 0；但若目标是 4 源共享的 pattern，
   则写进去的位流**无法区分这四个源** —— 这正是本项目的写入器在 `c3/c4/c5` 上各差 1 位、以及 2-bit 篡改检不出的根源。

---

## 7. 旧文档数字出处（建议逐条修订）

| 旧数字 | 出处 | 实测值 |
|---|---|---|
| 每 feature 2.45 格（8,904/3,636） | `REUSE_RULES.md:99` | 3.35 格（12,168/3,636） |
| 每 cell 3..18 源、均值 5.57 | `REUSE_RULES.md:98`、`PIP_LAW.md:217` | 3..24 源、均值 7.61 |
| 3,636 feature | `REUSE_RULES.md:95` | `all_cells` 3,636 ✓ / `law_cells` 3,634（差 2） |
| 域内编码唯一 172/172 | `REUSE_RULES.md:96`（原文「域内编码唯一」） | 102/172 唯一，70 族 4:1 合并 |
| 形状 5 类 | `REUSE_RULES.md:94-99` | ✓（以 `all_cells.json` 为准；`law_cells` 有 3 族形状不同） |

> `law_cells` 与 `all_cells` 的跨族共享结论相反（3 例 vs 0 例）：
> 两表都由实测回填，但 `law_cells` 少 2 条 feature、3 族形状不同。
> 在未查明生成脚本前，**跨族独占的结论只对 `all_cells.json` 成立**【数据事实】。

---

## 8. 复现命令

```python
import sqlite3, collections
c = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = c.execute("select family,src_wire,frame_off,bit,parity from law_cells where tile_type='INT_L'").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f,s,fo,b,p in rows: fam[f][s].add((fo,p,b))
# 每 cell 被几个 src 用
sh = collections.Counter(c_ for v in fam.values() for s in v.values() for c_ in s)
print(len(fam), "families", len(sh), "cells", sum(len(v) for v in fam.values()), "features")
print("share:", min(sh.values()), max(sh.values()), round(sum(sh.values())/len(sh),2))
# pattern 唯一性
dup = {f: len({frozenset(x) for x in v.values()}) for f,v in fam.items()}
print("unique families:", sum(1 for f in dup if dup[f]==len(fam[f])), "/", len(fam))
```

`all_cells.json` 版本把 `sqlite3` 换成 `json.load(open(r"step03_pip\all_cells.json"))` 即可（行字段同名）。

---

## 9. 术语与外对应

| 本项目 | 含义 | Xilinx 侧 / 英文 |
|---|---|---|
| `family` | 一个 mux 或长线驱动器的**输出 wire** | mux output wire / segment driver（非官方术语） |
| `src_wire` | 该 mux 的某个**输入 wire** | mux input wire |
| `feature` | 一条 PIP = (输出 wire, 输入 wire) | PIP (programmable interconnect point) |
| `cell` | 一个 CRAM 位 `(frame_off, parity, bit)` | configuration memory bit / CRAM cell |
| pattern | 一条 feature 对应的置位集合 | —（本项目术语） |
| `BEG→END` | tileconn 固定连接，**不是** mux | tile-to-tile fixed connection |

【硬件事实】`BEG→END`（如 `EE2BEG0 → EE2END0`）在 7 系列是**固定的 tile 间直连**，由 geometry 决定，不占 CRAM 位；
把它当成可配置 mux 会得出「少了一族」的错觉。
