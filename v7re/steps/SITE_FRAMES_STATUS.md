# Phase B / P1：CLB site_frames 生成器现状（2026-11-02）

## 1. 产物

| 文件 | 内容 |
|---|---|
| `v7re/scripts/build_site_frames.py` | `--site-addr` / `--site-frames` / `--validate` 三个入口 |
| `v7_model.sqlite: site_addr` | 75,800 行（device, site, tile_type, grid_col, inst, y, band, base_frame, word0, source） |
| `v7_model.sqlite: site_frames` | 按列分批生成；本机已验证 grid_col 19 共 600 slice / 292,200 行 |

数据源（只读）：`E:\v7work\model\v7_law.sqlite` 的 `clb_tiles`(75,900) / `clb_blocks`(763) / `clb_cells`(3,884) / `v7_verified`(98)。

## 2. 地址公式（与实现一致）

```
band  = y // 50
base  = clb_blocks[(grid_col, band)]
frame = base + frame_off
word  = 2*(y % 50) + (1 if y % 50 >= 25 else 0) + parity
bit   = law.bit                      # CLB 恒在 0..31，无需 bit//32 → word+1
inst  = slice 名 X 的奇偶（偶 → X0，奇 → X1）
```

帧长实测 **101 word**（`a.bit` 每帧 101 个 32 位字）。50 行 slice × 2 word + 1 备用 = 101，
因此 `word 0..100` 均为合法索引；`y % 50 == 49` 且 `parity == 1` 时落在 word 100。

## 3. 校验（`--validate`，全 PASS）

| 检查 | 结果 |
|---|---|
| 结构：75,900 个 slice 中 75,800 个能落到 block | PASS（缺 100 个，见 §5） |
| 锚点 `SLICE_X10Y20`：base=31716、word0=40、ALUT INIT 四帧组 [31748..31751] | PASS |
| 与 `v7_verified` 98 条实测对账 | PASS：命中定律 49、恒 0 池 1、已登记 V7 偏差 1、注释/非定律跳过 47、未命中 0 |

### 3.1 已登记的 V7 偏差（`V7_EMPTY_OVERRIDES`）

`AOUTMUX.A5Q`：artix7 定律里有位 `(30,7)`，V7 实测该特征**不占用任何配置位**
（出处 `v7_verified` 中 bit 为 NULL 的行，note："FF.Q exit needs no CLB bit
(artix7 bit7 not seen on V7); decode: AOUTMUX=null + FF present + Q used -> A5Q"）。
生成时剔除，否则每个 slice 多出 1 行假条目（全芯片 75,800 行）。
**开放项**：该 note 只在 `CLBLM_R.SLICEM_X0`（D 片）上取得实测，当前按 `*` 通配到所有
tile_type；需在 CLBLL_L / CLBLM_L 上重做同一实验后收紧或确认。

## 4. 与真实 bitstream 的位级对账（当前最强证据）

设计 `probe\SLICE_X10Y10\A6LUT\top.v`：单个 `LUT6 #(.INIT(64'h...0001))`。

`bit_base.bit`（空）与 `a.bit`（该 LUT）差分 = **10 bit，全部落在 frame 31750**：

| 差分位 | 解释 |
|---|---|
| `(31750, word 20, bit 15)` | `SLICE_X10Y10 / ALUT / INIT[00]` ✔ 与 `INIT=1` 完全一致 |
| `(31750, word 50, bits 0,1,2,3,6,7,8,10,12)` | **帧校验字**，不是配置特征（见 §4.1） |

### 4.1 word 50 定性：帧校验/ECC 字，不属配置特征

初版把这个字当成"缺失的 tile 级控制字"，**该判断已被证伪**。三条独立证据：

**(a) 相关性为 100%。** `bit_base`/`a`/`b` 三个 bitstream 中，
"含数据字的帧"与"word 50 非零的帧"完全同一集合，无一例外
（79/79、80/80、80/80）。全零帧的 word 50 恒为 0。

**(b) 值域仅 13 位。** 239 个非零样本里最大位号 12，最大值 `0x1e91 < 0x2000`；
位 11 极少出现（3/239）。这正是"12 位 Hamming + 1 位总校验"的形态，
与 3200 个数据位所需的 SECDED 校验位数目吻合（2^12 = 4096 > 3200+13）。

**(c) 远端成对实验直接证明它随帧内容重算。** 在 `xc7vx485tffg1761-2` 上固定
LOC 到 `SLICE_X10Y10` 造了 6 个设计（`/opt/lzh/v7re/work/word50/e0..e5`），
`e0` 只放 LUT，`e1` +FDRE(CE=1)，`e2` +CE 输入，`e3` +R 输入，`e4` 改 FDSE，
`e5` 换时钟源。以 `e0` 为基准做差分，**每一处数据字变化都伴随同一帧 word 50 的变化**，
且块外 word 50 差分条数（200–347）恰好等于块外有数据变化的帧数：

| 对比 | 总差分位 | 本 CLB 块内 | 块外 word 50 差分 |
|---|---|---|---|
| e0→e1 | 384 | 100 | 200 |
| e0→e2 | 584 | 110 | 347 |
| e0→e3 | 558 | 106 | 327 |
| e0→e4 | 546 | 94 | 327 |
| e0→e5 | 384 | 100 | 200 |

结论：**word 50 是每帧独立的校验/冗余字，不属于任何 slice 或 tile 特征。**
`site_frames` 跳过它是正确的，不需要补 law 行。

校验值本身**尚未解出**（尝试过 CRC32/MPEG-2 变体直接对 100 个数据字计算，均不匹配；
且简单线性假设在三组单比特样本上不自洽，说明输入还含帧地址或采用了非公开排序）。
这对"解析/反解"无影响（解码时忽略该字即可），但对"从零写 bitstream"有影响——
写回时必须保留原帧校验字或实现同一算法。详见 §7 第 1 项。

## 5. 已知数据缺口

- `clb_tiles` 中 **100 个 slice 找不到对应 `clb_blocks`**（样例 `SLICE_X13Y299` /
  `SLICE_X12Y299` / `SLICE_X13Y298`，均为 `CLBLM_L`、grid_col 20、band 5）。
  这些 slice 不进 `site_addr`，全芯片覆盖率为 75,800 / 75,900。
- `word 51..100`（`y % 50 >= 25` 的下半区）目前**只有公式外推、无实测**。
  已测锚点（`y=10/11/20/300`）全部落在上半区。

## 6. 行数与体积

单 slice 的 site_frames 行数 488–498（依 tile_type / 是否含 SLICEM 而定），
全芯片外推约 **3,715 万行 / ~2 GB**。当前库 717.6 MB（含 34 万行 site_frames）。
生成速度 ~2.9 s / 600 slice，全量约 6–8 分钟。

## 7. 下一步（按优先级）

1. **帧校验字（word 50）算法**：解码可忽略，但"从零写 bitstream"必须能重算。
   已确认它是 13 位 ECC 形态且随帧内容重算；下一步用受控单比特样本（LUT `INIT`
   单个 bit、FF 单个属性）收集"数据位 → 校验列"的映射，先拟合线性性，再判断是
   Hamming SECDED 还是含帧地址的变体。临时方案：写回时整帧复制原校验字。
2. **下半区实测**：在 `y % 50 = 27/49` 处放同一 LUT，验证 `+1` 位移与 word 100。
3. **A5Q 偏差横向复验**：CLBLL_L / CLBLM_L 各做一次 FF.Q 出口，确认全局无位。
4. 全量生成 site_frames 并与 `bit2fasm` 反解结果做端到端互校。
5. **FF 特征位**：`e0→e1` 已给出 CLB 块 6 个帧组（31716/31717/31736/31737/31746/31747）
   的 word 20/21 差分，可作为 FDRE 插入的最小对照集，用于补齐/复核 FF law。
