# T31：精确判据接入主解码路径（decode_law.py）

日期：2026-11-07
改动文件：`v7re/export/decode_law.py`

## 1. 改了什么

| 项 | 改动前 | 改动后 |
|---|---|---|
| INT PIP 判据 | 候选源的全部 sense=1 格为 1（all-ones） | 该 family 位域读数与候选 pattern **完全相等** |
| EXACT / WEAK 分档 | 按格数是否 ≥ `--min-cells`（默认 4） | 不再需要；精确判据下所有命中都是 EXACT |
| GCLK 直通 | 不还原 | 用使能位 `(0,1,16)` + `CLK_L*` 选中源合成真实 PIP |
| 旧判据 | 唯一路径 | 保留为 `--legacy-allones`（配合 `--min-cells` / `--require-zero`），仅供对照 |

## 2. 为什么新的判据没有歧义

跨 family 零共享（1,598 / 1,598 个 cell 各自只属于一个 family），
所以一个 family 的位域里只可能出现本族的位：

- 该族有一条 PIP 在用 → 位域读数 = 该源的 pattern；
- 该族没有 PIP 在用 → 位域读数 = 全 0。

「恰好相等」因此既充分又必要。旧判据只要求「候选源的格全为 1」，
于是同族内 pattern 为真子集的源会一起命中——这类关系有 **1,632 对、涉及 70/172 个家族**。

## 3. 三种口径在同一份位流上的对照（`_full8.bit`，真值 198 条）

| 口径 | 解码条数 | 命中 | 误判 | 漏判 | 精确率 | 召回率 |
|---|---|---|---|---|---|---|
| 旧判据 EXACT+WEAK（接受 WEAK） | 268 | 190 | 78 | 8 | 70.9% | 96.0% |
| 旧判据 仅 EXACT（`--min-cells 4`） | 39 | 39 | 0 | 159 | 100% | 19.7% |
| **新判据（精确匹配）** | **190** | **190** | **0** | **8** | **100%** | **96.0%** |

新判据同时拿到「旧的 EXACT 的精确率」和「旧的 EXACT+WEAK 的召回率」。

其他设计复核（`decode_law.py` 输出直接与 Vivado 路由对账）：

| 设计 | 解码 | 真值 | 命中 | 多 | 漏 | 精确率 | 召回率 |
|---|---|---|---|---|---|---|---|
| `_c0.bit` | 25 | 27 | 25 | 0 | 2 | 100% | 92.6% |
| `_c4.bit` | 36 | 39 | 36 | 0 | 3 | 100% | 92.3% |
| `_full8.bit` | 190 | 198 | 190 | 0 | 8 | 100% | 96.0% |

与独立实现 `v7re/scripts/decode_exact.py` 的 190 条**逐条相同**（两套实现交叉验证）。

## 4. GCLK 直通还原

时钟 tile 在 `(frame_off=0, parity=1, bit=16)` 置 1，这是「本 tile 有 GCLK 接入」的使能位，
不编码线号；线号在同 tile 的 `CLK_L*` family 的选中源里（`GCLK_L_B11_WEST`）。
两条信息合成真实 PIP `GCLK_L_B11 ->> GCLK_L_B11_WEST`：每个时钟设计因此各 +1 条
（`_c0` 24 → 25，`_c4` 35 → 36）。

## 5. 保留的兼容性

- `--ref` 行级差分、CLB 特征解码（`CLB_SET`）路径未改动，冒烟测试通过；
- 输出 CSV 五列结构不变（`tile, family, src, pattern, cells1`），
  下游 `bit2fasm` 无需改解析；
- `--legacy-allones` 保留，便于回归对照。

## 6. 仍未覆盖

漏判全部来自 8 个未建模的旁路/扇出直通族
（`BYP_BOUNCE0/1/3/4/5`、`BYP_L1`、`FAN_BOUNCE7`、`FAN_L7`），属**未测**。
补测只需两个构建（BYP 走 bounce / 不走），待机器空出后插队。

## 7. 复现

```bash
python v7re/export/decode_law.py _full8.bit --out _full8_exact.csv --no-clb
python v7re/export/decode_law.py _full8.bit --legacy-allones --out _full8_legacy.csv --no-clb
```
