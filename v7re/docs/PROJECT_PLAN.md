# V7RE 完整项目计划（485T → V7 系列）

| 项目 | 内容 |
|---|---|
| 文档版本 | v1.0 |
| 日期 | 2026-10-22 |
| 目标器件 | `xc7vx485tffg1761-2`（VC707 级） |
| 工具链 | Vivado 2017.2 + Ubuntu 18.04 远程主机 |
| 当前阶段 | M3 LUT6 壳完成，进入 FAR/CLB 语义扩展 |
| 文档状态 | 已批准；按阶段执行 |

## 0. 文档目的与执行边界

本文件是 V7RE 项目的路线图、阶段契约和验收标准。它回答四个问题：

1. 最终要交付什么；
2. 当前已经有什么、还缺什么；
3. 每一阶段先做什么、后做什么、什么情况下停止；
4. 什么证据才算“完成”，什么只能算“未定”。

本文件不直接执行实验、不改代码。后续按阶段实施时，每个阶段单独提交代码、数据和报告；阶段之间以本文的验收条件为 go/no-go 门槛。

---

## 1. 目标与成功标准

### 1.1 总目标

在 `xc7vx485tffg1761-2` 上建立可验证、可查询、可复现的位流语义数据库：

```text
tilegrid.json
tile_type_*.json
segbits_*.db
ppips_*.db
FAR / frame / word / bit 地址模型
FASM ↔ bitstream ↔ 物理网表 闭环
```

完成 485T 后，再评估 690T / 2000T 的器件移植；不把 485T 的地址和 tile 规律直接外推到 690T/2000T。

### 1.2 发布级成功标准

1. **地址层**：FAR 解码和 `frame/word/tile offset` 在 485T 上至少覆盖 CLBLL、CLBLM、HCLK、INT、BRAM、DSP 六类列，包含 top/bottom、多个 row 和 minor，且与现有 M1/M2/M3 实测一致。
2. **CLB 语义层**：LUT6、FF、CARRY4、F7/F8、O5/O6、site PIP 的 `segbits` 有足够覆盖；每个 feature 至少两个独立样本，并记录复用、极性、残差和置信状态。
3. **路由层**：选定的 INT PIP 家族有 `pip_bits` 和 `ppips` 分类；每个 PIP 有 route 预检和至少两次独立复现；pseudo/hint PIP 不得混入真实可编程 PIP。
4. **数据库层**：`v7_model.sqlite` 中 `frame_map`、`frame_words`、`site_frames`、`bit_map`、`pip_bits` 非空且可查询；旧表保留兼容视图。
5. **闭环层**：一个小设计（LUT + FF + 一条 INT 路由 + 一条 site 内路由）完成 `bitstream → FASM → 网表 → bitstream`，除已记录元数据外没有未解释位。
6. **复现层**：一条命令重建数据库；一条命令重跑指定实验；所有结果带 manifest、SHA256、Vivado 版本、device、LOC/BEL、route 和证据状态。
7. **负样本层**：不改设计、只改 placement、只改 route、只改 INIT、非法 PIP、版本不匹配六类负样本全部有记录；门禁不得为通过而放宽阈值。

### 1.3 非目标

- 不在本计划内完成 690T/2000T 全量数据库。
- 不直接复制 prjxray 的 Artix/Kintex 数据；只参考格式。
- 不在 word 50 机制未定时，用手工改位的方式生成“最终可加载 bitstream”。
- 不把图上的 PIP 可达性当成真实可编程性。

---

## 2. 当前基线（2026-10-22）

### 2.1 已完成

| 层 | 状态 | 关键数字 |
|---|---|---|
| P0 site 边界 | PASS | 86,022 fabric sites；5,489,706 site-pin→tile-wire |
| STEP01 拓扑 | PASS | 150,380 tiles；115 tile types；56,847,864 wires；207,253,149 intra-tile PIPs |
| STEP02 tileconn | PASS | 39,923,710 exact edges；804,680 corridor rules |
| M0 模型库 | PASS | sites/site_pins/tiles/probes 等已入库 |
| M1 地址 | pilot PASS | 7 region bases；420 column offsets；20/20 blind holdout |
| M2 受控差分 | PASS（有条件） | 6 pairs / 3 families / 2 input transitions；gate 重算证据；14 tests |
| M3 LUT6 壳 | 部分完成 | 一个 `CLBLM_R` tile 的 A/B/C/D 四个 LUT6；256 segbits；24/24 |

### 2.2 明确缺口

- `frame_map`、`frame_words`、`site_frames`、`bit_map`、`pip_bits` 仍为空；`v7_model.sqlite` 中这些表计数为 0。
- parser 只保留 FDRI 拼接帧，未把 FAR 按帧绑定；现有 frame index 仍是经验序号。
- M3 的 LUT6 结果尚未导入模型库，也未在第二个 tile type / 第二个 site 复现。
- FF、CARRY4、F7/F8、O6 mux、site PIP、INT PIP、IOI、BRAM、DSP 均未进入 `segbits/ppips`。
- word 50 已证明会随 INIT 改变，但编码/ECC 机制未定。
- M2 的 6 对主要是 CLBLL/CLBLM 的 LUT 输入，不能外推为通用语义模型。
- 尚无网表级逆向后一致性验证。

---

## 3. 设计原则与停止规则

1. **FAR 优先**：先有地址空间，再谈 `segbits`。禁止继续用全局 frame index 作为数据库主键。
2. **证据优先**：每个结论至少两个独立样本；每个实验记录设计、约束、route、bitstream、FAR、diff、frame hash。
3. **预检优先**：任何 PIP/route 候选先 `route_design` 预检，再 build；图上可达不算证据。
4. **XOR 有条件**：LUT6 INIT 这种 one-hot/no-reuse 场景可用 XOR；FF/MUX/CARRY/INT 必须多样本矩阵，必要时 Tikhonov 或路径测试。
5. **不静默跳过**：失败、未覆盖、伪 PIP、未定 word 必须显式标记 `negative`/`uncertain`，不得用空值冒充完成。
6. **门禁不放宽**：`pip_symdiff <= 4`、frame count、sink pin、frame hash 等阈值只允许加严或新增解释，不允许为凑数放宽。
7. **Linux 为唯一生产环境**：所有生成数据在 `/data/lzh/v7re/data`；Windows 只做编辑和查看。

---

## 4. 工作分解

### Phase A — FAR / frame 地址层（第 1 周）

**目标**：把经验 frame index 升级为可解码的 FAR 地址模型。

任务：

1. 新增 `v7re/bitstream/far.py`：
   - `FarAddress` dataclass：`raw, block_type, top_bottom, row, column, minor`；
   - `decode_far(raw)`、`encode_far(addr)`、`far_to_frame(addr)`、`frame_to_far(index)`。
2. 扩展 `bitstream/parser.py`：
   - `Bitstream` 增加 `frames: list[Frame]`；
   - 每帧保留 `frame_index, far_raw, far_decoded`；
   - 兼容现有 `payload_words`，不破坏当前脚本。
3. 新增数据库表：
   - `far_fields(device, frame, block_type, top_bottom, row, column, minor, far_raw, source)`；
   - `frame_words(device, frame, word, label, width, encoding, source)`；
   - `frame_map(device, frame, far_raw, block_type, row, column, minor, source)`；
   - `tile_word_offsets(device, tile_type, feature, word_offset, width, source)`。
4. 用 `frame 31748 / FAR 0x004203a0` 作为 golden anchor（M3 4 帧组基址；实际发生差异的帧是 31750 / 0x004203a2），逐项验证：
   - A6LUT 4 帧组；
   - M1 的 7 个 region base；
   - 至少一个 CLBLL、CLBLM、HCLK、INT、BRAM、DSP 列；
   - top/bottom 两个半区，多个 row/minor。
5. 新增 `scripts/audit_far.py`：对现有 M1/M2/M3 所有 diff 重算 FAR，报告 `residual=0` 或具体不符项。

**验收**：

- 现有 LUT6 4 帧组全部能用 FAR 解释；
- 6 类列的最小样本全部通过；
- `frame_map/frame_words` 非空；
- 旧经验公式保留为兼容视图，但文档标注 deprecated。

### Phase B — LUT6 覆盖矩阵（第 2 周）

**目标**：从“一个 LUT6 壳”变成可发布的 CLB LUT6 segbits。

任务：

1. 扩展 `vivado/` 生成器：支持 A/B/C/D LUT6、O5/O6、INIT 0→1 与 1→0、六个输入、至少两个 site。
2. 新增统一的 `scripts/run_experiment.py`：输入 manifest，输出 design、bit、route、FAR、diff、evidence。
3. 将 M3 的 `segbits_clblm_r.db` 导入模型库；新增第二个 `CLBLL_L` 或 `CLBLM_L` site 复现。
4. 导出 `segbits_clb_lut6.db`，并保留 `tile_type_CLBLM_R.json` 的兼容格式。

**验收**：

- 至少两个独立 site、两个 tile type；
- 每个 LUT 的 64 个 INIT 位全部覆盖；
- 0→1 与 1→0 两个方向都验证；
- 24/24 任意 INIT 回放扩展到至少 2 个 site；
- 失败/未覆盖项显式列出。

### Phase C — FF / CARRY4 / MUX / site PIP（第 3 周）

**目标**：进入非 one-hot 资源，建立复用感知的提取流程。

任务：

1. 新增 FF 生成器：D、CE、SR、INIT、同步/异步、极性；CARRY4：CYINIT、CI、DI、S；F7/F8、O5/O6 mux；site PIP。
2. 对每个 feature 收集多组样本，构造 `A(m×n)` 与 `B(m×k)`；用 Tikhonov 求解：
   `x = (AᵀA + ΓᵀΓ)⁻¹AᵀB`，阈值 0.95，记录 residual。
3. residual 高或 context 变化时，标记 `reused/coupled`，改用路径测试（Li 方法）。
4. 数据库字段：`confidence(proven|inferred|uncertain|negative)`、`sample_count`、`context_count`、`residual`、`polarity`、`reuse_group`。

**验收**：

- FF 的 D/CE/SR/INIT 至少各 2 个样本；
- CARRY4 至少一个完整进位链；
- 复用项没有被误标为独立位；
- `segbits_ff.db`、`segbits_carry.db` 可导入、可查询；
- 所有未定项有 `uncertain` 记录。

### Phase D — INT PIP / ppips（第 3–4 周）

**目标**：建立第一批可复现的 `pip_bits` 和 `ppips`。

任务：

1. 从 `v7_routing.db` 选 3–5 个 PIP 家族（短 local、双向、跨 tile）。
2. 每个候选先 `route_design` 预检，要求：
   - route 实际经过目标 PIP；
   - 无 `CRITICAL WARNING`；
   - 与同族另一条 route 的 `pip_symdiff <= 4`。
3. 每个 PIP 至少两次独立 build；第二次用不同 site 或不同输入。
4. 新增 `pip_bits` 字段：`is_pseudo`、`is_hint`、`verified_by_route`、`confidence`。
5. 导出 `ppips_*.db`，并明确列出未覆盖/伪 PIP。

**验收**：

- 每个家族至少 1 个 PIP 完整闭环；
- 每个 PIP 2 次独立复现；
- 0 个 graph-only 候选进入数据库；
- 伪 PIP/hint 不进入真实 `ppips` 集合；
- replay 失败项进入 negative。

### Phase E — word 50 / 帧元数据（第 2 周开始，贯穿）

**目标**：定性 word 50，决定能否手工生成 bitstream。

任务：

1. 用多组 INIT 扰动（1 位、2 位、不同 LUT）收集 word 50 变化。
2. 判断它是否满足线性/ECC 关系；尝试拟合 parity matrix。
3. 若无法确定：数据库标记 `unknown/data-bearing`；最终 bitstream 仍由 Vivado 生成，禁止手工 patch。
4. 在 `frame_words` 中记录 word 50 的 `label=unknown` 和证据状态。

**验收**：

- 要么给出可复算规则并通过 3 组独立扰动；
- 要么明确记录 blocker，且发布流程不使用手工改位。

### Phase F — 自动化与数据治理（第 4 周）

**目标**：把手工脚本收成可重复流水线。

任务：

1. `scripts/run_experiment.py`：manifest → 生成 → Vivado → parser → evidence → gate。
2. `scripts/import_evidence.py`：evidence JSON → SQLite，幂等。
3. `scripts/build_release.py`：生成 `tilegrid.json`、`tile_type_*.json`、`segbits_*.db`、`ppips_*.db`。
4. 所有阶段写 `stages`/`artifacts`，带 SHA256、Vivado 版本、device、命令、时间。
5. CI 级检查：`python -m unittest discover -s tests`、`check_m2_gate.py`、`audit_far.py`、schema 校验。

**验收**：

- 一条命令重建 `v7_model.sqlite`；
- 一条命令重跑指定 LUT/PIP 实验；
- 相同输入得到相同 frame hash；
- 无手工 XDC 路径。

### Phase G — 网表闭环与发布（第 5–6 周）

**目标**：完成 STEP04 级验收。

任务：

1. 小设计：LUT + FF + 一条 INT route + 一条 site 内 route。
2. `bitstream → FASM`：用现有 `bit2fasm`/`segbits` 生成 FASM。
3. `FASM → 网表`：接 `fasm2bels` 或自建 CLB/BEL 还原器。
4. 与原始物理网表比较：Cell 属性、LUT 等价变换、Net 端点、RouteBEL、非法冗余资源。
5. 负样本：不改、只 placement、只 route、只 INIT、非法 PIP、版本不匹配。
6. 发布兼容目录：`tilegrid.json`、`tile_type_*.json`、`segbits_*.db`、`ppips_*.db`，附 README 和 SHA256。

**验收**：

- 小设计 round-trip 通过；
- 未解释位为 0，或全部列入 `metadata` 白名单；
- 网表比较 0 mismatch；
- 负样本全部按预期失败；
- 发布包可在干净目录复现。

---

## 5. 数据库与数据流

### 5.1 新增/扩展表

```sql
far_fields(device, frame, block_type, top_bottom, row, column, minor,
           far_raw, source)

frame_words(device, frame, word, label, width, encoding, source)

frame_map(device, frame, far_raw, block_type, top_bottom, row, column,
          minor, source)

tile_word_offsets(device, tile_type, feature, word_offset, width, source)

-- 扩展已有表
site_frames(..., confidence, sample_count, context_count, residual, polarity, reuse_group)
bit_map(..., confidence, sample_count, context_count, residual, polarity, reuse_group)
pip_bits(..., is_pseudo, is_hint, verified_by_route, confidence)
```

### 5.2 数据流

```text
experiment manifest
  -> Vivado build (DCP + .bit + route.log)
  -> parser: frames + FAR + frame hash
  -> evidence JSON: design/constraints/route/FAR/diff/status
  -> gate: evidence + recompute + sink + hashes
  -> import: SQLite
  -> export: tilegrid / tile_type / segbits / ppips
```

### 5.3 兼容策略

- 旧 `v7.sqlite`、`v7_p0.sqlite`、`v7_routing.db` 保留只读；
- 新表加在 `v7_model.sqlite`；
- 旧 `sites.tile` 空值问题用 P0 数据回填；
- 不删除旧列，只加新列和视图；
- `frame index` 与 `FAR` 双主键并存，迁移期允许两者互查。

---

## 6. 代码与脚本改动清单

| 文件/模块 | 改动 |
|---|---|
| `bitstream/far.py` | 新增 FAR 编解码与 frame 映射 |
| `bitstream/parser.py` | 每帧绑定 FAR；保留旧接口 |
| `bitstream/frames.py` | 支持带 FAR 的 Frame 对象 |
| `db/schema_model.sql` | 新增表/列/索引 |
| `db/import_results.py` | 导入 evidence，幂等 |
| `db/import_model.py` | 构建新表与兼容视图 |
| `model.py` | 增加 FAR/feature 查询 helper |
| `vivado/design.py` | 参数化 LUT/FF/CARRY/MUX/PIP 模板 |
| `vivado/probe.py` | 通用实验入口 |
| `scripts/run_experiment.py` | 新增统一 runner |
| `scripts/audit_far.py` | 新增 FAR 审计 |
| `scripts/build_release.py` | 新增发布导出 |
| `scripts/check_m2_gate.py` | 保持并复用证据门禁 |
| `tests/test_far.py` | FAR roundtrip / anchor |
| `tests/test_schema.py` | 新表/迁移/查询 |
| `tests/test_experiment.py` | manifest/负样本 |

---

## 7. 测试与验收

### 7.1 单元测试

- FAR encode/decode roundtrip；
- `frame_to_far/far_to_frame` 对 31748 / 0x004203a0，以及 M3 差异帧 31750 / 0x004203a2；
- parser 对 50,176 帧、0 leftover；
- frame hash 对 header 时间戳不敏感；
- 不等帧数必须报错；
- schema 迁移幂等；
- gate 对伪造 data_bits、错误 sink、重复 route 必须失败。

### 7.2 集成测试

- M1 的 7 个 region base 和 20 holdout 重放；
- M2 的 6 对 corpus 重放，`M2 GATE PASS`；
- M3 的 4 个 LUT6、24/24 回放；
- 第二 site/tile type 的 LUT6；
- FF/CARRY 各一个最小设计；
- 一个 INT PIP 的两次独立复现。

### 7.3 端到端测试

- 小设计 `bitstream → FASM → 网表`；
- 网表与原始物理网表一致；
- 再生成 bitstream，差异只允许在文档化元数据；
- 六类负样本全部按预期失败。

### 7.4 发布门禁

```text
M1 PASS
M2 PASS
M3 LUT6 PASS（两个 site）
FF/CARRY 至少一个家族 PASS
INT PIP 至少一个家族 PASS
FAR 六类列 PASS
netlist round-trip PASS
0 unexplained bits
```

---

## 8. 风险与未决问题

| 风险 | 影响 | 缓解 |
|---|---|---|
| FAR 字段/半区模型在 485T 不成立 | 地址层返工 | 六类列 + 多 row/minor 验证；保留经验视图 |
| word 50/ECC 未解 | 不能手工生成 bitstream | 标记 unknown；最终 bitstream 用 Vivado |
| 控制位复用/一元多值 | 错误 segbits | 矩阵 + Tikhonov；residual 高转路径测试 |
| 图候选不等于真实 PIP | ppips 假阳性 | route 预检 + 两次复现 + is_pseudo |
| B 侧 LOCK_PINS 命名坑 | 构建回退 | 统一 `get_bel_pins` 校验 |
| 远程机器资源/锁 | build 失败 | 串行 manifest；失败重试；记录 error |
| Vivado 2017.2 限制 | 新器件/新特性不可用 | 固定版本；所有结果带版本 |
| 数据量增长 | DB/仓库膨胀 | SQLite + 外部大文件 + manifest；不提交二进制 |
| 过度外推 485T | 690T/2000T 失败 | 先 485T 发布，再器件移植评估 |

### 未决问题

1. M1 是否补满 13×7=91 个 probe，还是以 7 anchors + 20 holdout + 第二个 site 作为发布门槛？
2. word 50 是否就是 ECC；若不是，是否允许发布“Vivado 生成 bitstream”的受限版本？
3. FF/CARRY 先做矩阵还是先做路径测试；建议矩阵优先，路径测试作为 residual 兜底。
4. 690T/2000T 的器件数据获取和 license 方案尚未确定，放在 485T 发布后单独立项。

---

## 9. 时间表与里程碑

| 周 | 里程碑 | 交付 |
|---|---|---|
| 1 | FAR/frame 层 | `far.py`、`frame_map`、`audit_far`，六类列验证 |
| 2 | LUT6 覆盖 + word50 | 两个 site 的 `segbits_clb_lut6`；word50 结论或 blocker |
| 3 | FF/CARRY/site PIP | 第一批非 one-hot segbits、Tikhonov 报告 |
| 4 | INT PIP/ppips + 自动化 | `pip_bits`、`ppips`、统一 runner |
| 5 | 网表闭环 | FASM→网表→bitstream round-trip |
| 6 | 发布 | 兼容目录、README、SHA256、负样本报告 |

每个里程碑结束做一次 go/no-go：未达到验收则停在当前阶段，不把未证明项带入下一阶段。

---

## 10. 发布定义（Definition of Done）

发布包至少包含：

```text
tilegrid.json
tile_type_*.json
segbits_clb_lut6.db
segbits_ff.db
segbits_carry.db
ppips_<family>.db
frame_map.csv / frame_words.csv
v7_model.sqlite
RELEASE_NOTES.md
SHA256SUMS
```

并满足：

- 所有数据有 source、sample_count、confidence；
- 未覆盖/negative/uncertain 单独列出；
- 发布目录可在干净 Linux 环境按 README 重建；
- 不包含未解释的“魔法位”；
- 不把 Vivado 生成的 bitstream 说成自研 bitgen 输出。

---

## 11. 假设

- 目标器件先锁定 `xc7vx485tffg1761-2`，Vivado 2017.2，Ubuntu 18.04。
- 生产数据目录为 `/data/lzh/v7re/data`；Windows 仅编辑/查看。
- 现有 P0/STEP01/STEP02/M0/M1/M2 数据可信，不重新造轮子。
- M3 的 LUT6 结果只算“单 tile 壳”，不是完整 CLB 语义。
- 代码和实验按阶段执行；每个阶段结束更新本文的“当前基线”和验收记录。
