# T21 — SLICE 内四个 6-LUT 的 INIT 落位不变性 + 行位置不变性

日期：2026-11-06
器件：`xc7vx485tffg1157-3`（显式 `-part`，11 个构建全部回读断言一致）
实验目的：给 `v7re/scripts/build_site_frames.py` 替换 T13 血统 INIT 表铺路，补齐 STATUS §51.3 的两条未测项。

## 1. 假设（可证伪）

| 编号 | 假设 | 若成立应当观测到 | 若失败会看到 |
|---|---|---|---|
| H1 bel 不变性 | 同一 SLICE 内 A/B/C/D 四个 6-LUT 的 INIT 使用**同一组 frame_off**，差别仅在 (word, 16 位块) | 四组 pair 的 frame 集合都等于 `{base+68..base+71}`，且归一化后位图集合逐位相同 | 某一 bel 出现别的 frame_off，或归一化位图不等 |
| H2 行位置不变性 | `frame_off` 按 block 相对地址走，与 `Y%50` 无关；`word = 2*(Y%50)+parity` | `SLICE_X12Y21` 的 frame 集合与 y=20 相同，word 精确 +2 | frame_off 跟着行漂移，或 word 不是 +2 |
| H3 无附带差异 | 只改 BEL / LOC 不引入路由或 IOB 差异 | 除数据字与 word 50 ECC 外**无其他字变化** | 出现别的 word → 需归因后才可下结论 |

## 2. 构建（11 个，全部 rc=0）

固定条件：`LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}`、`DONT_TOUCH`、单 LUT6、`place_design` + `route_design`。

| build_id | 角色 | LOC | BEL | INIT |
|---|---|---|---|---|
| `a0_y20` | baseline | SLICE_X12Y20 | A6LUT | `64'h0` |
| `ar_y20` | variant | SLICE_X12Y20 | A6LUT | `64'hDEADBEEFCAFEBABE` |
| `a0bc` | **negative_control**（同参数重跑） | SLICE_X12Y20 | A6LUT | `64'h0` |
| `b0_y20` / `br_y20` | baseline / variant | SLICE_X12Y20 | B6LUT | `0` / `DEADBEEF…` |
| `c0_y20` / `cr_y20` | baseline / variant | SLICE_X12Y20 | C6LUT | `0` / `DEADBEEF…` |
| `d0_y20` / `dr_y20` | baseline / variant | SLICE_X12Y20 | D6LUT | `0` / `DEADBEEF…` |
| `a0_y21` / `ar_y21` | baseline / variant | SLICE_X12Y21 | A6LUT | `0` / `DEADBEEF…` |

回读断言（全部一致）：`RB_PART=xc7vx485tffg1157-3`、`RB_SITE` = 请求 LOC、`RB_BEL=SLICEM.<X>6LUT`、`RB_INIT` = 请求 INIT、`RB_LOCK=I0:A1 … I5:A6`。

差分语义：**PURE**（参考流 INIT=0，目标流 INIT=随机；无第三变量）。

## 3. 结果

负对照：`a0_y20` vs `a0bc` → 差分帧 **0**。

| pair | frame（绝对） | 数据字 | 位区间 | 内容位 | word 50 ECC 位 | 总位 |
|---|---|---|---|---|---|---|
| A_y20 | 31784,31785,31786,31787 | **40** | 0–15 | 46 | 14 | 60 |
| B_y20 | 同上 | **40** | 16–31 | 46 | 18 | 64 |
| C_y20 | 同上 | **41** | 0–15 | 46 | 14 | 60 |
| D_y20 | 同上 | **41** | 16–31 | 46 | 14 | 60 |
| A_y21 | 同上 | **42** | 0–15 | 46 | 14 | 60 |

`frame_off` = **32,33,34,35**（五组完全相同）。

> **勘误（2026-11-07，T23 并入）**：本节初版写「`base = 31716`，故 frame_off = 68,69,70,71」。`SLICE_X12Y20` 属 `grid_col = 20`，`clb_blocks[(20,0)] = 31752`（31716 是 `grid_col = 19` 的 base）。绝对帧号 `31784..31787` 是对的，错的只是 base 标注；换算后 `frame_off = 32..35`，与 law 的 `SLICEM_X0.*` INIT 行一致。结论（bel/行不变性）不受影响。

【数据事实】H1 成立：四个 6-LUT 的 frame_off 与 16 位块内位图**逐位相同**（把 B/D 的 bit−16、C/D 的 word−1 归一化后与 A 的集合对称差为 0）。落位规则：

```
w0 = 2 * (Y % 50)
A6LUT -> (word w0  , bits  0..15)
B6LUT -> (word w0  , bits 16..31)
C6LUT -> (word w0+1, bits  0..15)
D6LUT -> (word w0+1, bits 16..31)
frame_off 与 4 个 16 位块内的位图由 INIT 索引决定，与 bel / 行无关
```

【数据事实】H2 成立：`SLICE_X12Y21` 的 frame 集合与 y=20 完全相同，数据字从 40 增到 **42 = 2*21**，位区间与位图不变 —— 与地址公式的**事先预测**精确相符（不是事后拟合）。此结论与 T13 血统的表无关，是独立实测。

【数据事实】H3 成立：五组 pair 变化的字只有 `{数据字, 50}`，其他字一个都没变 → **无未解释差异**（0 帧 / 0 位）。word 50 的位集随数据变化（ECC 重算），符合 ECC 模型预期。

## 4. 交叉自证（另一脚本 + 另一批独立构建）

预测来源：T19 的 64 个单最小项锁引脚表 `v7re/steps/clb_init_locked_x12y20_a6lut.json`（64 个独立构建，A6LUT 单比特扫描）。
比对方法：`step03_pip/t21_crosscheck.py` 取 popcount(0xDEADBEEFCAFEBABE)=46 个索引，按上表规则平移（B: bit+16；C: word+1；D: word+1,bit+16；A_y21: word+2），与 T21 实测集合做**集合级**比对。

```
pair      pred  act  missing  extra
A_y20       46   46        0      0
B_y20       46   46        0      0
C_y20       46   46        0      0
D_y20       46   46        0      0
A_y21       46   46        0      0
RESULT PASS
```

【数据事实】交叉批次名 `T19_closed_form`，5 个 pair，一致 5 / 5，不一致列表为空。

## 5. 结论

**结论等级：verified**（判定依据：负对照 0 帧；集合级自证 missing=0 且 extra=0；交叉自证 5/5；无未解释差异；11 个构建回读断言一致）。

对 `build_site_frames.py` 的直接含义：
- INIT 落位不再需要依赖 T13 血统的 `clb_cells`：可由 `(INIT index) -> (frame_off, bit_in_16block)` 一张 64 行表 + bel/行公式 `(w0=2*(Y%50), word/bits 见 §3 表)` 生成。
- T19 表可直接复用为 `frame_off/bit` 基底，bel 差异只体现在 word 与 16 位块偏移。

## 6. 未测（本结论的覆盖边界）

1. **word 让位边界未测**：`Y%50 >= 25` 时 `w0+1 = 2*(Y%50)+1 >= 51`，与 word 50（ECC 字）相撞的让位规则未验证。最小实验：`SLICE_X12Y25`（w0=50）A6LUT 一对，看数据字落到 51 还是 50+1 的其它规则。
2. **B/C/D6LUT 只在 y=20 测过**：其它行的 bel×行组合未构建（规则外推，非实测）。最小实验：`SLICE_X12Y21` 的 B/C/D 各一对（3 构建，预测 word 42/43）。
3. **只在 SLICEM 测过**：`SLICE_X12Y20` 回读为 `SLICEM.A6LUT`；SLICEL 站点（无分布式 RAM 的 SLICE）未测，若 LUT 落位与 SLICEM 不同需另测。
4. **只在一个 block / 一个 clock region 内测过**：跨 block（不同 `Y%50` band、不同 clock region）的 frame_off（即 `block_start` 与 68..71 的相对关系）未测。

## 7. 本次踩到的坑（已写进 skill reference）

1. **locale**：WSL 里直接跑 `vivado` 报 `terminate called after throwing an instance of 'std::runtime_error' what(): locale::facet::_S_create_c_locale name not valid`（rc=134，全批同错），因为 Windows 主机的 `LANG=en_US.UTF-8` 被带进 WSL 而该 locale 未安装（`locale -a` 只有 C / C.UTF-8 / POSIX）。修法：脚本里 `export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE`。
2. **LOCK_PINS 管脚名不是按 BEL 命名**：`SLICEM.B6LUT` 的 BEL 管脚同样是 `A1..A6`（`get_bel_pins` 实测，四个 LUT 全部 A1..A6）；写 `I0:B1` 会 `ERROR: [Vivado 12-2497] … invalid device pin 'B1'`。
3. **本地 run_code 默认 120 s 超时**短于一批 11 个 Vivado 构建的墙钟（约 3 分钟），必须抬 `timeoutMs`，否则读不到 RC。

## 8. 产物

- manifest：`v7re/steps/t21_manifest.json`（`check_manifest.py` → PASS 15 ok / 0 warn / 0 fail）
- 交叉自证脚本：`step03_pip/t21_crosscheck.py`
- 远端构建脚本：`step03_pip/_t21_build.sh`；差分脚本：`step03_pip/_t21_diff.sh`；差分原始输出：`step03_pip/t21_diff_raw.txt`
- 远端目录：`/opt/lzh/v7re/work/t21/<build_id>/`
