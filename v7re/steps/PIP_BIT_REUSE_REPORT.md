# Xilinx 7 系列 INT tile PIP 位编码复用规律 —— 研究报告

器件：**xc7vx485t**（ffg1157-3 / ffg1761-2，fabric 层一致）
工具：Vivado 2017.2（少量对照用 2020.2）、RapidWright 2026.1.0、Python 3.8/3.10
日期：2026-11-09
版本：v1.0

---

## 摘要

本文给出 Xilinx 7 系列 **INT（互连开关盒）tile 中每条 PIP 的配置位地址的完整编码规律**，
并用实测量化其覆盖度。

三条结论：

1. **复用发生在“格”级，且在族内**：每族有固定的一小片位格（1,598 格），24 个源共享它们，
   平均每格被 5.56 个源共用（1–18）。跨族的格从不共享。
2. **位地址 = 行列寻址**：一个源 = 一个**行格** + 一个**列 cube**。
   `frame = 块基址 + frame_off`、`word = 2*(y%50) + parity`（`y%50 ≥ 25` 再 +1）、`bit` 由规则给出。
   其中 **列码就是线长类别**（1/2 → DOUBLE，7/11 → SINGLE，744/744 零例外），
   **6 行 = 4 类方向线 + 逻辑输出 + bounce**。
3. **不可导出的只剩“类内成员序”**：每族 24 个源落哪一行是器件布线事实（48 族 36 种），
   几何路线已排除（routing 模板无坐标字段、RapidWright 无 mux 内部坐标 API）。

验证规模：**12,565 个 INT tile 实例、64,686 个观测位、0 个表外位**；
线长律累计 **5,832/5,832** 全中。

---

## 1. 问题

Xilinx 7 系列的 bitstream 中，一条 PIP（把某条源线接到某个目的线）并不对应“一位”，
而是对应**若干位同时置位**。本项目要回答三个问题：

- 复用**在哪**发生（哪些位被多少条 PIP 共用）？
- 复用的**结构**是什么（为什么 2 位 / 4 位，能否预测）？
- 给定 `(tile_type, family, source)`，能否**算出**该置哪些位？

---

## 2. 数据与方法

### 2.1 数据源

| 名称 | 内容 | 用途 |
|---|---|---|
| `v7_law.sqlite: law_cells` | 24,328 行 `(tile_type, family, src_wire, frame_off, bit, sense, parity)` | 位语义 |
| `routing/out_routing/templates/INT_L.json` | 3,737 条 `(src, dst)` | 源集合校验 |
| `law_tiles` / `far_bands` / `meta.band_by_region` | 62,625 tile 与块基址 | 绝对地址 |
| Vivado `get_pips -of_objects <net>` | 真实布线（A 级证据） | 对照真值 |

### 2.2 实验协议（每条结论都必须过）

1. 固定 `LOC` / `BEL` / `LOCK_PINS` / **显式 `-part`**，回读断言 `SITE`/`BEL`/`INIT`；
2. **集合级自证**：预测位集合与实际差分集合必须 `missing=0 且 extra=0`，禁止抽样；
3. **交叉自证**：另一批构建 / 另一个脚本独立复算；
4. **负对照**：同参数重跑差分必须为 0；
5. 未解释的差异必须归因或显式标注“未解释”，不得沉默。

---

## 3. 复用的位置与形态

### 3.1 复用是族内格级

- 目的线 = **family**（如 `IMUX_L34`、`WW4BEG0`）；
- `(family, source)` = 一条可配置的“连接”；
- 每条连接占 **2 格**（BEG 族）或 **2–4 格**（mux 族）；
- 每族 24 个源共享 **10 个位格**（`IMUX_L40` 例），格被 4–18 个源共用。

统计（INT_L，sense=1）：1,598 格、3,634 条连接、8,900 次引用，平均 **5.56 次/格**。

### 3.2 结构分三类

| 类 | 规模 | 形状 | 每源格数 |
|---|---|---|---|
| mux 区 | 64 族 | 6 行 × 4 列网格 | 2 或 4 |
| BEG 长线 | 96 族 | 完全二分 `K(4,5)` / `K(5,4)` | 2 |
| 时钟/控制 | 7 族 | 组-核心-附加位 | 2–4 |

时钟族结构：`4 组 × (2 个“核心去一格” + 2 个“核心加一附加位”)`，96 条连接全部可重建。

### 3.3 为什么是 6 × 4

| 维度 | 语义 | 证据 |
|---|---|---|
| 6 行 | 4 类方向线（DIAG/ORTH/R/L）+ `LOGIC_OUTS` + `BOUNCE` | 64/64 族行分布恒为 (4,4,4,4,4,4) |
| 4 列 | 每类内部的成员索引 | 列 cube 全族只有 4 种 |

**列 code = 线长类别**：`1/2` 对应 `*E2*`（DOUBLE），`7/11` 对应 `*E1*`（SINGLE），
48 族 × 16 条可归类源 = **744 条，零例外**。

列 → 帧：`1→{25}`、`2→{24}`、`7→{23,24,25}`、`11→{22,24,25}`。

---

## 4. 可计算的部分（公式）

```
# 地址
base   = clb_blocks[(grid_col, band)]        # band = band_by_region[y // 50]
word(r) = 2*r + parity   (r = y % 50)，r >= 25 时再 +1
frame  = base + frame_off

# mux 区：族参数
pair, parity, primary  ← 族属性（16 位对 × 2 parity × 2 phase = 64 族，一一对应）
row_bit(r)  = primary        if r ∈ {0,1,4,5}
              twin           if r ∈ {2,3}
列帧         = 由列码决定（见 §3.3）
列位         = primary

# 位对与 parity（族编号 i）
minbit  = 8*(i % 4) + 2*(i // 16) + 2*((i // 8) % 2)
parity  = 1 if (i % 8) >= 4 else 0

# 方向类 → 列码
(i // 8) 偶 → DIAG:1  ORTH:2  R:7   L:11
(i // 8) 奇 → DIAG:2  ORTH:1  R:11  L:7

# 行内角色（LOGIC vs BOUNCE 在 row20）
row20 放 LOGIC ⟺ (i // 8) 偶，或 family ∈ BYP_ALT
```

---

## 5. 证据链

| 编号 | 结论 | 规模 | 结果 |
|---|---|---|---|
| E1 | mux 区行列定律 | 64 族 × 24 源 | 1,536/1,536 精确 |
| E2 | BEG 完全二分可重建 | 32 族（后扩到 96） | 可重建，0 反例 |
| E3 | 线长 → 列码 | 744 条 | 744/744 |
| E4 | 线长律（名字一致 + 列帧置位） | 5,535 + 5,184 | 0 反例 / 100% |
| E5 | 全器件同一套规则 | 12,565 tile、64,686 位 | **0 表外** |
| E6 | 叠加线性 | 48 条 PIP 同时 | 56/56 预测位全 1；`sense=0` 48/48 |
| E7 | 位流 → FASM → 位流 | 4 个设计 | 逐字节幂等 |
| E8 | 改一行 FASM → 与 Vivado 等价 | BUFGCTRL 例 | 帧级 0 差异 |

其中 E8 的细节：把 `BUFGCTRL_X0Y16.SEL=I0` 改成 `I1`，用 `g16_s0.bit` 作基底重新生成，
与 Vivado 独立产出的 `g16_s1.bit` 比较 —— **50,176 帧全等**，字节级只差时间戳（2 B）与尾部 CRC（4 B）。

---

## 6. 边界：不可导出的部分

| 项 | 状态 | 说明 |
|---|---|---|
| 类内成员序（每族 24 源的行号） | **数据** | 48 族 36 种，几何路线已排除 |
| 跨 tile_type 命名差异 | 未建模 | INT_R 的 `LOGIC_OUTS0` vs `LOGIC_OUTS_L0` |
| 尾部 CRC | 未解 | 影响“生成可加载 bitstream”，不影响读写闭环 |
| 非 INT tile | 未做 | CLB 自身 PIP ≈150、BRAM/DSP/IOI |

几何路线为何排除：`INT_L.json` 的 `pip_defs` 只有 `(src, dst, 0, bool)`，
第 3 字段 3,737 条全为 0；RapidWright 的 `Wire`/`PIP` 无坐标 API，只有所属 tile 的 XY。

---

## 7. 工程可用性

- **读**：位流 → FASM（INT/BEG + CLB INIT + GCLK + BUFGCTRL），4 个设计幂等；
- **写**：FASM → 位流，改一行即可复现 Vivado 的设计（帧级全等），ECC 自动重算；
- **性能**：单设计解码秒级；构建吞吐 32 路并发 ≈ 1,200 个/小时（84 s/构建）。
- **数据压缩**：从“3,634 条连接逐条查表”到“族参数 + 少量每族数据”，约 2.7× 压缩，
  且新增 tile 实例**零成本**（同一张表套所有实例）。

---

## 8. 与 prjxray 的关系

- `law_cells` 的**名字**来自 prjxray 的 `segbits_int_l.db`（A 级：Vivado 输出与之逐字相同）；
- 本文的**分组语义**（family、行/列、线长对应）是本文提出的，不是厂商术语；
- prjxray 的模型是“每条 feature 一组位”，本文额外给出**位地址的生成式**，
  使得未观测到的实例/源也可预测。

---

## 9. 复现清单

```bash
# 位坐标定律（离线）
python v7re/scripts/pip_reuse_law.py --build --verify          # 1,536/1,536
python v7re/scripts/beg_families.py --build                    # 96 族
python v7re/scripts/verify_all_pip.py --tile-type INT_L        # 3,634/3,634, 0 不符
python v7re/scripts/wirelen_check.py --pips <pips> --bit <bit> # 线长律

# 全器件一致性
python v7re/scripts/all_int_tiles_check.py --bit <bit>         # 格宇宙残差

# 读写闭环
python v7re/scripts/fasm2bit.py --in a.bit --decode --out a.fasm
python v7re/scripts/fasm2bit.py --in a.bit --fasm a.fasm --out b.bit
```

---

## 10. 方法学教训

1. **位平面法会被优化器破坏**：Vivado 把低复杂度函数降级成小 LUT / 缓冲，导致某一位平面整体反相。
   必须用**单最小项**枚举，并对每个构建回读断言。
2. **`LOCK_PINS` 不是可选项**：不加它，Vivado 自由重排 `I0..I5`，测出的索引是当次分配的。
3. **`DONT_TOUCH` 不阻止常量传播**：CE 接常量时整格被删。
4. **检验器本身也要被检验**：本轮最后 22 个“表外位”全部由检验脚本漏掉 `+1` 位移造成，
   连续两轮把结论引向错误方向（先怀疑长线，再怀疑位移边界）。

---

## 附录 A：术语

| 术语 | 含义 |
|---|---|
| tile / family / source / cell | 物理 tile / 目的线 / 源线 / `(frame_off, parity, bit)` |
| 格宇宙 | 某 tile_type 在 `law_cells` 中所有 `sense=1` 格的并集 |
| 线长类别 | DOUBLE（`*E2*`）/ SINGLE（`*E1*`） |
| 行格 / 列格 | 源所占的行定位格 / 列 code 对应的 1–3 个格 |
