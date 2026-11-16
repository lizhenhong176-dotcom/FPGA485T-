# PIP 线进度报告（2026-11-08）

> 按 `step03_pip/PROMPT_PIP_PROGRESS_V2.md` 生成。器件 `xc7vx485tffg1761-2`（VC707）。
> **主线（2026-11-08 起，用户口径）：只做 PIP 复用分析** —— 复用发生在哪几层、复用规律是什么、
> 这套规律能否反过来生成/判定位库。ECC 闭合、数据层补全、跨 tile 类型迁移、篡改定位器上板
> 都**不是主线**，列进本报告只是为了让「复用」的边界与前提清楚。
> 标注纪律：【硬件事实】= 器件结构层面确定的事实；【数据事实】= 本机可复算的测量结果；【推断】= 依据事实的推理；【未测】= 无数据。
> 所有数字在 2026-11-08 复核过一遍（命令见各行「复算」列）。

---

## 一、一页结论

**复用这一层已经讲完可讲的部分**：复用度量 = 码字矩阵列重（Σw = 8,900），
分布只落在 4–5 源档（80.7%）；172 个 family 只出现 **7 种谱型**且 172/172 命中；
「族 × 源」构成**乘积结构**（163/172 通过，9 个例外全是已知难族）；
族内每源码字 **172/172 互不相同**、跨族只共享 **3/1,598** 个 cell；
复用的地址根源是「同一 (band,col) 的 50 个 tile 共用同一批 26 帧、只差两个 word」。
**没做到的两件**：① 这套规律仍是**查表**（`law_cells` 3,634 条），还没写成可闭式生成的代数；
② 「源 → 槽位顺序」**0/1,536 可推**（顺序像是由布线邻接决定的数据，不是规律）。
旁支（ECC 地址项、数据层 16,979,200 行、跨类型迁移）与主线无关，只影响复用规律的**下游可用性**。

---

## 二、主线边界（先看这张表，再看下面的清单）

| 层 | 与主线的关系 | 理由 |
|---|---|---|
| 复用度量 / 7 谱型 / 乘积结构 / 族内唯一 / 子集对 / 跨族共享 | **主线核心** | 这就是「复用在哪、规律是什么」的答案本身 |
| 地址五层（band→col→frame_off→word→bit） | **主线前提** | 复用的地址根源就在这里：50 个 tile 共用 26 帧、只差 word |
| 位库构成（3,737 = 3,693 + 44、3,634 + 59 + 44） | **主线前提** | 不先把 PIP 总数与 family 数对齐，复用度无从定义 |
| 源级可解性（P1，1,066 tile 唯一解） | **主线副产品** | 用复用表做精确覆盖判据的必然结果，反过来支撑「复用表是完备的」 |
| 解码器精确率 / FASM 幂等 | 支撑 | 证明复用表可用，但不是复用规律本身 |
| 篡改检出与定位 | 旁支 | 复用规律的一个应用，不是主线 |
| ECC 与帧地址耦合 | 旁支（阻塞下游） | 挡「生成任意可加载位流」，不影响复用规律的表述 |
| 数据层 `site_frames` 缺口 | 旁支（阻塞下游） | 缺的是 CLB/BRAM/DSP 的 INIT，不是 INT 的复用 |
| 跨 tile 类型迁移 | 旁支（可能反哺主线） | 若 A 类也存在复用层，主线范围要扩；目前未测 |

## 三、进度表

### 3.1 地址与定位层

| 层 | 指标 | 数值 | 状态 | 证据 | 复算 |
|---|---|---|---|---|---|
| 地址 | `far_bands` 覆盖 | 1,078 行 = 7 band × 154 列（col 0..153） | 已完成 | `v7_law.sqlite.far_bands`【数据事实】 | `python step03_pip/_q_far_bands.py` |
| 地址 | band 帧窗口 | 每 band 5,246 帧，band0 0..5245 … band6 31476..36721；7×5,246 = 36,722 | 已完成 | 同上 | `SELECT band,min(start_frame),max(start_frame) FROM far_bands GROUP BY band;` |
| 地址 | 器件总帧 / block 1 | 50,176 = 36,722（block 0 逻辑）+ 13,454（block 1，7 段 × 15 列 × 128 帧） | 已完成 | `_q_far_segments.py` | `python step03_pip/_q_far_segments.py` |
| 地址 | 换算链 | `region=Y//50`；`band=[6,5,0,1,2,3,4][region]`；`frame=start_frame+frame_off`；`word=2*(Y%50)+parity`（≥50 再 +1） | 已完成 | `v7re/scripts/bitwriter.py:41-43,56`【数据事实】 | 见 `PIP_REUSE_STRUCTURE.md` §9 |
| 地址 | FAR 字段语义 | `[25:23]` block type / `[22]` top / `[21:17]` row / `[16:7]` column / `[6:0]` minor | 已完成 | `_q_bit_far.py`、`v7re/bitstream/far.py`【数据事实】 | `python step03_pip/_q_bit_far.py` |
| 地址 | overhead 帧 | 28 个 = 14 段 × 2，`frame_map.is_overhead=1` 且 far 为 NULL | 已完成 | `v7_model.sqlite.frame_map`【数据事实】 | `SELECT count(*) FROM frame_map WHERE is_overhead=1;` |
| 地址 | 建模位覆盖 | 88,358,400 / 162,168,832 = **54.49%** | 部分完成（CLB/DSP/BRAM/word50 未含） | `tamper_localize.py --coverage` | `python v7re/scripts/tamper_localize.py --coverage` |
| 地址 | 可定位 tile | **53,100 / 62,625 = 84.79%**（分母含 4 列穿通 tile） | 部分完成 | 同上 | 同上 |
| ECC | word 50 模型 | `word50 = ECC(data) ⊕ marker(far_low)`，marker 只在边界帧非零 | 部分完成（A 项未定） | `STATUS.md §34` | `python v7re/scripts/ecc_solve.py`（旧秩 143 实验） |
| ECC | 可重算范围 | `ecc_table.json` 只覆盖 IMUX 字段触及的 23/100 word | **未开始**（全表未拟合） | `STATUS.md §5` 待办 1b | 给不出：需要先补 `ecc_solve` 的地址项 |

### 3.2 PIP → 位库

| 层 | 指标 | 数值 | 状态 | 证据 | 复算 |
|---|---|---|---|---|---|
| 位库 | 每 INT tile PIP 数 | 600 wire / **3,737 PIP** / 216 目的 wire | 已完成 | `templates` + `pip_law_any` 统计【数据事实】 | `python step03_pip/_q_pip_reconcile.py` |
| 位库 | 多源族 PIP | 172 个目的 wire 扇入>1，含 **3,693** PIP | 已完成 | 同上 | 同上 |
| 位库 | 直通 PIP | **44**（`BYP_BOUNCE*`/`BYP_L*`/`FAN_BOUNCE*`/`FAN_L*` 各 1） | 已完成 | 同上 | 同上 |
| 位库 | 对账 | `3,693 + 44 = 3,737`；`3,634 + 59(VCC 常量) + 44 = 3,737` | 已完成 | `STATUS.md §69` | `python step03_pip/_q_pip_gap59.py` |
| 位库 | feature / cell 数 | 每侧 **3,634 feature**（2,818 个 2 格 + 816 个 4 格）、**1,598 cell** | 已完成 | `law_cells` sense=1 = 8,900 行【数据事实】 | `SELECT count(*) FROM law_cells WHERE tile_type='INT_L' AND sense=1;` |
| 位库 | sense 两类行 | sense=1 **8,900** / sense=0 **3,264**（各侧） | 已完成 | `law_cells`【数据事实】 | 同上（`sense=0`） |
| 位库 | 定律覆盖 | INT_L、INT_R 均 **172/172 族、3,634/3,634 命中、不符 0、未覆盖 0** | 已完成 | `verify_all_pip.py`【数据事实】 | `python v7re/scripts/verify_all_pip.py --tile-type INT_L --normalize` |
| 位库 | 码字律 | mux 族占 26 帧块最后 10 帧；行格 `frame_row = 16+r` **384/384**；列码位帧 `25−i`，码值 ∈ {1,2,7,11} | 已完成 | `_q_row_law.py`、`STATUS.md §75` | `python step03_pip/_q_row_law.py` |
| 位库 | 6×4 网格验证 | 64 族、1,536/1,536 组合唯一（`max_per_combo=1`） | 已完成 | `v7re/steps/T3_PIP_REUSE_LAW.md` | `python step03_pip/pip_law.py --verify` |

### 3.3 复用规律

| 层 | 指标 | 数值 | 状态 | 证据 | 复算 |
|---|---|---|---|---|---|
| 复用 | 度量定义 | 码字矩阵列重 `w(c)=Σ_f A[f,c]`，`Σw = 8,900` | 已完成 | `_q_reuse_structure.py`【数据事实】 | `python step03_pip/_q_reuse_structure.py` |
| 复用 | 列重直方图 | 18→128、12→12、6→134、5→384、4→909、3→26、2→5、1→4（共 1,602 族-格对） | 已完成 | 同上 | 同上 |
| 复用 | 主要档位 | 4–5 源档占 **1,293/1,602 = 80.7%** | 已完成 | 同上 | 同上 |
| 复用 | 谱型 | **7 种谱型，172/172 命中**（(5,5,5,5,4,4,4,4,4)×96、(18,18,6,6,…)×64、(12,12,4,…)×6、长线 4 族各 1） | 已完成 | `STATUS.md §73` | 同上 |
| 复用 | 乘积结构 | **163/172** 族通过「组 × 码」完全叉积检验；9 个例外全是已知难族 | 已完成 | `_q_grid_is_real.py`、`_q_grid_exceptions.py` | `python step03_pip/_q_grid_is_real.py` |
| 复用 | 族内唯一性 | **172/172**（族内每源码字互不相同） | 已完成 | `verify_all_pip.py`、`STATUS.md §76` | 同上 |
| 复用 | 子集对 | **1,632** 对（2,818 个 2 格 feature 里 816 个被同族 4 格 feature 严格包含） | 已完成 | `_q_subset_pairs.py` | `python step03_pip/_q_subset_pairs.py` |
| 复用 | 跨族共享 | **3/1,598**：`(1,0,6)`∈LH0/LV_L0/LV_L18、`(0,0,2)`∈LH0/LV_L0、`(0,0,9)`∈LV_L0/LV_L18 | 已完成 | `_q_reuse_structure.py` | 同上 |
| 复用 | 地址可公式化 | **160/172 = 93.0%**；剩 12 族（6 时钟/控制 + 6 长线）覆盖 178/3,634 = 4.9% feature | 部分完成 | `STATUS.md §74` | `python step03_pip/_q_reuse_mainline.py` |
| 复用 | 源→槽位顺序 | **0/1,536 = 0%**（顺序由布线邻接决定，是数据不是规律） | 已作废（当作「可推导」的目标） | 同上 | 同上 |

### 3.4 读写闭环与可解性

| 层 | 指标 | 数值 | 状态 | 证据 | 复算 |
|---|---|---|---|---|---|
| 读 | 精确解码器 | `_full8.bit` 真值 198：解 190、命中 190、误判 0、漏 8 → **精确 100% / 召回 96.0%** | 已完成 | `v7re/steps/T31_DECODE_LAW_EXACT.md` | `python v7re/export/decode_law.py --bit _full8.bit` |
| 写 | FASM 幂等 | 4 个设计解码→回写，**0 帧改动**，sha256 相同 | 已完成 | `v7re/steps/T32_FASM_ROUNDTRIP.md` | `python v7re/scripts/fasm2bit.py --decode _full8.bit --in _full8.bit` |
| 写 | 从零重建 | 数据字差 **118 位 / 13 帧**（50,176 帧），全部可归因已知缺口 | 部分完成 | 同上 | 同上 `--blank` |
| 闭环 | 位级重综合 | `SLICE_X47Y51` 0 字差异；全芯片 53 字差异 | 部分完成 | `STATUS.md §15` | `python v7re/scripts/resynth_diff.py` |
| 篡改 | 单 bit 穷举 | **1,624,720 / 1,633,808 = 99.4438%**（982 tile × 1,664 格） | 已完成 | `tamper/exhaustive_ref_154col.json` | `python v7re/scripts/tamper_localize.py --exhaustive tamper/ref/ref.bit` |
| 篡改 | 整条 PIP 删除 | 8/300 = **2.67%**（全是共享格附带损伤，孤立 PIP 删除 0 检出） | 已完成 | `tamper/classes_ref300_154col.json` | `--classes tamper/ref/ref.bit` |
| 篡改 | 空槽整条 PIP 添加 | **0/300** | 已完成 | 同上 | 同上 |
| 篡改 | word 50 单 bit | **0/300** | 已完成 | 同上 | 同上 |
| 篡改 | 换源（改 2–4 bit） | 18/300 = **6.0%**（共享格命中 15.2% / 无共享 0.5%） | 已完成 | `tamper/atk_ref300_154col_fixed.json` | `--attack tamper/ref/ref.bit` |
| 篡改 | 真实 LUT 功能篡改 | Vivado 改 24 个 LUT6 的 INIT：差 1,092 bit、**落在建模区 0 个**、PIP 集合 982/982 tile 相同 | 已完成（这是「抓不到」的证据） | `tamper/delta_init.json`、`_q_delta_154col.py` | `python step03_pip/_q_delta_154col.py` |
| 误报 | 真实设计 | 未标定 12.22% 的 tile 报警（146.87 ppm）；白名单两格后 **0** | 已完成 | `tamper/fpstats.txt` | `--fpstats tamper/ref/ref.bit` |
| 可解性 | 源级判定 | 1,066 个含 mux 配置的 tile **全部唯一解，0 多解、0 零解** | 已完成 | `step03_pip/out/p1_solvability.json`、`STATUS.md §94` | `python step03_pip/p1_solvability.py --bit tamper/ref/ref.bit` |

### 3.5 跨 tile 类型

| 层 | 指标 | 数值 | 状态 | 证据 | 复算 |
|---|---|---|---|---|---|
| 普查 | 有 PIP 的 tile 类型 | 115 类型中 **70 个含 PIP**，共 **35,126 条 PIP / 16,951 family**，平均 2.07 源/族 | 已完成 | `v7re/steps/T44_ALL_TILE_PIP_SURVEY.md` | `python step03_pip/pip_law_any.py --all` |
| 普查 | A 类（每目的 1 源） | 23 类型、**7,517 条 = 21.4%**、平均 1.00 源/族 | 已完成（普查） | 同上 | 给不出：同上一行 |
| 普查 | D 类（密集多源） | 8 类型、**15,518 条 = 44.2%**、平均 15.46 源/族（INT 17.3、HCLK_CMT 23.4、CLK_HROW 12.7） | 已完成（普查） | 同上 | 给不出：同上 |
| 位映射 | INT 以外实测 | 只有 `BUFGCTRL`：S0/S1 = **2 位**，`(frame_f, word_w, bit 11)` + `(frame_f+1, word_w, bit 3)` | 部分完成 | `v7re/steps/T42_CLOCK_MUX_BATCH.md` | 见该文档表 |
| 位映射 | A 类位映射 | **从未实测**（T40 计划第 1 批未执行） | 未开始 | `v7re/steps/T40_OTHER_TILES_PLAN.md` | 给不出：需远端 Vivado 逐实例删 PIP |
| 迁移 | 阻塞 | A 类 21.4% 能否「一条 PIP 一位」按可证伪处理；反例已有（BUFGCTRL 2 源占 2 位、IOSTANDARD 7 位/2 帧） | — | `STATUS.md §84`、`§89` | — |

---

## 四、已作废结论

| 旧结论 | 作废依据 | 新结论 |
|---|---|---|
| 每源恒 5 格、cell 共用 `[4,4,4,4,4,4,24,24,24,24]`、平均 3.35 格/feature、7.61 次/cell、102/172 唯一、70 族 4:1 合并、组模型需并 4 个恒定格 | **sense=1 与 sense=0 混算**；按 sense=1 重算（`_q_reuse_structure.py`、`verify_all_pip.py`） | 2.45 格/feature、5.57 次/cell、**172/172 唯一**、7 类形状、组模型 96/96 精确命中、恒定格 0（`STATUS.md §65`、`T35 §6`） |
| INT_R 覆盖率只有 2,312/3,634 = 63.6%、缺 1,274 | **线名不对称**（`IMUX_L40` vs `IMUX40`、`GCLK_L_B0` vs `GCLK_B0_EAST`）；加 `--normalize` 后 | INT_R **3,634/3,634 = 100%**，`STATUS.md §68` |
| 幽灵 mux 篡改 300/300 = 100% 可检出 | **检测器未减基线**：120 个带标记位的 tile 被误算成检出；改成同 tile 前后差分后 | 幽灵 mux **0/300**，`STATUS.md §90`、`tamper/atk_ref300_154col_fixed.json` |
| 读出侧「2 格 pattern 下源不可判」，与写入侧 2 bit 自由是同一缺口 | **P1 精确覆盖枚举**：1,066 tile 全唯一解（`p1_solvability.py`） | 读侧**唯一可解**（模型口径）；写侧 2 bit 自由是字距事实，两者不同源（`STATUS.md §94`、`paper/TAMPER_LOCALIZER.md` §7） |
| `far_bands` 只有 128 列，9,000 个 tile 靠 `column_offsets` 别名换算 | **导出脚本 `& 0x7F` 截断**了 FAR 的 10 位列字段；补到 154 列后 | 1,078 行、覆盖 53,100 个 INT 实例（84.79%），`STATUS.md §87/§90` |
| CLB LUT INIT 位定义（`site_frames`） | Vivado 对照：INIT[01] 实际在 `frame 31786 w40 bit7`，表说 `31787 w15`（`STATUS.md §38`） | T11–T19 重建；**表不能用于真实设计**（`§48` T18） |
| `site_frames` 缺口「727 万行」 | 直接数表：INIT 只有 A6LUT 的 37,900 site × 64 = 2,425,600 | 缺口 **16,979,200 行**（目标 36,799,100） |
| 6×4 表格「前两列 2 格、后两列 4 格」 | 逐格核对 `law_cells` | **前两列 4 格、后两列 2 格**（`STATUS.md §73`） |
| `row_frames=5246` = 每 config row 的帧数 | 直接查 `far_bands` | = **每个 band 的帧数**（`STATUS.md §78`） |
| `end_frame` 可用于算列边界的帧数 | 自相矛盾（INT_L 列 4,387 vs INT_R 27–41），无代码消费 | 弃用；统一 `frames` 列 = `end−start+1` |

---

## 五、缺口账

| 缺口 | 描述 | 影响范围 | 阻塞项 |
|---|---|---|---|
| 数据层 INIT | `site_frames` 19,819,900 行；INIT 只覆盖 A6LUT（37,900 site × 64）；目标 36,799,100 | 全器件 LUT 配置读写；缺 16,979,200 行 | 需 `VACUUM INTO` 备份后建新表（禁原地 UPDATE） |
| 缺 block | 100 个 block 缺失（`Y≈298/299`，band 5） | 该行带的 tile 无地址 | 需远端补测 |
| ECC 地址项 | `A(frame_addr)` 未定；纯数据模型秩 143、矛盾 | 无法生成任意可加载位流；TM2 上板不可做 | 需更多边界帧样本（远端 + 板） |
| ECC 全表 | `ecc_table.json` 只覆盖 23/100 word | CLB/DSP/BRAM 数据位写不进去 | 依赖上一项 |
| 跨 tile 类型 | 除 INT/BUFGCTRL 外无实测；A 类位映射未验 | 78.6% 的 PIP 无位库 | 需远端 Vivado 逐实例实验（16–18 路并发） |
| 器件泛化 | 只有 485T 一个器件 | 结论不能外推到其它 7 系列 | 需第二器件样本 |
| 真实设计样本 | 只有 `tamper/ref/ref.bit` 一个真实设计 | 检出率/误报率的普适性弱 | 需更大设计 |
| 远端库版本 | 远端 `v7_law.sqlite` 仍是 128 列 | 远端脚本结果与本地不一致 | 需同步 + 重跑 |
| 文档口径 | `STATUS.md` §3–§5 停在 2026-10-27 | 「进度以 STATUS 为准」会误导 | 本次已加指向 §96 的告示 |

---

## 六、风险与边界

1. **模型依赖**：所有「100%」都是相对于 3,634 条 feature/侧的模型而言；模型外若存在未收录的 feature，唯一性会被高估。反证支撑：与 `pips_all.txt` 真值对账解出 91.45%。
2. **单器件、单设计**：485T + 一个 24 级 LUT 链设计；跨器件、跨设计未测。
3. **三项结论互为前提**：可解性（P1）依赖标记位口径；篡改检出（TM2）依赖 `law_cells` 的完整性；覆盖率（54.49%）依赖 `far_bands` 的 154 列。任一项错，其余数字要重算。
4. **【推断】成分**：`frame_row = 16+r` 的起点 `16 = 25−9` 是推断；band 置换 `[6,5,0,1,2,3,4]` 的成因未测；word 50 夹在中间的原因未测。
5. **不可讲的话**：不能说「首次」「唯一」「完全破解」；prjxray/artix7 的位形状是**移植**，本地新增的是地址律、生成式压缩、闭环与可解性判定。

---

## 七、下一步优先级（只排主线：PIP 复用分析）

1. **把「7 谱型 + 乘积结构 + 子集对」写成生成式代数**（2–3 人日，本地）。
   现状是查表（`law_cells` 3,634 条）；目标是给定 `(family, src)` 能闭式算出位集。
   判据：对 172 族闭式生成，与 `law_cells` **逐条 0 差异**；对 12 个未闭式族的边界要显式写清。
2. **判定「源 → 槽位顺序」是数据还是规律**（1–2 人日，本地）。
   现在实测 **0/1,536 可推**。检验法：用 `tileconn` 的布线邻接去预测源的槽位顺序，
   命中率显著高于随机就说明「顺序 = 邻接」，否则说明它真是表里的数据。这一条直接决定
   第 1 条的代数能不能覆盖顺序。
3. **复用的跨类型成立性**（3–5 人日，远端 Vivado）。
   A 类 7,517 条（21.4%）每目的只有 1 源 —— 结构上没有「复用」，但要确认**位上**也没有
   （即不存在共享 cell 的隐式复用）。这是主线范围的边界，不是迁移工程。
4. **复用的跨器件同构性**（>10 人日，需第二器件）。
   7 谱型是否在另一片 7 系列上重现；重现则「复用规律」可以升格为跨器件结论。
5. **复用表的下游验证**（0.5 人日，本地，可选）。
   把复用表当精确覆盖判据接回主解码器，替掉 `min-cells`；预期 T31 召回 96%→更高、T32 残差下降。
   这是「复用表完备」的最强证据，但**不是**主线目标。

> 不在本清单里的：ECC 地址项、`site_frames` 补全、篡改定位器上板、跨类型位库迁移。
> 它们与复用规律的正确性无关，等主线讲完再按需推进。

---

## 附：本轮复核用的命令

```bash
python step03_pip/_q_pipbits_state.py                      # pip_bits 构成
python v7re/scripts/verify_all_pip.py --tile-type INT_L --normalize
python v7re/scripts/verify_all_pip.py --tile-type INT_R --normalize
python step03_pip/p1_solvability.py --bit tamper/ref/ref.bit _full8.bit
python step03_pip/_q_pip_reconcile.py                      # 3,737 对账
```
