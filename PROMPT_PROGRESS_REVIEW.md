# 提示词：主线进度复盘 + 下一步建议

> 本文件为交付给 agent 的提示词。正文经 `prompt-optimizer`（`user-prompt-professional`，2026-11-16）优化，硬数据附录为人工补入的原文数字，不得改写。

## 一、提示词正文（优化后）

请对 Xilinx Virtex-7（xc7vx485tffg1157-3）位流逆向项目做一次主线进度复盘，并给出可直接执行的下一步建议。复盘对象仅限项目主线"INT tile 中 PIP 复用编码规律"，即多源共享少数配置位的结构及生成函数；不要扩展到其他 tile 或其他逆向子任务。权威信息仅取自以下四份材料：PROJECT_WORK_SUMMARY.md（当前全貌）、SINGLE_SOURCE_OF_TRUTH.md（口径与作废清单）、STATUS.md（逐节实验记录）、repro.py（12 项一键自检）。请按以下三部分输出。

### 一、主线进度总结
1. 用一句话概括主线当前所处阶段，阶段判断须能对应到上述文档中的具体节号或自检项。
2. 按"已闭合 / 数据缺口 / 方法上限"三类列出 INT PIP 复用主线的确切进度。每一项必须附带文档中已出现的数字，包括但不限于族数、feature 数、覆盖率、命中数；每个数字后注明出处（文档名 + 节号，或 repro.py 中对应自检项编号）。文档中未给出明确数字的项，写"文档中未给出"，不得估算或补全。
3. 明确区分并解释以下四个覆盖率口径各自的分母、分子和含义：位级已知、可由公式或表重建、纯定律、实例级实测。说明四者之间不可互相替代的原因，并指出文档中当前分别引用的是哪一口径。

### 二、识别真正的下一步
1. 从未闭合清单中筛选一项作为建议的下一步，筛选标准为：对论文贡献价值最高、且当前具备可执行条件（所需数据和工具已就绪）。列出候选清单及筛选过程。
2. 说明为什么选该项而非其它候选项，逐项对比至少两个其它候选的成本（所需构建量、依赖缺口、预计耗时）与收益（对论文的支撑点）。
3. 给出该项的完成标准，至少包括：需要多少构建量（如多少个 tile、多少条 PIP、多少个 feature）、产出什么表或数字（注明表名、字段和期望量级）、用 repro.py 中哪条命令或哪个自检项验证、预计耗时。完成标准须可判定是否达成。

### 三、诚实边界
1. 列出属于方法上限的事项——当前方法原理上无法覆盖，明确不建议投入。每项说明原理性限制所在。
2. 列出属于作废口径的数字或结论，注明其作废依据（SINGLE_SOURCE_OF_TRUTH.md 中的具体条目），并声明不得引用。

### 硬性要求
所有数字必须能在给定文档中找到出处，每个结论附一条可复现命令或文档节号；明确区分"已验证"与"推断"，推断项须标注为推断；文档中无明确数字的写"文档中未给出"，不得猜测。输出为中文，按上述三部分结构化分节，便于直接作为项目状态报告引用。

---

## 二、硬数据附录（回答时必须原样引用，不得改写）

### A. 主线定义
- 器件：`xc7vx485tffg1157-3`（ Virtex-7 485T）
- 主线：**PIP 复用编码规律** = 多源共享少数配置位的结构 + 生成函数（PROJECT_WORK_SUMMARY.md §1）
- 首期范围：CLB + INT + 基础时钟；BRAM/DSP/GT/PCIe 后置
- 当前阶段：收口 + 论文交付（PROJECT_WORK_SUMMARY.md §1、§0）

### B. INT 主线核心数字（PROJECT_WORK_SUMMARY.md §4 关键数字总表）
| 项 | 值 | 出处 |
|---|---|---|
| INT 族 / feature | 172 / 3,634（每侧 INT_L、INT_R 各一份） | `law_cells` |
| 24 源 mux | 64 族 / 1,536 feature / 每源 5 格 | `law_cells` |
| BEG | 96 族 / 1,920 feature / 每源 2 格 | `law_cells` |
| 长线 | 6 族 / 82 feature（48/82 完整乘积） | `law_cells` + `beg_families.json` |
| 行序 | 16 码 × 4 族；重建 32/32；147→20 bit | `_row_s4.py` / `row_law.py` |
| 列序 | 512 槽 → 32 bit（32×）；两侧 64/64 同 | §189/§190 |
| (feature,cell) | 8,900 条 / 1,598 个不同格 | `figs/fig3_coverage.csv` |
| ECC 位置 | 154 | T8 |
| CRC 签名 | 3,200（单帧）/ 64（条目） | `crc_table.json` |
| 自检 | `repro.py` **12/12 PASS**，约 9 s | 本地 |

### C. 四档覆盖率口径（SINGLE_SOURCE_OF_TRUTH.md §2.9 + PROJECT_WORK_SUMMARY.md §4）
| 档 | 分子/分母 | 比例 | 含义 |
|---|---|---|---|
| 位级已知 | 3,634 / 3,634 | 100% | 每条 feature 的 cell 全在库、命中 0 不符（repro.py `verify.INT_L`/`verify.INT_R`） |
| 可由公式或表重建 | 3,552 / 3,634 | 97.74% | 定律 3,456 + 复合组模型 96（repro.py `slots.coverage`） |
| 纯定律 | 3,456 / 3,634 | 95.10% | mux 1,536 + BEG 1,920，回落 0 |
| 无公式（长线） | 82 / 3,634 | 2.26% | 6 个长线族，只能查表 |
| 实例级实测 | 12,565 / 53,100 | 23.66% | 实测覆盖的 INT tile 占比（repro.py `tiles.instances`）——**是"测过的 tile"，不是"律成立的 tile"** |
| INT 占全器件可配置 PIP | 198,434,700 / 207,253,149 | 95.75% | 实例级重要性的上界 |

### D. 四级可解释性（SINGLE_SOURCE_OF_TRUTH.md §2.9、STATUS.md §206）
| 级 | 含义 | 数 | 状态 |
|---|---|---|---|
| L1 纯公式 | 槽位由线名（方向+长度）决定 | 3,456 / 3,634 = 95.10% | ✅ |
| L2 乘积+置换 | A×B 成立，配对需置换表 | 48（LH12 12 / LVB_L0 18 / LVB_L12 18） | ✅ |
| L3 纯查表 | 直接存 feature→2 cell | 34（LV_L0 10 / LV_L18 12 / LH0 12），21 个不同 cell | ✅ |
| L4 零配置位 | ppip / 单扇入 | 108 行（44 always + 64 default） | 📊 |

### E. 未闭合清单（PROJECT_WORK_SUMMARY.md §6）
数据缺口（6.1）：长线完整乘积（现已知无律，§203-205）、`LV_L9`/`LH6` 驱动源 2 条、INT 实例覆盖差 40,535 tile、BOUNCE 2 位结构解释、HCLK_CMT 剩余 32 源、CLB 约 6 条、整条流 CRC。
方法上限（6.2）：行轴类内成员序、BRAM 180 条地址 mux、其它类型 111–358 超大 fan-in、6×4 的 LOGIC/GFAN/BOUNCE 行归属、长线配对（§205 名字不含位置）。

### F. repro.py 12 项自检（可引用命令）
`slots.coverage` 3552/3634 · `slots.families` 172 · `verify.INT_L` 3634/3634 · `verify.INT_R` 3634/3634 · `mux.law` 1536/1536 · `beg.shape` 32/32 · `row.generator` 2048/2048 · `tiles.instances` residual 0/23.66% · `figs.data` fig5 2,893 · `figs.sum` sum 8900 · `frames.full` (1183,50148) · `unit.tests` 15 passed。运行：`python repro.py`（`-k` 过滤）。

### G. 作废口径（PROJECT_WORK_SUMMARY.md §8 / SINGLE_SOURCE_OF_TRUTH.md §4）
36 种行序、T13 INIT 表、24 源接口、word50 是配置位、4.3% 残余、CLB 151 条可配置、site_frames 残缺、"103 条"（正确 108）、"34 条无法生成"（正确 48+32+2）、"far_bands 覆盖全部帧"（只覆盖 73.2%）。

### H. 复现命令
- 一键自检：`python repro.py`
- 全族校验：`python v7re/scripts/verify_all_pip.py --tile-type INT_L`
- 实例覆盖：`python v7re/scripts/all_int_tiles_check.py --bit _tilecov2/cov2.bit`
- 槽位生成：`python step03_pip/gen_slots.py`
