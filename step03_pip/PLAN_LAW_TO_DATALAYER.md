# 把 PIP 定律接回数据层 —— 实施计划

> 生成依据：`step03_pip/PROMPT_LAW_TO_DATALAYER_PLAN_V2.md`（经 `prompt-optimizer` MCP 生成的计划提示词）。
> 读者假设：没有本会话上下文的工程师。文中所有数字均可用第 3 节的命令复算。

- **Goal**：INT tile 的 PIP 定律（172/172、0 不符）已经在位语义层闭环，但数据层 `site_frames` 的 LUT INIT 部分只覆盖了 1/8（37,900 个 site 的 A6LUT），导致解码器仍输出不了完整网表。本计划把定律、实测顺序表接回持久层，同时把 `STATUS.md` 的索引债收口。
- **Architecture**：`v7_law.sqlite`（定律/实测表）→ `v7re/scripts/build_site_frames.py`（生成器）→ `v7_model.sqlite.site_frames`（7.6 GB 持久表）→ `v7re/export/decode_law.py` / `v7re/scripts/fasm2bit.py`（解码与重建）。
- **Tech stack**：Python 3.8（numpy / pyyaml / intervaltree / pytest）、SQLite（`v7_law.sqlite` 10 MB、`v7_model.sqlite` 7,581 MB）、Vivado 2017.2（仅 C 轨需要）。
- **Baseline refs**：`STATUS.md` §56–§63、`step03_pip/REUSE_RULES.md:8`、`v7re/steps/T3_PIP_REUSE_LAW.md` §9.2、`T34_COMPOSITE_FAMILIES.md`、`T35_COMPOSITE_GROUP_MODEL.md`、`T32_FASM_ROUNDTRIP.md`。
- **Compatibility boundary**：`site_frames` 的 8 列 schema（`device, site, bel, feature, frame, word, bit, source`）不变；`source` 词表只增不改；已有 17,394,300 行 `law:clb_cells+clb_blocks@2026-11-02` 一字不动。
- **TDD Route**：`mode=off`，`decision=skipped`，authority = 项目 AGENTS.md 未要求 TDD。理由：B 轨主体是对持久表的数据替换与校验，没有可先写失败测试的行为变更；改用「负对照即 FAIL」的既有机制（`test_locked_init_map.py` 的 T2 互换测试）承担同等作用。
- **Verification**：见第 3 节全局回归门，任一失败即停止。

---

## 1. 现状基线

### 1.1 已验证（可直接引用，不要重做）

| 事实 | 证据 |
|---|---|
| INT tile PIP 定律覆盖 172/172 家族、3,634 条 feature、精确命中 3,634、未覆盖 0、不符 0 | `python v7re/scripts/verify_all_pip.py --tile-type INT_L`（本机实跑） |
| 复合码族组模型：24 组 core + 12 个附加位 + 96 条「源→槽位」 | `v7re/steps/composite_groups.json`、`T35_COMPOSITE_GROUP_MODEL.md` |
| 组模型重建 96/96、不符 0 | 本计划复算：模型集 ∪ 族恒定 4 cell == `law_cells` 观测集，96/96 一致 |
| 精确判据消 2 格歧义：`_full8` 190/198、误判 0 | `STATUS.md:1916-1926`（§57 T30）、`v7re/steps/T30_EXACT_MATCH.md` |
| 解码 → 回写逐字节幂等（4 个设计、改动帧 0） | `STATUS.md:1947-1954`（§59 T32） |
| LUT INIT 索引顺序随 slice 种类不同：SLICEM 用 T19 顺序、SLICEL 用 law 顺序，互为仿射置换 | `STATUS.md:1893-1899`（§56 T23）、`v7re/steps/clb_init_locked_map.json` |
| 位流 → 位流从零重建残差 118 位 / 13 帧，全部可归因 | `STATUS.md:1956-1958` |
| 帧/字地址律 `frame = base + frame_off`、`word = 2*(Y%50)+parity`（≥50 则 +1） | `step03_pip/CRAM_TERMS_AND_ADDRESSING.md`、`v7re/scripts/bitwriter.py:41-62` |

### 1.2 技术债（本次要还的）

| # | 债 | 量化 | 证据 |
|---|---|---|---|
| D1 | `site_frames` 的 LUT INIT 只覆盖 **37,900 个 site 的 A6LUT** | INIT 行 2,425,600 = 37,900 × 64；`bel` 前缀只有 `A`；`source='t19_locked_init'` | 本机 `select substr(bel,1,1),count(*) ... where feature like 'INIT%'` |
| D2 | 完整 INIT 应为 75,800 个 site × 4 个 BEL × 64 位 = 19,404,800 行 | 缺 16,979,200 行；补全后全表 19,819,900 + 16,979,200 = **36,799,100**（与历史全量生成数一致） | `STATUS.md:857`（历史 36,799,100 行）、本机计数 |
| D3 | 全库 `site_frames` 尚有 100 个 block 未覆盖（`Y≈298/299`，band 5） | 100 block | `STATUS.md:1913`（§56 覆盖边界） |
| D4 | 从零重建残差 118 位 / 13 帧，其中 8 个旁路直通族未建模 | 118 位 | `STATUS.md:1956-1958`（§59） |
| D5 | `STATUS.md` 编号重复 4 处 | §5 在 187/312 行、§6 在 286/331、§35 在 1294/1363、§52 在 1775/1812 | 本机正则扫描 |
| D6 | 本会话两节被 `git checkout` 回滚丢失 | 引用 `CRAM_TERMS_AND_ADDRESSING` / `PIP_REUSE_LAYER_EXPLAINED` / `CRAM_LAYOUT_DIAGRAM` 的字符串在 `STATUS.md` 中出现 **0 次**；文档本体在 `step03_pip/` 磁盘上完好 | 本机 grep |
| D7 | T35 组模型口径缺失：实际位集 = 模型集 ∪ 族恒定 4 cell，文档未写 | 照纯公式手算会得到不符率 100% | 本计划复算 |
| D8 | `composite_groups.json` 第 7 个键 `LV_L0` 语义未归档 | 10 个源、7 个 cell、无恒定 cell | `law_cells` 实测 + T33 遗留 10 条 |

> 【推断】D8 的 `LV_L0` 在 T34/T35 中被写入 JSON 但未产生组映射（组内 drops/extras 为空），它的 10 条 feature 由 BEG/时钟树分支覆盖，故总覆盖率仍是 3,634/3,634。**执行 A4 时必须实测确认，不得照抄本推断。**

---

## 2. 任务分解

依赖顺序：A1 →（A2、A3、A4 任意序）→ B1 → B2 → B3 → B4 →（可选 C1 → C2）。
A 轨与 B 轨无代码耦合，可并行；但 **B1 未完成前禁止执行任何 B 轨写库动作**。

### A1 —— 重新挂载被回滚的两节（§64、§65）

- **改动文件**：`STATUS.md`（仅追加，不动既有行）。
- **最小改动**：在文件末尾追加 `## 64.`（PIP 复用层次解释与数字修订：70/172 族 4:1 合并、3,634 条 feature、`IMUX_L40` 的 24 源/10 cell/每源 5 cell）与 `## 65.`（`(frame_off, parity, bit)` 术语与地址换算链 + 两条真实演算 + `step03_pip/CRAM_LAYOUT_DIAGRAM.html` 指针）。正文素材直接取 `step03_pip/PIP_REUSE_LAYER_EXPLAINED.md` 与 `step03_pip/CRAM_TERMS_AND_ADDRESSING.md`，不要重写内容。
- **验收命令与预期输出**：
  ```
  python -c "import io,re;t=io.open('STATUS.md',encoding='utf-8').read();print([l for l in t.splitlines() if l.startswith('## 64.') or l.startswith('## 65.')])"
  → 两行，且 t.count('CRAM_TERMS_AND_ADDRESSING') >= 1、t.count('CRAM_LAYOUT_DIAGRAM') >= 1
  ```
- **回滚**：`git checkout -- STATUS.md`（A 轨全部只动这一个文件，回滚代价为零）。

### A2 —— 修掉 4 处重复编号

- **改动文件**：`STATUS.md`（只改 4 个标题行）。
- **最小改动**：把后出现的那一节改为带后缀编号并加一行交叉引用，不重排正文：
  - 行 312 `## 5. 跨类型（INT_L vs INT_R）` → `## 5b. 跨类型（INT_L vs INT_R）`
  - 行 331 `## 6. PIP 复用规律（可执行形式…）` → `## 6b. PIP 复用规律（可执行形式…）`
  - 行 1363 `## 35. T8 —— 位流改写器闭环` → `## 35b. T8 —— 位流改写器闭环`
  - 行 1812 `## 52. T21 —— 四个 LUT 的 INIT 映射同构…` → `## 52b. T21 —— 四个 LUT 的 INIT 映射同构…`
- **验收命令与预期输出**：重复扫描脚本输出空集（第 3 节 G-A2），且 `§57`–`§63` 标题一字未变。
- **回滚**：同上。

### A3 —— 补写「恒定 cell 必须并回」口径

- **改动文件**：`v7re/steps/T35_COMPOSITE_GROUP_MODEL.md`、`STATUS.md:1992-2000`（§62）。
- **最小改动**：在 T35 的组模型公式旁加一句硬口径与一个可复算片段：
  `obs(src) = (core − {drop}) ∪ const`（2 格源）/ `obs(src) = (core ∪ {extra}) ∪ const`（4 格源），其中 `const` = 该族 16 个源的交集（6 个复合族各 4 个 cell）；§62 同步加一行指向。
- **验收命令与预期输出**：执行第 3 节 G-A3 的复算片段 → 打印 `checked 96 exact+const 96 exact 0`。
- **回滚**：`git checkout -- v7re/steps/T35_COMPOSITE_GROUP_MODEL.md STATUS.md`。

### A4 —— 归档 `LV_L0` 的语义

- **改动文件**：`v7re/steps/T35_COMPOSITE_GROUP_MODEL.md`（新增一小节）、`STATUS.md` §62。
- **最小改动**：查明 `LV_L0` 的 10 条 feature 由谁覆盖（BEG 96 族表 `v7re/steps/beg_families.json` 还是时钟树 5 族），写清「它是复合族还是普通族、为何在 JSON 中有键但组映射为空」，并明确「96 条」口径指复合族源数，不含 `LV_L0`。
- **验收命令与预期输出**：`verify_all_pip.py --tile-type INT_L` 仍 3,634/3,634；文档中出现 `LV_L0` 的归属结论与证据指针。
- **回滚**：文档回滚，无代码影响。

### B1 —— 备份与副本库（**前置，未完成不得写库**）

- **改动文件**：新增 `step03_pip/backup_site_frames.py`。
- **最小改动**：`VACUUM INTO` 出一份完整副本库（预计 7.6 GB，磁盘需 ≥8 GB 空闲），并在 `meta` 表写入备份时间与源库 sha256（分块摘要，不要整库读进内存）。
- **验收命令与预期输出**：
  ```
  python step03_pip/backup_site_frames.py --src E:\v7work\model\v7_model.sqlite --dst E:\v7work\model\v7_model.backup-YYYYMMDD.sqlite
  → 打印 COPY_DONE、行数 19819900 与源库一致
  ```
- **回滚**：删副本即可，源库未被触碰。

### B2 —— 补全 LUT INIT 到 19,404,800 行

- **改动文件**：`v7re/scripts/build_site_frames.py`（复用既有 `--locked-init` 路径，可能需要新增 `--only-feature INIT` 与按 BEL 选择 slice 种类的分派）；必要时 `step03_pip/gen_locked_init_map.py`。
- **最小改动**：把 INIT 的发射范围从「A6LUT × 37,900 site」扩到「A/B/C/D 四个 BEL × 75,800 site」，四个 BEL 通过 `clb_init_locked_map.json` 的 `orders.{SLICEM,SLICEL}` 与 `bel_rule` 选择顺序；`source` 仍写 `t19_locked_init`，不要新增来源字符串。
- **验收命令与预期输出**：
  ```
  python v7re/scripts/build_site_frames.py --validate          → VALIDATE: PASS
  python step03_pip/test_locked_init_map.py                    → RESULT: PASS
  SELECT count(*) FROM site_frames                             → 36799100
  SELECT count(*) FROM site_frames WHERE feature LIKE 'INIT%'  → 19404800
  SELECT substr(bel,1,1),count(*) ... GROUP BY 1               → A/B/C/D 各 4851200
  ```
- **回滚**：`DROP TABLE site_frames; ALTER TABLE site_frames_new RENAME TO site_frames`（写入必须走「新表 + 事务 + 改名」，禁止原地 UPDATE 千万行）；或直接从 B1 副本恢复。

### B3 —— 补齐 100 个缺失 block

- **改动文件**：`v7re/scripts/build_site_frames.py`（block 枚举来源）、`v7re/steps/FRAME_MAP_STATUS*`（状态更新）。
- **最小改动**：`Y≈298/299`（band 5）的 100 个 block 缺 `far_bands` 基址或 `clb_blocks` 记录，先把缺口列成清单，能由地址律推出的补；推不出的（需实测）单独列为已知边界，不硬凑。
- **验收命令与预期输出**：清单文件 100 条，每条标注「已补 / 仍缺 + 原因」；`--validate` 仍 PASS。
- **回滚**：同 B2。

### B4 —— 端到端验收：解码器输出完整网表

- **改动文件**：`v7re/export/decode_law.py`（如 INIT 覆盖面扩大后仍需改判据）、报告文件。
- **最小改动**：不动判据，只做测量：对 `tamper/ref/ref.bit` 与 `_full8.bit` 跑解码，统计「解出的 feature 类型分布」与「B/C/D 的 INIT 是否终于出现在输出里」。
- **验收命令与预期输出**：
  ```
  python v7re/scripts/fasm2bit.py --decode ...    → 4 个设计改动帧 0（T32 幂等不退化）
  python v7re/scripts/fasm2bit.py --blank ...     → 残差应 ≤ 118 位 / 13 帧（不得增加）
  python v7re/scripts/verify_all_pip.py --tile-type INT_L / INT_R → 两条均 0 不符
  ```
- **回滚**：代码改动不大，单文件 `git checkout`。

### C1（可选）—— 补 8 个旁路直通族

- **改动文件**：新增实验目录 `tamper/bypass/`（构建脚本与产物）、`v7re/steps/T36_*.md`。
- **最小改动**：2 次 Vivado 构建，定位 8 个旁路直通族的选通位，写进定律表。
- **前置**：必须先得到用户对「跑 Vivado 构建」的同意（第 6 节）。
- **验收命令与预期输出**：`fasm2bit.py --blank` 残差从 118 位降到接近 0；新族在 `verify_all_pip` 中 0 不符。
- **回滚**：丢弃 `C:\Temp\tamper_ref` 产物，不动工作区已有 `.bit`。

### C2（可选）—— 残差归零验证

- 与 C1 合并执行；只有当残差降到个位数且每条都能给出来源时才写「闭合」。

---

## 3. 全局回归门

任一失败即停止并回滚，不得带着红门继续下一步。

| 门 | 命令 | 预期 |
|---|---|---|
| G1 | `python v7re/scripts/verify_all_pip.py --tile-type INT_L` | 172 家族 / 3,634 feature / 命中 3,634 / 未覆盖 0 / 不符 0 |
| G2 | 同上 `--tile-type INT_R` | 对称，0 不符 |
| G3 | `python v7re/scripts/tamper_localize.py --check tamper/ref/ref.bit` | L1 未解释位 234（白名单后 0）、L2 槽位违例 0 |
| G4 | `python v7re/scripts/build_site_frames.py --validate` | `VALIDATE: PASS` |
| G5 | `python step03_pip/test_locked_init_map.py` | `RESULT: PASS` |
| G6 | T5 往返：清空重建 9/9 tile、52 条 PIP | 0 差异 |
| G7 | `fasm2bit.py --decode` 四个设计 | 改动帧 0、sha256 相同 |
| G-A2 | 重复标题扫描 | 空集 |
| G-A3 | 组模型复算 | `checked 96 exact+const 96 exact 0` |

---

## 4. 风险与回滚

| 风险 | 触发条件 | 处理 |
|---|---|---|
| 写坏持久表 | B2/B3 原地 UPDATE 千万行 | **禁止原地改**：新表 + 事务 + `RENAME`；失败直接 `DROP` 新表并保留旧表 |
| 副本库占满磁盘 | 磁盘空闲 < 8 GB | B1 前先查空闲；不足则先压缩历史 `.dcp`（C 档，另需用户同意） |
| 索引置换规律在 2 个 LUT 种类上不闭合 | T23 只实测了 SLICE_X11Y20 的 A6LUT | 先把「未测 BEL」标为未验证并只落已测部分，不要用外推填 4 个 BEL 的全部位 |
| `build_site_frames.py` 499 行改动外溢到非 INIT 特征 | 改 `emit_site_frames` 时 | 每次改写后跑 G7（幂等）与「INIT 之外行数不变」对账 |
| Vivado 中文路径崩溃 | 在仓库目录内跑构建 | 一律在 `C:\Temp\tamper_ref`；产物拷回 |
| PS 5.1 毁中文文件 | 用 `Get-Content`/`Set-Content` 回写 `STATUS.md` | 一律 Python 显式 UTF-8；见 `STATUS.md:2002-2008` |

---

## 5. 时间估计与优先级

| 任务 | 人日 | 不确定性来源 |
|---|---|---|
| A1–A4 | 0.5–1 | 无（纯文档，素材已在磁盘） |
| B1 | 0.2 | `VACUUM INTO` 7.6 GB 耗时 |
| B2 | 2–3 | 四个 BEL 的 slice 种类分派是否真的只由 `bel_rule` 决定；INIT 全量生成耗时（历史 679.9 s） |
| B3 | 0.5–1 | 100 个 block 能否纯由地址律推出 |
| B4 | 0.5 | 解码器是否需要新判据 |
| C1–C2（可选） | 1–2 + 2 次构建 | 旁路族覆盖率能否两次构建就吃到 |

优先级：A（消除索引歧义，代价最低）> B1（安全网）> B2（主收益）> B4（验收）> B3 > C。
**不建议先做 C**：它只压 118 位，却在 B2 之前引入新的持久状态风险。

---

## 6. 必须问用户的边界

只有三类，其余可自行决定：

1. **删改持久表**（B2/B3 的 `site_frames` 替换、B1 的副本落盘位置）；
2. **动远端在用目录**（`s8/`、`part/`）；
3. **跑 Vivado 构建**（C 轨，耗时且需要 ASCII 临时目录）。

---

## 7. 可自行决定的事项（已记录，便于事后审计）

- 副本库命名统一用 `v7_model.backup-YYYYMMDD.sqlite`，成对记录 sha256。
- B2 的写入顺序按 `bel ∈ {A,B,C,D}` 串行，便于中途失败时只回滚部分。
- 文档编号采用「后缀 b」而非重排全文，避免产生大量 diff 影响审阅。
- 若 B2 实测发现四个 BEL 的 INIT 顺序不一致，则放弃「一次生成」，改为「每个 BEL 单独一次实测 + 一次生成」，并在 STATUS 记录为新的 T 编号。
