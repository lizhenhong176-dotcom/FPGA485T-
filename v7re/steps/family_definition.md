# family 定义澄清：名字是真的，分组是我们的；「不同 tile 同名」有两层机制

回答的问题（用户原话）：**family 到底是什么 / 为什么不同的 tile 都有同一个 / 是有真实名字还是自己假设的。**

证据口径：每条断言后附 `路径:行号`；无法确认的写「未验证」。
三色标注沿用 `AGENTS.md`：【硬件事实】= 手册/厂商工具级；【数据事实】= 本项目实测；【推断】= 由数据反推。

生成日期：2026-11-08。上游输入：`v7re/steps/family_schema_trace.md`（T1 溯源）、`v7re/steps/T2_NAME_PROVENANCE.md`（T2 命名核对）、`v7re/steps/t3_tilewise_table.md`（T3 逐 tile 核账）。
本文对上述三份的**新增**部分是：§1 的词条边界、§2.3 的术语反证、§3 的两层机制拆分、§4 的可复用性边界表，以及在 §4.3/§4.5 里把 T1 遗留项「172 族未逐族核对」补成逐族复算结果。

---

## 0. 结论（A1：首段即给答案，不留模棱两可）

**三句话：**

1. **名字是真的。** 每个 family 的字符串取自 Vivado 器件描述里的 **PIP 目的 wire 名**（`IMUX_L34`、`WW4BEG0`、`BYP_ALT0`…）。项目代码对它只做三件事：**按前缀过滤、排序、原样写回**，全链路没有一处改名、拼接或聚类合并（§2.1）。
2. **「family」这个词是我们起的。** Xilinx 的数据模型里只有 `(src wire, dst wire)` 的 PIP 边，没有「族」这个对象——器件模板 JSON 的顶层键只有 `type / wires / pips / wire_defs / pip_defs`，全文件 0 处 `family`（§2.3）。我们把「**同一个目的 wire 的全部源 PIP**」定为一个分析单位，命名为 family。
3. **所以是混合形态：名字官方，分组自造。** 这正是 T1（导入真名）与「分组是等价类」两种说法看似冲突的原因——**它们不在同一层**：字符串是厂商的，切分口径是我们的。

**「为什么不同 tile 都有同一个 family」一句话答案：**

> 因为命名空间是 **tile_type 级**的，不是实例级：`law_cells` 八列里没有任何坐标列，`family` 只挂在 `tile_type` 上；而 `INT_L` 这个类型在器件里有 **26,550 个实例**，每个实例内部都是同一张 216 条目的开关盒图纸。**同名 = 同一张图纸的复印件，各印各的位**（§3.1）。

**必须同时说破的第二层（否则会把假设当事实交付）：**

> 「两个 tile 归一化后格集合一样」**不能**当成「我们观测到两边布局相同」的证据。格表本身不含 tile 坐标，`cells_of()` 返回的就是 `(frame_off, bit, parity)`，所以归一化后必然相同——这是**查表恒等（构造性恒真）**，不是独立观测（§3.2）。真正有判别力的观测证据是位流读数：458 预测格 0 落空、6142 个「其他源」候选格 0 误亮、30 个 tile 窗口 0 残余（§3.3）。

| 你问的 | 直接答案 | 主证据 |
|---|---|---|
| family 是什么 | 一个**目的 wire（sink）**的全部源 PIP 之集合 | `v7re/scripts/pip_reuse_law.py:107`、`v7re/export/law_db.py:314` |
| 名字哪来的 | Vivado 线名，prjxray 抄进 segbits，项目字面拷贝 | `prjxray_ref/artix7/segbits_int_l.db:1305`、`step03_pip/gen_all_cells.py:39/49` |
| 是假设吗 | 名字不是；**「族」这个切分是** | 模板/DB 0 处 `family`（§2.3） |
| 为什么多 tile 同名 | 名字空间是类型级 + 该类型有 26,550 个实例 | `v7re/export/law_db.py:37-47`、`law_tiles` 实测 |
| 归一化后一样说明什么 | 说明表里没有坐标，**不说明**两次观测吻合 | `v7re/scripts/fasm2bit.py:113-130` |

---

## 1. 定义：本项目里「family」指什么

### 1.1 主用法（INT mux 区，也是本文与主线讨论的对象）

【推断】定义：**family ≡ 某个目的 wire；该族的成员 = 所有 `src → 该 dst` 的 PIP。**

- 概念上它是 mux 的**汇（sink）**，`src` 是它**选中的那一路输入**（`v7re/steps/t3_tilewise_table.md:43`）。
- 落盘两处：
  - `v7re/steps/pip_reuse_law.json` 的 `/families`（64 键 = 48 `IMUX_L*` + 8 `BYP_ALT*` + 8 `FAN_ALT*`；写点 `v7re/scripts/pip_reuse_law.py:107`）；
  - `v7_law.sqlite` 的 `law_cells.family`（INT_L **172** 族，写点 `v7re/export/law_db.py:314`）。
- **单位是类型级 `(tile_type, family)`，不是实例级**：`law_cells` 主键 `(tile_type, family, src_wire, frame_off, bit)`（`v7re/export/law_db.py:46`），没有列/行/实例名。

### 1.2 词条边界：三个「family」同名不同物（不拆开必然混用）

T1 已列过（`v7re/steps/family_schema_trace.md:123-127`），这里补上「能否反推器件结构」这一列：

| 出处 | family 指什么 | 名字性质 | 能否用来反推器件结构 |
|---|---|---|---|
| `law_cells` / `pip_reuse_law.json`（INT） | 一个目的 wire 的全部源 PIP | **导入真名**（Vivado 线名） | **能**（本文 §2、§3 的全部结论都建立在这一支上） |
| `clb_cells`（CLB site 内） | `<SITE_INST>.<BEL>`，如 `SLICEL_X0.AFFMUX` | **本项目构造**（f-string：`step03_pip/gen_site_cells.py:12`、`:49`） | **不能**（名字里带实例标记，见 §4.2） |
| `beg_families.json` | 帧 2..7 内、源数 ≥12 的 BEG 族 | 键仍是导入名，但**集合按帧窗口筛过** | 只能在窗口内用（`v7re/scripts/beg_families.py:39-45`） |

三者的数据通路互不相通：`clb_cells` 建表在 `v7re/export/law_db.py:83-92`、输入 `site_cells.json`（`:118`），与 `pip_reuse_law.json` 无任何读写关系。

### 1.3 一个高频误读：`WW4END0` 不是 family

| 检查 | 结果 | 证据 |
|---|---|---|
| 作为 DST（=family）出现 | **0 条** | `v7re/steps/t3_run.log:167` |
| 作为 SRC（=驱动线）出现 | 20 条，被 5 个 family 使用（`NL1BEG_N3, NW2BEG0, NW6BEG0, WR1BEG1, WW4BEG0`） | `v7re/steps/t3_run.log:168` |
| `law_cells` 中 `family='WW4END0'` 的行数 | **0** | `v7re/steps/t3_run.log:169` |

正确读法：**family = `WW4BEG0`，它选中的输入是 `WW4END0`**。判定依据与反例防护见 `v7re/steps/T2_NAME_PROVENANCE.md` §7（「不是所有同名线都是 family」），本节数字与 T2 §3 的角色统计同源。T2 原文写作「WW4BEG0/WW4END0 组」容易被读成两个族，实为 `(family, src)` 一对。

---

## 2. 名字来源：为什么说它是真名

### 2.1 代码侧：只做过滤/排序/拷贝，没有改名点（A2 结论）

| 层 | 行为 | 路径:行 |
|---|---|---|
| 前缀白名单 | 硬编码 `("IMUX","BYP_ALT","FAN_ALT")`，用于从 `law_cells` 挑 mux 区 | `v7re/scripts/pip_reuse_law.py:36` |
| 族名集合 | `sorted({f for (f, s) in cells if f.startswith(MUX_PREFIX)})`——集合推导体是 **`f` 本身**，不是 f-string | `v7re/scripts/pip_reuse_law.py:68` |
| 写 /families | `out["families"][fam] = {` | `v7re/scripts/pip_reuse_law.py:107` |
| 落盘 | `json.dump(model, fh, ...)` | `v7re/scripts/pip_reuse_law.py:242-243` |
| 入库 | `INSERT OR REPLACE INTO law_cells VALUES (?,?,?,?,?,?,?,?)` | `v7re/export/law_db.py:314` |
| 解析 | `seg = feat.split(".")` → `_t, family, src = seg` → `"family": family` | `step03_pip/gen_all_cells.py:36`、`:39`、`:49` |

**反证（同仓库确实存在「构造名」，但不在 PIP 链路上）**：CLB 侧 `step03_pip/gen_site_cells.py:49` 是 `family = f"{site_inst}.{bel}"`，进的是 `clb_cells`；PIP 链路里没有这种拼接。

### 2.2 器件侧：三层独立命中

逐名核对表见 `v7re/steps/T2_NAME_PROVENANCE.md` §3（A 级 = Vivado `get_pips`/`ROUTE` 直出、B 级 = prjxray 逆向库），本节只摘结论。

| 层 | 数据源 | 复算结果 |
|---|---|---|
| A 级 · Vivado 直出 | `_full8.pips`（`get_pips -of_objects` + `get_property NAME`） | **90 个 tile、145 个线名、100 个不同 dst**；`IMUX_L34` 出现在 **9 个不同 tile**：`:194`(`INT_L_X8Y20/INT_L.WR1END1->>IMUX_L34`)、`:208`(`X32Y6`)、`:222`(`X32Y7`)、`:237`(`X32Y8`)、`:250`(`X32Y9`)、`:265`(`X32Y10`)、`:278`(`X32Y11`)、`:293`(`X32Y12`)、`:305`(`X32Y13`) |
| 器件路由模板 | `templates/INT_L.json` 的 `pip_defs`，目的线是元素 **[1]** | distinct dst = **216**；`IMUX_L34` = **25 个源**；`WW4BEG0` = 20 |
| 第三方逆向库 | `prjxray_ref/artix7/segbits_int_l.db:1305` / `segbits_int_r.db:1697` | 行格式 `INT_L.IMUX_L34.BYP_BOUNCE_N3_6 21_21 !22_21 !23_21 !24_21 25_21`；R 侧 `INT_R.IMUX34.<同源>` **位图案逐位相同，只差一个 `_L`** |

> 行序陷阱：`pip_defs` 每行是 `[src, dst, 0, False]`，**dst 是元素 [1]**。按 `[0]` 取会得出「`IMUX_L34` 在模板里不存在」的假否定（T1 首轮踩过，见 `v7re/steps/family_schema_trace.md:47`）。

### 2.3 名字-对象是 1:1（本文把 T1 的「未验证」补成逐族复算）

T1 只对 `IMUX_L34` 做了全源集合比对，并在 `v7re/steps/family_schema_trace.md:143` 把「172 族全部 1:1」标为**未验证**。本文逐族复算结果：

| 检查 | 结果 |
|---|---|
| 有实测位的 family 数（INT_L） | **172** |
| 172 族全部 ⊆ 模板 216 个 dst | **是**（差集 `[]`） |
| 模板有、law 无位的 dst | **44**（§4.5：恰好是单源恒真连接） |
| 172 族中 law 源集合 ⊆ 模板源集合 | **168 族** |
| 其中唯一缺失源 | `VCC_WIRE`（64 族各 1 条，虚拟源无配置位） |
| law 源集合与模板**完全相等**（无缺失） | **108 族** |
| law 有、模板无的源 | **5 条，落在 4 族**：`LH0`(+`LH12`)、`LVB_L0`(+`LVB_L12`)、`LV_L0`(+`LH12`)、`LV_L18`(+`LH0`,`LH12`) → 见 §4.4 |
| `IMUX_L34` 专项 | 模板源 **25** vs law 有位源 **24**，差 `VCC_WIRE`；`sense` 分布 `{0: 48, 1: 72}`（48 个清零位 + 72 个选择位） |

**注意**：这 4 族的 5 条异常**不推翻「名字是真名」**——名字在模板里都真实存在（`LH12`、`LVB_L12`、`LH0` 本身也是模板里的 dst wire），异常在「源集合枚举」这一层，属跨器件/导出完备性问题，已单列 §4.4 并标未验证。

### 2.4 「family」这个词不是厂商术语（两条实测反证）

两层拆分（词的层次 vs 值的层次）见 `v7re/steps/T2_NAME_PROVENANCE.md` §4 与 §6（`family` 与「相对格集合等价类」不是同一层）。

| 检查 | 结果 |
|---|---|
| `templates/*.json` 全目录搜 `family` | **0 命中** |
| `prjxray_ref/artix7/*.db` 全目录搜 `family` | **0 命中** |
| 模板顶层键（实测） | 只有 `type / wires / pips / wire_defs / pip_defs` |

【推断】器件数据模型表达的是**边集合**（`(src_wire, dst_wire)` 的 PIP），没有「族」对象。「把同一个 dst 的所有 src 归成一族」是本项目的分析动作，Xilinx 的术语是「PIP 的目的 wire / sink」。

---

## 3. 「为什么不同的 tile 都有同一个 family」——必须拆成三层说

### 3.1 机制 M1（事实层）：命名空间是 tile_type 级

机制说明与跨 tile 覆盖统计见 `v7re/steps/T2_NAME_PROVENANCE.md` §5（「为什么不同的 tile 会有同一个 family」）。

| 断言 | 证据 |
|---|---|
| `law_cells` 没有坐标列 | DDL 八列：`tile_type, family, src_wire, frame_off, bit, sense, parity, src_index`（`v7re/export/law_db.py:37-45`） |
| 主键不含实例 | `PRIMARY KEY (tile_type, family, src_wire, frame_off, bit)`（`v7re/export/law_db.py:46`） |
| 该类型实例数 | `law_tiles` 实测：`INT_L` **26,550**、`INT_R` **26,550**（写入点 `v7re/export/law_db.py:354`） |
| 每个实例同一张图纸 | 模板 `INT_L.json` `pip_defs` 3737 条 → 216 个 dst（同一份类型级模板） |

【数据事实】结论：`(tile_type, family, src)` 是**类型级名字**。同名不是巧合，是 schema 的必然结果；物理上每个 tile 各有独立配置位，**不共享位**。

### 3.2 机制 M2（构造层）：归一化后格集合同一是「查表恒等」，不是观测

这一条是本文最需要写清的地方，也是用户追问「为什么会同时出现两个一样的」的正式答案。

```python
# v7re/scripts/fasm2bit.py:113-130
def cells_of(self, ttype, family, src):
    """→ [(frame_off, bit, parity)]，未知道 None。"""
```

- 返回值**不含 tile 坐标**（`fasm2bit.py:113` 的 docstring 即写明元组内容）。
- `rel3` 口径正是 `(frame_off, parity, bit)`（`v7re/steps/t3_tilewise_table.md:17-22`），即该返回值的原样投影。
- 因此对同一 `(family, src)`，跨 tile 的 `rel3` **必然相同**。T3 已自行标注这一点（`v7re/steps/t3_tilewise_table.md:174-182`：「这个 0 是定义性恒真，不是实证发现」），`v7re/steps/PAIR_IDENTITY_WHY.md` 也把它判为构造性恒真。

【推断】**推论**：判据 `missing=0 且 extra=0` 对「基址取错」以外的错误**无法失败**，不能用它证明「两次独立观测吻合」。它只证明「表与位流自洽」。

对照组（同一张表内并列，才有判别力）：

| 口径 | 定义 | IMUX_L34 (9 tile) | WW4BEG0 (22 tile) | WW4BEG0(src=WW4END0) (14 tile) |
|---|---|---|---|---|
| `abs` | `(frame, word, bit)` | **9 / 9 种**（全不同） | **22 / 22** | **14 / 14** |
| `rel2` | 减块基址 | 9 / 9 | 10 / 22 | 4 / 14 |
| `rel3` | 再减行项 | 5 / 9（= 5 种 src） | 4 / 22（= 4 种 src） | **1 / 14** |

来源：`v7re/steps/t3_run.log:31-33`、`:67-69`、`:95-97`（表见 `v7re/steps/t3_tilewise_table.md:79-83`、`:99-103`、`:120-124`）。

读法：**绝对落点全不同 → 相对格全相同**，同一批格只换坐标口径。若把 `rel3` 相同当成「独立观测吻合」，就是把恒等式当实验。

> 精度补注：行项公式完整写法是 `w = 2*(y%50)+parity; w+1 if w>=50 else w`（`v7re/scripts/fasm2bit.py:109-111`）。本文与 T3 表里写的 `2*(y%50)+parity` 是 `w<50` 分支；190 个实例的 `y` 取值使 `w ≤ 40`，折返分支不触发，故两者一致——但引用该公式时应带上 `fasm2bit.py:111` 的折返。

### 3.3 机制 M3（实证层）：有判别力的证据只能落在位流读数上

| 检查 | 结果 | 证据 |
|---|---|---|
| 预测格总数 / 位流未置位 | **458 / 0** | `v7re/steps/t3_run.log:129` |
| 同 family「其他源」候选格 / 被点亮 | **6142 / 0** | `v7re/steps/t3_run.log:130` |
| 30 个目标 tile 的窗口残余 | **合计 0 位**（含 `INT_L_X8Y20` 单 tile 188 位全覆盖） | `v7re/steps/t3_run.log:161`、`:164` |

6142 那一行是**对基址错误敏感**的：若 `tile_base` 取错，这些格会落到该 tile 窗口之外，读到别的族的位，几乎不可能全 0。所以它同时覆盖「基址取错」与「行项算错」两种失败模式。

### 3.4 小结：三种「一样」，三种含义

| 现象 | 是不是证据 | 机制 |
|---|---|---|
| 同一 family 名出现在多个 tile | **是事实**（schema 必然） | 名字空间 tile_type 级（§3.1） |
| 归一化后格集合相同 | **不是证据**（构造性恒真） | 格表无坐标（§3.2） |
| 绝对落点全不同 | **是证据**（有判别力） | `tile_base` 平移（§3.2 表） |
| 458 格 0 落空 / 6142 格 0 误亮 / 0 残余 | **是证据**（对错误敏感） | 直接读位流（§3.3） |

---

## 4. 适用边界（A3）：哪些 family 能跨 tile 复用，哪些不能

### 4.1 一张表定边界

| 对象 | 名字性质 | 相对格跨 tile（**同** tile_type） | 绝对位跨 tile | 跨 tile_type |
|---|---|---|---|---|
| INT mux family（172 族 / 190 个有位实例） | 真名 | **可复用**（同一 `(family,src)` 公式一致） | **不可复用**（必须先减 `tile_base`） | **不可**（`IMUX_L34` → `IMUX34`，须做名字映射） |
| 44 个单源恒真连接（`BYP_BOUNCE*`/`FAN_*`/`GCLK_*`） | 真名 | **无格可复用**（没有配置位） | — | — |
| CLB site family（79 个，如 `SLICEL_X0.AFFMUX`） | **自造**（f-string） | **不可**（名字含实例标记，非类型级） | 不可 | 4 个 CLB tile_type 共用同一套 79 名 |
| `beg_families.json` | 导入名 + 窗口筛选 | **仅帧 2..7**（其它窗口未纳入） | — | — |

### 4.2 为什么 CLB site family 不可当类型级复用

- 名字由 `f"{site_inst}.{bel}"` 拼出（`step03_pip/gen_site_cells.py:49`），**`site_inst` 是实例标识**（如 `SLICEL_X0`），语义上就把实例钉进名字里。
- 实测 79 个 distinct family 覆盖 4 个 tile_type（`CLBLL_L/CLBLL_R/CLBLM_L/CLBLM_R`，各 960/960/982/982 行）——同一套名字在四个类型上复用，名字本身**不携带类型信息**。
- 结论：它是「某实例的某 BEL」，**不是**「某类型的某结构」。要跨 tile 迁移，必须回到 site 索引规则（见 T57 的 CLBLL INIT 重建），不能靠名字。

### 4.3 跨 tile_type 的命名规则（实测 172 vs 172）

| 项 | 数值 | 说明 |
|---|---|---|
| INT_L 族数 / INT_R 族数 | 172 / 172 | 两侧同规模 |
| 两侧**同名** | **116** | `BYP_ALT0-7`、`FAN_ALT0-7`、`EE*/WW*/SS*/SE*/NE*/NN*/NW*/SW*/SR*/ER*/WR*/EL*/NR*/NL*`、`LH0/6`、`GFAN0/1`、`SL1BEG0-3`、`WL1BEG*` 等 |
| 仅 INT_L 有 | **56** | 48 `IMUX_L*` + 2 `CLK_L*` + 2 `CTRL_L*` + 2 `LV_L*` + 2 `LVB_L*` |
| 仅 INT_R 有 | **56** | 48 `IMUX*` + 2 `CLK*` + 2 `CTRL*` + 2 `LV*` + 2 `LVB*` |

【推断】带 `_L` 后缀的是 **5 个前缀族**（IMUX / CLK / CTRL / LV / LVB），其余 116 个两侧同名。这是 Vivado 对左右侧 tile 的线命名约定，不是项目改的（`segbits_int_l.db:1305` 与 `segbits_int_r.db:1697` 位图案逐位相同）。

**工程后果**：跨 tile_type 直接用 `cells_of` 会**静默返回 None**（`v7re/scripts/fasm2bit.py:115-121` 对不认识的 family 返回 `None`）。`v7re/steps/PAIR_IDENTITY_WHY.md` 里那 48 个 INT_R 独占 mux family（3456 引用 / 480 格）被跳过，就是这条边界造成的——不是数据缺失，是命名空间不通用。

> 此处修正 T5 复盘里的一条旧表述：当时记「只有 IMUX*/CLK*/CTRL*/LV* 带 `_L`」，实测还有 `LVB_*`（`LVB_L0`、`LVB_L12`），是 **5 个**前缀。

### 4.4 4 族 5 条源异常（**未验证**，不阻塞主结论，但必须写明）

| family | law 有、模板无的源 |
|---|---|
| `LH0` | `LH12` |
| `LVB_L0` | `LVB_L12` |
| `LV_L0` | `LH12` |
| `LV_L18` | `LH0`、`LH12` |

两条候选解释，**均未验证**：

1. **跨器件差异**：位表来自 artix7 prjxray（`step03_pip/gen_all_cells.py:5`），模板来自 V7 路由库（`E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json`）。同叫 `INT_L` 的 tile 在 A7 与 V7 上 pip 集合可能不同。
2. **模板导出不完备**：`pip_defs` 3737 条覆盖 216 个 dst（均值 17.3），不能先验排除个别边缺失。

**验证办法（待执行，不在本子任务范围）**：对 `V7` 全器件 `get_pips` 枚举（而非单设计导出），比对 `LH0`/`LV_L0`/`LV_L18`/`LVB_L0` 的目的边集合；若 V7 侧确实无 `LH12→LH0`，则解释 1 成立。

**为什么它不推翻主结论**：异常发生在「源集合枚举完备性」，而「名字是不是真名」由字符串在器件数据中的存在性决定——`LH12`、`LVB_L12`、`LH0` 在模板里都是真实存在的 dst wire（本次已核）。

### 4.5 44 个「有名字、无配置位」的 dst：恰好是单源恒真连接

| 检查 | 结果 |
|---|---|
| 模板 dst 总数 / 有位的 family | 216 / **172** |
| 差集大小 | **44** |
| 差集内每个 dst 的源数 | **全部为 1**（`Counter({1: 44})`） |
| 该 44 个集合 vs `law_ppips where tile_type='INT_L' and kind='always'` | **集合完全相等**（44 = 44） |

组成：`BYP_BOUNCE0-7`(8)、`BYP_L0-7`(8)、`FAN_BOUNCE0-7`(8)、`FAN_L0-7`(8)、`GCLK_L_B6-B11_{EAST,WEST}`(12)。

【推断】单源 = 无需选择 = 不需要配置位，所以这些连接恒真。这给出一个更准确的数字关系：**216 = 172（有选择位）+ 44（单源恒真）**。

> 这条同时**修正 STATUS §108 的措辞**：§108 写「172 个 family 是 216 个目的线名中『有 site 连接 / 有实测位数据』的子集」。「有 site 连接」不是判据——真正的判据是「**有多源选择**」，44 个被排除的恰好是单源。

### 4.6 零位实例的口径（不计入分母，但必须披露）

`_full8.pips` 里有 8 条有名字但表里无任何位的实例，全部 `law_ppips.kind='always'`（`v7re/steps/t3_run.log:171-179`，表见 `v7re/steps/t3_tilewise_table.md:220-227`）。

口径写死：**190 个有位实例**用于一致性统计，**8 个零位实例**单列。若把零位当「解不出」，会把「本来没有位」误报成「坐标不一致」（T2b 首版犯过，见 `v7re/steps/t3_tilewise_table.md:229-235`）。

---

## 5. 未验证与边界（同行评审请从这里挑）

1. **4 族 5 条源差异的原因未定**（§4.4）。候选解释两条，验证需全器件 `get_pips` 枚举。
2. **`_full8.pips` 是单设计的部分导出**（308 行 / 90 tile / 145 线名），所以「9 个 tile 有 `IMUX_L34`」是**该导出下**的实例数，**不是器件级总数**。器件级需全器件枚举。
3. **`sense=0` 的 48 个清零位语义**本文未建模（只统计了 `{0:48, 1:72}`）。若要把 family 的位集合用于「生成」，清零位必须建模，这是另一层结论。
4. **名字-对象 1:1 只在「源集合」维度核过**（§2.3 逐族）。位级 1:1（一源对应哪些格）由 `v7re/scripts/fasm2bit.py:113-130` 的公式表达，其正确性由 §3.3 的观测核对支撑，属 T3/T56 范围，本文不重复判定。
5. **`law_cells` 只含 INT_L / INT_R**（各 12,164 行），其它 tile 类型（`INT_INTERFACE_L/R`、`INT_FEEDTHRU_*`）不在表内，本文的 family 结论**不覆盖**这些类型。

---

## 6. 复现（全部命令可重跑，不依赖网络）

```powershell
# 1) 名字在器件数据里存在 + 216 个 dst + IMUX_L34 源集合 25 vs 24（差 VCC_WIRE）
@'
import json,sqlite3,collections
tpl=json.load(open(r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json",encoding="utf-8"))
c=collections.Counter(x[1] for x in tpl["pip_defs"]); print("dst",len(c),"IMUX_L34",c["IMUX_L34"])
con=sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro",uri=True)
fams={r[0] for r in con.execute("select distinct family from law_cells where tile_type='INT_L'")}
print("172族未命中模板:",sorted(fams-set(c)),"| 模板多出:",len(set(c)-fams))
t={x[0] for x in tpl["pip_defs"] if x[1]=="IMUX_L34"}
l={r[0] for r in con.execute("select distinct src_wire from law_cells where tile_type='INT_L' and family='IMUX_L34' and sense=1")}
print("模板源",len(t),"law源",len(l),"差",t-l)
'@ | Out-File -Encoding utf8 _chk.py; python _chk.py; Remove-Item _chk.py
# 输出：dst 216 IMUX_L34 25 / 172族未命中模板: [] | 模板多出: 44 / 模板源 25 law源 24 差 {'VCC_WIRE'}

# 2) 44 个无位 dst == 44 条 always ppips，且每个 dst 源数=1
@'
import json,sqlite3,collections
tpl=json.load(open(r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json",encoding="utf-8"))
byd=collections.defaultdict(set)
for s,d,_,_ in tpl["pip_defs"]: byd[d].add(s)
con=sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro",uri=True)
law={r[0] for r in con.execute("select distinct family from law_cells where tile_type='INT_L'")}
extra=set(byd)-law
print("无位dst",len(extra),"源数分布",collections.Counter(len(byd[d]) for d in extra))
print("== always集合:",extra=={r[0] for r in con.execute("select family from law_ppips where tile_type='INT_L' and kind='always'")})
'@ | Out-File -Encoding utf8 _chk2.py; python _chk2.py; Remove-Item _chk2.py
# 输出：无位dst 44 源数分布 Counter({1: 44}) / == always集合: True

# 3) 跨 tile_type 命名空间：116 同名 / 56+56 独有
@'
import sqlite3,collections
con=sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro",uri=True)
L={r[0] for r in con.execute("select distinct family from law_cells where tile_type='INT_L'")}
R={r[0] for r in con.execute("select distinct family from law_cells where tile_type='INT_R'")}
print(len(L),len(R),"同名",len(L&R),"仅L",len(L-R),"仅R",len(R-L))
print("仅L前缀:",collections.Counter(x.split("_")[0] if not x.startswith(("IMUX","CLK","CTRL","LVB","LV")) else "侧缀族" for x in L-R))
'@ | Out-File -Encoding utf8 _chk3.py; python _chk3.py; Remove-Item _chk3.py
# 输出：172 172 同名 116 仅L 56 仅R 56

# 4) 逐 tile 核账与位流观测（复现 §3 的全部数字）
python v7re\steps\t3_tilewise_cells.py
```

`_full8.pips` 的 90 tile / 145 线名 / 100 dst 复算：

```powershell
@'
lines=[l.rstrip("\n") for l in open("_full8.pips",encoding="utf-8",errors="replace")]
t=set(); d=set(); w=set()
for l in lines:
    if "->>" not in l: continue
    lhs,dst=[x.strip() for x in l.split("->>",1)]
    tile,rest=lhs.split()[-1].split("/",1); src=rest.split(".",1)[1]
    t.add(tile); d.add(dst); w.add(src); w.add(dst)
print("tiles",len(t),"dst",len(d),"wires",len(w),"| ->> 行",sum(1 for l in lines if "->>" in l))
'@ | Out-File -Encoding utf8 _chk4.py; python _chk4.py; Remove-Item _chk4.py
# 输出：tiles 90 dst 100 wires 145 | ->> 行 232
```
