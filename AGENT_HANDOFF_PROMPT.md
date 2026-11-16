# 交接提示词：Virtex-7 位流逆向项目（给接手 Agent）

> 用法：把本文件整体交给接手的 Agent（或让它 `read` 本文件）。第 1～7 节是提示词正文，附录 A/B 是硬数据，不要删。
> 生成日期 2026-11-12　器件 `xc7vx485tffg1157-3`　Vivado 2017.2

---

## 0 一句话交接

我在把 Xilinx 7 系列（Virtex-7）的**位流还原成配置语义**：位流里每一位代表什么（LUT 初值、触发器属性、路由开关、时钟选择、校验字）。目标产物是可解码、可回写、可解释的位级数据库，而不是「跑通一次」的脚本。

**主线任务是 PIP 复用编码规律**（§6.0）：同一 tile_type 内「多个源共享同一组配置位」的几何形状由什么决定。目前 INT 的 mux 区与 BEG 区已用公式 + 数据表完全覆盖（172/172 族、3,634/3,634 feature），未解的是「行序 36 种能否从结构导出」以及其它 tile_type（DSP 79 族 / BRAM 63 族）与 HCLK_CMT 的复用形状。

CLB 位表（LUT INIT、FF、选择器）是另一条线，已可用（`v7re/docs/CLB_BIT_SPEC.md`），剩余空白是 A5FF、SMEM 三位、CLBLL 布局。

你的任务是**在不推翻既有结论的前提下继续推进**，并保持「一条结论必须有第二次独立验证」的纪律。

---

## 1 项目现状摘要

### 1.1 开始之前必须先读（顺序固定）

| 顺序 | 文件 | 为什么 |
|---|---|---|
| 1 | `STATUS.md` | **唯一权威现状**，5,998 行 / 240 节，按 § 编号追加。任何结论以它为准，不以对话记忆为准 |
| 2 | `REMOTE.md` | 远端机器的唯一权威记录（地址会变、shell 是 cmd.exe） |
| 3 | `v7re/docs/CLB_BIT_SPEC.md` | CLB 位级规格（公式 + 位表 + 置信度分层） |
| 4 | `v7re/docs/PROJECT_PLAN.md`、`v7re/ARCHITECTURE.md`、`v7re/README.md`、`CHEATSHEET.md` | 计划、分层、脚本用法 |
| 5 | `v7re/steps/ALL_TILE_PIP_ENCODING_REPORT.md`、`v7re/steps/PIP_BIT_REUSE_REPORT.md` | INT 路由位编码的两份总报告 |

### 1.2 已确认的映射（有实验复核，可直接用）

| 对象 | 结论 | 证据强度 |
|---|---|---|
| 帧/字坐标 | 50,176 帧 × 101 字；**word 50 是帧级 ECC，解码必须跳过** | 已证（远端 6 个受控设计） |
| CLB 块基址 | `clb_blocks[(grid_col, y//50)]`；`SLICE_X12Y20` → **31752** | 已证 |
| LUT INIT（64 位） | `frame_off = 34+(k&1)-2*((k>>3)&1)`；`word = 40(A/B)/41(C/D)`；`bit = B_L-4*(k>>4)-((k>>1)&3)`，`B_A=B_C=15, B_B=B_D=31` | **256/256 逐格相等** |
| `FFSYNC` | `(0,41,16)`，1=同步(FDRE) 0=异步(FDCE) | AFF/BFF 双点 |
| `CLKINV` | `(1,41,19)`，1=反相 | negedge + latch 两路 |
| `LATCH` | `(30,41,0)`，1=LDCE | 独立对照 |
| `FF.INIT` | `(67,40,3)` | 已证 |
| `AFFMUX` O5/O6 | `(30,40,0)`，1=O5 0=O6（**是 4 位字段里的 1 位，不是 one-hot**） | 已证 + prjxray 对齐 |
| `AOUTMUX` | 4 位：O5=`(3,40,8)(4,40,10)(6,41,4)(7,41,5)`；O6=`(3,40,4)(4,41,10)(6,41,8)(7,40,5)` | 两组构造一致 |
| `SR` 使用 | `(1,41,2)(1,41,3)(1,41,9)` 三位同 1 | 两组独立设计 |
| `PRECYINIT` 常量 1 | `(0,40,12)` | 两组（CI=1 / CYINIT=1） |
| INT 路由 PIP | 每 tile_type **172 family / 3,634 feature**；解码 **100% 精确**、召回 96%；全器件可配置 PIP 实例 207,253,149，INT 占 **95.7%** | 多次全量对账 0 不符 |
| INT 地址编码 | 列码=线长类别；`minbit = 8*(i%4)+2*(i//16)+2*((i//8)%2)`；`parity = 1 if (i%8)>=4 else 0` | 744/744、5,832/5,832 |
| `BUFGCTRL` SEL | 全芯片 2 位：`f0 = 7834+5246*(Y//16)`、`w = (93+Y//2)%101` | 32 site |
| `HCLK_CMT` 选择 | **per 列 + per 类型常量**（全器件仅 4 套布局）；`CK_BUFHCLK0..11` 与 `BUFHCE_X0Y72..Y83` 一一对应；CCIO 索引 = 2 位二进制 | 28 + 12 + 96 构建 |
| CLB 的 151/146 条「PIP」 | 全是 **ppip**：93 always（零配置位）+ 58 hint | prjxray 对齐 + 实测 |

### 1.3 仍为「候选」（单次观测或含混杂变量）

- `CEUSEDMUX = (1,41,7)`（跨 CE 源稳定，但对照含一个混杂变量）
- `CE` 目标编码 `(23,41,0)(24,41,0)(25,41,0)`
- CLB 单输出形态下的 `(30,40,6)(30,40,11)`（疑 LUT 模式位）
- PLL X1 列的簇边界（被孤立位干扰）

### 1.4 明确「未测 / 未拿到」

- `A5FF` / `A5FFMUX`（换 IN_A 必然换整条输入网，噪声不可控）
- SMEM 的 `WEMUX` / `WA7USED` / `WA8USED`（`RAM32M` 差分 8 移除/59 新增，噪声过大）
- `PRECYINIT` 的另两档（CYINIT 改档必改布线）
- HCLK_CMT 剩余 32 源（`CK_IN` 10、`MUX_MMCM_CLKIN1` 18）
- **CLBLL** 的位表（已证与 CLBLM 布局不同：`SLICE_X8Y20` 用 CLBLM 表解 INIT 会 13 缺 13 多）
- 跨列/跨行的位号不变性（目前全部在 `SLICE_X12Y20`、grid_col 20、Y=20 上半区实测）

### 1.5 已知的失败路线（别重复踩）

- **CRC 标准多项式反解**：8 个多项式 × 2 方向 × 4 下标约定 = 64 组全败（矛盾 5 万条）。原因：`d` 未按真实包序算 + 位序/ECC 耦合。
- **CRC 单帧签名直接外推**：签名是**绝对帧位置的函数**（`SLICE_X12Y200` 的签名与 anchor 不同），3,200 条只在帧 31786 有效。
- **位平面法建 INIT 表**：格集合正确但**索引标签被置换**，不能直接产出可解码表（必须先 `LOCK_PINS`，或先解出引脚序）。
- **BRAM 180 条地址 mux**：档位由布局器按物理邻接自动选，三设计对照仍无法隔离位号。

---

## 2 目录与数据库清单

### 2.1 代码与文档（权威）

| 路径 | 用途 | 性质 |
|---|---|---|
| `STATUS.md` | 项目现状，按 § 追加 | **权威** |
| `REMOTE.md` | 远端连接与调用姿势 | **权威** |
| `v7re/bitstream/{parser,frames,far}.py` | 位流解析、帧提取、32 位 FAR 编解码 | 权威实现 |
| `v7re/docs/CLB_BIT_SPEC.md` | CLB 位级规格（给解码器） | **权威** |
| `v7re/docs/PROJECT_PLAN.md` / `ARCHITECTURE.md` / `HIERARCHY.md` / `GLOSSARY.md` | 计划、层次、术语 | 权威 |
| `v7re/steps/*.md` | 每次实验的记录（T1～T87） | 证据 |
| `v7re/steps/*.json` | 位表与模型（`clb_init_locked_x12y20_4lut.json`、`law_cells` 导出、`beg_families.json`、`composite_groups.json`、`crc_table.json`） | 派生数据 |
| `v7re/prompts/` | 各阶段任务提示词（V1/V2） | 方法 |
| `.agents/skills/fpga-bitstream-experiment/SKILL.md` | 位级差分实验的通用流程 | **先读** |

### 2.2 数据库（本机）

| 路径 | 大小 | 内容 |
|---|---|---|
| `E:\v7work\model\v7_law.sqlite` | 14.5 MB | 规则库：`law_cells` 24,328、`law_tiles` 62,625、`clb_blocks` 763、`clb_cells` 3,884、`clb_tiles` 75,900、`far_bands` 1,078、`ppips` 2,958、`v7_verified` 245、`cmt_code` 33 |
| `E:\v7work\model\v7_model.sqlite` | 7.58 GB | 器件模型：`frame_map` 50,176、`site_frames` **19,819,900 ← 已确认是残缺表，见 §6 P0**、`sites` 86,022、`site_pins` 5,489,706、`site_bel_pins` 7,107、`tiles` 150,380、`tile_types` 115、`pip_bits` 3,528、`imux_codes` 2,304 |

> 数据源分工：`frame_map` 与器件拓扑是**权威**；`site_frames` 是从 `clb_blocks` 派生的宽表，可用 `v7re/scripts/build_site_frames.py` 重生成。

### 2.3 位流语料（本机，`_*` 目录）

| 目录 | 内容 |
|---|---|
| `_crc` / `_crcb` / `_lk` / `_t24` / `_sb` / `_sr4` / `_clbll` / `_m2` | 各 65 份（单因素扫描语料） |
| `_initbits` | 112 份 INIT 位平面 |
| `_ff` `_ci` `_aff` `_corners_*` `_ck2` `_ha2` `_h48` `_ccio_out` | CLB/时钟专项语料（注意：部分只有远端产物，本地仅 `.tgz`） |

---

### 2.4 数据分布：什么在本机、什么在远端（交接必看）

| 数据 | 只在哪 | 体量 | 交接处理 |
|---|---|---|---|
| `site_frames` **全量 36,799,100 行** | **只有远端** `/opt/lzh/v7re/data/model/v7_model.sqlite`（7,948,218,368 B） | 7.6 GB | ①让新 agent 直接用远端；②或从远端拉回。**本机那份是残缺表（19,819,900 行），别用** |
| `frame_map` / 器件拓扑（sites/pins/tiles） | 两侧都有 | 同上库 | 用远端即可 |
| **规则库** `v7_law.sqlite`（`law_cells` 等） | **只有本机是对的**（14.5 MB） | 14.5 MB | 远端 `data/model/v7_law.sqlite` 是 **0 字节**，`work/word50/v7_law.sqlite` 是 11.5 MB 旧副本 → **以本机为准，必须推给新 agent** |
| **路由模板** `pip_defs`（每 tile_type 的 PIP 源/目的） | **只有远端** `/opt/lzh/v7re/work/refs_20261021/routing/out_routing/templates/`（6.8 MB，含 `INT_L.json` `BRAM_L.json` `HCLK_CMT_L.json` 等） | 6.8 MB | **必须给**：PIP 复用的「源集合」全部来自这里 |
| `prjxray_ref/artix7/*.db`（A7 的 segbits / ppips） | **只有本机** | 25.1 MB | 必须给：跨代对照（V7 字段结构可借用，位号不能借用） |
| 位流语料 | 本机 `step03_pip/`（714.7 MB，含 `regbits`/`s3bits`/`s4bits`/`sweepbits`）+ 根目录 `_*`（约 1,000 份 `.bit`，单份 20,273,538 B） | GB 级 | 按任务给子集；`_crc` `_lk` `_t24` `_sb` `_clbll` 各 65 份是主力语料 |
| 远端工作目录 | `/opt/lzh/v7re/work/*/`（`aoutmux` `clbff` `corners` `word50` `crcfull2` 等几十个） | — | 里面是各批构建的 tcl/bit/log，可直接复用构造 |

> 结论：**光给本仓库不够**。至少四样要单独交接：全量 `site_frames`（远端）、`v7_law.sqlite`（本机）、routing templates（远端）、`prjxray_ref`（本机）。


## 3 关键脚本清单

| 脚本 | 作用 | 调用 |
|---|---|---|
| `v7re/scripts/clb_decode.py` | 读 `.bit` → 输出 CLB 全部位（INIT/FF/选择器/控制） | 本地 `python v7re\scripts\clb_decode.py <bit> [site] [--base N] [--json]` |
| `v7re/scripts/bitwriter.py` | 清空后按定律重建 PIP 位 | 本地 Python API |
| `v7re/scripts/fasm2bit.py` | FASM ⇄ 位流 双向（逐字节幂等） | 本地 |
| `v7re/scripts/bitgen.py` | 写位流（含 ECC 增量修正） | 本地 |
| `v7re/scripts/pip_reuse_law.py` | INT mux 区 6×4 网格定律 + `--verify` | 本地 |
| `v7re/scripts/verify_all_pip.py` | 全族覆盖对账（`--tile-type INT_L/INT_R --normalize`） | 本地 |
| `v7re/scripts/beg_families.py` | BEG 族二分图重建 | 本地 |
| `v7re/scripts/all_int_tiles_check.py` | 全器件 INT tile 位级复验（含 6 个控制位白名单） | 本地 |
| `v7re/scripts/build_site_frames.py` | 生成 `site_frames` 宽表（`--all --replace --validate`） | 本地或远端 |
| `v7re/scripts/diff_frames.py` | 两份位流按 FAR 对齐做 XOR 差分 | 本地 |
| `v7re/scripts/crc_delta.py` / `crc_learn.py` / `crc_structure.py` | CRC 增量、学习、结构检证 | 本地 |
| `v7re/scripts/hclk_observe.py` | 扫语料的 HCLK_CMT 选择组合 | 本地 |
| `v7re/vivado/*.py` | 批量综合/实现/位流生成的封装 | 远端 |

**远端调用姿势（唯一可靠的方式）**：本地写 `.sh`（必须 LF），再

```powershell
cmd /c 'ssh -o BatchMode=yes fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" < "路径\xxx.sh"' 2>&1 | Out-String
```

脚本首段固定：

```bash
set -u
export LANG=C LC_ALL=C
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
```

---

## 4 实验方法论（逐条可操作）

**(a) 先读再动手。** 任何任务开始前读 `STATUS.md` 与 `v7re/docs/CLB_BIT_SPEC.md`，在 `STATUS.md` 的「未解项」里确认这件事没做过。禁止凭记忆给位号。

**(b) 一次只改一个因素。** 固定 `LOC` / `BEL` / `LOCK_PINS` / 引脚 / 综合与实现策略 / bitgen 选项；把 FF 或 CARRY 也显式钉 `LOC`+`BEL`（**踩过坑：只钉 LUT，FF 被布局器搬到别的 tile，差分全落在别处**）。差分以 `(frame, word, bit)` 三元组记录，**跳过 word 50**。

**(c) 两条独立验证才叫「确认」。** 第二个构造，或同结构的第二个 BEL/site。单次观测标「候选」并写清混杂变量。

**(d) 环境三坑。** ① Vivado 必须 `LANG=C LC_ALL=C`，否则 `Aborted (core dumped)`；② 多命令必须 `bash -s` 喂脚本（cmd.exe 会抢管道；`nohup ... &` 起的后台进程会随 ssh 断开被杀，要前台阻塞 + 本地后台挂住）；③ PowerShell 写脚本必须 `newline="\n"`，CRLF 会让远端报 `setlocale` 或 `syntax error: unexpected end of file`。

**(e) 十六进制长度断言。** 生成 `INIT=1<<k` 时必须 `[ ${#HEX} -eq 16 ]`——曾因 `printf "%08x"` 拼出 15 位，Vivado 当 60 位零扩展，32 个构建静默重复。

**(f) 禁编造。** 帧偏移、cell 位置、数量、tile_type 没有数据就写「未测」并给出可执行的验证办法；不要用「一般来说 / 通常」代替数字。

**(g) 术语用英文原文**（`tile_type` / `BEL` / `PIP` / `family` / `site_frames` / `ppip`），正文中文。注意：`family` 是分析单位自造的词，不是 Xilinx 官方术语，其命名空间是 **tile_type 级**（同一 family 名在 26,550 个 INT 实例上含义相同）。

**(h) 记账。** 每次实验后在 `STATUS.md` 追加一节：设计、差分数字、结论、边界、复现命令。写文件用 Python `io.open(..., newline="\n")`，别用 PowerShell 管道（会毁中文）。

---

## 5 禁区

1. **不要把 prjxray 的 Artix-7 位号直接套到 V7。** 两套帧内偏移不同体系（V7 的 INIT 在 34/35、AOUTMUX 在 3/4/6/7、AFFMUX 在 30；A7 对应项在 30/31）。可以用 A7 的**字段结构**做假设，但位号必须实测。
2. **不要把 CLB 那 151/146 条 ppip 当成可配置开关。** 93 条是 always（硬连线，零配置位），58 条是 hint（真实选择在 INT 侧）。
3. **不要为通过断言而放宽判据。** 判据放宽后「覆盖 100%」是假的。判据该升级就升级（例如从「候选源全 1」升级到「族内位域与候选 pattern 完全相等」，从「换引脚」升级到「PIP 列表逐行相同」）。
4. **不要在未验证的情况下写出可加载位流。** CRC 目前只覆盖 64 个位置且只在单帧内有效。
5. **不要把 `site_frames` 当成实测位表。** 它的地址公式正确，但 CLB cell 定义是派生的、且部分曾错。

---

## 6 主线与优先级

### 6.0 主线定义（本项目的核心问题）

**主线 = PIP 复用编码规律**：同一个 tile_type 里，为什么「多个源共享同一组配置位」，共享的几何形状由什么决定。

已完成的部分：

| 结论 | 数字 |
|---|---|
| mux 区 6×4 网格定律（行帧 `16+row`、列码第 i 位→帧 `25-i`） | 1,536/1,536 |
| 列码 = 线长类别（1/2→DOUBLE、7/11→SINGLE） | 744/744 与 5,832/5,832 |
| `row20 放 LOGIC ⟺ (IMUX//8) 偶数 或 family ∈ BYP_ALT` | 64/64，0 例外 |
| BEG 32 族 = 完全二分图（`K(4,5)`×14 + `K(5,4)`×18） | 32/32 |
| 覆盖：族级 / feature 级 | 172/172、3,634/3,634（精确 100%，召回 96%） |
| INT_L 与 INT_R 去 `_L/_R` 后同构 | 3,586/3,586 零差异 |
| 全器件可配置 PIP 实例 / INT 占比 | 207,253,149 / **95.7%** |

**已判为「数据」而非公式**（这是主线的真实边界，别当成 bug）：① 行（类内成员序）**36 种**；② 源→槽位映射 **1,536 条**。两者已落库 `pip_reuse_law.json` / `composite_groups.json`。

### 6.1 优先级

| 优先级 | 事项 | 为什么在这个位置 | 假设 / 预期 | 入口 |
|---|---|---|---|---|
| **P0** | 修复 `site_frames` | 数据前提：本地残缺（19,819,900 行 / 6,104 frame），任何覆盖率数字依赖它 | 重建后 36,799,100 行、9,156 distinct frame、`SLICE_X10Y20` 498 行三者同时成立；或直接用远端全量件 | `select count(*),count(distinct frame) from site_frames`；远端 `/opt/lzh/v7re/data/model/v7_model.sqlite` 已是全量 |
| **P1** | **行序 36 种能否从结构导出**（主线核心未解） | 若可导出，复用编码就从「公式+数据表」升级为纯公式；若不可，就把它固化成受支持的常量表并停止追问 | 候选变量：源在 `pip_defs` 里的排列、IMUX 编号、线长类别、方向类。判据：至少 2 个 tile_type 上同时成立 | `v7re/scripts/pip_reuse_law.py --verify`、`tile_pip_lawscan.py`、`v7re/steps/PIP_ADDRESS_ENCODING_LAW.md` |
| **P2** | HCLK_CMT 剩余 32 源 | 全器件**最密**的复用结构（平均 23.38 源/目的），且已解出 16/48 | `CK_IN` 与 `MUX_MMCM_CLKIN1` 的索引可能复用同一套「半区+槽位」形态 | `v7re/scripts/hclk_observe.py`、`_hclk*` 脚本、`v7re/steps/T73/T74/T75` |
| **P3** | 其它 tile_type 的复用形状 | 全器件 636 family：INT 172 / **DSP 79** / **BRAM 63** / CLB 2；目前只有 INT 做了定律级分析 | DSP 基本 one-hot（无复用）；BRAM 多为 1–2 格；若某类出现 ≥8 格共享，就值得做定律 | `tile_pip_lawscan.py`、`v7re/steps/T62/T63/T64` |
| **P4** | 实例级覆盖率提升（23.66% → 更高） | 定律已在 12,565 tile 上残差 0；提高覆盖率只是抽样成本 | 每 1,000 个 LUT 设计约覆盖 400 tile；成本线性 | `all_int_tiles_check.py --bit` |
| **P5** | CLBLL 标定、跨列不变性（CLB 线，非主线） | 属于 CLB 位表工程，与复用编码无直接关系；可延后 | CLBLL 需换 `B_L` 与帧偏移常数复算 256 格 | `clb_decode.py --base`、`v7re/steps/T54/T57` |


---

## 7 汇报格式

每次汇报按这个顺序，不许打乱：

1. **已改变的事实**——这轮新增/修正了什么，数字是什么，证据在哪（文件 + 命令）。
2. **未解项**——哪些还没拿到，为什么（构造失败 / 噪声 / 不可达），下一步的最小可行动作。
3. **下一步选项**——2～3 个，每个带假设、预期差分、可复现命令、涉及文件路径。
4. **失败记录**——如果这轮没做成，直接说「这轮没拿到 X，原因是 Y」，并写进 `STATUS.md`。

实验前先说清假设与预期差分，实验后说清实际差分与假设是否成立（成立/否定/混杂）。

---

## 附录 A 环境（细节见 `REMOTE.md`）

| 项 | 值 |
|---|---|
| 器件 | `xc7vx485tffg1157-3`（Vivado 2017.2 支持） |
| SSH | `ssh fpga` → `s.tschai@172.17.70.41`（DHCP 会变），私钥 `C:\Users\i\.ssh\v7remote` |
| 远端 shell | **cmd.exe**（不是 bash）；Linux 侧 `C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root` |
| 远端工作区 | `/opt/lzh`（1007 G，已用 216 G）；项目 `/opt/lzh/v7re` |
| Vivado | `/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado` |
| Python（远端） | `/opt/lzh/venv/bin/python` |
| 本机 | Windows，PowerShell 5.1；项目根 `E:\DEEPSEEK\FPGA比特流逆向` |

## 附录 B 硬数据基线（写结论时对照）

- 帧数 `50,176`；每帧 `101` 字；`word 50` = ECC。
- `SLICE_X12Y20` 块基址 `31,752`；块内 `frame_off ∈ [0,35]`。
- INIT 公式已在 4 个 LUT × 64 位 = **256 格**上与实测表逐项相等。
- INT：`family 172 / feature 3,634 / 置位格 8,900 / 源 182`（INT_L 与 INT_R 去 `_L/_R` 后完全相同）。
- 全器件可配置 PIP 实例 `207,253,149`，INT 占 `95.7%`。
- CLB ppip：CLBLM 151 条（93 always + 58 hint）、CLBLL 146 条。
- 解码器对拍：6/6 设计（`d_fdre` `d_fdce` `d_lat` `d_cepin` `d_ce1` `p_ci1`）与意图一致。
- 语料规模：本机 `_*` 目录合计约 1,000 份 `.bit`（单份 20,273,538 B）。
