# S20 —— DSP48E1 编码完整实验设计（V7 xc7vx485tffg1157-3）

> 前置已确认（S19）：DSP48E1 配置块 = **28 帧**；`DSP48_X0Y0` 块基址 **31960**；全部配置位在 `base+26 / base+27` 的 word 0..9；
> artix7 表在该位流上 **39/39 家族唯一命中、0 歧义**；AREG 四条位逐位对上。

本设计的目的是把“能对上 39 个家族”升级为“**DSP 全配置位 100% 可解释、可反向解码、可写回**”。

---

## 0. 验收门（不过门不算完成）

| 门 | 判据 | 度量方式 |
|---|---|---|
| **G0 基址** | 8 个 DSP tile 的块基址全部由差分确定，且与列/band 有可预测关系 | 8/8 命中，误差 0 |
| **G1 属性位** | 280 条属性 feature 每条都有实测差分签名，且与 artix7 表一致或给出 V7 偏差说明 | 一致率 ≥ 95%，偏差条目逐条记录 |
| **G2 mux 家族** | 78 条 GND/VCC 家族在“接 0 / 接 1”两种设计下都唯一判读 | 156/156 唯一，歧义 0 |
| **G3 双 site** | `DSP_0_*` 与 `DSP_1_*` 各自基线确定，未用 site 的默认态可预测 | 两 site 均 100% 解释 |
| **G4 输入 mux** | DSP 的 A/B/C/D 输入来源（INT 侧 `DSP_*` 端点）能定位到具体 INT 线 | 每条输入线唯一归属 |
| **G5 反向** | 任意 10 组随机配置，仅从 `.bit` 恢复属性，与 Vivado 真值全等 | 10/10 全字段相等 |
| **G6 写回** | 直接改配置位（含 ECC）后重新判读，解出目标属性 | 5/5 成功且不触发 CRC 拒绝 |

---

## 1. 实验单元与变量控制

### 1.1 固定项（所有设计共享）
```tcl
synth_design -top top -part xc7vx485t -flatten_hierarchy none
set_property LOC DSP48_X0Y0 [get_cells -hier -filter {REF_NAME==DSP48E1 && NAME !~ "*/*"}]
set_property IS_LOC_FIXED 1 <cell>
place_design; route_design
# DRC 豁免（否则 bitgen 不跑）
NSTD-1 UCIO-1 DPIP-1 DPOP-1 DPOP-2 REQP-20 REQP-24 REQP-29 REQP-30 REQP-31 AVAL-4
```
- `(* DONT_TOUCH = "true" *)` 加在 module 与 DSP 实例上，防止综合优化掉未用输出。
- 输入全部来自顶层端口（`a[29:0]`、`b[17:0]`、`clk`），输出 `p[47:0]` 到端口 → 保证 DSP 不被裁剪、布线存在但不影响配置位。
- 每个设计都记录 `report_property` 的**真值快照**（属性值 + 实例 LOC），作为后续判读的 ground truth。

### 1.2 唯一变量
每个设计**只改一个**属性（或一对必须联动的属性，如 `AREG`/`ACASCREG`），其余与基线 `BASE` 完全一致。
基线 `BASE` = 全默认：`AREG=0,ACASCREG=0,BREG=0,BCASCREG=0,CREG=0,DREG=0,MREG=0,PREG=0,ADREG=0,OPMODEREG=0,ALUMODEREG=0,INMODEREG=0,CARRYINREG=0,CARRYINSELREG=0,USE_DPORT=FALSE,USE_MULT=MULTIPLY,AUTORESET_PATDET=NO_RESET,IS_*=0,MASK=0,PATTERN=0`。

### 1.3 差分语义（沿用 INT 的三条纪律）
- **PURE**：`B − R` 与 `A − R` 交集为空 → 该位由本设计独占决定；
- **XOR**：A/B 均有该位但取值相反 → 语义翻转；
- **FAM**：多位同族一起变 → 家族级编码（mux）。
- 每批都必须带**负对照**：两个完全相同输入的重复构建，差异必须为 0（否则说明有非确定性来源）。

---

## 2. 六组实验

### A 组：块基址定位（8 个设计）
| 目标 | 设计 |
|---|---|
| 列方向 | `DSP48_X0Y0` 放在 `DSP_L_X14Y0`、`DSP_R_X15Y0`、`DSP_L_X20Y0`、`DSP_R_X21Y0` |
| 行方向 | 同列 `Y0`、`Y1`、`Y50`（band 边界）、`Y150` |

方法：每个 tile 各建一对设计（`BASE` 与 `AREG=2`），差分落在 `base+26/+27` → 直接读出块基址。
**产出**：`dsp_block_base.csv`（tile, grid_x, grid_y, band, base_frame）；用于检验“同列相邻 tile 基址差 = 28 或 36/64”这类规律。

### B 组：属性位全表（约 280 个设计）
| 子组 | 变量 | 设计数 | 说明 |
|---|---|---|---|
| B1 寄存器位 | `AREG∈{0,1,2}`、`BREG∈{0,1,2}`、`CREG`、`DREG`、`MREG`、`PREG`、`ADREG`、`OPMODEREG`、`ALUMODEREG`、`INMODEREG`、`CARRYINREG`、`CARRYINSELREG` | ~20 | 每个取值一个设计；注意 `AREG/ACASCREG`、`BREG/BCASCREG` 联动 |
| B2 MASK/PATTERN | `MASK[0..47]`、`PATTERN[0..47]` 各取**全 1** 与**单 bit 置 1**（抽样 12 个 bit） | 4 + 24 | 全 1 设计给出 48 位的 1-hot 位置；抽样验证线性 |
| B3 反相位 | `IS_ALUMODE_INVERTED[0..3]`、`IS_INMODE_INVERTED[0..4]`、`IS_OPMODE_INVERTED[0..6]`、`IS_CLK_INVERTED`、`IS_CARRYIN_INVERTED` | 20 | 每个取 1 |
| B4 模式位 | `USE_DPORT=TRUE`、`USE_MULT=NONE`、`SEL_MASK=MASK/PATTERN`、`SEL_PATTERN`、`AUTORESET_PATDET=RESET_MATCH`、`USE_SIMD=FOUR12/FOUR12_TWO24/TWO24_48` | ~10 | 组合语义，需逐项单测 |

判读：`diff(BASE, Bx)` → 位集合；与 artix7 `segbits_dsp_l.db` 的 `DSP48.DSP_0.<attr>` 行比对。

### C 组：mux 家族双向（156 个设计）
对 78 条 `*_GND_L / *_VCC_L` 家族各建两个设计：把对应控制引脚**接 0** 与**接 1**。
判读：接 0 时应命中 GND 模式、接 1 时命中 VCC 模式 → 得到 156/156 双向判读。
**注意**：部分家族的控制不是端口而是常量（如 `ALUMODE2` 由 `ALUMODE[2]` 决定），需从 OP MDOE/ALUMODE 组合推得，映射表写入 `dsp_ctrl_map.csv`。

### D 组：DSP_0 / DSP_1 双 site（6 个设计）
| 设计 | 目的 |
|---|---|
| 只用 `DSP48_X0Y1`（第二 site），`BASE` | 得到 `DSP_1_*` 的基线位（验证 S19 里 39 个“未命中”确为默认态） |
| 只用 `DSP48_X0Y1`，`AREG=2` | 定位 `DSP_1` 的位偏移是否与 `DSP_0` 同帧/同 word |
| 两 site 同时用，`DSP_0:AREG=0` / `DSP_1:AREG=2` | 交叉验证两 site 的位域不重叠（关键：若重叠则“位池私有”在 DSP 内失效） |

### E 组：输入 mux（INT 侧端点）（12 个设计）
DSP 的 A/B 输入来自 INT 的 `DSP_*` 线，**不在 DSP tile 内**。
| 设计 | 变量 |
|---|---|
| E1 | `A` 由不同 INT `EE4BEG*` 线驱动（3 个不同源）→ 差应在 INT tile 帧 |
| E2 | `B` 由不同 `WW2BEG*` 驱动 |
| E3 | `C`/`D` 接常量 vs 接 INT 线（区分“常量省位”与“mux 选择”） |

判读：用已有 INT 表（181 PIP + IMUX 表）解释 INT 侧差异；不能解释的位 → 新增 DSP 端点家族，进入 `dsp_int_endpoint.json`。

### F 组：反向与写回（15 次）
| 子组 | 做法 |
|---|---|
| F1 反向 | 随机生成 10 组属性组合 → 构建 → 只用 `.bit` 判读 → 与真值全字段比对 |
| F2 写回 | 取 5 个位流，直接翻转目标位 + 重算 word50 校验 → 重新判读，验证解码器给出目标属性 |
| F3 负对照 | 同一输入重复构建 2 次，差分必须为 0 |

---

## 3. 构建与并发

| 项 | 值 |
|---|---|
| 单设计耗时 | ≈ 65–75 s（synth 20 s + place/route 30 s + bitgen 10 s） |
| 并发度 | 32（已验证：44 核 / 98 GB，32 并发峰值约 3 GB/实例） |
| 一波 | ≈ 4–5 min |
| 总设计数 | A 8 + B ~280 + C 156 + D 6 + E 12 + F 15 ≈ **477** |
| 总机时 | ≈ 16 波 × 5 min ≈ **80 min**（含失败重试余量取 2 h） |
| 产物大小 | 每 `.bit` 20 MB → 477 × 20 MB ≈ 9.5 GB（**只保留差分包**：diff 后立即删 bit） |

驱动脚本 `dsp_fleet.sh`：
1. 读 `inventory.json`（每项：`id`、`verilog 变量`、`expected_attr`）；
2. 生成 `gen/<id>.v`（模板 + 变量注入）；
3. `xargs -P32` 逐个跑 `vivado -mode batch -source build.tcl`，日志 `log/<id>.txt`；
4. 失败的按 §5 分类重试一次；
5. 全部 `diff_bit.py BASE <id>` → `diffs/<id>.json`；
6. **删 `.bit`** 只留 `diffs/` 与 `truth/`。

---

## 4. 数据与判读

### 4.1 中间产物
| 文件 | 内容 |
|---|---|
| `inventory.json` | 477 项设计清单 |
| `truth/<id>.json` | `report_property` 真值快照（全属性 + LOC） |
| `diffs/<id>.json` | `{frame, word, bits_before, bits_after}` 列表 |
| `dsp_cells.json` | 反推表：`{family, source, frame_off, word, bit, sense}` |
| `dsp_block_base.csv` | tile → 块基址 |
| `dsp_ctrl_map.csv` | 家族 → 控制引脚/属性表达式 |

### 4.2 判读规则（照搬 INT 的判定器）
```
候选 = { s : ones(s) ⊆ 观测 且 zeros(s) ∩ 观测 = ∅ }
```
- 命中 1 个 → 唯一判读；
- 命中 >1 → 记 AMBIGUOUS（必须为 0，否则说明位池不私有）；
- 命中 0 → 记 UNEXPLAINED（必须为 0，否则表缺家族）。

### 4.3 解释率指标
`解释率 = 已解释位 / 差分总位`，按组统计；G1/G2 要求 ≥ 95% / 100%。

---

## 5. 失败分类与处置（都是已踩过的坑）

| 症状 | 根因 | 处置 |
|---|---|---|
| `DRC AVAL-2 / AVAL-4` | `AREG`≠`ACASCREG` 等寄存器联动约束 | 按 `AREG=2→ACASCREG=1`、其他同值生成 |
| `Synth 8-448 M/CARRYOUTF` | 2017.2 unisim 无这些端口 | 只连 `P` |
| `Vivado 12-1345` | NSTD/UCIO/DPIP/DPOP/REQP 阻断 bitgen | 统一豁免（见 §1.1） |
| 差分 0 位 | 综合把未用逻辑裁掉 / 属性被常量传播 | 查 `get_cells` 是否为空；加 `DONT_TOUCH`；`-flatten_hierarchy none` |
| 差分落在 band1（帧 27xxx） | 预综合 XDC 施加 LOC 失败 | LOC 必须在 `synth_design` 之后 |
| word50 差异出现 | ECC（该帧 ECC 变化） | 单独归入 `ecc` 类，不计入配置位 |
| 差分帧号差 28/36 | 基址取错（相邻块） | 用 A 组基址表核对，禁止用名字算术推基址 |

---

## 6. 交付物

1. `S20_DSP_FULL.md` —— 结论报告（六组结果 + 解释率 + 偏差条目）
2. `dsp_cells.json` —— V7 版 DSP 配置位表（含 V7 相对 artix7 的偏差标注）
3. `dsp_block_base.csv`、`dsp_ctrl_map.csv`
4. `dsp_decoder.py` —— 输入 `.bit` → DSP 属性字典（含歧义报错）
5. `dsp_encode_check.py` —— 属性 → 位集（正向），与反向互检
6. DB 写入 `v7_law.sqlite`：`v7_verified` 增 `DSP48E1` 段

---

## 7. 时间表

| 阶段 | 内容 | 预计 |
|---|---|---|
| 阶段 1 | A 组（基址 8）+ 负对照 | 30 min |
| 阶段 2 | C 组（78 家族双向） | 30 min |
| 阶段 3 | B 组（属性位全表） | 60 min |
| 阶段 4 | D/E 组（双 site、输入 mux） | 40 min |
| 阶段 5 | F 组（反向 + 写回）+ 报告 | 40 min |

---

## 8. 已知不确定项（写进报告，不许默认成立）

1. `MASK/PATTERN` 是否线性（单 bit 置 1 → 单 bit 变化）未验证；若非线性需改为逐位穷举。
2. `DSP_1` 的位域是否与 `DSP_0` 完全同构未验证（D 组第 3 个设计就是判它的）。
3. `USE_SIMD` 组合可能不是单一位，而是多家族联合，需按 FAM 语义处理。
4. 位流写入后 `word50` 的真实语义（CRC or ECC）仍未定论，F2 写回会顺带给出一个反例/正例。
