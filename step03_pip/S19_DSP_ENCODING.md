# S19 —— DSP48E1 编码在 V7 485T 上的实测验证（2026-11-08）

目标：回答“PIP 编码律在 DSP 上是否成立”。结论：**成立，且 artix7 的 DSP 配置表可原样迁移到 V7**（39/39 家族唯一命中、0 歧义；4 个 AREG 位逐位对上）。

## 1. DSP 配置块的位置（V7 实测）

三个对比位流（只改 DSP48E1 的 `AREG`，其他一切固定）：

| 对比 | 差异帧 | 差异内容 |
|---|---|---|
| AREG 0 → 1 | `31986` w3、w4（+ w50 ECC） | w3 清 bit17；w4 清 bit9 |
| AREG 1 → 2 | `31987` w3、w4（+ ECC） | w3 清 bit15；w4 **置** bit8 |

表预测（artix7 `segbits_dsp_l.db`）：
- `DSP_0_AREG_0 = [26_113, 26_137, 27_111]`，`DSP_0_AREG_2 = [27_136]`，格式 `frame_off _ bit`，`word = bit//32`。
- 若 `base = 31960`，则 → `(31986,3,17)`、`(31986,4,9)`、`(31987,3,15)`、`(31987,4,8)`。

**四条位全部命中**：AREG 0→1 正好清掉前两条，1→2 正好清掉第三条并置上第四条。

⇒ **DSP48E1 配置块 = 28 帧（base…base+27），基址 31960（DSP48_X0Y0）；DSP 的全部配置位落在最后两帧 base+26、base+27 的 word 0..9**。

## 2. 编码律在 DSP 上是什么形态

从 artix7 `segbits_dsp_l/r.db` 统计：

| 类别 | 数量 | 编码形态 |
|---|---|---|
| 二选一 mux 家族（`DSP_0_CEAD`、`DSP_0_D0`…，源 `DSP_GND_L`/`DSP_VCC_L`） | **78** | 每源 **1 位**，池 K=2，N=2 → 单层 one-hot（1 级） |
| 普通属性位（`MASK[0..47]`、`PATTERN[0..47]`、`IS_*_INVERTED`、`USE_DPORT` 等） | 280 | 1 位 = 1 个语义位，非 mux |

对比 INT tile（多级 mux，K=Σ、N=∏、每源 2 或 4 位）：
**同一个“位池 + 分级 one-hot”模型，强度只有 1 级**——因为 DSP 内部的 mux 都是 2 选 1（GND/VCC）。

## 3. 绝对位验证（不是差分）

用真实 V7 位流（AREG=0，CEAD=1 等）在 `base=31960` 上逐个家族判读：

```
families 78  unique-match 39  ambiguous 0  no-match 39
side histogram: NONE 39, DSP_GND_L 35, DSP_VCC_L 4
```

- **命中的 39 个全是 `DSP_0_*`**，且与设计属性一致：`CEAD/CEALUMODE/CED/CEINMODE` → VCC（我们接 1），`ALUMODE2/3、CARRYINSEL2` → GND（我们接 0）。
- **未命中的 39 个全是 `DSP_1_*`**：该 tile 的第二个 DSP site 未被使用，配置位是默认值，所以 GND/VCC 两个模式都不满足——这是**预期行为**，不是解码错误（要证实需再建一个用 DSP48_X0Y1 的设计）。

⇒ 位池模型、`frame_off+word/bit` 地址换算、GND/VCC 极性，在 DSP 上**逐位正确**。

## 4. DSP 与 INT 的“律”对照

| 项 | INT tile PIP | DSP48E1 |
|---|---|---|
| 块大小 | 36 帧（34 数据 + 2 overhead） | **28 帧**（配置集中在 base+26/27） |
| 位池 | 家族私有，3–18 源共 7–10 cell | 家族私有，**恒 2 cell / 2 源** |
| 编码 | 分级 one-hot，K=Σ、N=∏，每源 2/4 位 | 单级 one-hot，每源 **1 位** |
| 极性 | 正负混用 | GND/VCC 各占一位（均为“置 1”语义） |
| 默认态 | 空源常见 | 未用 site 全 0 |

## 5. 构建约束（踩到的坑，供复现）

- `DSP48E1` 的 `AREG` 与 `ACASCREG` 必须同值，或 `AREG=2 + ACASCREG=1`，否则 `ERROR: [DRC AVAL-2]`，bitgen 不跑。
- 端口名：`M`、`CARRYOUTF` 在 2017.2 的 unisim 里**不存在**（`ERROR: [Synth 8-448]`），只连 `P` 即可。
- 必须豁免 `NSTD-1 / UCIO-1 / DPIP-1 / DPOP-1 / DPOP-2 / REQP-20/24/29/30/31 / AVAL-4`，否则 `Vivado 12-1345` 阻断 bitgen。
- 位流解析必须**大端**，且先验证 FDRI burst = 帧数 × 101。

## 6. 尚未验证

1. `DSP_1_*` 的基线（需用 `DSP48_X0Y1` 建一个设计再跑同一张表）。
2. DSP 输入 mux（A/B 从 INT 线来）不在 DSP tile 内，属于 INT tile 的 `DSP_*` 端点，尚未纳入。
3. BRAM 的同类验证（BRAM 配置块显然远大于 28 帧：INIT 区就横跨 128 帧，见 S17）。
