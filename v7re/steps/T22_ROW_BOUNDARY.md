# T22 —— word 让位边界（Y%50=26）实测：`word = 2*(Y%50)` 且 `>=50` 时 +1

日期：2026-11-07　器件：`xc7vx485tffg1157-3`　差分语义：PURE

## 1. 目的

T21 只测了 `Y%50 = 20/21`（word 40/42），`2*(Y%50)+parity >= 50` 时「再 +1 让开 word 50 的 ECC 字」这条规则**从未被实测**。本次用 `SLICE_X12Y26`（`Y%50 = 26` → 原始字 52）验证它，同时给 skill 行为验证提供一个真实正例。

## 2. 事前可证伪假设（构建前写下）

- H：把 `SLICE_X12Y26` 的 A6LUT 从 `INIT=0` 改成 `0xDEADBEEFCAFEBABE`，翻位应只出现在 **4 帧 `31784..31787`**（即 `base+32..35`，base=`clb_blocks[(20,0)]`=31752；初版误写 `base+68..71`、base=31716，见 T21 勘误），内容位全部落在 **word 53（= 52+1）的 bit 0..15**，共 46 位；word 50 出现 ECC 位；**word 52 必须完全没有变化**。
- 判失败：若内容位出现在 word 52，或帧集合不是 `31784..31787`，或 word 50 之外还有别的字变化。
- 预测依据：T21 的 `frame_off 与 bel/行无关` + 地址律 `word = 2*(Y%50)+parity`（`>=50` 再 +1）。

## 3. 构建（3 个，`/opt/lzh/v7re/work/t22/`）

| build_id | role | INIT | 回读 SITE / BEL / PART |
|---|---|---|---|
| `a0_y26` | baseline | `64'h0000000000000000` | `SLICE_X12Y26` / `SLICEM.A6LUT` / `xc7vx485tffg1157-3` |
| `ar_y26` | variant | `64'hDEADBEEFCAFEBABE` | 同上 |
| `a0b_y26` | negative_control | `64'h0000000000000000` | 同上 |

固定条件：`LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}`、`DONT_TOUCH`、单 `LUT6`、`place_design` + `route_design`、显式 `-part`。三个构建 rc=0，bit 大小均为 20,273,538 字节。

## 4. 结果

**【数据事实】** 差分帧 = 4：`31784 / 31785 / 31786 / 31787`，与预测完全一致。

**【数据事实】** 内容位分布：

| 帧 | word 53 的位 | 位数 |
|---|---|---|
| 31784 | 0,1,2,5,6,8,13 | 7 |
| 31785 | 0,2,3,4,5,6,7,8,10,11,12,13,14,15 | 14 |
| 31786 | 2,3,4,6,7,8,9,10,13,14 | 10 |
| 31787 | 0,1,2,4,5,6,7,8,9,10,11,12,13,14,15 | 15 |

合计 46 位内容位；word 50 的 ECC 14 位（帧 31784: 0,2,9,11,12；31785: 3,12；31786: 2,3；31787: 0,1,9,11,12）。

**【数据事实】** `word 52` 在整个差分中**零变化** —— 「>=50 再 +1」让位规则成立。

**【数据事实】** 负对照 `a0_y26` vs `a0b_y26`：差分 0 帧 / 0 位。

## 5. 自校验与交叉自证

- 集合级自证：predicted 46 / actual 46 / missing 0 / extra 0（禁抽样，集合相等）。
- 交叉自证：`step03_pip/t22_crosscheck.py` 用 **T19 的 64 个单最小项锁引脚表**只做「word 40 → word_for(26)=53」的规则平移，然后与实测集比对 → `RESULT PASS`（pred=46 act=46 missing=0 extra=0 ecc=14）。
- manifest：`v7re/steps/t22_manifest.json`，`step03_pip/check_manifest.py` → **PASS 15 ok / 0 warn / 0 fail**。

## 6. 结论

**【数据事实】结论等级 verified**：地址律 `word = 2*(Y%50)+parity`，且当该值 `>= 50` 时再 `+1` 让开 word 50 的 ECC 字；`frame_off` 与行无关。覆盖 `Y%50 = 20, 21, 26`。

## 7. 未测（本结论不覆盖）

1. `Y%50 = 25`（原始字 50 → 51）与 `Y%50 = 49`（98 → 99）两个端点未单独测。
2. `Y%50 >= 50` 不可能（`%50` 值域 0..49）；跨 50 行的 block/band 切换（`BAND_BY_REGION`）未测。
3. B/C/D6LUT 在 `Y != 20/21` 的行未测。
4. SLICEL 站点、其它 col、其它 clock region 未测。

## 8. 产物

- 远端：`/opt/lzh/v7re/work/t22/{a0_y26,ar_y26,a0b_y26}/`（design.v / build.tcl / *.bit / stdout.txt）
- 本地：`step03_pip/_t22_build.sh`、`step03_pip/_t22_diff.sh`、`step03_pip/_t22_diff.py`、`step03_pip/t22_diff_raw.txt`、`step03_pip/t22_crosscheck.py`、`v7re/steps/t22_manifest.json`
