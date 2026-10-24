# 计划：找出 7 系列 PIP 复用规律

目标：回答“**一条比特流的配置位，是怎样被同一个 mux 的多条 PIP 共用的**”，
并把它变成可预测的规则（给定 PIP → 位集合；给定位集合 → 候选 PIP）。

---

## 0. 先把“复用”定义清楚

我们看到的现象（IMUX_L8，word 22，帧 31696~31705）是：

- 同一个 mux 的所有输入共用一个小位池；
- 不同输入取位池的不同**子集**；
- 位池内的位置（帧号、word、bit）在 mux 之间、行之间是否也复用，是待验证的部分。

因此“复用规律”分三层，必须逐层验证：

| 层 | 问题 | 判据 |
|---|---|---|
| L1 同 mux 内复用 | 同一 mux 的 N 个输入是否共用一个固定位池 | 所有输入的位集合 ⊆ 同一个池，且池大小 ≪ N |
| L2 跨 mux 复用 | 不同 mux 的位池是否重叠 | 两个 mux 的位集合交集非空 |
| L3 跨行列复用 | 同一 mux 在不同 Y/X 是否只是整体平移 | 位集合 = 基准集合 + 固定偏移 |

---

## 1. 方法：用“绝对位集”替代“对称差反推”

上一轮用 `A = B Δ D` 反推，误差会累积。这次改成**直接读绝对位集**：

1. 建一个**单源设计**：`lut_a → n1 → lut_b`，n1 只经过一条 `SRC->>IMUX_L8`，
   其它输入悬空/常量，保证整个 tile 里没有第二条路由竞争同一 mux。
2. 对该设计做 **一次** 布局布线（Vivado `place_design` + `route_design`），得到 `base.dcp`。
3. 对每个源 `SRC_i`：用 RapidWright 把 DCP 里那条 PIP 的源换成 `SRC_i->>IMUX_L8`，
   写 `v_i.dcp`，只跑 `write_bitstream`（**不重新布局布线**）。
4. 与“所有源都断开”的空设计 `empty.bit` 做差分 → 直接得到 `SRC_i` 的绝对位集。

代价：1 次完整 P&R（~60–90 s）+ N 次 bitgen（各 ~20 s）。
IMUX_L8 的 25 个源 ≈ **15 分钟**跑完，比重新 P&R 快一个数量级。

---

## 2. 实验矩阵

| 阶段 | 变量 | 规模 | 目的 |
|---|---|---|---|
| P1 | IMUX_L8 全部源（~25） | 25 次 bitgen | 拿到 L1 的完整位池 |
| P2 | IMUX_L8 的位池 ∪/∩ 分析 | 纯计算 | 判定 one-hot / 二进制 / 混合编码 |
| P3 | IMUX_L0/L4/L8/L12/L20/L32（抽样 6 个 mux） | 6×25 ≈ 150 | L2：mux 间是否共享位 |
| P4 | 行 Y10/Y20/Y30/Y40 + 列 X6/X12 | 4×2×25 ≈ 200（抽样源） | L3：平移规律 |
| P5 | 留出验证：随机 30 条 PIP 预测后实测 | 30 | 公式是否可预测 |
| P6 | 入库 + 报告 | — | 交付 |

规模说明：P3/P4 只对“每个 mux 抽 8 个有代表性的源”跑，避免 1000+ 次 bitgen。

---

## 3. 分析步骤（每阶段结束就做，不攒到最后）

### P2 编码判定

对 mux 的位池 `Pool = ∪ bits(SRC_i)`：

- 若 `|bits(SRC_i)| == 1` 且互不相交 → one-hot；
- 若 `|bits(SRC_i)| == |Pool|` 且互补 → 二进制/反码；
- 若子集大小不一 → 检查是否是“one-hot + 共享使能位”的混合（7 系列常见）。

同时统计：位池大小 vs 源数量（25 个源需要多少位），看是否符合 `ceil(log2 N)` 或 one-hot。

### L2 跨 mux

计算两两 mux 位池交集；若交集非空，记录共享位并检查共享位是否有“mux 组”结构
（例如 IMUX_L8 与 IMUX_L9 共享高位）。

### L3 跨行列

对行偏移 ΔY 和列偏移 ΔX：
- 帧号差是否恒定？
- word 差是否 = 2ΔY（已有初步证据）？
- bit 位是否不变？

拟合 `(frame, word, bit) = f(mux_index, Y, X)`，用 P5 留出点验证。

---

## 4. 基础设施改动

1. `step03_pip/add_pip.py` 已能替换单条 PIP；补一个 `swap_source.py`：
   读 `base.dcp` → 按 `--src` 构造新 PIP 列表（保留 sink，替换源）→ 写 `v_<src>.dcp`。
2. `build_once.tcl`：只做一次 P&R，产出 `base.dcp` + `base.bit`。
3. `bit_only.tcl`：`open_checkpoint v_i.dcp; write_bitstream -force v_i.bit`。
4. `diff_abs.py`：对 `empty.bit` 与 `v_i.bit` 求差，输出 `{frame: [(word,bit)...]}` JSON。
5. `run_p1.sh`：循环 25 个源，失败重试 1 次，日志落盘。
6. 结果写 `E:\v7work\model\v7_model.sqlite` 的 `pip_bits`（表已存在），
   `source` 字段用 `reuse_p1_20261025`。

---

## 5. 验收标准

- [ ] P1：25 个源全部拿到位集，且每个位集都 ⊆ 同一位池
- [ ] P2：给出编码类型（one-hot / binary / 混合），并解释位池大小
- [ ] L2：至少一对 mux 的位池相交（或证明不相交）
- [ ] L3：给出 `f(mux, Y, X)` 公式，误差 ≤ 1 位
- [ ] P5：留出 30 条 PIP，预测命中率 ≥ 90%
- [ ] 文档：`RESULTS.md` 增加“复用规律”章节，`STATUS.md` 更新

---

## 6. 时间与风险

| 项 | 估计 |
|---|---|
| P1（25 源） | 15 min |
| P2 分析 | 10 min |
| P3（6 mux × 8 源） | 50 min |
| P4（8 组合 × 8 源） | 70 min |
| P5 验证 | 15 min |
| 合计 | **约 3 小时**（含重跑余量） |

风险与对策：

1. **bitgen 非确定性**：同一 DCP 连跑两次比对，先证明位流稳定；不稳定就固定 `-no_binary` 等选项。
2. **ECC 干扰**：word 50 一律排除；若某帧只有 word 50 变化，视为无效点。
3. **站点内 mux 不适用**：本计划只做 INT tile 的 mux；CLB 内部 mux 另开一条线。
4. **源名不匹配**：RapidWright PIP 字符串带 `->>`，tile_type json 里是 `->`，统一在 `swap_source.py` 里做转换。

---

## 7. 产出

- `step03_pip/reuse/`：脚本 + 每源 JSON + 汇总 CSV
- `v7_model.sqlite`：`pip_bits` 新增 ~200 行（P1+P3+P4）
- `RESULTS.md`：复用规律章节（含 L1/L2/L3 结论与公式）
- `STATUS.md`：进度与待办同步
