# T56 同类型 tile PIP 开关盒最小实验设计单

> 上位对象判定见 [`T55_OBJECT_JUDGMENT_INIT_VS_PIP.md`](T55_OBJECT_JUDGMENT_INIT_VS_PIP.md)：
> 上一轮「同类型 PASS / CLBLL FAIL」测的是 **LUT6 INIT 数据位（CLB 配置位）**，不是 PIP 开关盒。
> 本文只设计 PIP 对象的最小实验。**执行状态：离线核验已完成；实机待执行（T5）。**

## 0. 一句话结论

【数据事实】在同一 `tile_type`（`INT_L`）下选 `INT_L_X6Y11`（已实测）与 `INT_L_X6Y61`（待测）这一对，
把唯一自变量钉死为 `INT_L_X6Y61/INT_L.NR1END0->>IMUX_L8` 的 5 个配置格，
判据为归一化三元组集合 `(off, word, bit)` 逐位相等，离线侧全部前置条件已闭合：

| 前置条件 | 结果 | 证据 |
|---|---|---|
| 地址律 `word = 2*(y%50)+parity`（≥50 再 +1） | **24/24** 命中；去掉 +1 只剩 **12/24** | `t56_pip_switchbox_offline.py` S1 |
| T1 的 25 个换源实测与 law 预测 | **25/25** 命中（XOR 语义，剥离 2 个 BEG 常量位） | S2，数据源 `step03_pip/reuse_bits.json` |
| `VCC_WIRE` = 零态（默认/未选态） | 实测集 == `abs(NR1END0)`，即编码为空集 | S2 |
| 判据能否拒绝假差分 | 突变测试 **6/6**（真值 PASS，5 类假差分全 FAIL） | S4 |
| T1 与 T2 的归一化集合相等 | 两条断言通过 | S3 |

**因此本设计的不确定性只剩「实机是否复现」这一项，而不在地址/编码/判据层面。**

## 1. 对象与边界（先把口径锁死）

| 维度 | 本实验的对象 | 明确不属于本实验 |
|---|---|---|
| 数据类型 | INT mux 选择位（`law_cells` 里 `family=IMUX_L8`） | CLB 的 `INIT`/`SR`/`FF` 配置位 |
| 帧位置 | INT 块 `frame_off` **16..25**（parity=0 ⇒ 全偶数 word） | CLB 块 `base+32..35`（上一轮 INIT 实验的位置） |
| 编码形状 | 一个 mux = 24 源共享 **10 个格**，每源 5 格 | INIT = 64 feature : 64 独立格（1:1 纯数据） |
| 站点侧 | 只作为**通道**（`CLBLL_IMUX8->>CLBLL_LL_A5`），不作为观测对象 | `CLBLL_LL_A` 等 site PIP 的编码本身 |

【硬件事实】`BEG->END` 的 `tileconn`（本设计里的 `NR1BEG0 → NR1END0`）是**固定连接，不是 mux**（`AGENTS.md` 纪律条）。
【数据事实】这 24 个源、10 个格的结构来自 `v7_law.sqlite:law_cells`（`tile_type=INT_L AND family=IMUX_L8`），
与路由模板 `templates/INT_L.json`（25 源，多一个常量源 `VCC_WIRE`）的差集恰为那一个常量源（S0 断言）。

## 2. A1：同类型 tile 对与坐标

| 项 | T1（对照，已实测） | T2（本实验，待测） |
|---|---|---|
| tile | `INT_L_X6Y11` | **`INT_L_X6Y61`** |
| tile_type | `INT_L` | `INT_L`（同类型） |
| col / y / band | 6 / 11 / 6 | 6 / 61 / 5 |
| 块基帧 `base` | **31680** | **26434** |
| word 基址 | 22 | 22（`2*(y%50)`，11 与 61 同余） |
| 站点 | `SLICE_X8Y11`（`CLBLL_L`，grid_col 16） | `SLICE_X8Y60/61`（`CLBLL_L`，grid_col 16） |
| 数据来源 | `reuse_bits.json` 25 条实测 + `RESULTS.md` | 本设计单预测 |

### 2.1 为什么这一对是「最小变量」

【数据事实】`y=11` 与 `y=61` 满足 `11 % 50 == 61 % 50 == 11`，故

```
word = 2*(y%50) + parity        # 两者都落在 word 22（IMUX_L8 全族 parity=0）
frame_abs = base + frame_off    # 唯一差别：base 31680 -> 26434，Δ = -5246
```

即：**除「块基帧整体平移」外，两个 tile 的观测位坐标完全相同**。这是一次严格意义上的单变量实验——
若 T2 的归一化集合与 T1 一致，说明编码律随 `base` 平移而不变；若不一致，差异只能来自 switchbox 本身
（tile 内的物理接线），而不能归因于 base/word 计算。

### 2.2 base 的可信度（两条独立表 + 三次实测）

| 证据 | 内容 |
|---|---|
| `far_bands(band=5,col=6).start_frame` | 26434 |
| `clb_blocks(grid_col=16, band=1).base_frame` | 26434（`clb_blocks` 的 band 序与 `far_bands` 相反，同址互证） |
| 实测点 Y=50 / 52 / 60 | 帧 26442/26448（off 8/14），word 1/5/21，含 +1 修正后 24/24 全中 → band5 的 base 已由三次删除实验独立验证 |

### 2.3 候选对的反例（为什么不是别的 tile）

| 候选 | 否决理由 |
|---|---|
| `INT_L_X6Y10` | `y=10 %50 = 10` ⇒ word 基址 20 ≠ 22；且它是 T1 的 BEG 母本，换它等于把两个变量一起动 |
| `INT_L_X8Y11` | col 从 6 变 8：列码（`(i//8)` 奇偶规则，744/744）与列几何同时改变，违反单变量 |
| `INT_L_X6Y62` | 可用，但 `61` 与 `11` 的 word 基址完全同余，是更干净的选择；62 留作备选（R3） |

【数据事实】站点存在性已核：`clb_tiles` 中 `SLICE_X8Y60`、`SLICE_X8Y61` 均为 `CLBLL_L`、`grid_col=16`、`inst=0`；
`law_tiles` 中 `INT_L_X6Y60`、`INT_L_X6Y61` 均存在（`clock_region=0`）。

## 3. A2：具体 PIP connection 与观测位

### 3.1 链路五段（4 个 PIP + 1 个 tileconn）

信号路径：`lut_a(CLBLL_L_X6Y60.A6LUT) → n1 → lut_b(CLBLL_L_X6Y61.A6LUT).I0`

| # | 名字 | 所在 tile | 性质 |
|---|---|---|---|
| 1 | `CLBLL_L_X6Y61/CLBLL_L.CLBLL_LL_A->CLBLL_LOGIC_OUTS12` | 站点 | 站点输出，由 BEL/A6LUT 决定（必然） |
| 2 | `INT_L_X6Y60/INT_L.LOGIC_OUTS_L12->>NR1BEG0` | INT | **BEG，路由器选择**（T1 实测为 `LOGIC_OUTS_L12`；T2 以 preflight 为准，见 §7 R2） |
| 3 | `INT_L.NR1BEG0 ->[0,+1]-> INT_L.NR1END0` | tileconn | 固定连接，无编码位 |
| 4 | **`INT_L_X6Y61/INT_L.NR1END0->>IMUX_L8`** | INT | **本实验唯一自变量**（5 个配置格） |
| 5 | `CLBLL_L_X6Y61/CLBLL_L.CLBLL_IMUX8->CLBLL_LL_A5` | 站点 | 由 `LOCK_PINS {I0:A5}` 结构强制：`I0` 只能从 `CLBLL_IMUX8` 进入 |

**第 5 段是整个设计成立的关键技巧**：`top.xdc` 把 `lut_b` 的 `I0` 锁到物理引脚 `A5`，
于是网络必须经 `CLBLL_IMUX8` 进入 slice，而 INT 侧对应的就是 `IMUX_L8`。
这样 INT 的 mux 选择位成为**唯一可观测且唯一可变**的对象；`LOCK_PINS` 只固定引脚映射，**不锁布线**
（布线是否同构由 preflight 的 `pips_*.txt` 实测证明，不靠声明）。

### 3.2 观测位（T2 预测，绝对坐标）

【推断】由 law 的 5 格 × `base=26434` 推得（law 本身由 T1 的 25/25 实测背书）：

| 源 | 归一化 (off, word, bit) | 绝对帧 |
|---|---|---|
| `NR1END0`（基线 A） | (19,22,3) (22,22,2) (24,22,2) (25,22,2) | 26453, 26456, 26458, 26459 |
| `VCC_WIRE`（零态 B） | 空集 | — |
| `LOGIC_OUTS_L12`（C） | (19,22,3) (21,22,2) (22,22,2) (23,22,2) | 26453, 26455, 26456, 26457 |

对称差（本实验真正比较的量）：

- `B − A` = `{(26453,22,3), (26456,22,2), (26458,22,2), (26459,22,2)}`（4 位）
- `C − A` = `{(26453,22,3), (26455,22,2), (26456,22,2), (26457,22,2)}`（4 位）

### 3.3 位池结构与「为什么只能覆盖 6/10 格」

【数据事实】IMUX_L8 的 10 个格分两类：

- **6 个独热组格** `(16,2)(17,2)(18,3)(19,3)(20,2)(21,2)`，各被 4 个源置 1；
- **4 个共享格** `(22,2)(23,2)(24,2)(25,2)`，24 个源**全部**都写，其中置 1 的源数分别为 6/6/18/18。

【数据事实】穷举 24 个源的全部两两配对，`|XOR(src_i, src_j)|` **最大恒为 4**。
故 `A→C` 这次换源最多只能覆盖 4 位；`delete(A)` + `swap(C)` 合计覆盖
`{19,21,22,23} ∪ {19,22,24,25} = {19,21,22,23,24,25}` = **6/10 格**。
剩余 4 个独热格 `(16,17,18,20)` 需要另选 4 个源各做一次换源才能覆盖（见 §7 R5 的延伸实验）。

### 3.4 观测位提取方法（机器可读）

`v7re/steps/t56/` 下的 `t56_diff.py` 有两种模式（对应 SKILL 的 PURE / XOR 语义声明）：

```bash
# XOR：A 与 B 的对称差（本实验主判据）
python3 t56_diff.py xor A.bit B.bit --base 26434 --off 16-25 \
        --expect t56_switchbox_spec.json --key B_minus_A --json g4_B_minus_A.json

# PURE：B 在 off 16..25、word 22 上的绝对 1 位（证明 VCC_WIRE = 零态）
python3 t56_diff.py abs B.bit --base 26434 --off 16-25 --word 22 \
        --expect t56_switchbox_spec.json --key B_abs_in_window

# 负对照：同设计重跑必须 0 位
python3 t56_diff.py xor base/base.bit base2/base2.bit --base 26434 --off 16-25 --must-be-empty
```

输出统一为 `(off, word, bit)`，并**强制**打印 SKILL 要求的四个数：
`预测集大小 / 实测集大小 / missing / extra`；`word == 50`（ECC）单独成桶、不参与内容位比对；
落在窗口外的任何变化直接判 FAIL（不是忽略）。`--word` 只对 `abs` 生效（限定单个 word），
`xor` 模式刻意不提供该过滤——其它 word 的任何变化都必须作为 `extra` 暴露出来。

## 4. 相对坐标归一化规则

```
frame_abs = base + off                       # base 由 far_bands(band(y), col) 给出
word      = 2*(y%50) + parity                # parity 来自 law_cells；>=50 时再 +1（word 50 = ECC，每帧 100 数据字）
bit       = law_cells.bit                    # 0..31
norm      = (off, word, bit)                 # 判据比较的唯一形式
```

- `y` 取**观测 tile 的行号**（T2 为 61，word 基址 22）。
- `parity=0` 的族（本族全体）不触发 `+1` 分支；`+1` 由 S1 的 24 条实测行证明是必需的（否则 6 个 y 全错）。
- 归一化后 **T1 与 T2 的预测集合逐位相等**（S3 已断言），这是「同类 tile 可移植」的可证伪形式。

## 5. 构建清单（5 个构建，成本 ≈ 2 次布线 + 3 次 write_bitstream）

| 构建 | 做法 | 源 | 作用 |
|---|---|---|---|
| `base` | Vivado 整流程布线（X6Y60/61） | 路由器 | 布线母本；preflight 从这里读实际 PIP 与 BEG 源 |
| `base2` | 同设计**整流程重跑** | 路由器 | **负对照 C1**：`base2 − base` 必须 0 位（构建确定性） |
| `A` | `swap_source.py` 改 `base.dcp` | `NR1END0` | 把 mux 选择**钉死**在 law 已知源，消除「路由器恰好选了别的源」这一自由度 |
| `B` | 同上 | `VCC_WIRE` | 零态：`B−A` 应 = `abs(NR1END0)`；`abs(B)` 窗口内应为空 |
| `C` | 同上 | `LOGIC_OUTS_L12` | XOR：`C−A` 应为 4 位对称差 |

**为什么用 `swap_source.py` 而不是 `pip_edit.py`**：【数据事实】T1 的删除法（`pip_edit.py`，按 `DROP` 索引删 `pips[idx]`）
删掉的其实是 **BEG PIP**，不是 IMUX PIP——25 个条目的共有常量位恰为
`{(31690,20,7), (31693,20,7)}`（`LOGIC_OUTS_L12->>NR1BEG0` 的两格），且 `NR1END0` 条目的差分恰为这 2 位。
所以 `reuse_diff.py:9` 注释里的「baseline with the IMUX_L8 PIP removed」与实测不符；
`RESULTS.md:110` 的「PURE 绝对集」实际是「相对 `VCC_WIRE` 的 XOR」。按索引删除是错的，按名换源是对的。

## 6. A3（其一）：PASS / FAIL 判据

### 6.1 判定规则

**PASS** 需同时满足：

1. `base2 − base` = 0 位（构建确定性成立）；
2. `B − A` 归一化后 == `expected.B_minus_A`，`missing=0` 且 `extra=0`；
3. `C − A` 归一化后 == `expected.C_minus_A`，`missing=0` 且 `extra=0`；
4. `abs(B)` 在 off 16..25、**word 22** 上为空（`VCC_WIRE` 零态成立）；
5. `abs(A)` 在 off 16..25、word 22 上 == `expected.A_abs_word22`（4 位）；
6. 以上所有比较中，窗口 `off ∈ [16,25]` 之外零变化；ECC（word 50）单独计数、不计入内容位。

> **为什么 PURE 检查必须限定 `word 22`**：同一批 10 个帧里按 word 穿插着**同一个 band 内所有 50 行**的配置位。
> `word = 2*(y%50) + parity` ⇒ 在 band5（y∈[50,99]）内 `word 22` 唯一对应 `y=61`、`word 21` 唯一对应 `y=60`。
> 若不限定 word，`abs(B)` 会把 `lut_a` 那一行（y=60，word 20/21）的 input mux 位一起算进来，
> 于是「零态」永远不可能为空——这不是缺陷，而是把别人的格子当成了本 mux 的格子。
> 该限制由 `t56_diff.py --word 22` 实施，并在 §6.3 的单测里验证过（`--word 20` 返回 1 位、`--word 50` 返回 0 位）。

**FAIL** 的任一条件：`missing>0`；`extra>0`；出现窗口外变化；`abs(B)` 非空；`base2−base ≠ 0`（后者触发 R4，
只作废绝对集结论，XOR 判据仍可用）。

**为什么用 XOR 作主判据**：`B−A` 与 `C−A` 都不依赖 BEG 走线（同一条母本 DCP 上只改 sink mux），
也不依赖 base 之外的环境因素；而「绝对集」还额外依赖「参考流里到底哪条 PIP 被删」这一历史约定（见 §5 末尾）。

### 6.2 判据不是空转：突变测试 6/6

| 注入的假差分 | 期望 | 实测 |
|---|---|---|
| 真值原样 | PASS | PASS |
| 单帧偏移 +1 | FAIL | FAIL（missing 1 / extra 1） |
| 单 bit 改号 3→2 | FAIL | FAIL |
| 少一位 | FAIL | FAIL |
| 窗口外多一帧（off=40） | FAIL | FAIL |
| ECC 位混入（word 50） | PASS（已单列） | PASS |

### 6.3 判据工具本体的双路径实测（本地，真 bitstream）

**【数据事实】** 样本：本地一对真实 `.bit`，`codex_review_overhead_20261022/data/{a,b}.bit`，各 50,176 帧。
两者唯一差异帧为 **31750**（绝对），内容位 `word 20 bit 14/15`、ECC 位 `word 50 bit 0/12`。

`t56_diff.py` 与既有 `v7re/scripts/diff_frames.py` 在同一对 `.bit` 上的位集合**完全一致**（同帧号、同 word、同 bit）。

下表七条为**本次重跑**的真实输出（`--base 31730` 是刻意选的：它让绝对帧 31750 落在 `off=20`，即窗口 16..25 内；
用真实 base 时这些位会落在 `off=0`，属于窗口外，只用于验窗口分类，不用于验命中判定）。原文表格里
`abs --word 20` 那条曾写作 `(off 70, 20, 14)`，该 `off` 与 `--off 16-25` 的扫描范围矛盾（`abs` 只扫窗口内帧，
offs=100 型不可能被扫到），**已按实测改正**。

| # | 检验 | 命令要点 | 实测输出 | 判定/退出码 |
|---|---|---|---|---|
| 1 | 同文件自比 + `--must-be-empty` | `xor a.bit a.bit` | `内容位 0 / ECC 位 0 / 窗口外 0` | `PASS` / 0 |
| 2 | 合成期望（三元组）恰好命中 | `xor a.bit b.bit --expect spec --key tri` | `预测=2 实测=2 missing=0 extra=0` | `PASS` / 0 |
| 3 | 同一期望的**字符串**写法 | `--key str`（`"31750 20 14"`） | 同第 2 条，`预测=2 实测=2 missing=0 extra=0` | `PASS` / 0 |
| 4 | 空期望遇真差分 | `--key empty` | `预测=0 实测=2 missing=0 extra=2` | `FAIL` / 1 |
| 5 | `abs --word 20`（该 word 确有 1 位） | `abs b.bit --word 20` | `内容位 1`，`[(20, 20, 14)]` | `INFO` / 0 |
| 6 | `abs --word 50`（ECC 必须被跳过） | `abs b.bit --word 50` | `内容位 0 / ECC 位 0` | `INFO` / 0 |
| 7 | `abs --word 22` + 空期望 | `abs b.bit --word 22 --key empty` | `预测=0 实测=0 missing=0 extra=0` | `PASS` / 0 |
| 8 | 非法期望条目（2 元组） | `--key bad`（`[[31750,20]]`） | `ValueError: expected 条目必须是 3 个整数: [31750, 20]` | 非零退出（**拒绝报 PASS**） |

复现命令（PowerShell，本地）：

```powershell
$env:PYTHONIOENCODING='utf-8'
$d = Join-Path $env:TEMP 't56_63'; New-Item -ItemType Directory -Force $d | Out-Null
@'
{"expected": {
  "tri":  [[31750,20,14],[31750,20,15]],
  "str":  ["31750 20 14","31750 20 15"],
  "empty": []
}}
'@ | Set-Content -Encoding UTF8 (Join-Path $d 'spec.json')

$a='codex_review_overhead_20261022\data\a.bit'; $b='codex_review_overhead_20261022\data\b.bit'
$t='v7re\steps\t56\t56_diff.py'
python $t xor $a $a --base 31730 --off 16-25 --must-be-empty                                  # 1
python $t xor $a $b --base 31730 --off 16-25 --expect (Join-Path $d 'spec.json') --key tri     # 2
python $t xor $a $b --base 31730 --off 16-25 --expect (Join-Path $d 'spec.json') --key str     # 3
python $t xor $a $b --base 31730 --off 16-25 --expect (Join-Path $d 'spec.json') --key empty   # 4 -> exit 1
python $t abs $b --base 31730 --off 16-25 --word 20                                            # 5
python $t abs $b --base 31730 --off 16-25 --word 50                                            # 6
python $t abs $b --base 31730 --off 16-25 --word 22 --expect (Join-Path $d 'spec.json') --key empty  # 7
```

三条结论：

- **判据不过松**：第 2/3 条证明「恰好命中才算 PASS」；第 4 条证明「空期望遇非零差分必 FAIL」（用错参考流会被抓到）。
- **判据不过严**：第 5/7 条证明正常位集合不会被误杀；第 6 条证明 ECC 被单列、不参与内容位比对。
- **输入不静默降级**：第 8 条证明格式错误的期望集直接报错，不会「解析出 0 条 → 碰巧 PASS」。
  （`parse_expect()` 同时接受 `[frame,word,bit]` 与 `"frame word bit"` 两种写法；正式
  `t56_switchbox_spec.json` 本身是三元组，实机路径不依赖此兼容分支。）

## 7. A3（其二）：失败回退方案

| 编号 | 触发条件 | 回退动作 |
|---|---|---|
| **R1** | `swap_source.py` 报 `PIP not found` | 该 tile 的 IMUX 源集合与模板不符（结构性差异）。先用 `templates/INT_L.json: pip_defs`（字段序 `(src,dst)`）按 dst 分组复核；确缺则改用**按名删除**语义（`pip_edit` 显式删 `->>IMUX_L8`，禁止按索引删） |
| **R2** | preflight 显示 `n1` 未从 `IMUX_L8` 进入（或 site pip 不是 `IMUX8->A5`） | 先查 `LOCK_PINS`/`BEL` 是否被工具改写；若 sink 变成 `IMUX_L7` 等，用对应 family 的 law 重算预测（S3 的 `FAMILY` 常量一处可改） |
| **R3** | diff 帧落在窗口但对 `base` 系统性偏移 | 先用 `pip_bits` 的 24 条实测行回归地址律（S1），再决定换 `INT_L_X6Y62` 或换 band |
| **R4** | `base2 − base ≠ 0`（路由器不确定） | 放弃绝对集，**仅用同一 DCP 内的 A/B/C 做 XOR 判据**（判据仍有效，PURE 结论作废） |
| **R5** | 需要覆盖剩余 4 个独热格 `(16,17,18,20)` | 另选 4 个源（各占一个独热组）各做一次 swap，判据同构；本文已给出全 25 源在 T2 的预测表（`t56_switchbox_spec.json: table_all_sources_T2`），无需重算 |
| **R6** | 同 tile_type 源集合真出现冲突 | 退回 `PIP_ADDRESS_ENCODING_LAW.md §5` 的 **36 组行映射按族固化**作为输入（该文档已证明行映射不可导出、只能按族取表） |

## 8. 执行状态与证据分级

| 项 | 状态 | 证据 |
|---|---|---|
| 对象判定（不是 INIT 而是 PIP） | **done**（T1/T55） | `T55_OBJECT_JUDGMENT_INIT_VS_PIP.md` |
| 地址律 / 25 源编码 / 判据 / 归一化 | **verified（离线）** | `t56_pip_switchbox_offline.py` 全绿，退出码 0；`t56_switchbox_spec.json` 14850 字节 |
| 判据工具 | **verified（本地真实 bitstream）** | §6.3 的八条实测（含格式错误拒绝 PASS） |
| 实机 T2（`INT_L_X6Y61`） | **未执行（待 T5）** | 本文给出可执行脚本；未跑之前**不得**声称「同类 tile 的 PIP 可移植」 |

**执行后允许/不允许说的话**：

- 若 §6.1 六条全过 ⇒ 可说「`INT_L` 同类型 tile 之间，`IMUX_L8` 开关盒编码随 `base` 平移 -5246 后逐位一致」
  （仍**不能**推广到 `INT_R`、不能推广到其它 family、也不能说行映射可导出）。
- 若 `C−A` 过而 `B−A` 不过 ⇒ 优先怀疑 `VCC_WIRE` 零态假设，而不是 switchbox 结构。
- 若两者都不过且差异在窗口内呈现系统性偏移 ⇒ 走 R3，先怀疑 `base/word`，不要先怀疑编码律。

## 9. 已知风险与不适用边界

| 风险 | 说明 | 对策 |
|---|---|---|
| 路由器在 y=61 选别的源 | 不同 band 的布线拓扑未必与 y=11 相同 | 构建 `A` 已把选择钉死为 `NR1END0`；preflight 只要求「通道」成立，不要求路由器选哪个源 |
| 只测了「基础平移」，没测行映射 | 本文固定 col=6、band 内行号 11，**刻意不引入行映射变量** | 行映射 36 种、每族数据（`PIP_ADDRESS_ENCODING_LAW.md §5`），属另一实验 |
| part 混用 | INIT 实验族用 `xc7vx485tffg1157-3`，PIP 实验族用 `xc7vx485tffg1761-2` | **本实验必须用 `ffg1761-2`**（与 T1 的 PIP 批、与 law 库同 part）；换 part 会改时序驱动布线 |
| 位池覆盖不全 | `A→C` 只覆盖 10 格中的 6 格 | R5：另选 4 源补齐；不补齐不得声称「全位池 10/10 验证」 |
| 单一实现对拍 | 目前只有 law 一套预测 | 判据工具已与 `diff_frames.py` 交叉对拍（§6.3）；实机侧建议 T5 再用一个独立脚本复核一次 |

## 10. 复现命令

**离线（本地，已完成）**

```powershell
$env:PYTHONIOENCODING='utf-8'
python v7re\scripts\t56_pip_switchbox_offline.py        # 期望：全部自检通过，exit 0
```

**实机（远端，待执行）**

```powershell
# 1) 打包 t56 目录（含 swap_source.py）+ v7re 的解析器，落远端 /opt/lzh/t56/
# 2) 执行
cmd /c 'ssh -o BatchMode=yes fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -lc \"cd /opt/lzh/t56 && bash run_t56.sh\"'
```

预期输出：`G1 preflight OK` → `G2 负对照 0 位` → `PASS B-A` → `PASS C-A` → `PASS abs(B)@word22=0` → `PASS abs(A)@word22` → `PASS_T56`。

## 11. 产物清单

| 文件 | 作用 |
|---|---|
| [`v7re/scripts/t56_pip_switchbox_offline.py`](../../scripts/t56_pip_switchbox_offline.py) | 离线核验 S0–S5（结构/地址律/25 源/预测/突变/输出设计单） |
| [`v7re/steps/t56_switchbox_spec.json`](t56_switchbox_spec.json) | 机器可读设计单（tile 对、connection、5 构建、预期集、归一化、判据、回退、25 源预测表） |
| [`v7re/steps/t56/t56_top.v`](t56_top.v) / [`t56_top.xdc`](t56_top.xdc) | 设计源（与 T1 逐字一致，仅 LOC 换成 X8Y60/61） |
| [`t56_build.tcl`](t56_build.tcl) / [`t56_bit.tcl`](t56_bit.tcl) | 构建 + bitstream 生成（含 part 断言与 PIP 导出） |
| [`t56_diff.py`](t56_diff.py) | 判据工具（xor/abs，归一化，四数自证，ECC 单列） |
| [`run_t56.sh`](run_t56.sh) | 远端编排（G0 构建 → G1 preflight → G2 负对照 → G3 三换源 → G4 判据 → G5 manifest） |
| [`swap_source.py`](swap_source.py) | 换源工具（与 `step03_pip/swap_source.py` 逐字节一致，sha256 `2099C7BE…332039`；**本次复核时该文件在本目录缺失，已从源处复制补齐**，两侧哈希已复算一致） |

## 12. 复核记录（本次，v1.0 → v1.1）

本设计单在交付前做了一次**自复核**：不重写方案，只把「文中写的」与「本机能重算的」逐条对齐。
共发现 **5** 处不一致，全部已修。C1–C4 修完 spec 哈希不变（只是文案/文件层面）；
C5 必须改动生成器里的 `fallbacks` 字典，故 spec 从 `799050CA…E186ACAF` 变为
`FA53458C…1A4EBA54`——新哈希已二次重写验证过**稳定**（连跑两次生成器，哈希相同）。

| # | 位置 | 原状（v1.0） | 实测/根因 | 处理 |
|---|---|---|---|---|
| C1 | §11 产物表 / `t56/` 目录 | 表中列了 `swap_source.py`，但目录里没有该文件 | 该文件只在 `step03_pip/` 下；T2 打包脚本会因缺文件失败 | 已复制补齐，两侧 sha256 均为 `2099C7BE84F74458AB89653FBFB61707A0EC2C0AD36C50C1240ADADF4D332039`；§11 已注明 |
| C2 | §6.3 表 `abs --word 20` 行 | 结果写作 `(off 70, 20, 14)` | 该 `off` 与 `--off 16-25` 矛盾：`abs` 只扫 `base+off, off∈16..25`，永不返回 `off=70`；按原文命令实跑返回 **0 位**（INFO）。可复现的正确值是 `--base 31730` 时的 `(20, 20, 14)` | §6.3 整节重写为可复现命令 + 真实输出 |
| C3 | §6.3 全文 | 只有 7 条，且未覆盖 `--expect` 的两种写法与「格式错误必须报错」 | `parse_expect()` 遇到字符串条目会逐字符解包 → `ValueError`；这是潜在静默/崩溃点 | 新增第 3 条（字符串写法同结果）、第 8 条（2 元组期望必须非零退出）；工具已加 `parse_expect()` 兼容字符串并保留严格校验 |
| C4 | §5 与离线脚本汇总 | 文档写「5 个构建」，`t56_pip_switchbox_offline.py` 汇总行打印「预算 4 构建」 | 脚本汇总行是硬编码文案，与文档/BOM 实际 5 个构建（base/base2/A/B/C）不一致 | 脚本改为「预算 5 构建（base/base2/A/B/C）」，重跑 exit 0 |
| C5 | §7 回退表 vs `t56_switchbox_spec.json: fallbacks` | 文档是 R1–**R6**（R5=补 4 独热格、R6=退回行映射），spec 只有 R1–**R5** 且 R5 语义是「源集合冲突」 | 两边**编号错位**：spec 的 `R5_source_set_conflict` 对应文档的 R6，文档的 R5 在 spec 里根本不存在。机器可读设计单缺一条回退，按 R5 去查会查到语义不同的条目 | 生成器 `fallbacks` 改为 R1–R6 与文档一一对应（新增 `R5_hot_group_coverage_incomplete`，冲突项改为 `R6_source_set_conflict`），spec 重新生成后 `fallbacks` 计数 5 → **6** |

**复核后可复算的关键数字**（均为本次实测）：

| 项 | 值 | 复现 |
|---|---|---|
| 离线自检 | S0–S5 全绿，`exit 0` | §10 第一条命令 |
| spec 哈希（二次重写稳定） | `FA53458C93CF19CFE0898DD1E45BA831FEAC6DC0752EDF6859EF56E71A4EBA54`，14850 字节 | `Get-FileHash v7re\steps\t56_switchbox_spec.json` |
| spec `fallbacks` | 6 条，R1–R6 与 §7 逐项同名同义 | `python -c "import json,io;print(list(json.load(io.open(r'v7re\steps\t56_switchbox_spec.json',encoding='utf-8-sig'))['fallbacks']))"` |
| 判据矩阵 | 8/8 符合预期（含失败路径 exit 1） | §6.3 |
| 位集合与 `diff_frames.py` 对拍 | 完全一致 | §6.3 首段 |

**未变的结论层面**：tile 对、PIP connection、观测位预测集（`B_minus_A` / `C_minus_A` / `A_abs_word22` 各 4 位，
`B_abs_in_window` 为空）、归一化规则、§6.1 的 PASS 六条件，均未改动。
本次只改「可复现性、文件齐备性、编号一致性」，不改技术结论。

**仍然未验证的（不得当成已验）**：实机 T2（`INT_L_X6Y61`）**从未执行**。因此本设计单当前可说的是
「同类型 tile 之间的 PIP 平移可测、判据已就绪、离线预测自洽」，**不能**说「同类 tile 的 PIP 开关盒已验证可移植」。

---

### 三色标注说明

- 【硬件事实】：`tileconn` 固定连接、`LOCK_PINS` 只固定引脚映射、`ffg1761-2` 的 CRAM 几何。
- 【数据事实】：本文所有帧号/位号/命中数（24/24、25/25、6/6、14850 字节等）均可用 §10 命令重算。
- 【推断】：§3.2 的 T2 绝对帧（由 law + `base` 推得，尚未实机验证）；§2.1 的「单变量」结论。

### 修订记录

| 版本 | 变更 |
|---|---|
| v1.0 | 设计单初稿（tile 对、connection、观测位、归一化、五构建、判据、回退） |
| v1.1 | 本次自复核 5 处：补 `swap_source.py`（C1）、§6.3 重写为可复现命令与真实输出（C2/C3，7 条 → 8 条）、脚本构建数文案 4 → 5（C4）、spec 回退编号对齐文档 R1–R6（C5，哈希 `799050…` → `FA5345…`，14850 字节）；新增 §12 复核记录与本节 |
