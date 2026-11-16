# INT tile 是怎么做出来的

编写日期：2026-11-15　器件：`xc7vx485tffg1157-3`　配图：`fig_int_tile_build.png`

本文把散落在 S9 / S10 / S24 / S30 / S31 / S37 / S38 七份报告里的流程合并成一条线：
**拓扑（边）→ 位（谁控制边）→ 地址（边在哪一帧）→ 同质性与独立校验**。

标注：**【实测】**= 本项目实验或数据直接测得；**【推断】**= 外推未直接验证；**【未测】**= 暂无证据。

---

## 1. 全景

```
┌──────────── 拓扑层（边）────────────┐   ┌────────── 位层（控制位）──────────┐
 prjxray V7 原生库    Vivado get_pips    routed.dcp → 改一根网 → bitgen → 差分
 tilegrid 150,380     3,737 pip/209 族   1,200 个变体 → 每源位集
 tileconn 17,928      (真值对照)         0 冲突 / 0 位集重复
        ↓ 补 106 条 IO 入口边                    ↓
   3,737 条边（172 族有位）              48 mux × ~25 源 的编码表
        └──────────────────┬──────────────────────┘
                           ↓
              ┌──── 地址层（帧号）────┐
              语料占用 1,038 块 / 45 LOC 锚点 / Y 差分 wof(Y)
                           ↓
              三条独立校验：CSP 48/48、ROUTE 6/6、写回 864/864
```

---

## 2. 拓扑层：边从哪来

### 2.1 主体来源：prjxray 的 V7 原生静态库【实测】

`E:\v7work\db\prjxray\xc7vx485t\`：

| 文件 | 内容 | 数量 |
|---|---|---|
| `tilegrid.json` | tile 名 → `(grid_x, grid_y, type)` | **150,380** |
| `tileconn.json` | 类型级连接（`tile_types` + `grid_deltas` + `wire_pairs`）| **17,928** |
| `tile_type_INT_L/R.json` | 每类 wire 表与 PIP 表 | 3,737 pip / 类 |
| `ppips_int_l/r.db` | 永远导通的连接 | 108 / 侧 |

> 早期曾试过用 artix7 的 `segbits_int_l.db` 迁移——源名体系不同（`BRAM_CASCINBOT_*` vs `BRAM_RAMB18_*`），失败。**拓扑必须用 V7 自己的库。**

### 2.2 缺口：IO 入口不在库里【实测】

`tileconn.json` 里 **INT_INTERFACE 相关对 = 0 条**。后果：走线到 IO 边界断掉（S10 的 A4 网就卡在缺一段）。

补法：手写 **106 条 fixed 边**（`step03_pip/tileconn_v7_patch.json`），经 `tconn_v7.py` 的 `Graph.land_f/land_b` 与 prjxray 合并。补完 6/6 网走通、token 级一致。

### 2.3 验证：用 Vivado `get_pips` 当对照真值【实测】

```tcl
link_design -part xc7vx485tffg1157-3
foreach t $tiles { foreach p [get_pips -of_objects [get_tiles $t]] { puts "$t\t$p" } }
```

14 个 tile × 6 类邻接位置（普通 CLB / BRAM 邻接 / IO 夹缝 / 跨 band / PCIE 邻接 / 终端区）：
**每个 tile 都是 3,737 pip / 209 家族，族名集合逐字节相同。**

**216（Vivado）vs 172（我们的位表）差在哪**：44 个单源常通抽头
（`BYP_BOUNCE0-7←BYP_ALT0-7`、`BYP_L0-7←BYP_ALT0-7`、`FAN_BOUNCE0-7←FAN_ALT0-7`、`FAN_L0-7←FAN_ALT0-7`、`GCLK_L_B6..B11_EAST/WEST`）。
Vivado 把它们当普通 pip 列出；我们归到 ppips（2,598 条，**0 位**）。【实测】S31

---

## 3. 位层：1,200 个变体的定向差分

### 3.1 核心手法：不是重新综合，而是改同一条 DCP 上的一根网

```
基线 routed.dcp
  ├─ 变体1: set_property ROUTE 该网末段 → 目标 track → write_bitstream
  ├─ 变体2: 同上，换一个 track
  └─ ...
```

为什么这样能控住变量：
- 综合结果不变 ⇒ LUT INIT / FF 位逐位不变；
- 布局不变 ⇒ 没有 cell 挪窝；
- 其它网路由不变 ⇒ 其它帧不变；
- **唯一变化** = 该网新路径（INT 帧）+ bitgen 由此重推的 IMUX 选择（CLB 帧）。

### 3.2 为什么 IMUX 只能这样测

DCP 里**没有"site 内 mux 选择"这个可编辑对象**——IMUX 由 netlist + 放置 + 该网 INT 路由终点共同推出。
所以你只能改"条件"，让 bitgen 推出唯一结果。**这是本项目所有 IMUX 表的唯一来源。**

### 3.3 规模与产物【实测】

| 项 | 数值 |
|---|---|
| INT_L 侧 mux | 48（每 slice 实例 24 × 2 形态：inst0/inst1）|
| 每 mux 源数 | 3–25 |
| 变体数 | **900+**（主批）+ **300**（X8Y11 补 C/D6LUT 可达的 12 个 mux）|
| 位集冲突 | **0** |
| 每 mux 空源 | 1 个（`VCC_WIRE`，恒定） |

产物链：`tilepipe.json`（48 tag）→ `pip_bits` 表（3,504 行）→ `all_cells.json`（24,336 cell）。

### 3.4 构建骨架

```tcl
read_verilog anchor.v
synth_design -top top -part xc7vx485tffg1157-3 -flatten_hierarchy none
set_property LOC SLICE_X8Y11      [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
opt_design; place_design; route_design
write_checkpoint -force base.dcp
# 每个变体：open_checkpoint base.dcp → set_property ROUTE <该网> {} → set_property ROUTE <新路径>
write_bitstream -force v_NN.bit
```

---

## 4. 地址层：帧号怎么定

### 4.1 块表（frame_blocks）【实测】

7,987 个语料的帧占用统计 → 按 band 切分 → **1,038 块 / 36,260 帧 = 7 × 5,180 精确闭合**。

| 块类型 | 帧数 | 数量 |
|---|---|---|
| `clb` | 36 | 763 |
| `gap28` | 28 | 245 |
| `io72` | 72 | 14 |
| `edge30` | 30 | 12 |
| `pcie` | 246 | 2 |
| `x36` | 36 | 2 |

### 4.2 行字规则 wof(Y)【实测】

Y 差分实验（只改片内行号，同列）：

```
yA: SLICE_X8Y20 → 只有 word 40 有 INIT 位     40 = 2×20
yB: SLICE_X8Y24 → 只有 word 48 有 INIT 位     48 = 2×24
⇒ word = 2*(Y%50) + parity；Y≥25 时 +1（跳过 word 50 校验字）
```

### 4.3 INT tile 的块归属【实测】

- `INT_L_Xn` → 同 band 内 `grid_col = gx − 1` 的 clb 块；
- `INT_R_Xn` → `grid_col = gx + 1`；
- 夹缝列（VBRK / BRAM 接口 / IO 接口）两侧**共用同一块**。

验证：45 个 LOC 地面真值锚点 + 7 个几何锚点（S13 解码、S24 走线），全部一致。
反例：**"每列块 +36"的递推假设只有 73/144 成立**，且同一块能被 4 个不同 tile "成功"解码（S31 T4b）⇒ 基址只能查表 + 锚点，不能递推。

---

## 5. 同质性：能不能拿一份表套所有 tile

| 维度 | 检验 | 结论 |
|---|---|---|
| 随邻接位置变化 | 14 tile × 6 类邻接 | **不变**（族名逐字节相同）|
| 随 tile_type 变（L vs R）| 各 12,168 cell | 坐标全同（1,598），同坐标归属 **384 同 / 1,214 不同** ⇒ 同一物理 mux、各自命名 |
| 夹缝列是否独立 | 181 PIP 按 (块基址, word, 族, 坐标集) 去重 | **181 → 140**，41 组重复全是 L/R 同名对 |
| 位空间覆盖 | 1,664 vs 1,598 | **96.03%**，缺 66 格（offset 0..3，CLB 混合区）|

**结论**：族集合与相对位坐标**全片统一**；绝对帧号**必须查表**。

---

## 6. 三条独立校验（缺一不算成立）

| 校验 | 方法 | 结果 | 它排除了什么 |
|---|---|---|---|
| **CSP 反解** | 48 变量、C1 覆盖、C2 掩码、MRV 回溯 | **48/48 unique，0 ambiguous** | 位集能唯一确定源 |
| **ROUTE 真值** | 与 Vivado 6 条网的 `ROUTE` 串逐 token 比 | **6/6 一致** | 表与工具一致，不是自洽的错觉 |
| **写回注入** | 改 `.bit` 位 + 重算校验 | **864/864** | 位语义在硬件层面成立 |

补充：绝对态判读 **636 tile / 1,196 次判读 / 0 歧义 / 0 未解释位**；反向检验 **TP 366 / FP 0 / AMBIG 0 / FN 6**（6 个 FN 全是 always ppip）。

---

## 7. 七种"定向"实验及其用途

| # | 类型 | 用途 | 代表性数字 |
|---|---|---|---|
| 1 | 单变量源切换差分 | 测某条 PIP 的位 | 1,200 变体 / 0 冲突 |
| 2 | 绝对态判读（不差分） | 读整块 tile 状态 | 636 tile / 0 歧义 |
| 3 | 双位置交集 | 区分局部位 vs 网络位 | S61 剔除 4 个局部位 |
| 4 | 负对照（同设计重跑）| 证明无环境噪声 | 差分必须 = 0 |
| 5 | 语料频率统计（被动）| 排优先级 | 13,749 个 .bit |
| 6 | 结构对照（get_pips）| 族集合真值 | 3,737 / 209 |
| 7 | 写回注入 | 验证位语义 | 864/864 |

### 三条踩过的坑（都改变了方法）

- **小端解析**：同步字读成 `0x665599AA`、FDRI count = 0 ⇒ 现在强制先断言 count = 5,067,776。
- **未钉 PACKAGE_PIN 的"单变量"**：两个变体 IOB 落同一 site，配置 0 差异 ⇒ 现在差分前先比 `ROUTE`。
- **命中数仲裁**：同一块被 4 个 tile 解都得 12 unique ⇒ 现在只用 LOC 地面真值 + 几何锚点。

---

## 8. 遗留与未测

| 项 | 状态 |
|---|---|
| 66 格（offset 0..3）| 已归属 14 个；9 个点亮未归属；43 个从未点亮（其中 32 格在 13,749 个设计里零出现）【未测】|
| `(1,1,30)` | 出现 1,284 次，任何探针都不命中【未测】|
| 时钟树 | `edge30` 已定 BUFGCTRL/BUFHCE/BUFIO；`HCLK_*` 3,020 tile 无独立帧块【部分】|
| GTX | 7 quad 块已定位（`band_base − 272`，X1 半区 +5212）；通道平面 0/22/57/79；COMMON 在 w45【部分】|
| PCIE 700 tile | 【未测】|

---

## 9. 复现清单

| 步骤 | 命令 / 文件 |
|---|---|
| 拓扑 | `E:\v7work\db\prjxray\xc7vx485t\tilegrid.json` + `tileconn.json` + `tconn_v7.py` + `tileconn_v7_patch.json` |
| 位表 | `step03_pip\tilepipe.json` → `pip_bits`（`ingest_tilepipe.py`）|
| 位表→家族表 | `all_cells.json`（24,336 条，字段 `tile_type/family/src_wire/frame_off/parity/bit/sense`）|
| 地址 | `v7_law.sqlite.frame_blocks` + `v7re/tilemap.py` / `v7re/blockmap.py` |
| 反解 | `step03_pip/csp_imux.py`、`s13_solve3.py` |
| 走线 | `int_walk_v1.py`、`walk_v5.py`、`s13_solve3.py` |
| 校验 | `step03_pip/decode_clb.py`、`imux_decode.py`、`emit_v.py` |
| 证据报告 | `S9_CSP_DISAMBIG.md`、`S10_INT_WALK.md`、`S24_IO_WALK_CLOSURE.md`、`S30/S31`、`S37_BITSTREAM_BLOCKMAP.md`、`S38_INT_BASE_RULE.md` |

---
_配图见 [fig_int_tile_build.png](fig_int_tile_build.png)。_
