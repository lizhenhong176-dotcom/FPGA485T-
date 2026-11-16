# PIP 覆盖盘点：哪些测了、哪些没测

日期：2026-11-10　数据：`v7_routing.db` 的 `tile_types`（实例数 × 每 tile PIP 数）+ `v7_law.sqlite`

## 1. 按「PIP 实例数」看全局

全器件可配置 PIP 实例 **207,253,149** 条。分布极不均衡：

| tile_type | 实例数 | PIP/个 | PIP 实例 | 占比 |
|---|---|---|---|---|
| **INT_L** | 26,550 | 3,737 | 99,217,350 | **47.9%** |
| **INT_R** | 26,550 | 3,737 | 99,217,350 | **47.9%** |
| CLBLM_R | 17,000 | 151 | 2,567,000 | 1.24% |
| CLBLM_L | 15,700 | 151 | 2,370,700 | 1.14% |
| DSP_L | 770 | 794 | 611,380 | 0.29% |
| BRAM_R | 550 | 974 | 535,700 | 0.26% |
| DSP_R | 630 | 794 | 500,220 | 0.24% |
| BRAM_L | 480 | 974 | 467,520 | 0.23% |
| CLBLL_L | 3,100 | 146 | 452,600 | 0.22% |
| CLBLL_R | 2,150 | 146 | 313,900 | 0.15% |
| 其余 60+ 类型 | — | — | ~8,000,000 | ~4% |

**INT_L + INT_R = 95.7% 的 PIP 实例。** 这也是为什么把 INT 做透就等于做透了绝大部分器件。

## 2. 已覆盖

| 范围 | 状态 | 依据 |
|---|---|---|
| INT_L / INT_R 的 172 个 family、3,634 条 feature | **100% 位坐标已知、0 不符** | `verify_all_pip.py` |
| 其中 mux 区 64 族 | 生成式定律，1,536/1,536 | `pip_reuse_law.py` |
| 其中 BEG 96 族 + 时钟树 12 族 | 结构解出，2,098/2,098 | `beg_families.json` |
| 同规则性 | 12,565 个 INT 实例零残差 | `all_int_tiles_check.py` |
| 左右对称 | INT_L/INT_R 172/172 格集合相同 | T66 |
| GCLK 直通使能位、BUFGCTRL 32 site、时钟 mux | 已测并接入编解码 | T5/T41–T45 |

## 3. 未覆盖（按缺口大小）

| 缺口 | 规模 | 现状 |
|---|---|---|
| **CLB 站内 PIP**（CLBLM_L/R、CLBLL_L/R） | 149 个 PIP/型、5.7M 实例 | 只测了 LUT INIT 与 FF.INIT，站内 151 条路由 PIP 未测 |
| **DSP 站内 PIP** | 794/型、1.1M 实例 | 只做了 9 个 CE 属性的 spot check（T63），794 条里约 437 条是配置 PIP |
| **BRAM 站内 PIP** | 974/型、1.0M 实例 | 只做了 8 个使能/复位引脚（T64） |
| **CLK_HROW_BOT/TOP_R** | 2,840 PIP/型、56 个实例 | 0 覆盖 |
| **HCLK_CMT 的 48 源 mux** | 982 PIP/型 | 只测 13 个源（MMCM 7 + PLL 6），第二级编码未闭合 |
| **HCLK_L/R、HCLK_IOI、HCLK_*_UTURN** | 200–244 PIP/型 | 0 覆盖 |
| **IOI / IOB**（LIOI 467、RIOI 467、LIOI_SING 222…） | ~0.12M 实例 | 只有 IOSTANDARD 的 7 位 spot check |
| **PCIE_BOT/TOP**（1,736 / 441 PIP） | — | 0 覆盖 |
| **GTX_CHANNEL_0..3、GTX_COMMON、GTX_INT_INTERFACE** | 628×4 + 133 + 168 | 0 覆盖 |
| **CMT_TOP_***（MMCM/PLL 站内） | 155–387 PIP/型 | 0 覆盖 |
| **CFG_CENTER_TOP/MID/BOT** | 285 / 38 / 13 | 0 覆盖（配置中心，可能含 CRC/回读控制） |
| **MONITOR_***（温度/电压传感器） | 117 / 12 / 8 | 0 覆盖 |
| **INT_INTERFACE / BRAM_INT_INTERFACE / IO_INT_INTERFACE** | 24 PIP/型 | 定位到 tile 了（A 类单源），未系统性测 |

## 4. 缺口的结构性判断

- **INT 之外的 tile 大多是 one-hot**：DSP 852 源里 428 单格、BRAM 350 源里 220 单格、
  CLB 1,282 源几乎全单格（`tile_pip_lawscan` 的统计）。**没有复用问题，所以"没测"的代价小**。
- 真正还有复用、且没测完的只剩两处：**HCLK_CMT 的 48 源 mux**（13/48 已测）
  与 **CLK_HROW / HCLK_* 的时钟树网**（200–2,840 PIP 的密集多源）。
- **PCIE / GTX / CFG_CENTER / MONITOR** 属于"要么用不到、要么不该由逆向碰"的部分：
  它们含掉电/复位/回读等控制位，测错会锁死配置通道。

## 5. 优先建议

| 优先级 | 目标 | 理由 | 成本 |
|---|---|---|---|
| 高 | CLB 站内 151 条 PIP（CLBLM/CLBLL） | 5.7M 实例，且 LUT 输出到站内布线的必经之路 | 每型约 10 个构建 |
| 中 | CLK_HROW 的 2,840 PIP | 时钟树关键，且是密集多源（可能又有复用） | 需构造 BUFG→HROW→不同 HCLK 的设计 |
| 中 | CMT_TOP_* 站内 | MMCM/PLL 参数配置位，做 PLL 重配必须 | 每型 5–8 构建 |
| 低 | HCLK_CMT 剩余 35 源 | 真实设计基本不出现 | 需跨区域设计 |
| 不做 | PCIE / GTX / CFG_CENTER / MONITOR | 风险高、收益低 | — |
