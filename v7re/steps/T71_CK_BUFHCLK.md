# T71：HCLK_CMT 的 CK_BUFHCLK 源编码（12 源全测）

日期：2026-11-10　器件：`xc7vx485tffg1157-3`　远端 `/opt/lzh/v7re/work/hb3`，本地 `_hb3_out/`

## 1. 怎么把 CK_BUFHCLK 逼出来

先前 T50 证明「BUFH→FF」根本不经过 HCLK_CMT（`d0/d1/d2` 三个设计 PIP 里 `HCLK_CMT` 计数 **0**）。
能逼出 CK_BUFHCLK 的构造是**让 BUFH 时钟去喂 MMCM 的 CLKIN1**：

```
pin → IBUF → BUFHCE → MMCME2_ADV.CLKIN1 → CLKOUT0 → FDRE
```

这样 Vivado 必须把区域时钟送进 CMT，于是出现：

```
HCLK_CMT_X88Y338/HCLK_CMT.HCLK_CMT_CK_BUFHCLK0->>HCLK_CMT_MUX_MMCM_CLKIN1
HCLK_CMT_X88Y338/HCLK_CMT.HCLK_CMT_MUX_CLK_MMCM0->>HCLK_CMT_MUX_CLK_0
```

（`e0`/`e1` 各 2 条 HCLK_CMT PIP。）

## 2. 12 个源：改 BUFHCE 站点即可逐个命中

`MMCME2_ADV_X0Y6` 所在 clock region `X0Y6` 内共 12 个 BUFHCE：`BUFHCE_X0Y72..Y83`。
依次把 `LOC` 换成这 12 个站点点，构建 12 份位流，每份的 `.pips` 里 CK_BUFHCLK 编号与站点一一对应：

| BUFH 序号 | 站点 | CK_BUFHCLK |
|---|---|---|
| 0 | `BUFHCE_X0Y72` | `CK_BUFHCLK0` |
| 1 | `BUFHCE_X0Y73` | `CK_BUFHCLK1` |
| 2 | `BUFHCE_X0Y74` | `CK_BUFHCLK2` |
| 3 | `BUFHCE_X0Y75` | `CK_BUFHCLK3` |
| 4 | `BUFHCE_X0Y76` | `CK_BUFHCLK4` |
| 5 | `BUFHCE_X0Y77` | `CK_BUFHCLK5` |
| 6 | `BUFHCE_X0Y78` | `CK_BUFHCLK6` |
| 7 | `BUFHCE_X0Y79` | `CK_BUFHCLK7` |
| 8 | `BUFHCE_X0Y80` | `CK_BUFHCLK8` |
| 9 | `BUFHCE_X0Y81` | `CK_BUFHCLK9` |
| 10 | `BUFHCE_X0Y82` | `CK_BUFHCLK10` |
| 11 | `BUFHCE_X0Y83` | `CK_BUFHCLK11` |

12/12 全部命中，**顺序严格等于站点序号**。

## 3. 位编码：2 个半区 × 6 个槽位

把 12 份位流与序号 0 基准差分，再取 CMT 配置簇（帧 22144–22149）内的 **word 48**：

| 序号 | 站点 | 置位格 |
|---|---|---|
|  0 | `BUFHCE_X0Y72` | `(22146,48,21) + (22146,48,26)` |
|  1 | `BUFHCE_X0Y73` | `(22146,48,21) + (22147,48,25)` |
|  2 | `BUFHCE_X0Y74` | `(22146,48,21) + (22146,48,25)` |
|  3 | `BUFHCE_X0Y75` | `(22146,48,21) + (22147,48,24)` |
|  4 | `BUFHCE_X0Y76` | `(22146,48,21) + (22146,48,24)` |
|  5 | `BUFHCE_X0Y77` | `(22146,48,21) + (22147,48,23)` |
|  6 | `BUFHCE_X0Y78` | `(22147,48,21) + (22146,48,26)` |
|  7 | `BUFHCE_X0Y79` | `(22147,48,21) + (22147,48,25)` |
|  8 | `BUFHCE_X0Y80` | `(22147,48,21) + (22146,48,25)` |
|  9 | `BUFHCE_X0Y81` | `(22147,48,21) + (22147,48,24)` |
| 10 | `BUFHCE_X0Y82` | `(22147,48,21) + (22146,48,24)` |
| 11 | `BUFHCE_X0Y83` | `(22147,48,21) + (22147,48,23)` |

规律：

- **半区位**：序号 0–5 置 `(22146, 48, 21)`；序号 6–11 置 `(22147, 48, 21)`。同一 bit、相邻两帧 ⇒ 半区。
- **槽位格**（6 选 1，两个半区共用同一组格）：
  `s0=(22146,26)  s1=(22147,25)  s2=(22146,25)  s3=(22147,24)  s4=(22146,24)  s5=(22147,23)`
- 即 `序号 = 6 × 半区 + 槽位`，`站点 Y72+k` → `半区 = k // 6`、`槽位 = k % 6`。

与 INT mux 完全同构的「两帧交替 + one-hot 槽位」形态，只是槽位数是 6 而不是 4。

## 4. 与 MMCM/PLL 源的关系

同一块位流里还有 `MUX_CLK_MMCM0 ->> MUX_CLK_0`，说明 48 源 mux（`CK_INk`）与 30 源 mux（`MUX_MMCM_CLKIN1`）是**两个不同的选择网络**：

| 网络 | 目的 | 源数 | 本轮状态 |
|---|---|---|---|
| `MUX_MMCM_CLKIN1` | MMCM 时钟输入 | 30 | **CK_BUFHCLK 12 源已解** |
| `CK_IN0..13` | 时钟网络输入 | 48 | MMCM/PLL 子集已解（T48/T49/T70） |

## 5. 边界

- 只测了 `X0Y6` 这一个 CMT 区域；按 T70 结论编码只随列/类型变，但 **CK_BUFHCLK 的 12 个槽位是否与区域绑定**（即同 region 内 12 个 BUFHCE 是否恒为 slot 0..5 × 半区）尚未跨区域验证。
- CCIO（4 源）与 `MUX_CLK_4..13` 链式源（10 源）仍未测。
- `MUX_MMCM_CLKIN1` 的 30 源里其余 18 源没有覆盖。

## 6. 复现

```bash
export LANG=C LC_ALL=C          # 必须！否则 Vivado 2017.2 报 locale::facet::_S_create_c_locale
cd /opt/lzh/v7re/work/hb3 && vivado -mode batch -notrace -source h00.tcl
```

坑：`LANG` 未设为 C 时 vivado 直接 `Aborted (core dumped)`，日志只有
`locale::facet::_S_create_c_locale name not valid`。
