# PIP 复用规律：可执行形式与验证（步骤 1 + 2）

日期：2026-10-25　器件：XC7VX485T-2FFG1761　数据：Vivado 2017.2 变体差分 + prjxray artix7 segbits

## 1. 结论

一个 PPIP 的落点可以完全由三因子给出，无需查表：

```
frame = block_start(col, region) + 16 + df
word  = 2*(Y % 50) + parity          # 若 ≥ 50 再 +1（跨过 ECC 字）
bit   = 形状表 bit           # 0..31，32 位字内位置
value = sense                # 1=置位，0=清位
```

- `col` = tile 名里的 X（`INT_L_X6Y11` → 6），`region` = `Y // 50`（0..6）。
- `block_start(col, region)` = 该 CLB 行带里第 col 个 block 的起始帧，读自
  `phaseA/frame_index_far.csv`。行带编号与时钟区域**不是简单反向**：
  `region → FAR 行带 = [6, 5, 0, 1, 2, 3, 4]`（实测，见 §7）。
- `df` ∈ 0..9：形状窗口在 block 内固定占 10 帧。
- `L` = mux 编号（`IMUX_L8` → 8，`IMUX8` → 8）。

三因子的角色分工：

| 因子 | 依赖 | 性质 |
|---|---|---|
| `block_start(col, region)` | 器件几何 | 设备常量（列、行带） |
| `word = 2*(Y%50) + f(mux)` | Y 与 mux | 行内位置（≥50 时后移一位） |
| `(df, bit, sense)` | tile 类型 + (mux, 源) | **tile 类型级常量** |

## 2. 验证

`pip_law.py --check` 的自检结果（逐格绝对坐标比对）：

| 数据 | tile | 规模 | 命中 |
|---|---|---|---|
| `tilepipe.json` | INT_L_X6Y11 | 36 tag × 25 源 | 2,592 / 2,592 |
| `tp3.json` | INT_L_X6Y21 | 6 tag × 25 源 | 3,024 / 3,024 |
| `tp2.json` | INT_R_X9Y11 | 36 tag × 25 源 | 2,592 / 2,592（累计 5,616） |
| `col_B1.json` | INT_L_X6Y61（行带 1） | 25 源 | 10 / 10 唯一格 |
| `band5.json` | Y=161（时钟区域 3） | 25 源 | 10 / 10 唯一格 |

**合计 5,616 个配置位 + 行带 1/3 各 10 个唯一格，0 漏报**。覆盖 INT_L/INT_R 两种类型、
Y11/Y21/Y61/Y161 四行、时钟区域 0/1/3。

行带 1 的验证同时确认了 `block_start` 的行带项：Y61 预测 26,434 帧起，实测
26,450–26,459（= 26,434 + 16…25），与 FAR 表算出的 26,230 + prefix(6)=204 完全一致。

另一条早先的追加验证落在 Y=161（时钟区域 3，FAR 行带 1）：预测 `5246*1 + 204 + 16`
= 5,466 帧起，实测窗口 5,466–5,475，GFAN0 落在 5,469/5,471/5,472/5,474，与公式
逐位一致。这条当时被记成「行带 5」，实际是区域 3 —— 正是它暴露了行带与时钟区域的
映射不是简单反向（见 §7）。

## 3. 步骤 2 的结论：列不改变形状

把 6 次列扫描（同一 mux 同一组 25 源，只换列）逐格对齐后：

| 数据文件 | 观测起始帧 | 实际 block 起点 | 对应 INT 列 | 唯一格命中 |
|---|---|---|---|---|
| `rep_C6R.json` | 31696 | 31680 | 6 | 10/10 |
| `rep_C8R.json` | 31768 | 31752 | 8 | 10/10 |
| `col_9.json` | 31804 | 31788 | 9 | 10/10 |
| `col_11.json` | 31904 | 31888 | 12 | 10/10 |
| `col_12.json` | 31940 | 31924 | 13 | 10/10 |
| `col_13.json` | 32004 | 31988 | 15 | 10/10 |

（每个文件 80 条 (frame,word,bit) 记录去重后是 10 个唯一配置位——25 个源共享这
10 个格，正是 mux 的使能/选择编码结构。10 个全部落在同一套形状上。）

**形状表在 6 个列上完全一致**，差异只来自 `block_start`（前缀差）。
之前判定的「奇偶列有两套形状」是**归一化假象**：当时用「最小帧」当原点，
而 colscan 的差分把若干「公共使能格」也带进了每个源的观测集，导致形状集被污染。
按 block 起点对齐后，两套形状归并为一套。

同时暴露一个布点陷阱：colscan 用 `SLICE_X(2*col-4)Y11` 反推列，实测
`col=11/12/13` 的落点分别对应 INT 列 12/13/15（偏移 1~2 列）。**后续受控实验必须
从 DCP 里读出 SLICE 所属的真实 tile 名，不能由 slice 序号反推。**

## 4. 覆盖范围与边界

- **全家族形状表**：`gen_all_cells.py` 把 prjxray 的 `segbits_int_{l,r}.db` 全量转成
  `all_cells.json`——**24,336 个单元 / 228 个家族**（96 个 IMUX + 132 个其它：
  BYP_ALT0-7、FAN_ALT0-7、CLK0-11、EE2BEG/EE4BEG/NE2BEG/NE6BEG/NN2BEG/NN6BEG/
  NR1BEG/NW2BEG/NW6BEG 等）。字段 `frame_off` = segbits 的 word 值，
  `frame = block_start + frame_off`；`bit` = segbits bit `% 32`（IMUX 已验证该取模）。
- 已用 Vivado 变体**实测**的 IMUX 家族：12 个 mux（L1/L2/L3/L7/L8、R7/R8 等），
  5,616 个单元 100% 命中。
- **非 IMUX 家族改用「追加 PIP + 差分」验证**（2026-10-26）：取已布通的
  `SLICE_X8Y11_A6LUT_A1.dcp`，在 net `n1` 的 PIP 列表**末尾追加**一条
  `src ->> 家族` 的 PIP，写 DCP → bitgen → 与 ref.bit 逐位差分。
  追加的 PIP 会真实写进配置位，因此差分只暴露该族的编码格。首轮 4 个家族 4/4 命中：

  | 家族 | 源 | 预测（frame, word, bit, sense） | 实测差分 |
  |---|---|---|---|
  | `BYP_ALT6` | `BYP_BOUNCE3` | (31701,23,23,1)(31705,23,23,1) + 3 个 0 格 | 恰好 31701/31705 两格 |
  | `FAN_ALT3` | `BYP_BOUNCE3` | (31700,23,24,1)(31704,23,24,1) + 3 个 0 格 | 恰好 31700/31704 两格 |
  | `EE2BEG1` | `LOGIC_OUTS_L1` | (31689,22,22,1)(31695,22,22,1) | 恰好这两格 |
  | `SE6BEG0` | `LOGIC_OUTS_L0` | (31683,22,10,1)(31686,22,10,1) | 31683 一格（另一格基线已是 1） |

  注意 `EE2BEG1`/`SE6BEG0` 的 `frame_off` 是 9/15 与 3/6——**不是 16..25**，
  说明 BEG 家族的帧偏移是另一套区间（正好推翻「全家族统一 16+df」的猜测）。
  这轮同时证实了 `parity` 规则：`BYP_ALT6`/`FAN_ALT3` 预测 word 23（bit//32=1）命中，
  `EE2BEG1`/`SE6BEG0` 预测 word 22 命中。
- **行内字奇偶 `parity` 已由打包规则给出**：prjxray 把一行两个 32 位字（2Y 与 2Y+1）
  打包进 bit 0..63，低半 `bit//32=0` 属 2Y、高半属 2Y+1。对 96 个 IMUX 家族逐一核对，
  `bit//32` 与实测得到的 `(L//4)%2` **完全一致**，故其它家族沿用同一规则；
  表中每个家族内部 parity 唯一（无混合），`all_cells.json` 已带 `parity` 字段。
  该规则已在 4 个非 IMUX 家族上实测通过（见上表），全量 124 个家族的验证见 §6。
- 行带（时钟区域）0–6 已全部做过变体对照，见 §7；`block_start` 的区域→行带映射
  由那轮实验定死，不再依赖「反向」假设。
- BRAM 列（行带 8–14，1,922 帧/带）未涉及；LUT INIT 映射另见 `IMUX_WRITE_VERIFIED.md`
  与 `lut_codec.py`。

## 5. 用法

```bash
# 查一个 PIP 的绝对坐标
python step03_pip/pip_law.py --tile INT_L_X6Y11 --mux IMUX_L8 --src GFAN0 --json

# 自检（回归）
python step03_pip/pip_law.py --check
```

## 6. 全量非 IMUX 家族实测（2026-10-26）

`all_cells.json` 里共 228 个家族，INT_L 与 INT_R 各 124 个。对两侧的
**124 个非 IMUX 家族逐一做「追加 PIP + 差分」**，每族一个变体：

- 基座：INT_L 用 `SLICE_X8Y11_A6LUT_A1.dcp`（tile `INT_L_X6Y11`，block 起点 31680）；
  INT_R 用 `right/rA1.dcp`（lut @ `SLICE_X11Y10`，tile `INT_R_X7Y10`）。
- 做法：把 `src ->> <family>` 追加进 net `n1` 的 PIP 列表 → 写 DCP → Vivado bitgen →
  与同一 DCP 重新生成的 `ref_now.bit` 逐位比对（word 50 的 ECC 位单独剔除）。
- 判定：观测到的「1 位翻转」必须全部落在 law 预测的 `sense=1` 格内，且非空。

结果：**INT_L 124 / 124 PASS、INT_R 124 / 124 PASS，合计 0 EXTRA，0 EMPTY**
（明细 `famdiff.json`、`famdiff_r.json`）。其中每侧 **122 个变体的观测集与预测集
完全相等**，2 个是真子集（该变体只翻了一部分格）。

附带一个独立验证：INT_R 基座在 Y=10，观测到的位全在 word **20/21**（144+144），
而 INT_L 基座在 Y=11 全在 word **22/23** —— 正好等于 `2*(Y%50)+parity`，
说明 word 的「块内行」部分也是对的，不只是 parity 对。

家族构成：BYP_ALT0-7、FAN_ALT0-7（各 8）、GFAN0/1、CTRL0/1、CLK0/1、LH0/LH12、
LV/LVB，以及 24 个 BEG 家族（EE2/EE4/EL1/ER1/NE2/NE6/NL1/NN2/NN6/NR1/NW2/NW6/
SE2/SE6/SL1/SR1/SS2/SS6/SW2/SW6/WL1/WR1/WW2/WW4，每个 4 个编号）——共 124。

两个结构性结论：
1. **word 二分**：恰好 62 个家族落在 word 22、62 个落在 word 23，与 `bit//32` 的
   打包奇偶完全吻合，说明 parity 规则对全部 INT_L 家族成立，不只是 IMUX。
2. **frame_off 分区（每类实测坐标与表一致）**：
   - BYP_ALT / FAN_ALT：16..25；
   - 6 步长 BEG（EE4/NE6/NN6/NW6/SE6/SS6/SW6/WW4）：2..7；
   - 2 步长 BEG（EE2/NE2/NN2/NW2/SE2/SS2/SW2/WW2）：6, 9..15；
   - 1 步长 BEG（EL1/ER1/NL1/NR1/SL1/SR1/WL1/WR1）：7, 8, 10..15；
   - 直通/时钟类（GFAN0/1、CTRL、CLK、LH0/LH12、LV/LVB）：0..1。
   不存在统一偏移；`frame = block_start + frame_off` 才是通式。
   INT_R 侧跑出完全相同的 124/124 与同样的 word 二分，说明这套分区不是左列的偶然。

至此 INT_L 与 INT_R 的全部路由家族（各 24×48 个 IMUX 格 + 124 个其它家族）
都已用 Vivado 变体实测过，不再是「从 prjxray 推断」。未覆盖：BRAM 行带 8–14、
以及同一 clock region 内 block 行偏移大于 1 的深行（每个区域只测了 1–2 个 Y）。

## 7. 行带（clock region）映射：实测修正

早先的 `band = 6 - Y//50` 只在 Y<100 时凑巧成立。七个区域各造一组变体（INT_L_X6Y，
四个家族 BYP_ALT6 / EE2BEG1 / SE6BEG0 / GFAN0，追加 PIP 法）后得到真实映射：

| clock region | Y 范围 | FAR 行带 | col6 起帧 | 观测窗口起点 | 观测 word |
|---|---|---|---|---|---|
| 0 | 0–49 | 6 | 31,680 | 31,696 | 51 / 52 |
| 1 | 50–99 | 5 | 26,434 | 26,450 | 40 / 41 |
| 2 | 100–149 | 0 | 204 | 220 | 51 / 52 |
| 3 | 150–199 | 1 | 5,450 | 5,466 | 51 / 52 |
| 4 | 200–249 | 2 | 10,696 | 10,712 | 40 / 41 |
| 5 | 250–299 | 3 | 15,942 | 15,958 | 51 / 52 |
| 6 | 300–349 | 4 | 21,188 | 21,204 | 51 / 52 |

（区域 1 与 4 的 40/41 是因为测试点了 Y=75/70、220，`2*(Y%50)` 只有 40 出头。）

### 7.1 行带与区域不是反向

`region → FAR 行带 = [6, 5, 0, 1, 2, 3, 4]`。前两个区域排在 FAR 表尾且顺序相反，
恰好在两半区交界处折返：FAR 表把 Y=0 那一半放在最后两带、且内部再倒一次。
所以「Y=0 在最上」这个直觉只在区域 0/1 内成立，不能外推。

### 7.2 字号跨 ECC 时后移一位

`word = 2*(Y%50) + parity`，当结果 ≥ 50 时再 +1。因为第 50 字是 ECC，
每个区域最上面那一行（Y%50=25，word 50/51）会让位：实测区域 0 的
BYP_ALT6 落在 **52**、EE2BEG1 落在 **51**，正是 `2*25+0=50→51`、`2*25+1=51→52`。
校验字始终是第 50 字，ECC 覆盖范围不随之平移。

### 7.3 结果

`check_bands2.py` 对 7 个区域 × 4 家族共 40 项：**32 项 EXACT、8 项 SUB**（GFAN0
每次只翻出预测格中的一部分），0 项 FAIL。即帧基址、字号、位、极性四项全对。

SUB 的成因现已定死（见 `REUSE_RULES.md` §3、§4）：**位域按 family 独占**，
所以一个预测的 `sense=1` 格没出现在差分里，只可能是**基线里已有同 family 的另一条 PIP
把它置成 1 了**（`v_GFAN0_NR1END1` 缺 `(0,11),(1,14)`，两格都只属于 `GFAN0`）。
不是形状错，也不是布线器「没写完整」。

副作用结论：ECC 只覆盖前 50 个字（word 0..49），后半帧（51..100）没有独立校验字。

## 8. 复用规则总纲（2026-10-27）

规则的最终形式、量化统计与全部实测判定已汇总到 **`REUSE_RULES.md`**，本文只留三条订正：

1. **差分有三种语义**（PURE / XOR / FAM），取决于参考流是不是删掉了 sink PIP。
   `BLOCK_ADDR_CHECK.md` 原结论 3「形状随 CLB 类型（CLBLL/CLBLM）变」是**误读**，
   真因是把 XOR 语义的差分当成了 PURE，已证伪（10 个列扫描文件每个都被唯一一组
   `(mux, S0)` 解释；跨 col 6/8/10/12 逐 wire 完全一致）。
2. **统计复用度必须用 `(frame_off, parity, bit)` 三元组**。只用 `(frame_off, bit)`
   会看到「每格被 2 个 family 共用、95 对 family 成对复用」的假象
   （`IMUX_L0` 与 `IMUX_L4` 其实是 `parity=0` 与 `parity=1` 两组不同的位）。
   正确结论：**1,598 个 cell 全部被单一 family 独占，跨 family 零共享**；
   复用发生在 family 内部——每个位平均被同 family 的 5.57 个源共用（3..18）。
3. **实测规模升级**：`tilepipe.json` 864 EXACT（原记为「一致」）、`tp2.json`（INT_R_X9Y11）
   864 EXACT、`tp3.json`（INT_L_X6Y21）144 EXACT、`tp4b.json` 36/36 个 mux 的 XOR 唯一命中、
   `famdiff`/`famdiff_r` 各 122 EXACT + 2 SUB、`_famexp.json` 22 次清零 **124/124** 落在
   `sense=0` 格上。合计 **3,270 条观测、0 反例**，一条命令复现：`python verify_reuse.py`。

另：`all_cells.json` 的 family 计数口径——**每侧 172 个 family / 3,636 个 feature**，
全器件不同 family **名** 228 个（116 个两侧同名 + 56 个仅 INT_L + 56 个仅 INT_R，
差别在 `IMUX_L*` vs `IMUX*`、`CLK_L*` vs `CLK*`、`LVB_L*` vs `LVB*`、`LV_L*` vs `LV*`）。
