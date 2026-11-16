# T3 脚本资产清单：v7re/scripts 对「PIP 开关盒」位观测的支持度

盘点时点：2026-11-08 14:52–14:58（Asia/Shanghai）
盘点对象：`v7re\scripts\*.py` 全部 **55 个**文件 = **44 个主脚本** + **11 个 `_` 前缀临时探针**
机器可读扫描产物：`v7re\steps\t3_script_scan.json`（含每文件 mtime / 行数 / docstring 首行 / argparse 选项）

---

## 0. 一句话结论

**PIP 语义层共 12 个脚本，其中真正"从位流/DCP 直接读出或写出 PIP"的只有 4 个（`pip_enum` / `decode_exact` / `fasm2bit` / `roundtrip`），其余 8 个是它们的定律/校验/写出侧组件；而"把两个位流的差分直接归因到 (tile, family, src)"的 CLI 一个都没有（L4 = 0）。**

实测证据：我用库函数手工拼出这条链路，对「同一 primitive 只换 sink 引脚 A1→A2」的两个构建做归因，得到 **14/15 数据位唯一归因**（其余 1 位需 7.9 GB 的 `v7_model.sqlite`）——说明缺的是**封装**，不是定律。

---

## 1. 盘点方法与可复现性

| 步骤 | 命令 | 产出 |
|---|---|---|
| 目录与文件数 | `Get-ChildItem v7re\scripts\*.py \| Measure-Object` | 55（44 主 + 11 探针） |
| docstring / argparse / `__main__` | 见 §8 附录 A 的 AST 扫描脚本 | `v7re\steps\t3_script_scan.json` |
| PIP 关键词分布 | `Select-String -Path scripts\*.py -Pattern "pip\|PIP"` | 23 个文件命中，计数见 §8 附录 B |
| 观测能力实测 | 见 §4、§5 每条证据的"复现命令" | 命令输出内联引用 |

**判定口径**：一个脚本"支持 PIP 位观测"的充分条件是——它把 **PIP（tile + family/mux + src wire）** 与 **配置位（frame, word, bit）** 之间建立了可验证映射。只做 bit 级 diff、不知道 PIP 语义的，记为"等级 L1"，不算支持。

---

## 2. PIP 支持度分级（本文档用）

| 级别 | 含义 |
|---|---|
| **L0** | 与本主题无关（导入/审计/拓扑/ECC/CLB INIT） |
| **L1** | 位级读写或 diff，但**无 PIP 语义**（不知道这一位属于哪个 mux） |
| **L2** | **单向**语义：PIP → 位（写）或 位 → PIP（读），需给定 tile 或整芯片扫描 |
| **L3** | **双向**且覆盖多 tile：位流 ↔ PIP 可互相推导 |
| **L4** | 跨位流**归因**：两个位流的差分 → (tile, family, src) 列表（本文档欲服务的目标） |

**全仓现状：L4 = 0 个脚本。** L3 = 3 个（`decode_exact`、`fasm2bit`、`roundtrip`，且都有边界）。L0/L1 占绝大多数。

---

## 3. 全量清单（44 主脚本）

> "入口"列写 `__main__` 的实际入口形式（argv 位置参数 / argparse 选项 / 库模块无入口）。
> 每条"用途"取自该文件 docstring 首行（原文，未改写），以便复核。

### 3.1 A 类 —— PIP 语义层（12 个）

| 脚本 | 行数 | 用途（docstring 原文） | 入口 | 输入 | 输出 | PIP | 级别 |
|---|---|---|---|---|---|---|---|
| `pip_enum.py` | 71 | Dump the physical PIPs of every net in a routed DCP, grouped by tile | `argv[1]=dcp`, `argv[2]=tile_filter?` | routed `.dcp` | 每 net 的 `src->dst` 文本，按 tile 分组 | ✅ 真值来源 | **L2**（只读 DCP，需 Vivado/RapidWright） |
| `pip_fuzz.py` | 190 | Task 2 PIP fuzzer: attribute INT/site PIPs of ONE sink tile to bits | `--dst --src --pins` | 生成 VERILOG/XDC + 跑 Vivado + 读 DCP | bit delta ↔ PIP 配对表 | ✅ 唯一"PIP↔bit 配对"脚本 | **L2**（硬编码，见 G4） |
| `decode_exact.py` | 184 | 用「族内精确匹配」解码 INT PIP（任务 3） | `--bit --pips --law-db --no-gclk` | `.bit`（+ 可选 pips 真值文件） | `tile family src` 列表 | ✅ 位→PIP | **L3**（INT_L/INT_R 全芯片，纯离线 21.3 s） |
| `fasm2bit.py` | 467 | FASM 行 → 位流（覆盖 mux 区 64 族 + law_cells 表内族） | `--in --out --fasm --blank --decode --tiles --law-db --model-db --law-json --ecc-json` | `.bit` / FASM 文本 | `.bit` 或 `TILE.FAMILY.SRC` 行 | ✅ 双向（有 G2 静默缺口） | **L3** |
| `bitwriter.py` | 196 | T5 v1：由 PIP 列表写出配置位（只覆盖 mux 区，帧 16–25） | `--bit --pips --law --law-db --selftest --frames --with-table` | PIP 列表 | 改写后的 `.bit` | ✅ 仅写、仅帧 16–25 | **L2**（显式声明不支持帧 0–15 时钟族 / 帧 2–7 BEG6/4） |
| `roundtrip.py` | 214 | 端到端闭环：位流 → PIP 列表 → 用定律重写 → 逐位比对 | `--bit --law --law-db --min-cells --frames --max-report` | `.bit` | 逐位比对报告 | ✅ 自洽性校验 | **L3**（不喂 Vivado 路由，是"自洽"而非"对真值"） |
| `verify_superposition.py` | 161 | T4：多 PIP 同时开启时，用 T3 定律「先预测、再对账」 | `--bit --pips --law --law-db` | `.bit` + 期望 PIP 列表 | 预测 vs 实测 | ✅ | **L2** |
| `pip_reuse_law.py` | 256 | PIP 复用定律（mux 区）——生成式实现与验证 | `--law-db --build --verify --stats --out` | law sqlite | `steps/pip_reuse_law.json` | ✅ 定律本体（64 族） | **L2**（只 INT_L 命名） |
| `beg_families.py` | 132 | beg_families.py —— BEG6/4 家族的二分图结构与可验证预测 | `--law-db --tile-type --build --report --out` | law sqlite | `steps/beg_families.json` | ✅ BEG 结构 | **L2** |
| `t51_generative_law.py` | 506 | T51: validate a generative INT PIP law with family hold-out checks | `--law-db --json` | law sqlite | 留出验证结果 + `gen()` 接口 | ✅ | **L2** |
| `verify_all_pip.py` | 163 | 统一的对账：mux 区（闭式）+ BEG6/4（二分结构）覆盖多少 feature | `--law-db --tile-type --normalize` | law sqlite | 覆盖率/命中数 | ✅ | **L2** |
| `tamper_localize.py` | 786 | 无参考位流的篡改检出与定位（TM2：语义自洽性校验） | `--check --exhaustive --attack --coverage --verify --json ...` | `.bit`（无参考） | 异常位列表 + 定位 | ✅ L1 可解释性 = 位是否属于已知 mux 格 | **L2**（自述覆盖 INT 帧 0..25 两个 word，占全器件 45.2%） |

### 3.2 B 类 —— 位级读写/差分，无 PIP 语义（3 个）

| 脚本 | 行数 | 用途（原文） | 入口 | 输入 | 输出 | PIP |
|---|---|---|---|---|---|---|
| `diff_frames.py` | 44 | Compare two bitstreams or two frames.bin files | `a b --bits --max` | 两个 `.bit`/`.bin`/`frames.bin` | 帧号 + (word,bit) 列表 | ❌ **仅 bit，无 tile/族归因** |
| `parse_bit.py` | 44 | Parse a 7-series .bit/.bin and optionally dump raw frames | `bit [out]` | `.bit`/`.bin` | frames（.bin） | ❌ |
| `bitgen.py` | 138 | 在 .bit 文件里按位改写，并同步重算帧级 ECC | `--in --out --set 'frame:word:bit=v' --set-file --ecc` | `.bit` + 位坐标 | 改写后的 `.bit`（ECC 正确） | ❌（但它是"写回"的唯一可靠路径） |

### 3.3 C 类 —— CLB / INIT 配置位（**上一轮跨 tile 验证实际用的对象**，10 个）

| 脚本 | 行数 | 用途（原文） | 入口 | 输入 | 输出 | PIP |
|---|---|---|---|---|---|---|
| `build_site_frames.py` | 500 | Phase B 第一步：把 CLB site 绑定到具体 frame/word/bit | `--law-db --model-db --site-addr --site-frames --columns --all --validate --replace --dry-run --locked-init` | site 表 + 模型库 | `site_frames` 表 | ❌ CLB 位 |
| `rebuild_clb_init.py` | 135 | 用 LOCK_PINS 实测表重建 site_frames 的 CLB INIT 行 | `--x0 --x1 --law-db --model-db --apply --check --ref-base` | clb_cells + model db | 重建后的 INIT 位表 | ❌ CLB 位 |
| `init_map_sweep.py` | 86 | 由「每个 LUT 各 6 个位平面」的设计差分，重建 CLB LUT INIT 位映射 | `--dir --base --out` | 探针目录 | INIT 位映射 JSON | ❌ |
| `probe_lut.py` | 51 | Clean probe for one (LOC, BEL): build DCP, write two INIT variants, diff | `--loc --bel --init-a --init-b --part --workdir --rebuild` | 参数 | 该 BEL 的差异位 | ❌（**这正是"INIT 差分"范式的原型**） |
| `probe_bits.py` | 105 | Sweep every LUT6 INIT bit at one (LOC, BEL) and record physical bit positions | `--loc --bel --part --workdir --count --skip-build --skip-vivado` | 参数 | 位位置列表 | ❌ |
| `sweep_lut.py` | 86 | Sweep many LOCs with the clean probe and record results | `--locs --bel --init-a --init-b --part --work-root --rebuild` | LOC 列表 | 汇总结果 | ❌ |
| `lut_codec.py` | 39 | Encode a LUT6 INIT value into physical (frame, word, bit) positions | `--bit-map --init` | bit map + INIT | 位坐标 | ❌ |
| `make_manifest.py` | 107 | Build a spread-out LUT6 probe manifest from a site table | `--sites --count --bel --init-a --init-b --types --tags --out` | site 表 | manifest JSON | ❌ |
| `run_batch.py` | 57 | Run a manifest of LUT probes with resume support | `--manifest --workdir-root --out --part --force --dry-run --limit --stop-on-error --jobs` | manifest | 批量结果 | ❌ |
| `t55_object_check.py` | 151 | t55_object_check.py —— 判定「跨 tile 验证」的观测对象：CLB INIT 还是 PIP 开关盒 | `--bits-dir --locked --law-db` | bits 目录 | 对象判定 | ⚠️ **盘点期间新增**（mtime 14:56:34，兄弟子任务 T1 产出），**不属本次盘点范围**，仅登记 |

### 3.4 D 类 —— ECC（2 个）

| 脚本 | 行数 | 用途（原文） | 入口 | 输入 | 输出 | PIP |
|---|---|---|---|---|---|---|
| `ecc_model.py` | 143 | 建 ECC 数据项模型 L：位置 → 13 位签名 | `--bits --out` | 位流样本 | `ecc_model.json` | ❌ |
| `ecc_solve.py` | 168 | 用 GF(2) 线性代数解出帧级 ECC 的每位置签名 S_b | `--bits --holdout --out-model` | 位流样本 | 签名模型 | ❌ |

### 3.5 E 类 —— 拓扑 / 导入 / 审计 / 时钟（17 个；其中 4 个与 PIP 有边缘关系）

| 脚本 | 行数 | 用途（原文） | 入口 | 输入 | 输出 | PIP |
|---|---|---|---|---|---|---|
| `step1_topology.py` | 147 | Step 1 driver: device routing topology → artifacts → database | 子命令 `all/verify/conns/db/manifest` | Vivado/RapidWright 导出的 routing 拓扑 | `E:\v7work\routing` 下 JSON + SQLite | ❌ 只产拓扑，不含位 |
| `step2_tileconn.py` | 109 | Step 2 CLI: query canonical tile connections offline | `--source rules/exact` + `query/stats/import` | `v7_routing.db` 的 `conn_rules` 或精确边表（~4000 万行） | 命令行查询结果 | ❌ PIP 的**逻辑**连接，非位 |
| `export_site_topology.py` | 392 | Export P0 site-level static topology for V485T from RapidWright | `--topology --out --part --device --samples-per-type` | RapidWright 器件模型 | `site_types.json` / `site_instances.csv` / `site_pin_wires.csv.gz` / `validation.json` | ❌ site PIP = site 内布线，**非 tile PIP 位** |
| `import_site_topology.py` | 299 | Import P0 site-topology exports into a queryable SQLite database | `--p0 --db` | 同上 4 个文件 | site 拓扑 SQLite | ❌ |
| `import_frame_map.py` | 1238 | Import frame_map from the validated Phase A CSV and run full audits | 无 argparse（模块级/`--selftest`） | Phase A CSV + 迁移 SQL + 锚定位流 | `frame_map` 表 + 审计输出 | ❌ 帧级地址映射 |
| `import_db.py` | 59 | Build the SQLite probe database from site table + clean-probe results | `--db --probe-root --exclude --site-table --part --skip-sites` | site 表 JSON + 探针目录 | 探针 SQLite | ❌ |
| `build_model_db.py` | 43 | Build `v7_model.sqlite` from P0 + probes + routing metadata | `--out --p0-db --probe-db --routing-db --no-hash` | p0/probe/routing 三个库 | `E:\v7work\model\v7_model.sqlite`（7.9 GB） | ❌ 但它是 CLB 位归因的唯一数据源 |
| `import_m1.py` | 316 | Import M1 frame-address anchors into the canonical model DB | `--db --root --old-db --schema` | M1 探针 `result.json` | 模型库地址锚点 | ❌ |
| `validate_m1_holdout.py` | 108 | Validate blind M1 holdout probes against the measured address model | `--db --root --out` | 模型库 + holdout 探针目录 | 校验报告 | ❌ |
| `validate_p0_against_routing.py` | 105 | Cross-check P0 site-pin tile wires against the routing tile templates | `--p0 --routing --out` | `site_pin_wires.csv.gz` + `templates/*.json`（`wire_defs[0]`） | 差异报告 | ❌ 只校验 wire 名存在性 |
| `audit_db.py` | 43 | Audit imported probe word positions against the site table | `--db` | 探针 SQLite | 审计输出 | ❌ |
| `audit_far.py` | 46 | Audit FAR usage in a 7-series bitstream and decode candidate addresses | `bitstream [--far]` | `.bit` | 帧地址解码结果 | ❌ 帧级，非位级语义 |
| `enumerate_sites.py` | 67 | Enumerate FPGA sites with Vivado and write a reusable JSON table | `--part --types --workdir --out --timeout` | Vivado 器件 | site 表 JSON | ❌ |
| `prune_chains.py` | 181 | 用 net 链连通性消解 2 格 pattern 的歧义（T6c） | `--bit --pips --law --min-cells --rounds` | `.bit` + PIP 真值 + law 库 + `templates/*.json` | 消歧后的 PIP 列表 | ⚠️ **间接**（把 roundtrip 精确率从 67% 往上拉；**本次未运行验证**） |
| `rw_coupling_probe.py` | 111 | Feasibility gate for Task 2: RapidWright read/modify + robust Vivado | 无 argparse（模块级） | 源 DCP（只读） | `E:\v7work\rw_probe` 下的可行性结论 | ⚠️ **间接**（验证 `Net.addPIP` 能否单 PIP 隔离；**本次未运行验证**） |
| `hclk_survey.py` | 111 | HCLK_CMT 的 PIP 结构离线摸底（阶段一，0 个构建） | 无 argv（硬编码模板路径） | `routing/out_routing/templates/HCLK_CMT.json`（982 条 PIP） | `v7re/steps/hclk_sources.json` + 控制台摘要 | ⚠️ **仅结构、无位**（唯一碰过非 INT tile PIP 的脚本） |
| `clk_mux_bits.py` | 53 | BUFGCTRL 输入选择位的编解码（T43 实测公式） | 无 `__main__`（库：`f0`/`w` 公式） | Y 坐标 | `(frame, word, bit)` | ⚠️ **有位公式但非 tile PIP**（BUFGCTRL 的 SEL 位） |

> `hclk_survey.py` 是**唯一对非 INT tile 做过 PIP 结构摸底**的脚本（BUFGCTRL 侧的 `clk_mux_bits.py` 只有公式、无脚本入口），但两者都**没有位流侧观测**——见 G7。

### 3.6 F 类 —— 11 个 `_` 前缀探针

`_amb.py`(18) `_p.py`(28) `_pip_introspect.py`(32) `_pipcmp.py`(14) `_pred.py`(18) `_probe_det.py`(26) `_q.py`(7) `_share.py`(16) `_sw2.py`(33) `_swaploc.py`(33) `_swloc2.py`(33)

共同特征（已逐个核实）：**11/11 无 docstring、无 `__main__`、无 argparse**，只能 `import` 后手工调用；**10 个带 UTF-8 BOM**（`_pip_introspect.py` 除外），用 `utf-8`（而非 `utf-8-sig`）读取时 `ast.parse` 立即失败（`invalid non-printable character U+FEFF`）。
**结论：一次性探针，不构成可复用资产；不建议作为 T2 实验的落地入口。**

---

## 4. 可直接复用点（R1–R5，全部有实测证据）

### R1（最重要）`decode_exact.py` 的 `load_bits / load_tiles / load_families / decode`

**这是"同类 tile 的 PIP 开关盒是否被打开"的现成观测器**：纯离线、按 tile 坐标、覆盖 INT_L/INT_R 全芯片。

复现（CLI 只打印总数，逐 tile 明细需调用 `decode()`）：
```
python scripts\decode_exact.py --bit E:\v7work\pip_fuzz\p1_A2\design.bit
→ design.bit：精确匹配解出 40 条 PIP        （耗时 19.7 s，无 Vivado）
```
逐 tile 展开（`M=load_bits(); names,ttypes,ys,bases=load_tiles(); fams=load_families(); decode(...)`）：
```
共 40 条，分布在 23 个 tile；INT_R_X7Y24 有 9 条（其中 IMUX 族 6 条）：
  EE4BEG0 LOGIC_OUTS12 | GFAN0 GND_WIRE | GFAN1 GND_WIRE
  IMUX1 GFAN0 | IMUX2 NL1END1 | IMUX4 GFAN1 | IMUX7 GFAN1 | IMUX8 GFAN0 | IMUX11 GFAN0
```
**这条输出就是"PIP 开关盒"的直接证据形态**：它给的是 `mux 族 + 被选中的源 wire`，而不是 INIT 值。
（注：`decode_exact.py` 的 CLI 不打印逐 tile 明细，只打印总数——见 G1 的同类问题：能力在库里，没暴露到 CLI。）

### R2 `bitstream\frames.py`：`load_frames / diff_frame_indices / diff_bits_in_frame` + `bitgen.py`

两个位流 → 变化位坐标（库级，不依赖排版）+ ECC 正确写回。
复现：`diff_frames.py p0_A1\design.bit p1_A2\design.bit` → `diff frames: 11`，共 **78 位**，其中 **word50(ECC)=63 位**、非 ECC 数据位 **15 位**。

### R3 tile-base 逆映射（far_bands + `band_by_region` + y → word）

`decode_exact.load_tiles()` 已实现，实测可把 `(frame, word, bit)` 反解成 `(tile, frame_off, parity)`，**14/15 唯一归因**：

| 位 | 归因 | 族 |
|---|---|---|
| (31724,47,1) (31724,47,23) (31726,46,1) (31729,46,1) (31729,47,23) (31730,47,1) | INT_R_X7Y23 off 8/10/13/14 | NL1BEG1、NR1BEG3、NL1BEG_N3（馈线） |
| (31732,49,25) (31736,49,25) (31739,49,25) (31741,49,25) | INT_R_X7Y24 off 16/20/23/25 | **IMUX7**（sink 的 mux 区） |
| (31733,48,17) (31736,48,17) (31738,48,17) (31741,48,17) | INT_R_X7Y24 off 17/20/22/25 | **IMUX2** |
| (31746,46,11) | ❌ 未唯一 | clb_cells 给出 12+ 并列候选 |

**注意 `IMUX2` 与 `IMUX7` 同时变化**：A1→A2 换引脚，sink 侧是 `IMUX2/IMUX7` 两个 mux 族一起动，不是"一个 PIP 一位"。这条直接决定 T2 的最小实验判据（见 §6）。

### R4 `pip_fuzz.py` 的 `net_pips(dcp)` + `build_variant()`

唯一"自动生成设计 → 取真值 PIP"的骨架。`net_pips` 用 RapidWright `Design.readCheckpoint` + `pip.getStartWireName()->getEndWireName()`。
**但它只认 `--pins` 里的 6 个 A 引脚与 `SLICEM.A6LUT`**，不能指定任意 PIP connection（G4）。

### R5 `pip_reuse_law.py --verify`（定律自检）

```
python scripts\pip_reuse_law.py --verify
→ mux 区 (family, src) 对账：1536 / 1536 精确命中，0 不符
```

---

## 5. 缺口（G1–G8，按对 T2 的阻塞程度排序）

### G1【最关键】没有「两位流 diff → (tile, family, src)」的 CLI
`diff_frames.py` 只给 frame/word/bit；`decode_exact.py` 只吃单个位流。二者之间那一步（R3 的逆映射）**没有脚本**，我是用 `bitstream.frames` + law 库临时拼的（14/15）。
→ 实测影响：跑完 Vivado 只得到一串数字，必须手写 30 行代码才能变成"哪个 mux 被打开"。**这是 T2 实验的直接落地缺口。**

### G2【静默】`fasm2bit --decode` 会静默丢弃全部 IMUX 族
根因：`Model.all_sources()` 对 `family.startswith(('IMUX','BYP_ALT','FAN_ALT'))` 的族**只查 `self.law`**，而 `self.law` 的键是 `IMUX_L*`；`law_cells` 里的族名是 `IMUX7`（无 `_L`）→ `law.get("IMUX7") is None` → 返回 `[]` → 该族被跳过，**不报错**。
同一 tile 对比（可复现）：

| 脚本 | INT_R_X7Y24 解出的 IMUX 条数 |
|---|---|
| `decode_exact.py`（调 `decode()`） | **6 条**（IMUX1/GFAN0、IMUX2/NL1END1、IMUX4/GFAN1、IMUX7/GFAN1、IMUX8/GFAN0、IMUX11/GFAN0） |
| `fasm2bit.py --decode --tiles INT_R_X7Y24` | **0 条**（只出 3 条 INT/GCLK + 2 条 CLB INIT） |

**危险等级：高。** 不报错地低估 PIP 状态，正是"看起来 PASS 其实是没看到"的典型。

### G3 两套命名空间不一致（law JSON vs law_cells）
`v7re\steps\pip_reuse_law.json` 顶层是 `{device, tile_type, version, law, families, combo_check}`；**`tile_type` 写死 `"INT_L"`，`families` 下 64 个键 = 48×`IMUX_L0..47` + 8×`BYP_ALT*` + 8×`FAN_ALT*`，没有任何 `IMUX_R*`**（已逐键统计）。而 `law_cells` 里 INT_R 的 172 族名是 `IMUX0..47`（无 `_L`/`_R` 后缀）。
实测后果：`verify_all_pip.py --tile-type INT_R` → 覆盖 **63.6%**、精确命中 **45.8%**、未覆盖 **1274**、`不符: ('EE2BEG0','LOGIC_OUTS0','缺源')`……而 INT_L 是 100%/100%。
**注意：这不代表 INT_R 的定律错了**——`decode_exact` 对 INT_R 有实测输出（R1）。差异来自 `fasm2bit`/`verify_all_pip` 走的是"law JSON 优先"的路径。

### G4 `pip_fuzz.py` 硬编码，无法指向任意 PIP
写死：`PIN_IMUX`（只 A1–A6）、`SLICEM.A6LUT`、2 个 LUT6 的 VERILOG、`ROOT = E:\v7work\pip_fuzz`、`--dst/--src/--pins` 三个参数之外无扩展点。
→ **无法回答"指定 INT_X7Y24 的 IMUX2 从 NL1END1 改选 NR1END0，位怎么变"**，而这正是 T2 要问的形态。

### G5 没有「两次构建只差一个 PIP」的预检
实测：只换一个 sink 引脚，数据位就 **15 个、跨 2 个 INT tile**（+1 个未归因 CLB 位），ECC **63 位**。
→ 实验设计必须显式声明"这 15 位里哪几位是预期 PIP 位、哪几位是路由伴随位"，否则 PASS/FAIL 无法判定。目前无脚本做这层预检（应调用 `pip_enum` 对两个 DCP 求 PIP 差集）。

### G6 word50(ECC) 占差分 81%，过滤逻辑只硬编码在 `pip_fuzz.py` 内（`if w != 50`）
库级无 helper。任何新写的归因脚本都要复制这个常量，容易漏。

### G7 非 INT tile 无 PIP 位模型
`law_cells` 只有 INT_L/INT_R（各 172 族，frame_off 0..25）。CLB/DSP/BRAM/HCLK 的位只能靠 `v7_model.sqlite`（**7.9 GB**，`site_frames`）或 `clb_cells`（79 族、frame_off 0..35）。
实测后果：第 15 位 `(31746,46,11)` 用 `clb_cells` 反查得 **12+ 并列候选**（PRECYINIT / ALUT INIT[16/17/24/25] / AOUTMUX / A5FFMUX），无法唯一归因。
→ "同类 tile" 只能是 **INT 类 tile**；CLB 类 tile 的 PIP 开关盒目前**不可观测**。

### G8 工程质量
- **PIP 脚本零单元测试**：`v7re\tests\` 6 个文件，`Select-String -Pattern "pip_reuse_law|decode_exact|fasm2bit|pip_fuzz"` **无命中**（`test_model_db.py` 只有 `site_type_pips`/`pip_count` 列名）。
- **README 覆盖率 17/44**：已提到 17 个主脚本，**26 个未收录**（含全部 PIP 核心脚本：`pip_enum / pip_fuzz / pip_reuse_law / decode_exact / fasm2bit / roundtrip / verify_all_pip / verify_superposition / bitwriter / beg_families / t51_generative_law / tamper_localize / hclk_survey / clk_mux_bits`）。另有盘点期间新增的 `t55_object_check.py` 也未收录。
- **编码坑**：`prune_chains.py` / `hclk_survey.py` / `clk_mux_bits.py` 的中文 docstring 是 UTF-8；PowerShell `Get-Content`/`Select-String` 不加 `-Encoding UTF8` 时显示为乱码，按中文关键词 grep 会漏命中。盘点须显式指定 UTF-8。

---

## 6. 与 T2「最小 PIP 实验」的对接路径

现有资产已够，**缺 3 个小件**（都不需要新定律）：

| 件 | 现状 | 补法 | 成本 |
|---|---|---|---|
| ① 任意 PIP 的构建器 | `pip_fuzz.py` 硬编码（G4） | 把 `build_variant` 的 `dst_pin` 换成 `(tile, mux_family, src_wire)`，用 `pip_enum` 取 DCP 真值反查需要改哪条 net | 半天 |
| ② diff→归因 CLI（G1） | 无 | 把本文档 §4 R3 的 30 行脚本固化成 `scripts/attribute_diff.py`，参数 `--a --b --law-db`，输出 `tile family src frame_off parity bit` | 2 小时（逻辑已实测 14/15） |
| ③ 预检（G5） | 无 | 两个构建各跑 `pip_enum`，求 PIP 集合差集，断言"差集 = 目标 PIP ± 允许集合" | 1 小时 |

**T2 的判据应写成三层**（因为一个测试点会牵动多个族）：
1. **PIP 层**：DCP 的 PIP 差集 == 期望的那一条（真值）；
2. **归因层**：位流 diff 的数据位 ⊆ `law_cells` 中该 PIP 所在族的合法格（R3 可判）；
3. **反证层**：控制组（不换 PIP、只重跑）的 diff == 0（排除 Vivado 随机化噪声）。

---

## 7. 待确认 / 未验证

| 项 | 状态 |
|---|---|
| T1 的对象判定结论 | **未拿到**（依赖项）。本文档只在 §3.3 说明"CLB INIT 类脚本共 10 个，是上一轮跨 tile 验证的范式来源"；"上一轮用的到底是 INIT 还是 PIP" 以 T1 为准 |
| `t55_object_check.py` | 盘点期间（14:56:34）由兄弟子任务新增，**未纳入盘点范围**，仅登记存在 |
| `prune_chains.py` 的实际消歧效果 | **未验证**（只读了 docstring 与 argv，未运行） |
| `rw_coupling_probe.py` 的结论 | **未验证**（无 argparse，模块级执行，未运行） |
| `import_frame_map.py` 的输入 CSV 现状 | **未验证**（文件 1238 行、无 argparse） |
| 第 15 位 `(31746,46,11)` 的真实归属 | **未验证**（需 `v7_model.sqlite` 的 site_frames；clb_cells 单独用有 12+ 候选） |

---

## 8. 附录

### 附录 A：AST 扫描脚本（生成 `t3_script_scan.json`）

```python
import os,re,ast,json,datetime
d=r"E:\DEEPSEEK\FPGA比特流逆向\v7re\scripts"
rows=[]
for fn in sorted(os.listdir(d)):
    if not fn.endswith(".py"): continue
    p=os.path.join(d,fn); raw=open(p,"rb").read(); src=raw.decode("utf-8-sig",errors="replace")
    try: doc=(ast.get_docstring(ast.parse(src)) or "").strip().splitlines()
    except Exception as e: doc=["PARSE_FAIL:"+str(e)]
    rows.append({"file":fn,"lines":src.count("\n")+1,"bytes":len(raw),
      "mtime":datetime.datetime.fromtimestamp(os.path.getmtime(p)).strftime("%Y-%m-%d %H:%M:%S"),
      "docstring_first_line":doc[0] if doc else "","has_main":"__main__" in src,
      "argparse_options":re.findall(r'add_argument\(\s*"([^"]+)"',src),
      "probe":fn.startswith("_")})
json.dump({"scanned_at":datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
  "count":len(rows),"main":sum(1 for r in rows if not r["probe"]),
  "probe":sum(1 for r in rows if r["probe"]),"scripts":rows},
  open(r"E:\DEEPSEEK\FPGA比特流逆向\v7re\steps\t3_script_scan.json","w",encoding="utf-8"),
  ensure_ascii=False,indent=1)
```

### 附录 B：PIP 关键词命中计数（`pip|PIP`，按文件）

pip_fuzz 26 / tamper_localize 21 / export_site_topology 19 / bitwriter 18 / verify_superposition 16 / import_site_topology 14 / pip_enum 12 / prune_chains 9 / decode_exact 9 / hclk_survey 8 / _pip_introspect 8 / verify_all_pip 6 / roundtrip 5 / pip_reuse_law 4 / t51_generative_law 3 / build_site_frames 2 / fasm2bit 2 / rw_coupling_probe 2 / _share 1 / _pred 1 / step1_topology 1 / _amb 1 / _pipcmp 1

> 注意 `fasm2bit` 只有 2 次命中——它其实有 PIP 能力，但关键词集中在 `MUX_PREFIX`/`law` 上，**用关键词筛选会漏掉它**。这本身是一条方法论提醒：本次清点以 docstring + 代码结构为准，关键词只用于交叉验证。

### 附录 C：数据资产（盘点中核实存在）

| 路径 | 大小/规模 | 内容 |
|---|---|---|
| `E:\v7work\model\v7_law.sqlite` | 11.5 MB | `law_cells` 24,328 行（INT_L/INT_R 各 172 族 sense=1 共 8,900 行、70 族 sense=0 共 3,264 行；frame_off **0..25**）/ `law_tiles` 62,625（INT_L 26,550 + INT_R 26,550 + FEEDTHRU/INTERFACE 9,525）/ `clb_cells` 3,884 行（79 族，frame_off **0..35**）/ `v7_verified` 98 行 |
| `E:\v7work\model\v7_model.sqlite` | **7.9 GB** | `site_addr` / `site_frames` 等；旁有 4 个 .bak |
| `v7re\steps\pip_reuse_law.json` | 75,983 B | `families` 64 键 = 48 `IMUX_L*` + 8 `BYP_ALT*` + 8 `FAN_ALT*`（**无 `IMUX_R*`**）；`tile_type="INT_L"` |
| `v7re\steps\beg_families.json` | 308,287 B | BEG6/4 二分结构 |
| `v7re\steps\ecc_model.json` | 2,396 B | ECC 位置签名 |

---

## 9. 证据复现命令清单（本次实际执行，工作目录 `E:\DEEPSEEK\FPGA比特流逆向\v7re`）

| # | 命令 | 实测输出（摘要） | 用途 |
|---|---|---|---|
| 1 | `python scripts\pip_reuse_law.py --verify` | `mux 区 (family, src) 对账：1536 / 1536 精确命中，0 不符` | R5 定律自检 |
| 2 | `python scripts\verify_all_pip.py` | `tile_type=INT_L 家族 172 feature 3634`；覆盖 3634（100.0%）精确命中 3634（100.0%） | INT_L 全覆盖 |
| 3 | `python scripts\verify_all_pip.py --tile-type INT_R` | 覆盖 2312（**63.6%**）精确命中 1666（**45.8%**）未覆盖 **1274**；`不符: ('EE2BEG0','LOGIC_OUTS0','缺源')` | G3 |
| 4 | `python scripts\decode_exact.py --bit E:\v7work\pip_fuzz\p1_A2\design.bit` | `design.bit：精确匹配解出 40 条 PIP`（19.7 s） | R1 |
| 5 | 同上，调 `decode()` 展开 | 40 条 / 23 tile；`INT_R_X7Y24` 9 条（IMUX 6 条：IMUX1/2/4/7/8/11） | R1 |
| 6 | `python scripts\fasm2bit.py --in ...\p1_A2\design.bit --decode --tiles INT_R_X7Y24` | `INT_R_X7Y24.GFAN0.GND_WIRE` / `.GFAN1.GND_WIRE` / `.EE4BEG0.LOGIC_OUTS12` / `SLICE_X10Y23.ALUT=0xfffffffffffffffe` / `SLICE_X10Y24.ALUT=0x...fe`（**0 条 IMUX**） | G2 |
| 7 | `python scripts\diff_frames.py ...\p0_A1\design.bit ...\p1_A2\design.bit` | `diff frames: 11` → `[31724,31726,31729,31730,31732,31733,31736,31738,31739,31741,31746]` | R2 |
| 8 | 同上 `--bits` + `bitstream.frames` 统计 | 78 位，word50(ECC) 63 位、非 ECC 数据位 **15** 位 | R2/G5/G6 |
| 9 | 库级逆映射（`load_tiles` + `word_of` + `law_cells`） | 14/15 唯一归因（§4 R3 表） | R3/G1 |
| 10 | `python scripts\t51_generative_law.py --json` | 退出码 0，输出 `absolute_word_y_20` 等字段 | 接口可用 |
| 11 | 上述第 2/5/7 条的脚本源码核对（`decode_exact.py:150-183`、`fasm2bit.py` 的 `MUX_PREFIX`/`all_sources`） | 见 R1、G2 根因 | G1/G2 |

> 第 5/8/9 条没有现成 CLI，是我用 `v7re.bitstream.frames` + `v7re.scripts.decode_exact` 的库函数临时拼的——这本身就是 G1 的证据（能力在库里，没有入口）。
