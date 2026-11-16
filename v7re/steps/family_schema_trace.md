# family 字段溯源：它是导入的名字，不是脚本聚出来的

任务：定位 `pip_reuse_law.json` 中 `family` 字段的 schema 定义与写入代码，判定它是**外部导入**还是**脚本聚类生成**。
日期：2026-11-08。证据口径：每条结论后带 `路径:行号`，无行号的不写。

---

## 0. 结论

**`family` 是外部导入的名字（Vivado 的 PIP 目的 wire 名），不是本项目聚出来的。**

- 【硬件事实】`IMUX_L34` / `BYP_ALT0` / `WW4BEG0` 是 **PIP 的目的 wire（sink）名**，由 Vivado 器件描述给出。
- 【数据事实】项目侧对 `family` 只做三件事：**过滤前缀、排序、原样写进 JSON**。全链路没有任何一处把它改名、拼接或聚类合并。
- 【推断】「family」这个**词**是本项目的分析单位；它指「同一个目的 wire 的全部源 PIP」。Xilinx 自己不叫 family。

追溯链（单向，无回环）：

```
Vivado 器件描述                    本仓库代码                                   产物
get_pips 输出 (_full8.pips)  ┐
                             ├─→ (核对用，不入库)
INT_L.json pip_defs[1]       ┘
prjxray segbits_int_{l,r}.db ─→ gen_all_cells.py:39 ─→ all_cells.json:49
                                                          │
                                                    law_db.py:314 (INSERT)
                                                          ↓
                                             v7_law.sqlite / law_cells.family
                                                          │
                                              pip_reuse_law.py:68/77/107
                                                          ↓
                                          v7re/steps/pip_reuse_law.json / families
```

---

## 1. 溯源表（字段 → 写入代码 → 来源）

| # | 字段 | 写入代码（路径:行） | 数据来源 | 性质 |
|---|---|---|---|---|
| 1 | `pip_reuse_law.json` 的 `/families` 对象 | `v7re/scripts/pip_reuse_law.py:107` `out["families"][fam] = {`；初始化 `:76` `"families": {}`；落盘 `:242-243` `json.dump(model, fh, ...)` | 键 `fam` 来自 `:77` `for fam in families:`，而 `families` 定义在 `:68` `families = sorted({f for (f, s) in cells if f.startswith(MUX_PREFIX)})` | **导入**（只过滤+排序） |
| 2 | 过滤条件 | `v7re/scripts/pip_reuse_law.py:36` `MUX_PREFIX = ("IMUX", "BYP_ALT", "FAN_ALT")` | 硬编码前缀，用于把 mux 区族从 `law_cells` 里挑出来 | 生成侧唯一动作（不改名） |
| 3 | `law_cells.family` | `v7re/export/law_db.py:314` `con.executemany("INSERT OR REPLACE INTO law_cells VALUES (?,?,?,?,?,?,?,?)", payload)`；payload 组装在 `:308-313`；schema 在 `:37-47`（`family TEXT NOT NULL`，PK 含 family） | `:304` `cells = load_cells(a.cells)` → `:183-190` 逐条 `c["family"]`（`:187`）；默认输入 `:31` `DEFAULT_CELLS = step03_pip/all_cells.json` | **导入** |
| 4 | `all_cells.json[].family` | `step03_pip/gen_all_cells.py:49` `"family": family,` | 变量绑定在 `:39` `_t, family, src = seg`，`seg` 来自 `:36` `feat.split(".")`；输入 `:5` `prjxray_ref/artix7/segbits_int_{l,r}.db`，格式 `:6` `INT_L.<mux>.<src> <word>_<bit> ...` | **导入**（字面拷贝） |
| 5 | prjxray 行里的第 2 段 | 数据文件本体 | `prjxray_ref/artix7/segbits_int_l.db:1305` `INT_L.IMUX_L34.BYP_BOUNCE_N3_6 21_21 !22_21 !23_21 !24_21 25_21`；INT_R 对应 `segbits_int_r.db:1697` `INT_R.IMUX34.BYP_BOUNCE_N3_6 21_21 !22_21 !23_21 !24_21 25_21` | **导入**（prjxray 抄 Vivado） |
| 6 | 名字的器件侧本体 | — | `_full8.pips`（308 行，Vivado 2017.2 `get_pips -of_objects` + `get_property NAME`，见 `_t1b_build.sh:37-39`、`:44`）；器件模板 `E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json` 的 `pip_defs` 每行 `[src_wire, dst_wire, 0, False]`，**dst 是元素 [1]** | **外部真名** |

> 注：`pip_defs` 的行序容易被读反。首轮按 `[0]` 取 dst 曾得出「`IMUX_L34` 在模板里不存在」的假否定；按 `[1]` 取才是目的 wire。样例行 `['BYP_BOUNCE0', 'IMUX_L10', 0, False]` 即 `BYP_BOUNCE0 → IMUX_L10`。

---

## 2. 判定：导入，不是生成（含反证）

**A2 结论：外部导入。** 依据三条，且已检查过反方向（即「有没有聚类代码」）：

1. **写法上不存在改名点。** `v7re/scripts/pip_reuse_law.py` 全文 255 行、`step03_pip/gen_all_cells.py` 全文 86 行逐行看过：`family` 只出现在「读取、`startswith` 过滤、`sorted` 排序、原样写回」四种位置，没有任何 `family = ...` 的字符串构造或 `+` 拼接。
   - `pip_reuse_law.py:68` 是 `sorted({...})`，集合推导体是 `f`（原值），不是 `f"..."`。
   - `gen_all_cells.py:39` 是解包赋值，`:49` 是写回；`:74` 有 `r["family"].replace("_L", "")`，但只用于**打印计数**（`imux` 变量），不参与落盘。
2. **反例对照说明「构造名」长什么样。** 同仓库确实存在一种**本项目构造**的 family：`step03_pip/gen_site_cells.py:12` 注释 `family = "<SITE_INST>.<BEL>"，如 "SLICEL_X0.AFFMUX"`，实现 `:49` `family = f"{site_inst}.{bel}"`。这是 f-string 拼接、进的是 `clb_cells` 表（`v7re/export/law_db.py:82-95` 建表、`:118` 输入 `site_cells.json`、`:368-369` 写入），**与 `pip_reuse_law.json` 无数据通路**。PIP 链路的代码里没有这种拼接。
3. **名字在项目代码之外独立存在。** 见 §3：同一个字符串在 Vivado 的 `get_pips` 输出与器件路由模板里都出现，且在 prjxray 里以 `<TILE>.<WIRE>.<SRC>` 形式出现。如果名字是脚本造的，这三处不可能同时命中，更不可能源集合一一对应（§3 第 3 条）。

---

## 2.1 检索覆盖（用于排除「另有一个聚类脚本」）

检索范围与关键词：

| 检索 | 范围 | 结果 |
|---|---|---|
| `grep '"families"'` | 整个 `v7re/` 树 | 41 处命中；**写** `pip_reuse_law.json` 的 `families` 的只有 `v7re/scripts/pip_reuse_law.py:76/:107/:242`，其余全是**读**（`bitwriter.py:95`、`fasm2bit.py:76`、`roundtrip.py:77`、`t51_generative_law.py`、`verify_*.py` 等） |
| `grep "家族\|cluster"` | `*.md`、`v7re/steps/*.md`、`step03_pip/*.md` | **排除本文件自身**后零命中（本文件因为要讨论「是不是聚类」而含该词；写入前已跑过一次，原始命中为 0） |
| 全目录列 `v7re/steps` | 全部 `.py`/`.json` | 无第二个写 `families` 键的脚本 |

---

## 3. 名字真伪：三层独立核对（都是实测，不是引用）

| 层 | 数据源 | 复算结果 |
|---|---|---|
| L-a Vivado 运行时 | `_full8.pips`（90 个 tile、145 个线名、100 个不同 dst 族；其中 INT_L 70 个 tile） | `IMUX_L34` 出现在 **9 个不同 tile**：`:194` `INT_L_X8Y20/INT_L.WR1END1->>IMUX_L34`、`:208` `INT_L_X32Y6/INT_L.BYP_BOUNCE0->>IMUX_L34`、`:222` `INT_L_X32Y7/INT_L.SL1END1->>IMUX_L34`、`:237` `INT_L_X32Y8/FAN_BOUNCE7`、`:250`/`:265`/`:278`/`:293`/`:305`（X32Y9..13） |
| L-b 器件路由模板 | `templates/INT_L.json` `pip_defs` 的目的线（元素 [1]） | distinct dst = **216**；`IMUX_L34` = **25** 条；`WW4BEG0` = **20**；`BYP_ALT0`/`FAN_ALT0` 各 **25**；`CLK_L0` = **16**；`IMUX*` 共 **48** 个 dst |
| L-c 集合等价 | `law_cells`(INT_L) 的 172 个 family vs 模板 216 个 dst | **172 个全部命中**（`law families not in template dst: []`）；模板多出 44 个是「无实测位数据」的族 |

**最硬的一条：`IMUX_L34` 的源集合在两侧是同一个对象。**

```
模板 dst=IMUX_L34 的 source 数：25
law_cells sense=1 的 source 数：24
in template not in law：['VCC_WIRE']
in law not in template：[]
```

差的恰好只有 `VCC_WIRE`——一个常量/虚拟源，没有配置位。也就是说：
**family `IMUX_L34` ≡ 目的 wire `IMUX_L34` 的全部 PIP（24 条有位 + 1 条无位）**，名字与对象 1:1。

再看 L/R 命名差异（这是最容易被误当成「我们编的」的地方）：

```
segbits_int_l.db:1305   INT_L.IMUX_L34.BYP_BOUNCE_N3_6 21_21 !22_21 !23_21 !24_21 25_21
segbits_int_r.db:1697   INT_R.IMUX34.BYP_BOUNCE_N3_6   21_21 !22_21 !23_21 !24_21 25_21
```

两边**位完全一样，只是名字差一个 `_L`**；而且 INT_R 侧无名后缀不是项目改的，模板 `INT_R.json` 的目的线里本来就叫 `IMUX34`（25 个 source），`IMUX_L34` 在 INT_R 模板里**不存在**。可见 `_L` / 无后缀是 **Vivado 对左右两侧 tile 的线命名约定**，prjxray 与项目都只是照抄。

---

## 4. 为什么不同的 tile 都有同一个 family

【数据事实】两层原因，一层是 schema，一层是器件实例数：

1. **schema 里没有坐标列。** `law_cells` 实际列（PRAGMA 实测）：`tile_type, family, src_wire, frame_off, bit, sense, parity, src_index`，主键 `(tile_type, family, src_wire, frame_off, bit)`（DDL：`v7re/export/law_db.py:37-47`）。全程没有 `col` / `y` / tile 实例名——`family` 只挂在 `tile_type` 上，天然是**类型级**名字。`all_cells.json` 同理（`gen_all_cells.py:47-57` 只写 tile_type/family/src_wire/frame_off/bit/sense/parity）。
2. **该类型在器件里有 26,550 个实例。** `law_tiles` 实测：`INT_L` 26,550、`INT_R` 26,550（全库 62,625）。每个实例内部是同一张 216 条目的开关盒图纸，所以同名是必然，不是巧合。

【推断】于是「同一个 family 出现在不同 tile」的正确读法是：**同一张图纸的复印件，各印各的位**。同位问题（相对布局可复用、绝对位点不可复用）由 `v7re/steps/t2b_pair_detail.md` 与 `STATUS.md` §104–§105 负责，本报告不重复判定。

---

## 5. 必须区分的三个「family」（同名不同物）

本例的最大风险是把这三者混成一个词：

| 出处 | family 是什么 | 名字性质 | 证据 |
|---|---|---|---|
| `pip_reuse_law.json` / `law_cells`（INT） | 一个目的 wire 的全部源 PIP | **导入**（Vivado 线名） | `pip_reuse_law.py:107`、`law_db.py:314` |
| `clb_cells`（CLB site 内） | `<SITE_INST>.<BEL>`，如 `SLICEL_X0.AFFMUX` | **本项目构造**（f-string） | `gen_site_cells.py:12`、`:49`；`law_db.py:82-95`、`:118` |
| `beg_families.json` | 帧 2..7 内、源数 ≥12 的 BEG 族 | **导入**（键仍取自 `law_cells.family`） | `v7re/scripts/beg_families.py:34-36`（select）、`:40-44`（筛选）、`:111`（`out[fam]=...`）、`:126`（落盘） |

结论一句话：**只有 INT mux 区和 BEG 区的 family 是器件真名；CLB site 区的 family 是本项目按 `<site>.<bel>` 造的复合名，不能拿它反推器件结构。**

---

## 6. 与 STATUS §108 的一致性

`STATUS.md:3664-3682` §108 已给出同方向结论「名字是真的，分组概念是我们的」，并写了三个数字：90 tile / 145 线名（`:3671`）、216 个目的线名（`:3672`）、26,550 实例（`:3677`）。本次**独立复算**三个都成立：`_full8.pips` 90 tile / 145 线名；模板 dst 216；`law_tiles` INT_L 26,550。§108:3676「172 个 family 是 216 的子集」也已复算（`law families not in template dst: []`）。

本报告相对 §108 新增的是**代码侧溯源**：字段级写入点（`pip_reuse_law.py:107` ← `:68` ← `law_db.py:314` ← `gen_all_cells.py:39/49`）与「无改名点」的反证检查（§2），以及 `IMUX_L34` 源集合 25 vs 24（差 `VCC_WIRE`）这一条名字-对象 1:1 的量化证据。

---

## 7. 未验证 / 边界

1. **bit 位置不是本报告结论。** 本报告只判名字与 schema；`frame/word/bit` 的正确性由 `t2b_pair_detail.md` 与 §104–§105 负责。跨器件样本（名字曾在 artix7 上取，位在 V7 上核）这一前提在 §104/§105 已显式声明，此处沿用。
2. **`family` 一词在别的产物里可能另有所指**（如 `beg_families.json` 的 `families` 按帧窗口筛过、`t51_generative_law.py:131` 又读它）。本报告只判定 `pip_reuse_law.json` 的 `families` 与其上游 `law_cells.family`。
3. **未逐个核对 216 个 dst 名的全部源集合**，只对 `IMUX_L34` 做了 1:1 等价核对（其余用集合包含关系 172⊆216 覆盖）。若要把「172 族全部 1:1」升为事实，需对 172 族各跑一次源集合比对——目前是**未验证**。
4. **`law_ppips` 216 行**与模板 216 个 dst 名数量相同，纯属巧合，未发现任何代码把它们关联，不做推断。

---

## 8. 复现命令

```powershell
# 1) 字段写入点
Select-String -Path 'v7re\scripts\pip_reuse_law.py' -Pattern 'out\["families"\]|MUX_PREFIX|sorted\(\{f for'
Select-String -Path 'v7re\export\law_db.py' -Pattern 'INSERT OR REPLACE INTO law_cells'
Select-String -Path 'step03_pip\gen_all_cells.py' -Pattern '"family"|_t, family, src'

# 2) 名字在器件侧存在（模板 dst = pip_defs 元素 [1]）
@'
import json,collections
d=json.load(open(r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json",encoding="utf-8"))
c=collections.Counter(x[1] for x in d["pip_defs"])
print(len(c), c["IMUX_L34"], c["WW4BEG0"])
'@ | Out-File -Encoding utf8 _chk.py; python _chk.py; Remove-Item _chk.py
# 输出：216 25 20

# 3) law 族 ⊆ 模板 dst，且 IMUX_L34 源集合只差 VCC_WIRE
@'
import json,sqlite3
tpl=json.load(open(r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json",encoding="utf-8"))
dst={x[1] for x in tpl["pip_defs"]}
con=sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro",uri=True)
fams={r[0] for r in con.execute("select distinct family from law_cells where tile_type='INT_L'")}
print("172 族未命中：",sorted(fams-dst))
t={x[0] for x in tpl["pip_defs"] if x[1]=="IMUX_L34"}
l={r[0] for r in con.execute("select distinct src_wire from law_cells where tile_type='INT_L' and family='IMUX_L34' and sense=1")}
print("模板源",len(t),"law源",len(l),"差",t-l)
'@ | Out-File -Encoding utf8 _chk2.py; python _chk2.py; Remove-Item _chk2.py
# 输出：172 族未命中：[]  /  模板源 25 law源 24 差 {'VCC_WIRE'}
```

文件哈希（本次核对时）：

| 文件 | 字节 | sha256 |
|---|---|---|
| `v7re/steps/pip_reuse_law.json` | 75,983 | `c267c827c487a5af1ea3cadf830ecc73b4dc29df1fa639f30c6b2e56151f1de4` |
| `step03_pip/all_cells.json` | 2,973,032 | `2f1de13f35f4afd43afde9eb4f2fa6fbc6dfbeb56ba38019f1b0e956f93beb7b` |
| `step03_pip/site_cells.json` | 501,732 | `5926913a74887adbc209986da1c4e52dacf8f7abbf92d1a192584f07832d3d46` |
| `_full8.pips` | 15,622 | `fb058f6296de03141180812af24350915fb10ecb9d8db219d2800fb1739402a3` |

`pip_reuse_law.json` 关键字段实测：`tile_type="INT_L"`、`device="xc7vx485t"`、`version=1`、`families` 64 键（48 `IMUX_L*` + 8 `BYP_ALT*` + 8 `FAN_ALT*`）、`combo_check.families=64`、`distinct_combos=64`、`IMUX_L34={"pair":20,"parity":0,"primary":"S","slots":{...24 项...}}`。
