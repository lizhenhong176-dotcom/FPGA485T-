# 帧结构 · 寻址 · fuzz 流程 · PIP 复用 —— 新人上手讲解

器件：`xc7vx485tffg1157-3`　编写日期：2026-11-15　配图：`fig_frame_addressing.png`

标注约定：**【实测】**= 本项目实验/数据直接测得；**【推断】**= 由实测外推、未直接验证；**【未测】**= 尚无证据。

---

## 第 1 章　帧结构总览

**输入**：一个 `20,273,538` 字节的 `.bit` 文件。
**操作**：按「文件层 → 命令层 → 帧层」三层拆解（见图①）。

```
文件层    [ASCII 头 150B][同步 AA995566][包 1][包 2]...[包 N][尾部]
命令层     TIMER  IDCODE  COR  WCFG   FDRI(头)+type2(count=5,067,776)  CRC  START
帧层       帧 0 [word0..word100]  帧 1 [word0..word100]  ...  帧 50,175
```

**输出**：`50,176 × 101 = 5,067,776` 个 32 位字。

**判据**：若解析出的 FDRI type2 count ≠ `5,067,776`，**判定解析器失败**（多半是小端误读——小端会把同步字读成 `0x665599AA` 且 count 解出 0）。【实测】S26/S27、`/opt/lzh/step18/holescan_all.py`

> 关键点：同步字在**字节偏移 150**，不是 4 字节对齐的 0/4/8。【实测】逐字节搜索 `AA 99 55 66` 得 offset 150。
> 整个配置区只由**一次** FDRI burst 写满：count 恰等于帧数×字宽，且数据区内没有第二个同步字。【实测】S31

---

## 第 2 章　地址空间：7 band × 5,180 帧

**输入**：帧号 `f ∈ [0, 50176)`。
**操作**：把帧切成「band 内块序列」（见图②③）。

```
band0  0 ................ 5179     ┐
band1  5180 ............. 10359    │  每 band 5,180 帧
band2  10360 ............ 15539    │  150 块（band1/2 为 144 块 + PCIE 246 帧）
...                                │
band6  31080 ............ 36259    ┘
尾部   36260 ........... 50175        13,916 帧（IO / GTX / CFG 侧）
```

**输出**：`frame_blocks` 表，**1,038 块 / 36,260 帧 / 7 × 5,180 精确闭合**。【实测】S37

| 块类型 | 尺寸（帧） | 含义 |
|---|---|---|
| `clb` | 36 | CLB 列（兼载两侧 INT 的 mux 位）|
| `gap28` | 28 | BRAM / DSP / 接口列 |
| `io72` | 72 | IO 列 |
| `edge30` | 30 | 时钟脊（BUFGCTRL / BUFHCE / BUFIO）|
| `pcie` | 246 | PCIE 区 |
| `x36` | 36 | 其它 |

每 band 签名（band0/3/4/6）：`111×36 + 35×28 + 2×30 + 2×72 = 5,180`。【实测】`frame_blocks` 预算校验

**判据**：若某个 band 的块尺寸求和 ≠ 5,180，**判定块表损坏**（不要继续用它算地址）。

---

## 第 3 章　三坐标律与手算示例

**输入**：tile 名 + 片内行号 Y + `(frame_off, parity, bit)`。
**操作**：三坐标律

```
frame = block_base + frame_off
word  = wof(Y) + parity,   wof(y) = 2*(y%50) + (y%50>=25 ? 1 : 0)
bit   = raw % 32            （raw = prjxray 的 frame_off_bit，>=32 时进位到 parity）
```

**手算示例**：tile `INT_L_X6Y11`、`Y=11`、`parity=1`、`bit=7`（该坐标在 S70 实测为 `CE_SOURCE_FABRIC`）

| 步骤 | 计算 | 结果 | 标注 | 出处 |
|---|---|---|---|---|
| ① 查块基址 | `INT_L_X6Y11` → band0、grid_col 16 的 clb 块 | `block_base = 31680` | 【实测】 | S38 / S24 走线真值 |
| ② 帧号 | `31680 + frame_off=1` | **`frame = 31681`** | 【实测】 | 同上 |
| ③ 行字基值 | `Y%50 = 11 < 25` → `wof = 2×11` | `wof = 22` | 【实测】 | S30 半带规则、S27 Y 差分 |
| ④ 字号 | `22 + parity=1` | **`word = 23`** | 【实测】 | S70 |
| ⑤ 位号 | `raw % 32 = 7` | **`bit = 7`** | 【实测】 | S70 |

**输出**：`(frame, word, bit) = (31681, 23, 7)`。

**判据**：若在 31681 帧 23 字第 7 位上读到的值与 S70 记录不一致（CE 接端口时为 1、CE 恒 1 时为 0），**判定块基址或行字规则用错**。

> **半带跳变**：`Y=24 → wof=48`、`Y=25 → wof=51`（跳过 50）。原因：`word 50` 在该行让位给帧级校验字。见第 4 章。【实测】S27 Y 差分实验（yA=Y20→word 40，yB=Y24→word 48）

---

## 第 4 章　位空间、家族与 66 格

**输入**：一个 INT tile 名。
**操作**：`26 帧 × 2 word × 32 bit = 1,664` 个位位置，与 172 个家族的 cell 集合求交（见图⑤）。

**输出**：

| 量 | 值 | 出处 |
|---|---|---|
| 位空间 | 1,664 | 26×2×32 |
| 有主位 | **1,598（96.03%）** | `all_cells.json` INT_L 侧 |
| 家族数 | 172 / 侧 | 同上 |
| 每源占位 | 2 位（102 族）或 5 位（70 族）| S65 |
| 空洞 | 66 格（off0..3）| S67 |

块内 offset 布局（图⑤）：

```
off 0 .. 15 | off 16 .. 25 | 26..29 | off 30 .. 35
INT 控制家族 | IMUX 池 48 mux | 少量   | AFFMUX / CARRY4 / INIT / FF 控制
+ CLB 的 A5FF/PRECYINIT（混合区）
```

**判据**：若把 `off 30..35` 当 IMUX 用，或在 `off 0..3` 上找不到家族就判"该位无效"，**判定失败**——`off 0..3` 是 INT 与 CLB 的混合区（S67），`off 30..35` 是 CLB 侧特征区（S42/S43）。

> **word 50 的三种身份**（容易踩）：fabric 块（CLB/INT/BRAM/DSP）里是**帧级校验/ECC**；`io72/edge30/CMT` 块里是**真实配置字**（S58 的 `BUFR_DIVIDE` 就落在 w50）；GTX 块里又是校验字（S60）。【实测】

---

## 第 5 章　PIP 复用规律

**输入**：`all_cells.json` 里某个 `(tile_type, family)` 的全部 cell。
**操作**：按 `src_wire` 分组，统计每源位数、每 cell 被几个源置 1。

**输出（可复算公式）**：

```
家族 = (tile_type, 目标 wire)           —— 同族 = 同一棵 mux 树
N = 该族互斥源个数
k = 该族 cell 数（位池大小）
N = a × b    且    k = a + b            —— 344/344 家族零例外
每源占位 = 2（段族）或 5（IMUX/BYP/FAN/GCLK/CTRL/GFAN）
跨族共享 = 0                            —— 1,598/1,598
```

两级 one-hot：

```
5 位族（N=24）:  [1 位隐式组选][4 位显式成员选]
                 组线只写选中的那条 1，其余组线一次都不写
                 4 条成员线全写：选中=1，其余 3 个明确写 0
2 位族（N=20）:  [组位][成员位]  —— 两级都显式，各写 1 位
```

### 反例 1：看似共享、实际不共享

`IMUX_L7` 与 `IMUX_L4` 若只用 `(frame_off, bit)` 统计，会出现**大量重叠 cell**；加上 `parity` 后两者**完全分离**。
⇒ 位坐标必须写成三元组 `(frame_off, parity, bit)`。【实测】S9 的"假共享"教训、REUSE_RULES §3

### 反例 2：看似 2 位、实际 5 位

`BYP_ALT0`（N=24）如果按"每源 2 位"的段族假设解码，会漏掉 3 个"必须为 0"的位；结果同一个观测位集能同时匹配多个源 ⇒ 判成 AMBIGUOUS 或 WRONG。
⇒ 解码时 `ones ⊆ 观测` **且** `zeros ∩ 观测 = ∅` 两个条件都要用。【实测】S16 的 6 条 FN、S65 的 70/70 判别

**判据**：若某个家族的 `N ≠ a×b` 或 `k ≠ a+b`，**判定该族不是 one-hot 家族**（应改判为码字/时钟网络类，见 REUSE_RULES §6）。

---

## 第 6 章　fuzz 实验流程（四段式 + 脚本骨架）

### 6.1 设计

**输入**：要测的属性 + 目标 site（如 `SLICE_X10Y20`）。
**操作**：建「基线 + 变体」两份设计，**只改一个属性**；`LOC` / `BEL` 在 synth 之后施加；LUT 加 `LOCK_PINS`。
**输出**：两份 `.bit`。
**判据**：若两份设计的 `ROUTE` 完全相同却出现非零差分，**判定差分不可信**（先查 IOB 落点是否相同——S21 的教训）。

### 6.2 构建（远端骨架）

```tcl
# build.tcl
set f $env(SRC); set base $env(JOB)
read_verilog $f
synth_design -top top -part xc7vx485tffg1157-3 -flatten_hierarchy none   ;# part 必须显式
set_property CFGBVS GND        [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
# LOCAL/BEL/LOCK_PINS 必须在 synth 之后
set_property LOC  $env(PROBE_LOC) [get_cells -hierarchical -filter {IS_PRIMITIVE && NAME !~ "*/*" && (REF_NAME =~ LUT* || REF_NAME =~ FD* || REF_NAME =~ CARRY* || REF_NAME =~ RAM* || REF_NAME =~ SRLC*)}]
set_property SEVERITY Warning [get_drc_checks NSTD-1]
set_property SEVERITY Warning [get_drc_checks UCIO-1]
opt_design; place_design; route_design
write_bitstream -force /opt/lzh/work/${base}.bit
puts "DONE $base"
```

```bash
#!/bin/bash
cd /opt/lzh/work || exit 1
export LANG=C.UTF-8 LC_ALL=C.UTF-8; unset LANGUAGE      # 缺这三行 Vivado 会 rc=134 abort
export PATH=/opt/lzh/Xilinx/Vivado/2017.2/bin:$PATH
JOB=base SRC=base.v PROBE_LOC=SLICE_X10Y20 vivado -mode batch -nojournal -nolog -source build.tcl &
JOB=var  SRC=var.v  PROBE_LOC=SLICE_X10Y20 vivado -mode batch -nojournal -nolog -source build.tcl &
wait; echo ALLDONE
```

### 6.3 差分与判读

```python
# 大端解析 + 自检
arr = np.frombuffer(data[p:p+4*n], dtype='>u4').reshape(50176, 101)
assert arr.size == 50176*101          # 若不等 => 解析失败
x = (A != B)
for f, w in zip(*np.nonzero(x)):
    v = int(A[f,w]) ^ int(B[f,w]); b = 0
    while v:
        if v & 1: print(f, w, b, 'off=%d word=%d bit=%d' % (f-base, w, b))
        v >>= 1; b += 1
```

**输出**：`(frame, word, bit)` 三元组列表。
**判据**：
- 若差分落在骨架以为的块之外（`f-base` 不在 0..35），**判定位归属错误**；
- 若 `word == 50`，**先当校验字处理、单独计数**，不得混入内容位（S55 的首次误判即此）；
- 若差分位集在两处 LOC 不一致，**判定归属失败**（取交集，差集不解释）。

### 6.4 常见报错 → 根因 → 修法

| 报错 | 根因 | 修法 |
|---|---|---|
| `locale::facet::_S_create_c_locale name not valid`（rc=134）| WSL 未装 locale | 脚本头 `export LANG=C.UTF-8 LC_ALL=C.UTF-8; unset LANGUAGE` |
| `[Vivado 12-1410] Illegal to place instance ... site type (SLICEL) does not match (SRLC32E)` | 放错 site 类型 | RAM/SRL 只能放 **SLICEM**（偶 X 的 `CLBLM_*`） |
| `[Vivado 12-2285] Cannot set LOC property ... Cannot expand macro instance` | 对原语宏整体 LOC | 改在 Verilog 里写 `(* LOC="SLICE_X10Y20" *)` |
| `[Vivado 12-1411] PACKAGE_PIN is occupied by port ...` | 端口引脚重复 | 一次一脚写，`foreach` 会重复分配 |
| `[Common 17-163] Missing value for option 'objects'` | LOC 写在 synth 之前，`get_cells` 为空 | LOC/BEL/LOCK_PINS 一律放 synth 之后 |
| `[DRC CFGBVS-4]` | CONFIG_VOLTAGE 与 CFGBVS 不配 | `set_property CFGBVS GND [current_design]` |
| `[Vivado 12-1345] Error(s) found during DRC. Bitgen not run` | NSTD-1/UCIO-1 未豁免 | `set_property SEVERITY Warning [get_drc_checks NSTD-1]`（**不加花括号**）|
| FDRI count 解出 0 / 13 亿 | 小端误读 / count 掩码用 `0x7fffffff` | 大端 + 掩码 `0x7FFFFFF` |

---

## 第 7 章　为什么这样设计能保证受控（证伪视角）

1. **若变体之间不止一个变量**（例如换了 IOB 引脚但没察觉），**判定实验作废**——必须先用 `ROUTE` 或引脚表确认"唯一变量"成立（S21 首次失败的原因）。
2. **若只在单点 LOC 上测归属**，**判定归属不成立**——必须两个不同 LOC 各测一次取交集（S61 的 LOC 扫描噪声、S69/S70 的两位置一致性）。
3. **若不做"绝对态判读"**（只在两个变体间差分），**判定遗漏"基线已置 1"的位**——差分看不见参考流里本来就置 1 的 cell。
4. **若把 `word 50` 混进内容位统计**，**判定统计失败**——它是校验/ECC 字（fabric 块），或真实配置字（io72/CMT/GTX 块），两种身份必须按块类型区分。
5. **若用相邻块外推基址**（例如"每列块 +36"），**判定地址错误**——实测 144 条基址里只有 73 条与"每列一块"假设一致；基址必须查 `frame_blocks` 序列。

补充两条硬规则：**交叉自证**（同一结论必须由另一脚本、另一批构建复核，否则只能标 `unverified`）；**负对照**（同设计重跑一次，差分必须为 0）。

---

## 第 8 章　新人上手流程

| 步骤 | 输入 | 操作 | 输出 | 判据（失败即停） |
|---|---|---|---|---|
| 1 环境 | 远端主机 | `ssh` → `wsl -d Ubuntu -u root --` | 能跑 `vivado -version` | 若报 locale abort，先补环境变量 |
| 2 读料 | `STATUS.md`、`REUSE_RULES.md` | 读最近 2–3 节 | 知道哪些做过 | 若结论已存在，别再重跑 |
| 3 选目标 | 一个属性 + 一个 site | 确认 site 类型（SLICEM/SLICEL）| `LOC` 值 | 若 site 类型不符，换 site |
| 4 建两版 | 基线/变体 `.v` | `build.tcl` 两版 | 两份 `.bit` | 若 DRC 未过或 part 不显式，重跑 |
| 5 自检 | 两份 `.bit` | 大端解析 | FDRI count | 若 ≠ 5,067,776，解析器错 |
| 6 差分 | 两份帧数组 | 逐帧逐字异或 | 三元组列表 | 若落在预期块外，归属错 |
| 7 双位置 | 同上换一个 LOC | 重复 4–6 | 两个位集 | 若交集为空，归属不成立 |
| 8 判读 | 位集 + 家族表 | 匹配 family/pattern | 结论（带三色）| 若无法归属，写进"未测"清单 |
| 9 落库 | 结论 | STATUS + `v7_verified` | 可复算记录 | 若无出处，不许写结论 |

---

## 第 9 章　术语与索引

| 术语 | 定义 |
|---|---|
| 帧（frame）| 101 个 32 位字的一行配置；485T 共 50,176 帧 |
| 块（block）| 连续若干帧组成的配置单元；尺寸 28/30/36/72/246 |
| 家族（family）| `(tile_type, 目标 wire)`：一组互斥源 + 驱动它们的位池 |
| 位池（bit pool）| 一个家族占用的 k 个 cell |
| 隐式位 / 显式位 | 组选位只写选中项（隐式）；成员位四条全写（显式）|
| ppip | 永远导通的连接，不占配置位（2,598 条）|
| END 侧 | `*END*` 目的线的 pip，不占配置位（2,228 条）|

文件索引：`REUSE_RULES.md`（复用法则 v3）、`all_cells.json`（位表）、`frame_blocks` 表（块清单）、`S67/S69/S70`（66 格归属）、`CHEATSHEET.md`（速查）。

**未测清单**：offset 2..3 的 32 格（13,749 个设计里零出现，按要求未标"不配置"）；9 个点亮未归属格；`(1,1,30)` 1,284 次出现但无任何探针命中。【未测】

---
_配图见 [fig_frame_addressing.png](fig_frame_addressing.png)。_
