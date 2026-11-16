# T56 · 同类型 tile 的 PIP 相对位坐标可否跨实例复用

- 子任务：T2b（不新建工具，只用仓库已有解码产物）
- 输入：`_full8.bit`、`v7re/scripts/fasm2bit.py`、`v7re/steps/pip_reuse_law.json`、`E:\v7work\model\v7_law.sqlite`、`_full8.pips`
- 产物：本文 + `v7re/steps/t2b_full8_decode.fasm`（CLI 解码输出）+ `v7re/steps/t2b_pair_table.md`（附录表的机器生成版）
- 生成时间：2026-11-08

标注约定（本仓库强制）：`【硬件事实】` 手册/官方语义级；`【数据事实】` 本项目实测、可复算；`【推断】` 由数据反推、未被独立证伪。

---

## 0. 一句话结论

**【数据事实】在同类型 tile 之间，同一 PIP family + 同一源线的「相对位坐标」完全一致：31 个出现在 ≥2 个 tile 的 `(family, src)` 组合、跨 76 个 tile、共 220 个格，逐条比对 0 个例外；并且每个 tile 的 PIP 窗口内 458/458 位全部被同一张「无坐标表」解释干净，0 缺失、0 多余。**

**并且这与 Vivado 布线真值吻合：解码 190 条 PIP 全部命中真值、误判 0；Vivado 的 198 条中未解出的 8 条是零配置位的 `always` 型旁路连接（§3.1），按「有位可解」口径即 190/190。**

**因此：相对位坐标可以直接复用（`frame = tile_base(col, y) + frame_off`，`word = 2*(y%50) + parity`，`bit` 原样），不能复用的是绝对帧号。** 未覆盖范围与反例口径见 §6。

---

## 1. 术语与度量口径（先定坐标，再谈复用）

`law_cells` 表的键是 `(tile_type, family, src_wire, frame_off, bit)` + `sense`/`parity`/`src_index`，**没有 tile 坐标**（`v7re/export/law_db.py:37-47`）。所以「相对坐标」在本文定义为三元组：

```
相对格 = (frame_off, parity, bit)
绝对位 = (frame, word, bit) = (tile_base(col, y) + frame_off,  2*(y % 50) + parity,  bit)
```

- `tile_base(col, y)`：该 tile 所在列在所在 band 的首帧（`far_bands` 表；本 bitstream 全部 `y < 50`，即全在 band 0，`word_of` 的 `≥50 折返 +1` 分支未被触发）。
- **PIP 窗口（本文的判定域）**：某 tile 上 `/` 的 `frame_off ∈ [0,25]`（INT tile 的 mux 区，26 帧）× `word ∈ {2*(y%50), 2*(y%50)+1}`（两个 parity 字），每字 32 bit ⇒ **1,664 个位位置**。窗口之外（`frame_off 26..49`、其它 y 行、ECC 字 50）不属于 INT mux PIP，不参与本节判定。

这个定义是刻意的：如果某 tile 的 PIP 位落在别的相对位置，它要么让「观测集合 ≠ 预测集合」（产生 extra），要么让解码的精确匹配失败（产生 miss）。两种偏离都会被本节的量捉到。

---

## 2. A1 · 解码覆盖：76 tile / 85 family（命令行可复现）

### 2.1 命令与原始输出

```powershell
$env:PYTHONIOENCODING='utf-8'
python v7re\scripts\fasm2bit.py --in _full8.bit --decode --out v7re\steps\t2b_full8_decode.fasm
```

```
解出 191 行（INT/GCLK 190，CLB 1）→ v7re\steps\t2b_full8_decode.fasm
```

输出文件 191 行；其中 190 行是 INT PIP 特征（`TILE.family.src` 形），1 行是 CLB 侧（`SLICE_X12Y20.ALUT=0x…`，与本节无关，已排除）。

### 2.2 覆盖统计（第二条命令，可直接复算）

```powershell
python -c "L=[l.strip().split(':')[0].split('.') for l in open(r'v7re/steps/t2b_full8_decode.fasm',encoding='utf-8') if l.strip()];R=[x for x in L if len(x)==3];print('features',len(R),'tiles',len({x[0] for x in R}),'families',len({x[1] for x in R}))"
```

```
features 190 tiles 76 families 85
```

**【数据事实】明细**

| 量 | 值 |
|---|---|
| INT PIP 特征行 | 190 |
| 涉及 tile | **76**（`INT_L` 70，`INT_R` 6） |
| 涉及 family | **85** |
| 涉及列 | 17（INT_L：X8,10,12,…,32 共 13 列；INT_R：X9,11,15,19 共 4 列） |
| 涉及 y | 19 个值：0–16, 19, 20（**全部 < 50 ⇒ 单一 band**） |
| 涉及 base 帧 | 17 个：31752, 31788, 31824, 31860, 31888, 31960, 31988, 32024, 32096, 32132, 32168, 32232, 32296, 32368, 32432, 32496, 32568 |
| 每 tile 的 family 数 | 1 个族：41 tile；2：23；3：5；4：3；5：3；61：1（`INT_L_X8Y20`，IMUX 密集） |
| `(tile, family)` 重复 | 0 |
| 涉及格（cell）总数 | **458**（均值 2.41 格/特征） |

bitstream 侧底数：payload 帧 **50,181**（payload 5,068,281 字 / 101 字每帧），扣除 ECC 字 50 后置位 **1,151 位**，含 ECC 字为 1,701 位（ECC 550 位不参与语义）。

---

## 3. 判定方法：实测位 ↔ 无坐标表的双向对账

对每个 active tile：

1. 从 `_full8.bit` 直读该 tile 的 PIP 窗口实测位集 `W(tile)`（不经过解码器，纯 payload 扫描）；
2. 归一化：`N(tile) = { (f - base, w - 2*(y%50), b) | (f,w,b) ∈ W(tile) }`；
3. 预测：该 tile 上所有解码特征的格并集 `U(tile) = ∪ E(family, src)`，`E` 直接查 `law_cells`（无坐标表）；
4. 三个量同时成立才算通过：`N == U`（无缺无多）、`Σ|Eᵢ ∩ Eⱼ| = 0`（不同特征不共用位）、`|N| = Σ|Eᵢ|`。

**【数据事实】结果（76/76 tile 全部通过）**

| 判据 | 结果 |
|---|---|
| 预测格总数 / 实测命中 | **458 / 458** |
| 未命中的记录数 | **0** |
| `N(tile) == U(tile)` 的 tile 数 | **76 / 76** |
| 特征间位重叠（应 0） | **0** |
| 窗口内多余位（应 0） | **0** |
| 窗口内缺失位（应 0） | **0** |

这一步的非平凡性要说清：**解码器只做「域内精确匹配」，它不检查域外残余**（`v7re/scripts/fasm2bit.py:217-260` 的 `obs = domain ∩ rawbits`，仅当 `obs` 恰等于某源模式时才输出）。所以「0 多余」不是解码器自带的保证，而是本次独立扫描 payload 得到的。**如果某 tile 的 PIP 位相对坐标不同，这个 tile 的 `N` 就会与 `U` 不等，或者该特征根本解不出来。**

### 3.1 上界校验：与 Vivado 布线真值对账

解码结果必须与「Vivado 实际布了哪些 PIP」对得上，否则上面的一致性只是自我一致。`_full8.pips` 的格式是 `net TILE/TT.SRC->>DST`（`->` 单线为非 PIP 直连，本次 76 行，不参与），其中 **DST 就是 family（汇线），SRC 是驱动线**。

```powershell
python -c "T=set();[T.add((l.split()[-1].split('/')[0], l.split('/')[1].split('->>')[1], l.split('/')[1].split('->>')[0].split('.',1)[1])) for l in open(r'_full8.pips',encoding='utf-8') if '->>' in l and l.split()[-1].startswith('INT_')];print('truth pips',len(T),'tiles',len({t for t,_,_ in T}))"
# → truth pips 198 tiles 76
```

**【数据事实】**

| 量 | 值 |
|---|---|
| Vivado 真值（INT tile，双箭头） | **198** 条，覆盖 **76** 个 tile（与解码的 tile 集合完全相同） |
| 解码 190 条中命中真值 | **190（precision = 100%）** |
| 误判（解码出、Vivado 没布） | **0** |
| 漏解（Vivado 布了、解码没出） | **8** |

8 条漏解全部是同一形状：

```
INT_L_X32Y10  BYP_BOUNCE0 ← BYP_ALT0     INT_L_X8Y20  BYP_BOUNCE1 ← BYP_ALT1
INT_L_X32Y12  FAN_BOUNCE7 ← FAN_ALT7     INT_L_X8Y20  BYP_BOUNCE3 ← BYP_ALT3
INT_L_X32Y6   BYP_BOUNCE0 ← BYP_ALT0     INT_L_X8Y20  BYP_BOUNCE4 ← BYP_ALT4
INT_L_X32Y8   FAN_BOUNCE7 ← FAN_ALT7     INT_L_X8Y20  BYP_BOUNCE5 ← BYP_ALT5
```

它们在 `law_ppips` 里是 **`always` 型伪 PIP**（`BYP_BOUNCE*←BYP_ALT*`、`FAN_BOUNCE*←FAN_ALT*` 共 64 条全为 `always`；另有 32 条 `BYP_ALT*/FAN_ALT*←VCC_WIRE` 为 `default`）——**没有配置位**，所以既不可能解出、也不可能产生残余位。**因此「190/198」不是 8 个坐标错误，而是 8 条零位连接**；按「有位可解」的口径，本次等价于 **190/190 = 100%**。

---

## 4. A2 · 逐条比对：同一 family 在不同 tile 上是否落在同一相对格

### 4.1 全量统计

| 量 | 值 |
|---|---|
| 去重 `(family, src)` 组合 | 117 |
| 其中出现在 ≥2 个 tile 的组合 | **31**（覆盖 220 个格，占 458 的 48.0%） |
| 其中只出现在 1 个 tile 的组合 | 86 |
| **相对格集合在不同 tile 上不一致的组合** | **0** |
| 同一 family 内「不同 src 相对格集合相同（撞车）」的情况 | **0** |

最后一条很重要：族内各源的格集合两两可区分 ⇒ 观测到的相对格集合是 **src 的函数，与 tile 无关**；这也解释了为什么解码能唯一定源（全 bitstream 76 tile 唯一解，STATUS §94）。

### 4.2 反证对照：绝对坐标随 tile 变，相对坐标不变

| `(family, src)` | tile 数 | 不同 `(base, y)`（绝对落点） | 不同相对格集合 |
|---|---|---|---|
| `WW4BEG0 / WW4END0` | 14 | **14** | **1** |
| `NW6BEG0 / NW6END0` | 13 | **13** | **1** |
| `IMUX_L34 / SR1BEG_S0` | 2 | **2** | **1** |
| `LH12 / EE4END3` | 2 | **2** | **1** |

**【数据事实】同一 PIP 在 14 个不同列/行上的绝对帧号 14 种、相对格 1 种。** 这就是「绝对坐标不可复用、相对坐标可复用」的直接对照实验（同一份数据、同一批位，只换坐标口径）。

### 4.3 逐条明细（抽 6 个 ≥5 tile 或多个源的 family）

`(frame_off, parity, bit)` 为归一化相对格；`base` 是该 tile 的绝对首帧，`y` 是 tile 行号。

**`WW4BEG0`（22 个 tile，4 个源，22 条记录）**

| tile | src | base | y | 实测相对格 |
|---|---|---|---|---|
| `INT_L_X12Y19` | `WW4END0` | 31888 | 19 | (3,0,1) (5,0,0) |
| `INT_L_X14Y20` | `WW4END0` | 31960 | 20 | (3,0,1) (5,0,0) |
| `INT_L_X24Y16` | `WW4END0` | 32296 | 16 | (3,0,1) (5,0,0) |
| `INT_L_X32Y7` | `NN6END0` | 32568 | 7 | (5,0,3) (6,0,0) |
| `INT_R_X15Y20` | `WW4END0` | 31988 | 20 | (3,0,1) (5,0,0) |
| `INT_R_X19Y20` | `NW2END0` | 32132 | 20 | (2,0,1) (3,0,1) |

判定：同一 src（`WW4END0`）在 14 个 tile（13 个 `INT_L` + 1 个 `INT_R`、y ∈ {15,16,19,20}、**8 个不同 base**）**全部为 (3,0,1)+(5,0,0)**；不同 src 落到不同格集合，且各 src 的集合在跨 tile 上仍然唯一。**一致。**

**`NW6BEG0`（21 个 tile，5 个源，21 条记录）**

| tile | src | base | y | 实测相对格 |
|---|---|---|---|---|
| `INT_L_X22Y15` | `NW6END0` | 32232 | 15 | (2,0,2) (7,0,3) |
| `INT_L_X30Y4` | `NW6END0` | 32496 | 4 | (2,0,2) (7,0,3) |
| `INT_L_X28Y11` | `NW6END0` | 32432 | 11 | (2,0,2) (7,0,3) |
| `INT_L_X26Y7` | `WW2END_N0_3` | 32368 | 7 | (2,0,2) (2,0,3) |
| `INT_L_X32Y0` | `LOGIC_OUTS_L18` | 32568 | 0 | (5,0,1) (7,0,3) |

判定：`NW6END0` 跨 13 个 tile（y=4…16，5 个 base）**全部为 (2,0,2)+(7,0,3)**。**一致。**

**`IMUX_L34`（9 个 tile，5 个源）**——这是唯一带「4 格」模式的高密度 mux：

| tile | src | 实测相对格 |
|---|---|---|
| `INT_L_X32Y13` | `SR1BEG_S0` | (17,0,21) (23,0,21) (24,0,21) (25,0,21) |
| `INT_L_X32Y9` | `SR1BEG_S0` | (17,0,21) (23,0,21) (24,0,21) (25,0,21) |
| `INT_L_X32Y10` | `BYP_BOUNCE0` | (21,0,21) (24,0,21) |
| `INT_L_X32Y8` | `FAN_BOUNCE7` | (21,0,21) (23,0,21) (24,0,21) (25,0,21) |
| `INT_L_X8Y20` | `WR1END1` | (19,0,20) (23,0,21) (24,0,21) (25,0,21) |

判定：同一 src 跨 tile 逐位相同；且**不同的 4 格集合共享 (24,0,21)(25,0,21) 两个格**——注意这不是撞车：解码在族内按「整个集合精确相等」判定，共享格不产生歧义（族内不同源集合仍两两不等，见 §4.1 最后一行）。**一致。**

**`EE4BEG1`（9 个 tile，4 个源）**：`EE4END1` 在 5 个 tile（base 31888/32232/32368，y=12、20…）全部为 `(3,0,25)(5,0,24)`；`SE6END1` 在 2 个 tile 全部为 `(3,0,25)(6,0,24)`；`EE2END1` 为 `(3,0,24)(3,0,25)`；`LOGIC_OUTS_L9` 为 `(3,0,24)(4,0,26)`。**一致。**

**`LH12`（2 个 tile，1 个源，parity=1 的样例）**：`INT_L_X12Y20`（base 31888）与 `INT_L_X14Y20`（base 31960）均为 `(1,1,28)(1,1,30)`。**一致。**（这里 `parity=1`，说明「字 = 2y / 2y+1」两支在本数据里都被覆盖，不是只测了 parity=0。）

**`WR1BEG1`（3 个 tile，3 个源，跨 L/R）**：`INT_L_X10Y20`→`WW4END0`：`(8,0,2)(12,0,3)`；`INT_R_X11Y20`→`NW2END0`：`(8,0,3)(15,0,3)`；`INT_R_X9Y20`→`WW2END_N0_3`：`(8,0,2)(15,0,3)`。**一致（且证明 INT_R 与 INT_L 用同一归一化规则）。**

### 4.4 全部 31 个多 tile 组合

见附录 A（机器生成，同 `v7re/steps/t2b_pair_table.md`）。31 行中 31 行判定为「一致」，0 行不一致。

---

## 5. 与「CLB 配置位」的口径切割（防止误读）

本文测的是 **INT tile 的 mux PIP 选择位**：`frame_off ∈ [0,25]`，`word = 2*(y%50)+parity`。

不是以下两者：

| 对象 | 帧域 | 证据 |
|---|---|---|
| CLB 配置位（LUT INIT 真值表） | CLB 块 `base+32..35`，word 40 数据 / 50 ECC | T55 判定；`_xcheck.sh` 只改 INIT |
| CLB site PIP（`IMUXx→A_pin`） | CLB 块 `off 16..25` | `step03_pip/FPGA_UNITS_MUX_FULL.md:254` |

**【数据事实】本 bitstream 的 458 个 PIP 位全部落在 76 个 `INT_*` tile 的帧区间内（0 个落在 CLB tile 上）**，且**没有任何一个 PIP 位落在 T55 实测的 CLB INIT 变化帧（31712–31715、31956–31959）里：交集计数 = 0**。判据用 `(tile, frame_off)` 而不是「帧号区间」——不同列/块的帧号在数值上可能相邻甚至交错（例：`INT_L_X14Y20` 的 base 31960 紧邻 CLB 块的 31924–31973），所以「帧号区间不重叠」不是一个有效论述。

所以本文结论不能拿去支持/否定「INIT 是否可移植」——那是 T54/T55 的对象。

---

## 6. A3 · 结论、反例与未覆盖范围

### 6.1 结论

**【数据事实】同类型 tile（同 `tile_type`：INT_L 内部、INT_R 内部，以及 L↔R 之间）的 PIP 相对位坐标可直接复用。** 适用范围：本 bitstream 触发的 85 个 family、117 个 `(family, src)` 组合、458 个格、76 个 tile、17 列、19 个 y 值。

复用公式（对任意同类型 tile 直接用）：

```
frame = tile_base(col, y) + frame_off
word  = 2 * (y % 50) + parity      # y >= 50 时本数据未验证
bit   = bit
```

### 6.2 反例

**在 31 个跨 tile 组合、220 个格中，反例 0 个。** 且四个更强的判据也没有反例：族内源集合无撞车（0）、窗口无多余位（0）、窗口无缺失位（0）、与 Vivado 真值的误判 0（§3.1）。

### 6.3 未覆盖范围（按影响排序）

| # | 未覆盖 | 事实/边界 | 能否推出「坐标不同」 |
|---|---|---|---|
| U1 | 8 个旁路 family（`BYP_BOUNCE0/1/3/4/5`、`FAN_BOUNCE7`）在 `_full8.pips` 中出现但解不出 | 这 8 条是 **`always` 型伪 PIP**：`law_ppips` 中 `BYP_BOUNCE*←BYP_ALT*`、`FAN_BOUNCE*←FAN_ALT*` 全部为 `always`，**零配置位** ⇒ 不可能从位流解出，也不可能产生残余 | **不能。** 这不是坐标不一致，是「本来就没有位」。所以 §3 的 0 残余与它自洽 |
| U2 | 60 个只出现在 1 个 tile 的 family | 无第二个实例可比 | 不能 |
| U3 | `INT_R` 仅 6 tile、4 列（X9,11,15,19） | L↔R 之间只有 2 个组合同时出现（`WW4BEG0/WW4END0`、`WW2BEG3/WW4END_S0_0`），两组均一致 | 结论偏弱，但方向一致 |
| U4 | 全部 `y < 50`（单一 band） | `word_of` 的 `y%50 ≥ 25` 折返（word 50 之后 +1）在 PIP 域未被触发 | 不能，属未验证 |
| U5 | 未实例化列 / 未触发 tile | 已覆盖 X8（左边缘）与 X32（右边缘）；INT_L 共 13 个不同列（X8,10,…,32），INT_R 4 列。全器件 INT 列远多于此 | 不能 |
| U6 | `LL_OVERRIDE` 涉及的三族（`LV_L18`、`LH0`①、`LV_L0`） | 本 bitstream 无此类布线 | 不能；这三族的数据是**器件特定实测**而非 prjxray 迁移值（`law_db.py:316-347`），复用性需另测 |
| U7 | 单设计、单 bitstream | 一个 `_full8.bit` | 不能做多设计交叉 |

① `LH0` 在本 bitstream 中作为 **源线**（`EE4BEG3 / LH0`）出现过 2 次且一致；作为 **family**（被 LL_OVERRIDE 改写的那个）未出现。两者不要混。

### 6.4 循环性声明（必须写清，否则结论会被高估或低估）

`law_cells` 的 `frame_off/bit/parity` **不是**从 `_full8.bit` 反推出来的：`v7re/export/law_db.py:304` 灌入的 `step03_pip/all_cells.json` 由 `step03_pip/gen_all_cells.py:3` 从 **prjxray artix7** 的 `segbits_int_{l,r}.db` 全量转换而来（`gen_all_cells.py:24,5`），只有 `LL_OVERRIDE/LL_DELETE` 那 8 行为 V7 实测覆盖。

因此 §3、§4 的「0 残余」**不是**同一批语料上的自洽，而是：

- **跨器件**：artix7 参考库的相对格 → 直接落到 V7 器件上，458/458 命中；
- **跨 tile**：同一张无坐标表 → 76 个不同 (col, y) 的 tile，含 L/R 两侧。

由于表里根本没有 tile 维度，只要有任何 tile 的相对坐标与参考库不同，该 tile 必然出现 miss 或 extra。76/76 全通过 ⇒ 在本数据覆盖范围内「相对坐标与 tile 位置无关」这条假设**没有被证伪**。

反向的夸大也要挡住：**这不能证明「所有 PIP 在所有 tile 上都可移植」**，只能证明「prjxray 建模的族、在 V7 上被本设计触发的那部分，是可移植的」；U1–U7 未覆盖部分不得外推。

---

## 7. 复现命令（全部为既有脚本/既有产物）

```powershell
# 1) 解码（CLI，唯一入口）
$env:PYTHONIOENCODING='utf-8'
python v7re\scripts\fasm2bit.py --in _full8.bit --decode --out v7re\steps\t2b_full8_decode.fasm
#    → 解出 191 行（INT/GCLK 190，CLB 1）

# 2) 覆盖统计
python -c "L=[l.strip().split(':')[0].split('.') for l in open(r'v7re/steps/t2b_full8_decode.fasm',encoding='utf-8') if l.strip()];R=[x for x in L if len(x)==3];print('features',len(R),'tiles',len({x[0] for x in R}),'families',len({x[1] for x in R}))"
#    → features 190 tiles 76 families 85

# 3) 真值对账（Vivado 布的 PIP：INT tile 双箭头 198 条 / 76 tile）
python -c "T=set();[T.add((l.split()[-1].split('/')[0], l.split('/')[1].split('->>')[1], l.split('/')[1].split('->>')[0].split('.',1)[1])) for l in open(r'_full8.pips',encoding='utf-8') if '->>' in l and l.split()[-1].startswith('INT_')];print('truth pips',len(T),'tiles',len({t for t,_,_ in T}))"
#    → truth pips 198 tiles 76
```

§3、§4 的实测-预测对账需要读 payload 并查 `law_cells`，代码量约 40 行（见附录 B，可按需粘进交互式 python；本次未落盘为新脚本，遵守「不新建工具」）。附录 B 的片段已按原样跑通，输出为：

```
pairs 117 multi 31 cells 458 hit 458 rel-set-variants 1
```

---

## 附录 A · 全部 31 个跨 tile `(family, src)` 组合

`cells` 为格数；相对格记作 `(frame_off, parity, bit)`。

| family | src | tiles | cells | 相对格 | 判定 |
|---|---|---|---|---|---|
| `WW4BEG0` | `WW4END0` | 14 | 2 | (3,0,1) (5,0,0) | 一致 |
| `NW6BEG0` | `NW6END0` | 13 | 2 | (2,0,2) (7,0,3) | 一致 |
| `EE4BEG0` | `EE4END0` | 6 | 2 | (3,0,9) (5,0,8) | 一致 |
| `WW4BEG0` | `NW6END0` | 6 | 2 | (3,0,1) (6,0,0) | 一致 |
| `EE4BEG1` | `EE4END1` | 5 | 2 | (3,0,25) (5,0,24) | 一致 |
| `EE4BEG2` | `EE4END2` | 4 | 2 | (3,1,9) (5,1,8) | 一致 |
| `SE6BEG1` | `EE4END1` | 4 | 2 | (2,0,26) (4,0,27) | 一致 |
| `SE6BEG2` | `EE4END2` | 4 | 2 | (2,1,10) (4,1,11) | 一致 |
| `NN6BEG0` | `LOGIC_OUTS_L18` | 3 | 2 | (6,0,6) (7,0,7) | 一致 |
| `NW6BEG0` | `LOGIC_OUTS_L18` | 3 | 2 | (5,0,1) (7,0,3) | 一致 |
| `BYP_ALT0` | `EE2END0` | 2 | 2 | (18,0,6) (24,0,7) | 一致 |
| `EE2BEG0` | `SS6END0` | 2 | 2 | (9,0,7) (13,0,6) | 一致 |
| `EE2BEG2` | `SE6END2` | 2 | 2 | (9,1,6) (13,1,6) | 一致 |
| `EE4BEG0` | `SE6END0` | 2 | 2 | (3,0,9) (6,0,8) | 一致 |
| `EE4BEG1` | `SE6END1` | 2 | 2 | (3,0,25) (6,0,24) | 一致 |
| `EE4BEG2` | `SE6END2` | 2 | 2 | (3,1,9) (6,1,8) | 一致 |
| `EE4BEG3` | `LH0` | 2 | 2 | (4,1,26) (5,1,24) | 一致 |
| `FAN_ALT7` | `EE2END2` | 2 | 2 | (19,1,1) (25,1,0) | 一致 |
| `IMUX_L34` | `BYP_BOUNCE0` | 2 | 2 | (21,0,21) (24,0,21) | 一致 |
| `IMUX_L34` | `FAN_BOUNCE7` | 2 | 4 | (21,0,21) (23,0,21) (24,0,21) (25,0,21) | 一致 |
| `IMUX_L34` | `SL1END1` | 2 | 4 | (18,0,20) (22,0,21) (24,0,21) (25,0,21) | 一致 |
| `IMUX_L34` | `SR1BEG_S0` | 2 | 4 | (17,0,21) (23,0,21) (24,0,21) (25,0,21) | 一致 |
| `LH12` | `EE4END3` | 2 | 2 | (1,1,28) (1,1,30) | 一致 |
| `NL1BEG_N3` | `WW4END0` | 2 | 2 | (8,0,1) (12,0,1) | 一致 |
| `NW6BEG0` | `NN6END0` | 2 | 2 | (5,0,2) (7,0,3) | 一致 |
| `NW6BEG0` | `WW4END0` | 2 | 2 | (2,0,2) (4,0,3) | 一致 |
| `SL1BEG1` | `SE6END1` | 2 | 2 | (10,0,25) (12,0,25) | 一致 |
| `SL1BEG3` | `SS6END3` | 2 | 2 | (7,1,24) (12,1,25) | 一致 |
| `SR1BEG_S0` | `SL1END3` | 2 | 2 | (8,1,31) (13,1,31) | 一致 |
| `SS6BEG0` | `EE4END0` | 2 | 2 | (4,0,12) (4,0,15) | 一致 |
| `WW2BEG3` | `WW4END_S0_0` | 2 | 2 | (11,1,30) (13,1,30) | 一致 |

## 附录 B · §3/§4 的复算片段（不落盘为脚本）

```python
import os,sys,collections
ROOT=r"E:\DEEPSEEK\FPGA比特流逆向"; sys.path.insert(0,os.path.join(ROOT,"v7re","scripts"))
import fasm2bit as F
data,sp,words=F.load_words(os.path.join(ROOT,"_full8.bit")); poff=F.payload_offset(words)
FW,EW=F.FRAME_WORDS,F.ECC_WORD; nf=(len(words)-poff)//FW
raw=set()
for f in range(nf):
    b=poff+f*FW
    for w in range(FW):
        if w==EW: continue
        v=words[b+w]
        while v:
            bit=(v&-v).bit_length()-1; raw.add((f,w,bit)); v&=v-1
m=F.Model(r"E:\v7work\model\v7_law.sqlite", os.path.join(ROOT,"v7re","steps","pip_reuse_law.json"),
          os.path.join(ROOT,"v7re","steps","ecc_model.json"), r"E:\v7work\model\v7_model.sqlite")
lines=[l.strip() for l in open(os.path.join(ROOT,"v7re","steps","t2b_full8_decode.fasm"),encoding="utf-8") if l.strip()]
bytile=collections.defaultdict(list)
for l in lines:
    s=l.split(".")
    if len(s)==3: bytile[s[0]].append((s[1],s[2]))
pair=collections.defaultdict(set); tiles=collections.defaultdict(set); nb=na=0
for tile in sorted(bytile):
    tt,base,y=m.tile_base(tile); yo=2*(y%50)
    win={(f,w,b) for (f,w,b) in raw if base<=f<=base+25 and w in (m.word_of(y,0),m.word_of(y,1))}
    rel={(f-base,w-yo,b) for (f,w,b) in win}          # (frame_off, parity, bit)
    U=set()
    for fam,src in bytile[tile]:
        E={(fo,par,b) for (fo,b,par) in m.cells_of(tt,fam,src)}
        pair[(fam,src)].add(tuple(sorted(E&rel))); tiles[(fam,src)].add(tile)
        nb+=len(E); na+=len(E&rel); U|=E
    assert rel==U, tile
multi=[k for k in tiles if len(tiles[k])>=2]
print("pairs",len(tiles),"multi",len(multi),"cells",nb,"hit",na,
      "rel-set-variants",max(len(pair[k]) for k in multi))
# → pairs 117 multi 31 cells 458 hit 458 rel-set-variants 1
```

---

## 修订记录

| 版本 | 时间 | 改动 |
|---|---|---|
| v1.0 | 2026-11-08 | 首版。A1/A2/A3 与 §6.4 循环性声明、U1–U7 未覆盖清单。 |

## 相关产物

- `v7re/steps/t2b_full8_decode.fasm`（CLI 解码输出，191 行）
- `v7re/steps/t2b_pair_table.md`（附录 A 的机器生成版）
- `v7re/steps/T55_OBJECT_JUDGMENT_INIT_VS_PIP.md`（口径切割的上游判定）
- `v7re/steps/T56_PIP_SWITCHBOX_EXPERIMENT_DESIGN.md`（T2 的实验设计，与本文互补：本文只判「坐标可否复用」，不设计实验）

