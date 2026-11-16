# T46：HCLK_CMT 攻坚 —— 阶段一（离线摸底）与阶段二（帧定位）进展

日期：2026-11-08
脚本：`v7re/scripts/hclk_survey.py`；数据 `v7re/steps/hclk_sources.json`

## 1. 离线摸底（阶段一，0 构建，已完成）

HCLK_CMT 模板共 **982 条 PIP / 42 个目的 wire / 72 个源 wire**。目的按源数分四档：

| 源数 | 目的数 | 目的名 | 二进制最少位 | one-hot 位 |
|---|---|---|---|---|
| 48 | 14 | `MUX_CLK_0..13` | 6 | 48 |
| 30 | 6 | `MUX_MMCM_CLKIN1/2`、`MUX_MMCM_CLKFBIN`、`MUX_PLLE2_*` | 5 | 30 |
| 16 | 4 | `MUX_CLK_LEAF_UP0/1`、`DOWN0/1` | 4 | 16 |
| 13 / 6 / 2 / 1 | 18 | `BUFMR_INP0/1`、`MUX_PHSR_PERFCLK0..3`、`MUX_OUT_FREQ_REF0..3` 等 | 0–4 | — |

**14 个 `MUX_CLK_k` 的源集合完全相同**（同一组 48 源被复制 14 份）。
48 源构成：`CCIO0..3`(4) + `CK_BUFHCLK0..11`(12) + `CK_IN4..13`(10) + `MUX_CLK_MMCM0..13`(14) + `MUX_CLK_PLL0..7`(8)。

**组内索引全部连续**（CCIO / CK_BUFHCLK / CK_BUFRCLK / CK_IN / MUX_CLK_MMCM / MUX_CLK_PLL 均连续），
说明这些名字是「按组+序号」的规范命名，不含隐藏排序信息。

### 同构判定结论

**与 INT 的「8 方向 × 端线」不同构。** INT 的 24 源来自空间方向（NE/SE/NW/SW/N/E/S/W × 端号），
而 HCLK_CMT 的 48 源来自**功能分类**（CCIO / BUFHCLK / CK_IN / MMCM 输出 / PLL 输出）。
因此不能沿用 INT 的行格/列格模型，必须独立测编码。

### 编码候选

48 源 → one-hot 需 48 位（不可能在一个字里），故候选收敛为：
- **候选 A：6 位二进制**（64 槽，16 个未用）；
- **候选 B：两级**（先选组 3 位 × 组内 3–4 位）；
- **候选 C：one-hot 分组**（每组内 one-hot，组间二进制）。

阶段三用差分直接判定，不预设。

## 2. 帧定位（阶段二，部分完成）

### 2.1 tile 清单

`get_tiles -filter {TYPE =~ "HCLK_CMT*"}` → **14 个 tile**，两列：

```
HCLK_CMT_X88Y338   ROW=26  COL=88
HCLK_CMT_L_X305Y338 ROW=26 COL=305
HCLK_CMT_X88Y286   ROW=78  COL=88
HCLK_CMT_L_X305Y286 ROW=78 COL=305
... (每列 7 个，7 个时钟区域各一对)
```

### 2.2 设计确实经过 HCLK_CMT

MMCM 设计（`pin → MMCME2_ADV → BUFG → FDRE`）的实际路由包含：

```
clk0  HCLK_CMT_L_X305Y26/HCLK_CMT_L.HCLK_CMT_MUX_CLK_MMCM0->>HCLK_CMT_CK_IN0
```

即 **MMCM 的输出经 HCLK_CMT 的 `MUX_CLK_MMCM0` 汇入 `CK_IN0`**。

### 2.3 CMT 列的帧簇

`d1`（pin→BUFG→FF）vs `d2`（pin→MMCM→BUFG→FF）差分：174 格 / 124 帧，其中
**帧 35528–35585 是 CMT 列的新增配置区**：

| 帧 | 涉及的 word |
|---|---|
| 35528, 35535 | 30 |
| 35556, 35557 | 0, 2, 30 |
| 35576–35581, 35583–35585 | 0, 1, 2, 3, 30, 31 |

差异最多的帧：35585(16 位)、35584(12 位)。这一簇同时包含 **MMCME2_ADV 的配置位**与
**HCLK_CMT 的 mux 位**——因为 d1 完全没有 MMCM，无法分离。

## 3. 当前阻塞点与下一步

**阻塞**：`BUFG` 直连设计（d1）根本不经过 HCLK_CMT（PIP 计数 = 0），
而 MMCM 设计同时引入 MMCM 自身的配置位，两者混在同一帧簇里。

**下一步（阶段三的第一步）**：用 **BUFHCE** 作为叶子时钟缓冲，构造
「BUFHCE 输入来自 BUFG」vs「BUFHCE 输入来自 MMCM 输出」两个设计。
两者 MMCM 都已存在（或都不存在），MUX_CLK_k 的选择不同——差分里的 CMT 簇差异即属于
`MUX_CLK_k` 的选择位。

已知需要规避的坑：
1. `PLLE2_ADV` **没有** `CLKOUT0B/CLKOUT1B` 端口（我按 MMCM 的写法写错了）；
2. `BUFHCE` 的 `CE` 若为常量会被综合删除（T43 §8 已记录）；
3. 端口未使用会被裁掉，`set_property PACKAGE_PIN` 会因此报「no objects」——设计里每个端口都要真用。

## 4. 负结果记录

| 假设 | 结果 | 证据 |
|---|---|---|
| 换输入引脚会改变 HCLK_CMT 的 mux 选择 | **否** | `ma`(AF25) 与 `mb`(AN33) 用的是同一条 PIP `MUX_CLK_MMCM0->>CK_IN0` |
| 纯 BUFG 设计会经过 HCLK_CMT | **否** | `d1.pips` 中 HCLK_CMT 计数 = 0 |
