# T21：四个 LUT 的 INIT 映射同构 + 行不变性（part = ffg1157-3，verified）

日期：2026-11-06
manifest：`v7re/steps/t21_manifest.json`（`check_manifest.py` → **PASS 15 ok / 0 warn / 0 fail**）
构建：远端 `/opt/lzh/v7re/work/t21b`（A6 × 2 行）与 `/opt/lzh/v7re/work/t21c`（B/C/D）、`/opt/lzh/v7re/work/t21n`（负对照），共 11 个，全部显式 `-part xc7vx485tffg1157-3` 并断言回读。

## 1. 假设（可证伪）

在 `LOCK_PINS {I0:A1 … I5:A6}`、part `ffg1157-3`、同 block 内改动单个 BEL 的 `INIT`（0 → `0xDEADBEEFCAFEBABE`）时：
应在 4 帧 × 1 字内翻 **46 个内容位**（该值的 popcount），且

- B6LUT 与 A6LUT 同帧同字、位基相差 16；
- C6LUT 与 A6LUT 同位、字 40→41；
- D6LUT = B6LUT 的位 + 字 41；
- 行方向不变（`SLICE_X12Y20` vs `SLICE_X12Y21` 归一化后完全相同，只有 word 变）。

判失败：任一组的 `missing≠0` 或 `extra≠0`，或帧集合超出 `{B+68…B+71}`。

## 2. 结果：四条全部成立

| 组 | 预测 | 实测 | missing | extra |
|---|---|---|---|---|
| A6LUT @ X12Y20 | 46 | 46 | 0 | 0 |
| B6LUT @ X12Y20 | 46 | 46 | 0 | 0 |
| C6LUT @ X12Y20 | 46 | 46 | 0 | 0 |
| D6LUT @ X12Y20 | 46 | 46 | 0 | 0 |
| A6LUT @ X12Y21 | 46 | 46 | 0 | 0 |

负对照（同参数重跑 `A6_X12Y20_z2` vs `A6_X12Y20_z`）：差分 **0 格**。

【数据事实】四个 LUT 的内容位都在 `frame_off ∈ {68,69,70,71}`（即 `B+68…B+71`）；
A/B 用 word 40、C/D 用 word 41；B/D 的位序相对 A/C 整体 +16。

## 3. 统一公式（`B` = 块基址，本例 31716）

```
frame = B + 70 + (k & 1) - 2 * ((k >> 3) & 1)
word  = 40   (A/B)   |  41   (C/D)
bit   = (15 if hi==0 else 31) - 4 * (k >> 4) - ((k >> 1) & 3)
        其中 hi=0 对应 A/C，hi=1 对应 B/D
```

`v7re/steps/clb_init_locked_x12y20_4lut.json` 给出四个 LUT 的 64×4 全表。

## 4. 交叉自证

- 本批（ffg1157-3，B/C/D 由另一脚本生成）与 T19/T20 的闭式公式（ffg1761-2 批次）集合级一致：**4/4**；
- 行方向：`X12Y21` 与 `X12Y20` 归一化后完全相同（word 40 vs 42），**这条是 T14「布局随位置变」的反例，T14 判决维持作废**。

## 5. 未测 / 未解释

| 项 | 状态 |
|---|---|
| `SLICE_X13Y20`（X1 slice，D6/C6/A6/B6） | **未测**（T13 曾报其帧为 `B+62…B+65`，但属未锁引脚血统，不得直接采用） |
| 跨 block（不同 band / 不同 grid_col） | 未测 |
| 跨 part（ffg1761-2）的 B/C/D | 未测（只测了 A6LUT） |
| 未解释差异 | 本批 **0 帧 / 0 位** |

## 6. 结论等级

`verified` —— 同源自证（自批反读）+ 交叉自证（T19/T20 公式 + 另一脚本构建）均通过，
manifest 机检 PASS，无未解释差异。

## 7. 可证伪它的最小实验

造 `SLICE_X13Y20` 的 A6LUT 一对（INIT 0 / 0xDEADBEEFCAFEBABE，LOCK_PINS 锁 A1..A6）：
若其帧集合不是 `B+62…B+65`，则第 5 节的 X1 假设被推翻，需重测 X1 全部四个 LUT。
