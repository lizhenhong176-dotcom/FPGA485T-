# PIP、mux、家族：物理形态与「长度」到底指什么

> 口径约定：【硬件事实】= Xilinx 公开架构文档写明的；【数据事实】= 本仓库实测可复算；【推断】= 有证据但未证死；【未测】= 没证据，禁止当结论讲。
> 器件：XC7VX485T-2FFG1761（VC707）。

---

## 1. 一条信号从 CLB 走到邻居 CLB，路上到底有什么

```
SLICE 的 LUT 输出 DO
   └─[PIP]→ LOGIC_OUTS_L12        （CLB 站点内的输出线，属于 CLB tile，不是 INT tile）
        └─[PIP]→ NR1BEG0          （INT tile 内：一条向北的单线 wire 的"起点"）
             └─[线本身]→ NR1END0  （同一根线在下一个 tile 的"终点"；单线只跨 1 个 tile）
                  └─[PIP]→ IMUX_L40  （INT tile 内：某个 CLB 输入的多路选择器）
                       └─[PIP]→ CLB 的 A1 引脚
```

每一段之间的那个「开关」就是一个 **PIP**。一根线从起点（`…BEG`）走到终点（`…END`），中间可能跨 1、2、4、6 个 tile，甚至跨一个 clock region。

---

## 2. PIP 是什么【硬件事实】

- PIP = **Programmable Interconnect Point**，一段可编程的连接点：把一条上游 wire 接到一条下游 wire。
- 它由**配置 SRAM 位**控制（在本项目里就是一个或几个 `(frame, word, bit)`），1/0 决定这个开关通或断。
- 物理上是传输门/缓冲开关（7 系列用 SRAM + 传输门/三态缓冲实现），**不是**软件里的路由表项。

【数据事实】一个 INT_L tile 的规模（本器件实测，`uniform=1`）：

| 量 | 值 |
|---|---|
| wire 数 | 600 |
| PIP 数 | **3,737** |
| 目的 wire 数 | 216 |
| 其中扇入>1（是 mux 的） | **172** 个，含 **3,693** 个 PIP |
| 扇入=1（直通） | **44** 个 PIP（`BYP_BOUNCE*`/`BYP_L*`/`FAN_BOUNCE*`/`FAN_L*` 各 1） |

对账：`3,693 + 44 = 3,737` ✔；`law_cells` 记 3,634 = 3,693 − 59（59 个族的 `VCC_WIRE` 常量输入被剔除，模板扇入 25 / 本库 24）→ `3,634 + 59 + 44 = 3,737` ✔（§69）。

---

## 3. mux 是什么、和 PIP / switch box 什么关系

| 概念 | 定义 | 关系 |
|---|---|---|
| **PIP** | 两段 wire 之间的一个受控开关（一条边） | 最小单位 |
| **mux** | **共用同一个目的 wire** 的一组 PIP | mux = 组内 PIP 的互斥集合；点亮哪个源由「哪几个 PIP 被配置为 1」决定 |
| **家族 family** | 本项目术语：一个目的 wire 及其全部候选源 | 一个 family ≡ 一个 mux（本库只记有 >1 个候选源的） |
| **switch box** | 一个 tile 内全部 mux + 直通构成的整张网 | INT tile 的 switch box = 172 个 mux + 44 条直通 |

【硬件事实】mux 的「互斥」不是布线工具的约定，而是电路事实：一个目的 wire 在某一时刻只能由一条源驱动，所以同一 mux 内的 PIP 不会同时点亮。

【数据事实】这一点在位流侧面可以验证：`L2` 槽位判据（`tamper_localize.py`）检查「一个槽位最多 1 个行格 + 码字必须是 `{1,2,7,11}`」，在 73,152 个槽位上 **0 违例**；反过来说非法组合（同一槽位两行同时亮）从未出现。

---

## 4. 「家族的长度」有两种，别混

### 4.1 长度一：扇入（这个 mux 有多少个候选源）—— 实测

`law_cells`（INT_L，`sense=1`）按 `(family, src)` 去重后 3,634 条：

| 扇入 | 族数 | 是哪些 |
|---|---|---|
| **24** | 64 | `IMUX_L0..L47`(48) + `BYP_ALT0..7`(8) + `FAN_BOUNCE*`(8) —— 就是 6×4 网格那一批 |
| **20** | 96 | 全部方向线族：`EE2BEG/WW2BEG/EE4BEG/WW4BEG/NE6BEG/NW6BEG/SE6BEG/SW6BEG/NN2BEG/SS2BEG/NL1BEG/SL1BEG/EL1BEG/ER1BEG/…` 各 4 个变体 |
| **18** | 2 | `LVB_L0`、`LVB_L12` |
| **16** | 6 | `CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1`（复合族，T34 core+drops+extras） |
| **12** | 3 | `LH0`、`LH(n)`、`LV_L18` |
| **10** | 1 | `LV_L0` |

合计 64+96+2+6+3+1 = **172 族** ✔，`feature` 合计 3,634 ✔。
（复算：`step03_pip/_q_fanin3.py`）

**所以「家族」不是按名字分的长短，而是按「一个目的 wire 有几个候选源」分档**：24 档 = 密集选择器，20 档 = 标准方向线选择器，12/10/16 档 = 长线与时钟的偏心结构。

### 4.2 长度二：这根线本身跨多远（tile 为单位）【硬件事实：命名规则】

7 系列的 wire 名字自带长度档，数字 = 跨几个 tile：

| 名字 | 长度 | 方向 | 例 |
|---|---|---|---|
| `NL1BEG/SL1BEG/EL1BEG/ER1BEG`、`WL1BEG/WR1BEG` | **1** | 单线 | 只跨 1 个 tile |
| `NN2BEG/SS2BEG/EE2BEG/WW2BEG`、`NE2BEG/SE2BEG/SW2BEG/NW2BEG` | **2** | 双线 | 跨 2 个 tile |
| `EE4BEG/WW4BEG` | **4** | 四线 | 跨 4 个 tile |
| `NE6BEG/NW6BEG/SE6BEG/SW6BEG/NN6BEG/SS6BEG` | **6** | 六线 | 跨 6 个 tile |
| `LV/LVB`（long vertical）、`LH`（long horizontal） | **长线** | 跨 clock region 级别 | 一条顶几十条 |

【数据事实】用 `tileconn.json`（17,928 条连接模式 / 148,622 对 wire）实测偏移（`_q_span_examples.py`）：

| wire | 自连偏移（跨几格） | 对外连接 |
|---|---|---|
| `LV_L0` | (0,1)(0,3)(0,5)(0,7)(0,9)(0,11)… | 到 `INT_L` 偏移最大 **17 行** |
| `LVB_L0` | 同上，最大 11 行 | 到 `INT_L` 偏移 11 行 |
| `LH0` | — | 到 `INT_L` 偏移 **14…23 列**（横穿大半行） |
| `SE6BEG0` | — | 到 `INT_R` 偏移 (1,1)(1,2)(1,3) |
| `EE2BEG0` | — | 到 `INT_R` 偏移 (1,0) |
| `EE4BEG0` | — | 到 `INT_R` 偏移 (2,0) |
| `IMUX_L40`、`BYP_ALT0`、`FAN_BOUNCE7` | **无自连** | 目的 wire 只在本 tile 内，不跨格 |

**结论（可直接讲）**：172 族里 **只有 4 族的目的 wire 是长线**（`LV_L0`、`LV_L18`、`LVB_L0`、`LVB_L12`），其余 168 族的 mux 都只在本 tile 里工作，**「长度」体现在它接收的源线是 1/2/4/6 档还是长线**。

【数据事实】`band = 50 行 = 一个 clock region`（`band_rows=50`、`runtime 5,246 帧/band`），这正是长线的活动尺度——所以「长线跨区」和「band 边界」是同一件事的两面。

---

## 5. 一个完整的例子（把三种「长度」一次说清）

目标：`SLICE_X8Y20` 的 A1 输入，被 `INT_L_X8Y20` 的 `IMUX_L40` 家族驱动。

| 项 | 值 | 口径 |
|---|---|---|
| 家族 | `IMUX_L40` | 数据 |
| 扇入 | 24 个候选源 | 数据 |
| 目的 wire 跨度 | 本 tile，0 跳 | 数据 |
| 位池 | 26 帧 × 2 word × 32 bit = 1,664 位 | 数据（`frame_off 0..25`） |
| 该族实际占 | 10 个格：frame_off 16..25、parity 0、bit 6/7 | 数据 |
| 地址 | base 31,752 → frame 31,768 起，word 40/41 | 数据 |
| 若选中的源是 `EE2END0` | 该源是一条跨 2 tile 的双线，来自上一/下一 tile | 硬件事实 |

也就是说：**「家族的长度」= 扇入 24；「线的长度」= 源线 2 tile；「家族的跨度」= 目的 wire 不出本 tile**。三句话都对，且互不冲突。

---

## 6. 不能说什么（边界）

- 【未测】INT tile 内部这个 mux 是「传输门树」还是「多级缓冲树」、几级、晶体管怎么排——本仓库没有任何数据能支撑，讲成"开关盒里有一棵 24 选 1 的树"只是示意。
- 【未测】`IMUX_L40` 的 24 个源在硅片上的物理相邻关系（是不是真的按方向排成一圈）。
- 【推断】`6×4` 的组轴/码轴只保证「组合逻辑上的乘积」，**不保证物理排成 6 行 4 列**（§10.3）。
- 【数据事实但有限】「172 族」是 INT tile 内的 mux 数，不含 CLB/BRAM/DSP 站点内部的位（那是另一套 `clb_cells`）。

---

## 7. 复算命令

```bash
python step03_pip/_q_fanin3.py        # 扇入分布 24/20/18/16/12/10
python step03_pip/_q_family_span.py   # 172 族按目的 wire 跨度分类
python step03_pip/_q_span_examples.py # 代表线的 tileconn 偏移
python step03_pip/_q_pip_reconcile.py # 3,737 / 3,693 / 44 对账
```

---

## 8. 参考资料

- `STATUS.md` §69（数量对账）、§74（row 三义）、§76（复用层次）、§79（行列是数据还是命名）
- `step03_pip/ROW_BAND_SWITCHBOX_EXPLAINED.md`（row/band/switch box 概念）
- `step03_pip/PIP_REUSE_WHERE_AND_LAW.md`（七条复用规律）
- `E:\v7work\db\prjxray\xc7vx485t\tileconn.json`（wire 连接与偏移）
