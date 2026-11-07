# T23 —— LUT INIT 索引顺序随 slice 种类不同：SLICEM 与 SLICEL 各有一套

日期：2026-11-07　器件：`xc7vx485tffg1157-3`　差分语义：PURE

## 1. 背景与动机

T19 在 `SLICE_X12Y20`（CLBLM_R inst0 = **SLICEM** 切片）用 64 个单最小项构建测出了 LUT INIT 的 `索引 → (frame_off, word, bit)` 表，并给出闭式公式。T13 的表是在**未加 LOCK_PINS** 的同一位置测的，T18 证明其索引被 I0..I5 置换污染，于是「law 库里的 INIT 表不可用于真实设计」成了工作假设。

问题：law 库 `v7_law.sqlite` 的 `clb_cells` 里 INIT 行（`src_wire = INIT[00..63]`）只有 12 个 family，且 `frame_off` 落在 26..35。若直接按 T19 表去替换，输出会变；若 law 表本来就对，替换就是空操作。必须先判定「law 的 INIT 索引顺序到底错没错」，而且要按 **slice 种类** 分别判定。

## 2. 事前可证伪假设（构建前写下）

- H1：`SLICEM` 切片的 INIT 索引顺序 == T19 实测表（law 与 T19 一致）。
- H2：`SLICEL` 切片的 INIT 索引顺序与 T19 表**不同**，但 law 的 SLICEL 行是对的（即两套顺序都各自正确）。
- 判据（集合级，禁抽样）：把 `SLICE_X11Y20` 的 A6LUT 从 `INIT=0` 改成 `0xDEADBEEFCAFEBABE`，实测置位点集合必须与「law SLICEL 顺序」预测集合 **全等**（missing=0 且 extra=0）；同时与「T19 SLICEM 顺序」预测集合不等（帧集合可能相同，但位分布不同）。
- 判失败：若实测同时与两套顺序全等（说明该位置分辨不出顺序），或与两套都不等（说明两边都错，需要重测）。

## 3. 构建（3 个，`/opt/lzh/v7re/work/t23/`，5 路并行池中跑 3 路）

| build_id | role | INIT | 回读 SITE / BEL / PART |
|---|---|---|---|
| `l0_y20` | baseline | `64'h0000000000000000` | `SLICE_X11Y20` / `SLICEL.A6LUT` / `xc7vx485tffg1157-3` |
| `lr_y20` | variant | `64'hDEADBEEFCAFEBABE` | 同上 |
| `l0b_y20` | negative_control | `64'h0000000000000000` | 同上 |

固定条件：`LOC SLICE_X11Y20`（属 `CLBLM_R` 的 inst1 → `SLICEL_X1`）、`BEL A6LUT`、`LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}`、`DONT_TOUCH`、`place_design` + `route_design`、显式 `-part`。三个构建 rc=0，bit 均为 20,273,538 字节。

> 选 `X11Y20` 而不是 `X12Y20` 的原因：`clb_blocks[(19,0)] = 31716`，`X11Y20` 的 `SLICEL_X1` INIT 组基址是 `31716+26 = 31742`，与 T19 的 `X12Y20`（`31752+32 = 31784`）是**不同的 block**，顺带验证了「组基址由 block + slice 种类决定」。

## 4. 结果

**【数据事实】** 差分帧 = 4：`31742 / 31743 / 31744 / 31745`（= `31716 + 26..29`），与 law 的 SLICEL INIT `frame_off` 集合一致。

**【数据事实】** 内容位全部落在 word 40 的 bit 0..15，共 46 位，每帧 10 / 15 / 14 / 7；word 50 有 14 位 ECC 变化。

**【数据事实】** 与 law SLICEL 顺序预测：46/46 全等（symmetric-diff = 0）。
**【数据事实】** 与 T19 SLICEM 顺序预测：帧集合相同，但位分布不同（不等）。

**【数据事实】** 负对照 `l0_y20` vs `l0b_y20`：0 帧 0 位。

## 5. 结论

- 【数据事实】`SLICEM` 与 `SLICEL` 的 LUT INIT 索引顺序**不同**；law 库对两者都正确，T19 表只对 SLICEM 成立。
- 【推断】差异来自两种切片的 LUT6 输入到 BEL 引脚的对应关系不同（`SLICEM` 的 A1..A6 与 `SLICEL` 的 A1..A6 在 `INIT` 索引里排列不同），而不是 law 表写错。
- 两套顺序互为仿射输入置换：`p(k) = 0x8 ^ (b0*0x1 ^ b1*0x2 ^ b2*0x4 ^ b3*0x9 ^ b4*0x10 ^ b5*0x20)`（`b_i = (k>>i)&1`）。该关系由 `step03_pip/gen_locked_init_map.py --check` 机检。

## 6. 落地（代码改动，均在工作区）

1. `step03_pip/gen_locked_init_map.py`（新建）：由 T19 JSON + law 生成权威表 `v7re/steps/clb_init_locked_map.json`，含 `orders.{SLICEM,SLICEL}`、`bel_rule`、`group_off`、仿射 `permutation` 与 `measurements`（SLICEL 由本实验打 `matched=True`）。
2. `v7re/scripts/build_site_frames.py`：`load_law` 现在给每个 `(tile_type, inst)` 打 slice 种类标签；`emit_site_frames` 对 INIT 特征走按种类的实测表（`source` 标 `+locked:T19`），非 INIT 特征仍走 law；新增 `validate_locked_init()` 做 T19 锚点 + T23 锚点 + law 全库顺序对账；`--no-locked-init` 可回退做差分对照。
3. `step03_pip/test_locked_init_map.py`（新建）：T1 映射一致、T2 互换两套表后自检必须 FAIL（负对照）、T3 接入前后输出集合差异 0（1024 条锁定 INIT 行）、T4 交叉佐证 T21/T22 的 word 42/53 与四 bel 同帧组。

实跑：`python v7re/scripts/build_site_frames.py --validate` → `VALIDATE: PASS`；`python step03_pip/test_locked_init_map.py` → `RESULT: PASS`。

## 7. 覆盖边界（未测即写未测）

- SLICEL 顺序只在 `SLICE_X11Y20`（一个 block、一个 clock region、一个 BEL）测过；**跨列、跨 band、跨 `CLBLL_*`（另一类 tile）未直接测**，只靠 law 全库顺序对账（6 个 `(tile_type,inst)` 与实测表逐索引相等）间接支持。
- SLICEM 顺序沿用 T19（`SLICE_X12Y20`）+ T21（四 bel）+ T22（`Y%50=26`），已在 3 个位置/3 行验证；`CLBLL_*` 的 SLICEM 未单独测（该 tile 类型无 SLICEM）。
- `word = 2*(Y%50)+parity`（≥50 再 +1）已实测 `Y%50 ∈ {20,21,26}`；其余取值按公式外推。
- 地址 `frame_off` 的绝对帧号只在校验过的锚点（`X10Y20 / X11Y20 / X12Y20 / X12Y21 / X12Y26`）上对过；全库 75,800 行的 block 覆盖有 100 个缺 block（`Y≈298/299` band 5），那部分未生成。
