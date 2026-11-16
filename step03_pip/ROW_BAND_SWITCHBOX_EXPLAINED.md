# row / band / 行带 / PIP 与 mux：概念对照与数量对账

本文件按 `step03_pip/PROMPT_ROW_BAND_SWITCHBOX_V2.md` 生成。器件 `xc7vx485tffg1761-2`。
来源标注：【硬件事实】器件结构或厂商文档可直接确认；【数据事实】本仓库数据库/脚本实测可复算；【推断】由前两者推出但未直接验证。

---

## 0. 一句话答案

| 问题 | 一句话回答 |
|---|---|
| row 是什么 | 三个不同的东西共用一个词：tile 的 `Y` 坐标、band 内行号 `Y%50`、一帧里的 word 槽位。 |
| band（行带）是什么 | **帧地址上连续的 5,246 帧**，共 7 个；不是按 `Y` 切出来的。 |
| bank 和 band 是一回事吗 | **不是**。bank 是 I/O / 配置 / 时钟资源的编组，band 是本仓库给帧地址块起的名字。 |
| PIP 是什么 | 一个可编程互连点 = 一个受配置位控制的开关（把一根 wire 接到另一根）。 |
| mux 和 PIP 什么关系 | mux = **共用同一个目的 wire 的一组 PIP**；选哪个输入 = 点亮这组里的哪一个开关。 |
| switch box 是什么 | tile 内所有 mux + 直通 PIP 的集合；对一个 INT tile 就是 3,737 个 PIP 的整张网。 |

---

## 1. 坐标与存储层次

### 1.1 tile

- **【一句话定义】** 配置阵列里的一个块实例，由「类型 + 列号 + 行号」定位。
- **【取值范围】** 全器件 150,380 个 tile、115 种类型；INT_L 26,550 个、INT_R 26,550 个【数据事实：`v7_routing.db` 表 `tiles` / `tile_types.instances`】。网格坐标 `grid_x ∈ 0..411`、`grid_y ∈ 0..364`【数据事实：`tiles`】；INT 的列号 `col ∈ 0..157`、行号 `y ∈ 0..349`【数据事实：`v7_law.sqlite.law_tiles`】。
- **【真实演算】** `INT_L_X8Y20`：类型 INT_L、col=8、Y=20。同 `(col,Y)` 上还可以并存别的类型——`col=20` 一列 700 个 tile 全是 `INT_L_X20Y*` 与 `INT_INTERFACE_L_X20Y*` 成对【数据事实：`v7_law.sqlite` 表 `law_tiles`】。
- **【复算来源】** `select count(*) from tiles;` / `select * from tile_types where type='INT_L';`

### 1.2 row 的三种含义（不得合并叙述）

**含义 A —— tile 的行坐标 `Y`**

| 项 | 值 |
|---|---|
| 【一句话定义】 | tile 在配置阵列里的纵向位置，等于 `tile_name` 末尾的 `Ynnn` |
| 【取值范围】 | 0..364（`tilegrid` 口径）；INT tile 实际出现在 0..349 |
| 【真实演算】 | `INT_L_X8Y20` 的 `Y=20`；`INT_R_X37Y199` 的 `Y=199` |
| 【复算来源】 | `v7_routing.db.tiles.grid_y`、`v7_law.sqlite.law_tiles.y` |

**含义 B —— band 内的行号 `Y % 50`**

| 项 | 值 |
|---|---|
| 【一句话定义】 | 同一个 band 内，一个 tile 占 50 行里的第几行；一行对应同一帧里的 2 个 word |
| 【取值范围】 | 0..49 |
| 【真实演算】 | `INT_R_X37Y199`：`Y%50 = 199%50 = 49` |
| 【复算来源】 | `v7re/scripts/bitwriter.py:41-43`（`word_of`） |

**含义 C —— 帧内的 word 槽位**

| 项 | 值 |
|---|---|
| 【一句话定义】 | 一帧是固定 101 个 word（每个 32 bit）的载荷，这里说的是「第几个 word」 |
| 【取值范围】 | 0..100；其中 50 恒为 ECC 字 |
| 【真实演算】 | 一帧 101 word = 3,232 bit；`INT_L_X8Y20` 的 `IMUX_L40` 落在 word 40 |
| 【复算来源】 | `v7re/scripts/bitstream/parser.py`（`bits.shape = (n, 101, 32)`） |

### 1.3 region

- **【一句话定义】** 按 `Y` 坐标每 50 行切一刀得到的物理纵向分区，用来查「这一行属于哪一块帧地址」。
- **【取值范围】** `region = Y // 50`，0..6，共 7 个。
- **【真实演算】** `Y=20 → region 0`；`Y=199 → region 3`。
- **【复算来源】** `v7re/scripts/bitwriter.py:56`。

### 1.4 band（行带）

- **【一句话定义】** 帧地址上连续的 5,246 帧构成的一个存储块；`frame = far_bands[(band, col)].start_frame + frame_off`。
- **【取值范围】** 7 个 band，每个是 5,246 帧的地址窗口：band0 = 帧 0..5245、band1 = 5246..10491、band2 = 10492..15737、band3 = 15738..20983、band4 = 20984..26229、band5 = 26230..31475、band6 = 31476..36721；7×5246 = 36,722，器件共 50,176 帧，差额 13,454 帧属非 INT 列【数据事实：`v7_law.sqlite` 表 `far_bands`，每 band 128 个列基址】。窗口内并不全被 INT 列用满：INT 列的 `start_frame` 实际只到 35,800（band6 内），终点 35,826【数据事实：`select max(start_frame) from far_bands`】。
- **【真实演算】** `INT_L_X8Y20`：`region=0 → band=band_by_region[0]=6 → start_frame=31,752`；`INT_R_X37Y199`：`region=3 → band=band_by_region[3]=1 → start_frame=6,510`。
- **【复算来源】** `select * from far_bands where band=6 and col=8;`、`select value from meta where key='band_by_region';`

### 1.5 region 与 band 的置换（这是最容易搞错的一步）

- **【一句话定义】** `band_by_region = [6,5,0,1,2,3,4]`：物理上从下往上第 k 个 region，存到帧地址上第 `[6,5,0,1,2,3,4][k]` 个 band 里。
- **【取值范围】** 映射表 7 项；`region 0 → band 6`、`region 6 → band 4`。
- **【真实演算】** `Y=20`（region 0）的 tile 与 `Y=120`（region 2）的 tile **不在同一个 band**（band 6 vs band 0），二者帧地址相差 31,752 − 0 = 31,752 帧。
- **【复算来源】** `v7re/scripts/bitwriter.py:56`、`v7_law.sqlite.meta`。

**后果（本节的要点）**：同一个 band 覆盖的是**同一列上 50 个不同 `Y` 的 tile**，它们共用同一批 26 帧，各自只占不同 word；跨 region 就是跨 band，必然换帧、换 `start_frame`。band 号跟的是**帧地址顺序**，不是 `Y` 顺序 —— 所以 band0 装的是 `Y=100..149`，不是 `Y=0..49`。

### 1.6 frame / word / bit

| 概念 | 【一句话定义】 | 【取值范围】 | 【真实演算】 | 【复算来源】 |
|---|---|---|---|---|
| frame | 配置存储的一帧 = 101 word × 32 bit = 3,232 bit | 0..50,175（共 50,176 帧） | `INT_L_X8Y20` 的 `frame_off=16` → frame 31,768 | `far_bands.start_frame + frame_off` |
| word | 帧内第几个 32 bit 字 | 0..100；50 恒为 ECC，`word = 2*(Y%50)+parity`，≥50 则再 +1 | `Y=20`、parity 0 → word 40 | `v7re/scripts/bitwriter.py:41-43` |
| bit | word 内第几位 | 0..31 | `IMUX_L40` 的 cell 落在 bit 6 / 7 | `v7_law.sqlite.law_cells.bit` |

**为什么 row ≥ 25 时 word 要 +1**：【推断】word 50 被 ECC 占用，`2*(Y%50)+parity` 在 `Y%50 ≥ 25` 时会撞上 50，所以整体跳过一格。

---

## 2. bank 与 band 不是一回事

| bank 的口径 | 【一句话定义】 | 【取值范围/单位】 | 与本仓库 band 是否同物 | 【复算来源】 |
|---|---|---|---|---|
| I/O bank | 一组共享供电/参考电压的 I/O 引脚编组 | 器件的 I/O bank 数量与编号属器件手册范围，本文未测 | **不是** | 未测 |
| 配置/时钟 bank | 配置接口或时钟资源的编组（如 BPI/SPI 端口、时钟区域） | 未测 | **不是** | 未测 |
| Xilinx 文档里的 bank 地址 | 器件手册中按 bank 编号给出的引脚表 | 未测 | **不是** | 未测 |

- **【一句话定义】** 本仓库的 `band` 只描述「帧地址上的连续 5,246 帧」，与供电、引脚、时钟区域都无关。
- **【取值范围】** band ∈ 0..6。
- **【真实演算】** band 6 覆盖帧 31,476..36,721，对应的物理行是 `Y=100..149`（region 2）。
- **【复算来源】** `far_bands` 表 + `band_by_region`。

---

## 3. wire / PIP / mux / switch box

### 3.1 四个概念

| 概念 | 【一句话定义】 | 【取值范围】 | 【真实演算】 | 【复算来源】 |
|---|---|---|---|---|
| wire | 配置阵列里的一条布线资源（一根金属线或一段内部连线） | 一个 INT tile 600 根 | `IMUX_L40` 是一根目的 wire；`EE2END0` 是一根源 wire | `v7_routing.db.tile_types.wires = 600` |
| PIP | programmable interconnect point：把一根 wire 接到另一根的**一个开关**，由 1 个（少数由 2 个）配置位控制 | 一个 INT tile 3,737 个 | `EE2END0 → BYP_ALT0` 是一条 PIP | `tile_types.pips = 3,737` |
| mux | **共用同一个目的 wire 的一组 PIP**：同一时刻只允许其中一个导通，于是这一组就是一个多路选择器 | 一个 INT tile 172 个 mux | `BYP_ALT0` 这个 mux 有 24 个输入（law 口径） | `v7_law.sqlite.law_cells` 按 `family` 分组 |
| switch box | tile 内全部 mux 与直通 PIP 构成的整张可编程交换网络 | 一个 INT tile = 3,737 个 PIP | 见 §4 的对账 | 同上 |

### 3.2 回答你问的三个问题

**「PIP 不是一系列开关盒吗？」**
PIP 是**单个开关**，不是一系列。【硬件事实】7 系列每个 PIP 是一个由配置位驱动的传输门/缓冲对。所谓「开关盒（switch box）」是把 tile 里全部 PIP 放在一起看的整体名称——一个 INT tile 的 switch box 含 3,737 个 PIP【数据事实：`tile_types.pips`】。

**「mux 又是什么关系？」**
mux 是**PIP 的集合**，按目的 wire 归组。【数据事实】一个 INT tile 的 216 个目的 wire 里，172 个的扇入 > 1（构成 mux），44 个扇入 = 1（纯直通）；172 个 mux 一共含 3,693 个 PIP。

**「一个 mux 选哪一路是怎么编码的？」**
靠 `(frame_off, parity, bit)` 三元组【数据事实：`v7_law.sqlite.law_cells` 的 `sense=1` 行】。同一个 mux 的不同输入**共享一部分位、各自独占一部分位**：共享位是「这个 mux 被使能并选中某一组」的公共前缀，独占位是「选中组内第几个」的编码。以 `IMUX_L40` 为例：它占 10 个 cell（全在 `parity=0`、`frame_off=16..25`、`bit` 取 6 或 7），24 个输入每个占其中 5 个 cell，其中 4 个是 24 个输入共用的，1 个是它独占的。

---

## 4. 数量对账（3,737 与 3,634 的差从哪来）

一个 INT tile（INT_L，26,550 个实例完全一致，`tile_types.uniform = 1`）：

| 项 | 数量 | 来源 |
|---|---|---|
| 目的 wire 总数 | 216 | `out_routing/templates/INT_L.json` 的 `pip_defs` 按目的 wire 归组 |
| 其中：扇入 > 1（= 172 个 mux 家族） | 172 个目的 wire | 同上，与 `law_cells` 的 172 个 `family` 一一对应 |
| 这 172 个 mux 含的 PIP | 3,693 | 同上 |
| 其中：扇入 = 1 的直通 PIP | 44 | 全是 `BYP_BOUNCE*`、`BYP_L*`、`FAN_BOUNCE*`、`FAN_L*` 各 1 个 |
| PIP 合计 | 3,693 + 44 = **3,737** | `tile_types.pips = 3,737` ✔ |
| `law_cells` 记录的 feature（sense=1） | **3,634** | `law_cells`，两侧各 3,634 |
| 差量 | 3,693 − 3,634 = **59** | 见下 |

**59 的来源（逐族可核对）**：有 59 个 mux 在模板里多出一个 `VCC_WIRE` 输入（恒 1 的常量 tie-off），`law_cells` 不记录该源。例：`BYP_ALT1`、`FAN_ALT7`、`IMUX_L10` 等 59 个族，模板扇入 25、law 24，多出的都是 `VCC_WIRE`。

**全账**：`3,634（law 可解释的输入）+ 59（VCC 常量输入）+ 44（直通）= 3,737` ✔

- **【真实演算】** `IMUX_L40`：模板扇入 25（含 VCC_WIRE），law 24，本地编码 10 个 cell → 24×5 = 120 条 `law_cells` 行。
- **【复算来源】** `python step03_pip/_q_pip_reconcile.py`、`python step03_pip/_q_pip_gap59.py`。

---

## 5. 三种常见误解

**误解一：「band 就是物理行带，band 0 就是最下面 50 行」**
→ 错在把 **band（帧地址块）** 与 **region（物理 50 行）** 混为一谈。
→ 正确表述：`band` 是帧地址上连续的 5,246 帧；`region = Y//50` 才是物理分区；二者通过 `band_by_region = [6,5,0,1,2,3,4]` 关联，band 0 = 帧 0..5245 = `Y=100..149`（region 2），band 6 = 帧 31,476..36,721 = `Y=0..49`（region 0）【数据事实：`far_bands` + `meta`】。

**误解二：「PIP 是独立开关，改它就是改一根线」**
→ 错在忽略 **PIP 从属于某个 mux**。
→ 正确表述：一个 INT tile 的 3,737 个 PIP 被组织成 172 个 mux（3,693 个 PIP）+ 44 个直通；同一个 mux 的输入互斥，改动必须让「这一组里恰有一个导通」，否则解码端会看到非法码字（这就是 TM2 篡改检测 99.44% 检出率的来源，见 `paper/TAMPER_LOCALIZER.md` §5）。

**误解三：「一帧覆盖整个器件」**
→ 错在把 **帧** 当成全器件快照。
→ 正确表述：一帧只有 101 word = 3,232 bit，只覆盖**某一列某一个 band 内 50 行 tile 的一小片**；器件共 50,176 帧，一个 INT tile 的配置位落在 26 帧 × 2 word × 32 bit = 1,664 个位上【数据事实：`law_cells` 的 `frame_off` ∈ 0..25、`parity` ∈ {0,1}、`bit` ∈ 0..31】。

---

## 6. 复算命令（可直接粘贴）

```bash
# 1) 一个 INT tile 的 wire / PIP 数
python -c "import sqlite3;c=sqlite3.connect('file:E:/v7work/_curated_20261021/routing/v7_routing.db?mode=ro',uri=True);print(c.execute(\"select type,instances,wires,pips from tile_types where type in ('INT_L','INT_R')\").fetchall())"

# 2) band 边界与置换表
python -c "import sqlite3;c=sqlite3.connect('file:E:/v7work/model/v7_law.sqlite?mode=ro',uri=True);print(c.execute('select band,min(start_frame),max(start_frame) from far_bands group by band').fetchall());print(c.execute(\"select value from meta where key='band_by_region'\").fetchone())"

# 3) 172 家族 / 3,634 feature
python v7re/scripts/verify_all_pip.py --tile-type INT_L

# 4) 3,737 与 3,634 的差量
python step03_pip/_q_pip_reconcile.py
python step03_pip/_q_pip_gap59.py
```
