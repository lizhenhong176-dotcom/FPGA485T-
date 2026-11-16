# Virtex-7 配置位逆向 — 项目工作详情

> 器件：`xc7vx485tffg1157-3`（Virtex-7 485T）
> 本文件是**当前工作全貌**的单一入口；逐条历史与实验记录在 `STATUS.md`（6,970 行 / 274 节），口径与作废清单在 `SINGLE_SOURCE_OF_TRUTH.md`。
> 生成时间：2026-11-15　｜　当前 `repro.py` 状态：**12/12 PASS**

---

## 0. 一句话现状

**INT tile 的路由配置位已经从「逐位列表」变成「可生成的结构」**：172 个族里 64 个 24 源多路复用族的行轴由 S4 置换链生成（32/32 重建），列轴压到 32 bit 的 16 项表（跨 INT_L/INT_R 逐位一致）；CLB 站内配置位、时钟资源、ECC 均已闭合；CRC 与 BRAM 地址 mux 未闭合（已量化原因）。

---

## 1. 项目目标与边界

| 项 | 内容 |
|---|---|
| 目标 | 为 Virtex-7 建立「位流 ↔ 配置语义」的完整映射：帧系统 → 节内配置位 → 生成律 |
| 主线 | **PIP 复用编码规律**（多源共享少数配置格的结构与生成函数） |
| 首期范围 | CLB + INT + 基础时钟；BRAM / DSP / GT / PCIe 后置 |
| 已完成 | 帧系统、INT 全族、CLB 站内、时钟资源、ECC、器件区块表 |
| 未完成 | 整条流 32 位 CRC、BRAM 地址 mux、HCLK_CMT 剩余 32 源、A5FF/SMEM 若干位 |
| 明确不做 | 不推科学边界之外的东西（行轴版图证据已到工具上限）；当前阶段是收口 + 论文交付 |

---

## 2. 环境与数据资产

### 2.1 运行环境

| 项 | 值 |
|---|---|
| 实验机 | 远端 `ssh fpga`（`172.17.70.41`，用户 `s.tschai`，私钥 `C:\Users\i\.ssh\v7remote`） |
| 进 Linux | `C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s`（stdin 喂脚本，cmd.exe 会抢管道） |
| Vivado | `/opt/lzh/Xilinx/Vivado/2017.2`（**必须** `export LANG=C LC_ALL=C`，否则 `Aborted (core dumped)`） |
| Python | `/opt/lzh/venv/bin/python`（远端）、本机 `python` |
| 远端工作区 | `/opt/lzh/v7re`（构建产物、模板、位流） |
| 算力 | Dell 7920，2×Xeon Gold 5120（28C/56T），127.7 GB；WSL 配到 98 GiB / 44 核；单构建 84 s、2.2 GB → 32 路并发 |

### 2.2 数据库（两库分工）

| 库 | 大小 | 内容 |
|---|---|---|
| `E:\v7work\model\v7_model.sqlite` | 7,581 MB | 器件拓扑与位流模型：`site_frames` 36,799,100、`frame_map` 50,176、`site_addr` 75,800、`sites` 86,022、`tiles` 150,380、`site_pins` 5,489,706、`pip_bits` 3,528、`imux_codes` 2,304、`column_offsets` 420、`tile_types` 115 |
| `E:\v7work\model\v7_law.sqlite` | 14.6 MB | **规则库（只此一份可用，远端是 0 字节空文件）**：`law_cells` 24,328、`law_tiles` 62,625、`clb_cells` 3,884、`clb_blocks` 763、`clb_tiles` 75,900、`far_bands` 1,078、`frame_blocks_full` 1,183、`tile_blocks` 53,102、`ppips` 2,958、`v7_verified` 245、`clk_cells` 94、`cmt_code` 33、`law_ctrl` 132、`law_iob` 37、`law_ppips` 216 |

### 2.3 只在本机 / 只在远端（交接必读）

| 资产 | 位置 | 备注 |
|---|---|---|
| 路由模板 `pip_defs`（115 个 json，6.8 MB） | **只在远端** `/opt/lzh/v7re/work/refs_20261021/routing/out_routing/templates/` | 本机无副本 |
| `prjxray_ref/artix7/*.db`（22 个，25.1 MB） | **只在本机** | 用于 A7↔V7 对照 |
| `step03_pip/`（462 个脚本 + 位流语料，714.7 MB） | 本机 | 早期实验语料 |
| 实测位流样本（1,000+ 份 `.bit` + `.pips`） | 本机各 `_*` 目录 | 差分与观测法的输入 |

### 2.4 代码与文档规模

`v7re/scripts` **77** 个脚本 ｜ `step03_pip` **462** 个 ｜ `v7re/steps/*.md` **123** 篇 ｜ 单元测试 **15 passed** ｜ `figs/` 7 个 CSV ｜ 讲解图 3 张

---

## 3. 已闭合成果

### 3.1 帧系统

| 结论 | 值 | 依据 |
|---|---|---|
| 配置帧总数 | **50,176**（50,148 数据帧 + 28 overhead 行） | `frame_map`、RapidWright 独立复算 |
| 帧号 → FAR | 32 位编解码，锚点 frame 31748→`0x4203A0`、31750→`0x4203A2` | `bitstream/far.py`，sha256 校验 |
| 站点 → 帧/字 | `frame = clb_blocks[(grid_col, y//50)] + frame_off`；`word = 2*(y%50) + (1 if y%50>=25 else 0) + parity` | `build_site_frames.py` |
| `site_frames` 规模 | **36,799,100 行 / 9,156 帧**（763 block × 12 frame_off） | 本地=远端逐项一致（5 个校验和全同） |
| **word 50** | **帧级 ECC/校验字**，不承载配置语义 | 6 个受控设计（e0–e5）：任何数据字变化必伴同帧 word 50 变化 |
| 器件区块表 | **1,183 块 / 50,148 帧 = 100%**（`FAR_BLOCK_0` 1,078 + `BT1` 105） | `build_frame_blocks_full.py`，无缝隙无重叠 |

区块分类（`frame_blocks_full`）：CLB 777（111 列）｜ INT 245（35 列）｜ CLOCK 28（4 列）｜ BOUNDARY 14（2 列）｜ UNDETERMINED 14（2 列）｜ **BT1 105（15 列 × 7 带 × 128 帧）**

`band` 语义首次确定：`0..4 → (top=0,row=0..4)`、`5 → (1,0)`、`6 → (1,1)`。

> **BT1 的 13,440 帧在 36 份采样位流中恒为 0**（非零数据字合计 0，已排除 word 50）⇒ 会被写入器件，但不含配置数据；用途未定。

### 3.2 INT 路由配置位（主线）

**规模**：每侧 172 族 / 3,634 feature；INT_L 与 INT_R 去掉 `_L`/`_R` 后**格集合 172/172 完全相同**、同名 (族,源) 3,586/3,586 零差异。

按机制分四类（不能用同一套理论混着数）：

| 机制 | 族数 | 每族源数 | 每源格数 | feature | 状态 |
|---|---|---|---|---|---|
| **24 源 mux**（`IMUX` 48 + `BYP_ALT`/`FAN_ALT` 16） | 64 | 24 | 5 | 1,536 | ✅ 行轴+列轴均闭合 |
| **BEG**（`EE2BEG`/`NS2BEG`…） | 96 | 20 | 2 | 1,920 | ✅ 二分图 `K(4,5)`/`K(5,4)` |
| **时钟/控制**（`CLK`, `CTRL`, `GFAN`） | 6 | 16 | 5 | 96 | ✅ 复合码 |
| **长线**（`LV`, `LH`, `LVB`） | 6 | 10–18 | 2 | 82 | 🟡 48/82 完整乘积 |

#### 24 源 mux：6×4 结构

- 24 个源共用 **10 个格**：6 个行格（帧 `16..21`）+ 4 个列格（帧 `22..25`）；每源恰好 5 格（1 行 + 4 列位置），实际选通 = 行 ∧ 列。
- **6 = 源类别数**（4 类方向线 + LOGIC + BOUNCE）；**4 = 类内槽位数**。
- 64 族 = `16 位对 × 2 parity × 2 phase`，验证 **1,536/1,536** 精确。
- 列码 = **线长类别**（1/2→DOUBLE、7/11→SINGLE），744/744 与 5,832/5,832 全中。

#### 行轴：S4 置换生成链

```
p_{j+1} = g_j ∘ p_j
DIAG/ORTH : g = [r³, ρ, r³, e, r³, ρ, r³]      # 走 7 步回 p0（周期 8）
R/L       : g = [r,  ρ, r,  X2, r, ρ, r]       # 走 7 步回 p3（周期 4）
r=(1,2,3,0)  ρ=(3,2,1,0)  e=(0,1,2,3)  r³=(3,0,1,2)  X2=(3,2,0,1)
p0: DIAG (2,0,3,1) · ORTH (2,3,0,1) · R (2,0,1,3) · L (3,1,0,2)
```

- 64 族 → **16 种行序码 / 每码 4 族**；INT_L 与 INT_R 逐族同码 **64/64**。
- 重建 **32/32**；描述量 `147 bit → 20 bit`。
- 负结果：R/L 的 8 步用 ρ 共轭（`p∘ρ`、`ρ∘p`、`ρ∘ρ∘p`）**三种写法全败** ⇒「周期 8」不成立是硬结论。
- 旧文「48 族 36 种」**作废**（三种口径都复现不出；实际 IMUX 12 组、含 BYP/FAN 16 组）。

#### 列轴：先分「对」，再分「对内顺序」（512 个槽位）

列对由源的类唯一决定，**512 个源 0 例外**，INT_L/INT_R 两侧同：

| 源 | 列对 |
|---|---|
| `LOGIC_OUTS_L0..L15` | `{0, 1}` |
| `LOGIC_OUTS_L16..L23` | `{2, 3}` |
| `GFAN*` | `{2, 3}` |
| `BYP_BOUNCE*` | `{2, 3}` |
| `FAN_BOUNCE*` | `{0, 1}` |

- **LOGIC 半区 0 自由位**：所在行决定排列（row4 → `(1,0,3,2)`，row5 → `(0,1,2,3)`），**64/64 两侧全对**。
- **BOUNCE 半区 2 bit/族**，周期 16：`k = 族号 mod 16`，`(BYP,FAN)` 顺序位 = `g(k mod 8) XOR (1,1)（k≥8）`，`g = [(0,0),(1,1),(1,1),(1,1),(1,1),(0,1),(0,1),(0,1)]`。
- 逐族比对：INT_L 与 INT_R 的 BOUNCE 组合 **64/64 完全相同**。
- 量化：512 槽 × 2 bit = 1,024 bit → **32 bit**（16 项表）⇒ **32×**。
- 两条负结果：不是线对的属性（16/16 线对都出现两种顺序，6:6）；不是 (线,行) 的属性（14/42 歧义）。

#### BEG（96 族 / 1,920 feature）

- 每源恰好 **2 格**（A 侧 + B 侧）；源→2 格视为边、格为节点 ⇒ **完全二分图**。
- 帧 2–7 的 **32 族**：`K(4,5) × 14 + K(5,4) × 18`，覆盖 640 feature，位流级重建 32/32。
- json 侧记 101 族满足 `complete_product=True`（与 mux 64 + 长线 6 + 复合 7 合计 178，是另一套计数口径）。

#### 长线（6 族 / 82 feature）

- 续接边 26 条：`LV_L0←{LH12,LH6}`、`LV_L18←{LH0,LH12,LH6,LV_L0}`、`LH0←{LH12,LV_L0,LV_L18,LV_L9}`、`LH12←{LH0,LV_L0,LV_L18,LV_L9}`、`LVB_L0↔LVB_L12`。
- **没有「段数/跨度」编码**：跨 N 个 tile = N 次续接（bounce）。
- `LV_L9` 与 `LH6` 只作源、无自己的驱动族（缺口）。
- 完整乘积网格 **48/82 = 58.5%**（这就是 3,634 − 3,552 = 82 的缺口来源）。

#### 覆盖率四档

| 档 | 值 | 说明 |
|---|---|---|
| 族 | 172 / 172 = 100% | `verify_all_pip.py` |
| feature | 3,634 / 3,634 = 100% | 同上 |
| 可由槽位表生成 | 3,552 / 3,634 = **97.74%** | `repro.py: slots.coverage` |
| INT 实例（实测过的 tile） | 12,565 / 53,100 = **23.66%** | 抽样，不是理论覆盖 |

全器件可配置 PIP 实例 **207,253,149**，其中 INT **198,434,700 = 95.75%**；其余 4.25% 是接口类（**1:1 直通、不可配置**，342,000 实例）与 FEEDTHRU（**0 条 PIP**）等。

> 因此「还有 4.3% 可配置 PIP 没做」的说法**作废**。

### 3.2.1 INT 配置位的可解释性分级（四级）

把 INT_L/INT_R 的 3,737 条 PIP 按「描述一条 feature 需要多少信息」分四级，这是目前最能概括主线成果的一句话结论：

| 级 | 含义 | feature 数 | 占比 | 描述方式 |
|---|---|---|---|---|
| **L1 纯公式** | 槽位由**线名里的方向 + 长度**决定 | 3,456 | 95.10% | mux 48 族：`line_class`→列码、`dir_token`→行；BEG 48 族×2：`geo_class`→列、`dir_token`→组。代码 `step03_pip/gen_slots.py` |
| **L2 乘积 + 置换** | 结构是 `A 集 × B 集`，但「哪条源配哪个格」要存置换表 | 48 | 1.32% | `LH12`(K3,4,12 条)、`LVB_L0`(K3,6,18)、`LVB_L12`(K6,3,18)；模型在 `v7re/steps/longline_product_model.json` |
| **L3 纯查表** | 直接存「feature → 2 个 cell」，无任何结构可利用 | 34 | 0.94% | `LV_L0`(10)、`LV_L18`(12)、`LH0`(12)，共 21 个不同 cell；表在 `v7re/steps/longline_lookup_table.json` |
| **L4 零配置位** | 硬连线 / 单扇入，PIP 存在但没有可选性 | 108 条 ppip 行 | — | 44 always（`BYP_BOUNCE*`/`BYP_L*`/`FAN_BOUNCE*`/`FAN_L*`/`GCLK_L_B6..B11_*`）+ 64 default（`IMUX_L0..47`、`BYP_ALT*`/`FAN_ALT*` 各一条 `VCC_WIRE` 默认） |

判断标准不是资源类型，而是**「该 feature 的槽位能否由线名确定」**：
- mux 与 BEG 都是**单个 tile 内的接法**，入口=方向、出口=长度，名字里信息齐全 ⇒ 公式。
- 长线是**跨 tile 的续接许可**，配对取决于两段线在 tile 内的**相对位置**，而名字不含位置 ⇒ 至少需要置换表，部分连乘积结构都没有。
- 同一条长线在不同族里用到的 cell **完全不同**（`LH12` 出现在 13 个族，13 种 cell 集合），所以「源码→格」在长线里没有全局坐标系。

把 `geo_class`/`dir_token` 这两个在 BEG 上 96/96 成立的预测器原样套到 6 个长线族，**6/6 全部失效**（同一名字类别落进多个槽位），这是「长线拿不到公式」的直接实验证据。

### 3.3 CLB 站内配置位

**INIT（LUT 内容）闭式公式**（4 LUT × 64 位 = 256 格，逐项相等）：

```
frame_off = 34 + (k & 1) - 2*((k >> 3) & 1)
word      = 40（A/B）· 41（C/D）
bit       = B_L - 4*(k >> 4) - ((k >> 1) & 3)     B_A = B_C = 15，B_B = B_D = 31
```

**FF / 控制位实测表**（相对块基址，块基址例 31752）：

| 特征 | 位（frame_off, word, bit） | 证据 |
|---|---|---|
| `FFSYNC`（同步/异步复位） | `(0, 41, 16)` | FDRE=1 / FDCE=0，全芯片只差 1 格 |
| `CLKINV`（时钟反相） | `(1, 41, 19)` | posedge vs negedge，183/184 格 |
| `LATCH` | `(30, 41, 0)` | FDRE vs LDCE（BFF 侧确认） |
| SR 使用 | `(1,41,2)(1,41,3)(1,41,9)` | SR 接地 vs 接 rst |
| `CEUSEDMUX`（强候选） | `(1, 41, 7)` | CE=1 vs CE=pin |
| CE 目标（候选） | `(23,41,0)(24,41,0)(25,41,0)` | 与 CE 源无关的稳定 4 位 |
| `PRECYINIT`（常量 1 档） | `(0, 40, 12)` | `.CI(1'b1)` / `CYINIT=1` 同位 |
| `AFFMUX`（O5/O6 选择） | `(30, 40, 0)` | `LUT6_2` 换 `.O6()`/`.O5()` 只差 1 位；bit=1→O5 |
| `AOUTMUX`（LUT 输出选择） | 4 位：`(3,40,8)(4,40,10)(6,41,4)(7,41,5)`(O5) / `(3,40,4)(4,41,10)(6,41,8)(7,40,5)`(O6) | 两码全不同 |

**三类「零配置位」**（不是遗漏，是物理上没有）：

1. LUT 输入选择 `CLBLM_L_A ← A1..A6`（换引脚只改 INT 侧 IMUX）；
2. 旁路 `BYP0 → AX`（prjxray 的 segbits 里 0 行）；
3. CE/CLK/SR 的**源选择**（源在 INT 侧）。

**ppip 判定**：CLB 模板 151（CLBLM）/146（CLBLL）条与 prjxray `ppips_clblm_l.db`（hint 58 + always 93）数量一致 ⇒ **全是 ppip，不是可配置开关**。

**解码器**：`v7re/scripts/clb_decode.py`，对 6 个设计对拍 **6/6** 与设计意图一致；说明文档 `v7re/docs/CLB_BIT_SPEC.md`（207 行）。

### 3.4 时钟资源

| 对象 | 结论 |
|---|---|
| `BUFGCTRL.SEL`（I0/I1） | 全芯片 **2 位**：`f0 = 7834 + 5246*(Y//16)`、`w = (93 + Y//2) % 101`；偶 Y 位 `(11,3)`、奇 Y 位 `(27,19)`；32 site 全验证 |
| `HCLK_CMT` 选择 | **per 列 + per 类型常量**（MMCM X0 列 30/30、X1 列 30/30、跨列 4/30；PLL X0 292/292、跨列 0/292）⇒ 全器件仅 **4 套布局** |
| `CK_BUFHCLK`（12 源） | `BUFHCE_X0Y72..Y83` 与 `CK_BUFHCLK0..11` 严格一一对应；编码 = 半区位 `(base+2, 48, 21)` + 6 槽位 one-hot（`(base+2,26)(base+3,25)(base+2,25)(base+3,24)(base+2,24)(base+3,23)`） |
| `CCIO`（4 源） | 96 个时钟引脚里只有 8 个进 CCIO；索引 = `bit(base+1,51,27) \| bit(base+1,51,28)<<1`，8/8 精确 |
| 类别位 | `bit21 = BUFHCLK`、`bit22 = CCIO` |
| 链式 `MUX_CLK_k → CK_IN_j` | 264 份位流 **0 次使用** ⇒ 判为**不可达**（模板有、工具不用） |
| 剩余 | 32 源未解（`CK_IN` 10 + `MUX_MMCM_CLKIN1` 18 等） |

### 3.5 其它 tile 类型

| 类型 | 结论 |
|---|---|
| DSP | `CEAD/CEALUMODE/CED/CEINMODE` 1–2 格；`CECTRL/CEM/CEP/CEC` 为「零值默认」⇒ **基本 one-hot，无复用问题** |
| BRAM | EN/RST 各 2 格（同帧 word 13/16 两半区）、REGCE 各 4 格；多位来自 RAMB36 = 两 RAMB18 半区配对；**180 条地址 mux（`CASCINBOT`/`CASCINTOP`/`IMUX`）档位由布局器自动选，无法隔离位号**（n1/n3/n4 三设计证明） |
| CLB | 见 §3.3（全是 ppip + 58/61 条 site 特征） |
| 接口类 | `INT_INTERFACE` 1:1 直通、每目的 1 源 ⇒ 无配置位；帧 26/27 承载未登记内容（BT1 候选） |

### 3.6 ECC 与 CRC

| 项 | 状态 |
|---|---|
| 帧级 ECC（word 50） | ✅ **154 个位置签名**，线性（`c(A)^c(B)=c(A^B)`），`bitgen.py` 可字节级复原 Vivado 文件 |
| ECC 地址项 | 三模型（A≡0 / 块内偏移 / FAR 位）**全部证伪**；异常集中在 row 7 |
| CRC（整条流 32 位） | 🟡 64 条条目 + 3,200 条单格签名（帧 31786）；张成空间 **31 维**，留一 96/96、跨帧 13/13 · 14/14 |
| CRC 语义 | UG470：覆盖自 **RCRC 之后**（COR0/1、IDCODE、MASK、CTL0/1、FAR、FDRI）；尾部第二个 CRC 包恒为 **`E3AD7EA5`**；CRC 错 → INIT_B 拉低 |
| 关键限制 | 签名是**绝对帧位置的函数**（远距注入 `0x6d7922f5 ≠ 0xcc97191d`）⇒ 3,200 条只在帧 31786 有效 |
| 路线 B（标准多项式反解） | ❌ 8 poly × 2 方向 × 4 下标约定 = 64 组全败（矛盾 5 万+） |

> CRC 只影响「生成的位流能否被 FPGA 加载」，**不影响任何分析类结论**（PIP / ECC / 解码 / FASM 均已闭环）。

---

## 4. 关键数字总表

| 指标 | 值 | 来源 |
|---|---|---|
| 配置帧 | 50,176（数据 50,148） | `frame_map` |
| `site_frames` | 36,799,100 行 / 9,156 帧 | `v7_model.sqlite` |
| 器件区块 | 1,183 块 / 50,148 帧 | `frame_blocks_full` |
| INT 族 / feature | 172 / 3,634（每侧） | `law_cells` |
| 24 源 mux | 64 族 / 1,536 feature / 每源 5 格 | `law_cells` |
| BEG | 96 族 / 1,920 feature / 每源 2 格 | `law_cells` |
| 长线 | 6 族 / 82 feature（48/82 完整） | `law_cells` + `beg_families.json` |
| 行序 | 16 码 × 4 族；重建 32/32；147→20 bit | `_row_s4.py` / `row_law.py` |
| 列序 | 512 槽 → 32 bit（32×）；两侧 64/64 同 | §189/§190 |
| (feature,cell) | 8,900 条 / 1,598 个不同格 | `figs/fig3_coverage.csv` |
| 可生成覆盖率 | 3,552/3,634 = 97.74% | `repro.py` |
| 实例覆盖率 | 12,565/53,100 = 23.66% | `figs/fig3_coverage.csv` |
| INT 占全器件可配置 PIP | 198,434,700/207,253,149 = 95.75% | 同上 |
| ECC 位置 | 154 | T8 |
| CRC 签名 | 3,200（单帧）/ 64（条目） | `crc_table.json` |
| 自检 | `repro.py` **12/12 PASS**，约 9 s | 本地 |

---

## 5. 方法论与纪律（踩过的坑换来的）

1. **差分闸门**：一次只改一个因素；「PIP 列表逐行相同」或已知定律可归因，否则布线副作用会淹没目标位。
2. **`LOCK_PINS`**：Vivado 会重排 LUT 输入索引；不锁引脚时索引是"当次分配"，建出来的表**不可用于解码**（T13 表因此作废）。
3. **三类差分语义**：`sense=1` 必置 1、`sense=0` 必置 0、"不在集合"=不关心——混淆会得出「两个源共用同一格」的错结论（本人在 §189 踩过一次）。
4. **循环证据**：用同一份数据建表又回放不算验证；真正的验证是"留出/跨实例/独立重算"（如 INT_L 训练 → INT_R 预测 1,024/1,024）。
5. **作废口径要显式登记**，否则会被后来的报告引用（见 §8）。
6. **记账**：任何结论必须落到 `STATUS.md` 某节 + 一条可跑命令；批量改写前先 `copyfile` 备份（§182）。
7. **命名空间**：`far_col`(154) / `grid_x`(412) / `clb_col`(111) 是三套坐标系，禁裸写 `col`；`band` 在两表里含义不同（`clb_blocks.band` 与 `far_bands.band` 是 0→6 映射关系）。
8. **负结果照写**：失败路线（路线 B CRC、BRAM 地址 mux、链式 10 源）都写进了文档并标注原因。

---

## 6. 未闭合清单

### 6.1 数据缺口（补数据/补构建即可）

| 缺口 | 量 | 影响 |
|---|---|---|
| 长线族完整乘积 | 缺 34 条（48/82） | 那 82 条 feature 的可生成性 |
| `LV_L9` / `LH6` 驱动源 | 2 条 | 长线续接图的完整性 |
| INT 实例覆盖 | 还差 40,535 个 tile | 论文"全器件通用"的说法需要 |
| BOUNCE 2 位的结构解释 | 32 bit（16 项表） | 若能对上通道物理次序即可消掉 |
| HCLK_CMT 剩余 32 源 | 32 | 时钟资源完整度 |
| `A5FF`/`A5FFMUX`、SMEM 的 `WEMUX`/`WA7USED`/`WA8USED`、`PRECYINIT` 另两档 | 约 6 条 | CLB 全表 |
| 整条流 CRC | 全量 | 生成可加载位流 |

### 6.2 方法上限（当前方法原理上够不着）

| 上限 | 原因 |
|---|---|
| 行轴「类内成员序」 | 布局器自由选择，模板源列表是字典序、不含引脚序 ⇒ 只能当数据 + 用 S4 链压缩 |
| BRAM 180 条地址 mux | 档位由布局器按物理邻接自动选，无法用受控差分隔离 |
| 其它类型的"复用" | DSP/BRAM/CLB 是 111–358 源超大 fan-in，不是 24 源 6×4，行序律不迁移 |
| 6×4 的 `LOGIC/GFAN` 与 `BOUNCE` 行归属 | 由 `(族号//8)` 奇偶决定，但"为什么"属版图证据，工具给不出 |

---

## 7. 代码与文档索引

### 7.1 核心脚本

| 脚本 | 作用 |
|---|---|
| `repro.py` | **一键自检**（12 项，约 9 s） |
| `v7re/bitstream/far.py` | 32 位 FAR 编解码 |
| `v7re/bitstream/parser.py` | `.bit` → 帧矩阵（50,176 × 101） |
| `v7re/scripts/build_site_frames.py` | 站点 → 帧/字/位（36,799,100 行） |
| `v7re/scripts/build_frame_blocks_full.py` | 器件区块表（1,183 块） |
| `v7re/scripts/int_base_solve.py` | 从真实位流反解 INT tile 帧基址 |
| `v7re/scripts/verify_all_pip.py` | 全族 PIP 校验（172 族 / 3,634） |
| `step03_pip/row_law.py` | 行序预测（`predict()`） |
| `step03_pip/fasm2bit.py` / `bitgen.py` | FASM↔位流（含 ECC/CRC 修正） |
| `v7re/scripts/clb_decode.py` | CLB 位级解码器 |
| `v7re/scripts/make_fig_data.py` | 6 张论文图的数据 |
| `v7re/scripts/make_reuse_law_figs.py` | 3 张讲解图（复用/行序/覆盖） |

### 7.2 文档

| 文档 | 内容 |
|---|---|
| `STATUS.md` | 逐节实验记录（6,970 行 / 274 节）+ 索引见 `STATUS_SECTION_INDEX.md` |
| `SINGLE_SOURCE_OF_TRUTH.md` | 单一口径真源表（值 / 口径 / 命令 / 状态） |
| `v7re/steps/*.md` | 123 篇专题（T1–T91） |
| `v7re/docs/CLB_BIT_SPEC.md` | CLB 位级规格 + 解码器说明 |
| `v7re/steps/PIP_BIT_REUSE_REPORT.md` | PIP 复用分析报告（215 行） |
| `ALL_TILE_PIP_ENCODING_REPORT.md`（v1.2, 280 行） | 全器件 PIP 编码总报告 |
| `figs/README.md` | 论文图数据字典 + 四条画图注意 |
| `HANDOFF_*.md` | 对外交付提示词（A 档 / fig1 / 复用规律讲解） |

---

## 8. 作废口径（不得引用）

| 作废项 | 原因 |
|---|---|
| 「行序 48 族 36 种」 | 三种口径都复现不出；实际 16 组 |
| 「24 个未测 IMUX 是 CLBLM 专属」 | 8 LUT 基座一次 route 得 48/48 全可达 |
| 「接口类也是 24 源 mux」 | 1:1 直通、每目的 1 源、无配置位 |
| 「还有 4.3% 可配置 PIP 没做」 | 那部分是接口（不可配置）+ FEEDTHRU（0 条） |
| 「CLB 站内 151 条是可配置 PIP」 | 全是 ppip |
| 「`far_bands` 覆盖全部 50,176 帧」 | 只覆盖 `FAR_BLOCK_0` 的 36,708 帧（73.2%） |
| 「word 50 是配置字」 | 是帧级 ECC |
| 「T13 的 8-LUT INIT 表可用」 | 缺 `LOCK_PINS`，索引被置换 |
| 「本机 `site_frames` 残缺」 | 已重建为全量 36,799,100 行 |

---

## 9. 复现方式

```bash
cd /path/to/project
python repro.py            # 12 项检查，约 9 s，末行 OVERALL: PASS
python repro.py -k row     # 按关键字过滤
```

单项：

```bash
python v7re/scripts/verify_all_pip.py --tile-type INT_L
python step03_pip/gen_mux_rowlaw.py
python v7re/scripts/make_fig_data.py --check
python v7re/scripts/make_reuse_law_figs.py
```

---

## 10. 对外交付现状

| 交付物 | 状态 |
|---|---|
| A 档（给 ClawsGO 写论文） `HANDOFF_A_CLAWSGO_PROMPT.md` | 已交付并被对方接收；对方报 6 条口径冲突，**全部核实成立并已修复** |
| 论文图数据 `figs/*.csv`（7 个） | 已生成，`--check` 可复算 |
| fig1 绘图任务书 `HANDOFF_FIG1_PROMPT.md` | 已交付（含 sha256、五条不可改写事实、八条机械验收） |
| 复用规律讲解 `HANDOFF_REUSE_LAW_EXPLAIN.md` + 3 图 | 已交付 |
| 交接总提示词 `AGENT_HANDOFF_PROMPT.md`（259 行） | 已交付（含数据分布表：哪些资产只在本机/只在远端） |

---

## 11. 术语表

| 术语 | 含义 |
|---|---|
| **族（family）** | 一条 PIP 的**目的 wire**；命名空间是 tile_type 级（不是实例级） |
| **feature** | (族, 源) 对，即一条可选连接 |
| **cell / 格** | (frame_off, parity, bit) 三元组，一个配置位 |
| **sense** | 1 = 必置 1；0 = 必置 0；不在集合 = 不关心 |
| **frame_off** | 相对 tile 块基址的帧偏移（0..27） |
| **块基址** | tile 首帧号，如 `SLICE_X12Y20` = 31752 |
| **行格 / 列格** | mux 的 6 行（帧 16–21）与 4 列（帧 22–25）选择位 |
| **ppip** | pseudo-PIP，硬连线，无配置位（hint / always 两类） |
| **BT1** | `FAR_BLOCK_1` 的 105 个区块（每块 128 帧，内容恒 0） |
| **RCRC** | 复位 CRC 命令，CRC 覆盖区间从此开始 |
