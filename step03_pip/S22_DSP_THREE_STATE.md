# S22 —— DSP 端口选择位：三态编码实测（2026-11-08）

## 结论先行

1. **DSP 的端口源选择（GND / VCC / 走线）在 DSP 配置帧内，是一个 2-胞编码 + 隐含的第三态（两胞全 0 = 走线/BYP）**。
2. **artix7 的 DSP 表在 V7 上逐位精确**：`DSP_0_D0` 的 GND/VCC 两个 cell 与实测完全一致。
3. **不存在单独的“DSP tile 布线 PIP 层”**：先前在 `31960..31987` 内看到的 166 位变化，来自与该 28 帧块同槽位的 INT tile，而不是 DSP tile 的 PIP（4 个设计的 DSP tile 活跃 PIP 集合完全相同）。

## 实验：D[0] 三态

三个设计只差 `D[0]` 的来源，其余全固定（`DSP48_X0Y0`、`USE_DPORT=TRUE`、`INMODE=5'b00101`、`OPMODE=7'b0000101`、DRC 全豁免）：

| 设计 | `D[0]` |
|---|---|
| `d1_gnd` | 常量 0 |
| `d1_vcc` | 常量 1 |
| `d1_port` | 顶层端口（走线 = BYP） |

### 差分结果（只在配置帧，另有 word50 校验字变化）

| 对比 | 关键 cell |
|---|---|
| GND → VCC | `(31986, w2, b1)` 1→0；`(31987, w2, b0)` 0→1 |
| GND → PORT | `(31986, w2, b1)` 1→0 |
| VCC → PORT | `(31987, w2, b0)` 1→0 |

⇒ 三态编码表（`base = 31960`，故 `frame_off` 26 / 27）：

| 状态 | `(off26, w2, b1)` | `(off27, w2, b0)` |
|---|---|---|
| GND（接 0） | **1** | 0 |
| VCC（接 1） | 0 | **1** |
| BYP（走线驱动） | 0 | 0 |

### 与参考表对照（逐位命中）

```
segbits_dsp_l.db:  DSP_L.DSP_0_D0.DSP_GND_L 26_65   → off26, word 2, bit 1
                   DSP_L.DSP_0_D0.DSP_VCC_L 27_64   → off27, word 2, bit 0
```
（格式 `off _ frame内bit`，`word = bit//32`）——**两胞与实测完全相同**。

## 对“DSP tile 是否有布线 PIP”的判定

4 个设计（不同 IOB：AF24 / AP27 / AN27 / AP26）在建 `DSP_L_X14Y0` 内导出的活跃 PIP：

```
pips listed: 794     active: q1=68 q2=68 q3=68 q4=68     （四者完全相同的 68 条）
```

794 条 pip / 638 个家族，其中：
- **560 个家族只有 1 个源**（= 固定脚连接，如 `DSP_IMUX23_0 → DSP_0_A0`）；
- **78 个家族有 3 个源**：`{DSP_BYPk_m, DSP_GND_L, DSP_VCC_L}` —— 正是本文实测的三态家族，V7 比 artix7（只有 GND/VCC 两源）**多出的第三源就是 `DSP_BYPk_m`**（走线），在编码上退化为两胞全 0。

⇒ 4 个设计该 tile 的活跃 PIP 完全相同 ⇒ 先前 `31960..31987` 内的 166 位差异不属于 DSP tile，而属于与该 28 帧块共用槽位的 INT tile（`INT_L_X14` / `INT_R_X15` 一带）。**DSP 输入走线的选择不产生 DSP 侧 PIP 位**，最后一级固定在 INT tile 的 IMUX（`IMUX_L23 → DSP_0_A0`）。

## 与 INT 编码律的关系

| | INT PIP 家族 | DSP 端口家族 |
|---|---|---|
| 源数 N | 12 / 16 / 18 / 20 / 24 | 2 显式 + 1 隐含（BYP） |
| 位池 K | a+b（7–10） | **2** |
| 每源置 1 位 | 2 或 4 | **1**（隐含态 0 位） |
| 隐含态 | 空源（VCC_WIRE） | **两胞全 0 = 走线驱动** |

两者是同一模型的两种退化：INT 是多级 one-hot，DSP 是单级 one-hot + 全零态。

## 抽检：4 个三态家族（12 个设计，全部构建成功）

设计命名 `sp_{CEAD,RSTD,D1,INMODE0}_{gnd,vcc,port}`，唯一变量即被测端口。

| 家族 | 实测 GND cell | 实测 VCC cell | 表预测 | 结论 |
|---|---|---|---|---|
| `DSP_0_CEAD` | `(off26, w1, b31)` | `(off27, w1, b30)` | `[26,1,31]` / `[27,1,30]` | **逐位一致** |
| `DSP_0_RSTD` | `(off27, w3, b0)` | `(off27, w2, b21)` | `[27,3,0]` / `[27,2,21]` | **逐位一致** |
| `DSP_0_D1` | `(off27, w2, b4)` | `(off27, w2, b10)` | `[27,2,4]` / `[27,2,10]` | **逐位一致** |
| `DSP_0_INMODE0` | `(off27, w4, b6)` | `(off27, w4, b2)` | `[27,4,6]` / `[27,4,2]` | **逐位一致** |

三态行为完全同构（以 CEAD 为例，忽略 w50 校验字）：

```
GND -> VCC : (26,w1,b31) 1->0      (27,w1,b30) 0->1
GND -> PORT: (26,w1,b31) 1->0
VCC -> PORT:                        (27,w1,b30) 1->0
```

即 4 个家族都是「GND 一胞 / VCC 一胞 / 走线=两胞全 0」，与 `DSP_0_D0` 同构。
**累计：5 个三态家族（D0 / CEAD / RSTD / D1 / INMODE0）全部 2 胞 + 零态，且与 artix7 表逐位一致。**

## 单源家族（560 个）

`DSP_L_X14Y0` 的 638 个家族中 560 个只有 1 个源（`DSP_IMUXk_m → DSP_0_Xx` 这类固定脚连接）。它们**没有可选源 ⇒ 无配置位**，属 always-on 连接（与 INT 的 ppip 同类）。旁证：S21 中把同一个 DSP 输入改由不同 IOB（AF24/AP27）驱动后，DSP 配置帧 `31986/31987` **差异为 0**。

## 尚未验证

1. `DSP_1_*` 一侧的 cell 偏移（表里有，但本设计里第二个 DSP site 未激活）。
2. 78 个三态家族里已验 5 个，其余 73 个仍按“表可信”使用（未逐个实测）。

## 复现
```bash
for j in gnd vcc port; do JOB=$j vivado -mode batch -source /opt/lzh/step05/dsp/build_d1.tcl; done
python3 /opt/lzh/step05/dsp/diff_bit.py d1_gnd.bit d1_vcc.bit
```
