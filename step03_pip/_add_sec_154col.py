# -*- coding: utf-8 -*-
"""追加 STATUS 节：far_bands 补到 154 列。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
s = io.open(P, encoding="utf-8").read()
n = max(int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)) + 1

body = f"""## {n}. far_bands 从 128 列补到 154 列（2026-11-08）

### 一、根因：导出脚本把 10 位列字段截成了 7 位

`v7re/export/law_db.py::load_far()` 原写 `col = (int(r["block_addr"],16) >> 7) & 0x7F`。FAR 的 column 是 **`[16:7]`，10 位**，本器件实际 154 列（0..153），`& 0x7F` 把 128 列之后全截掉 ⇒ `far_bands` 只有 896 行（7 band × 128 列），26 列（128..153）没有基址，而 `INT_L`/`INT_R` 在这 26 列上各有 350 个 tile。

**结论订正**：「INT tile 只有 44,100/53,100 = 83.1% 能定位」是导出 bug，不是硬件限制（§87 已记 FAR 有 154 列）。

### 二、修法

1. `load_far()` 掩码改 `0x3FF`；
2. 新增 `load_far_from_frame_map(model_db)`：直接从 `frame_map.far` 解 (block, top, row, col) 算首帧与帧数，**优先于 CSV 路径**（CSV 会把每段末尾 2 个 overhead 帧算进最后一列）；
3. `far_bands` 增加 `frames INTEGER` 列；`end_frame` 统一改成 `start_frame + frames − 1`（旧值自相矛盾且无人消费，`grep end_frame` 只在 schema 里出现）；
4. 备份：`E:\\v7work\\model\\v7_law_backup_20261108_pre154.sqlite`（11,526,144 B）；脚本 `step03_pip/_extend_far_bands.py`。

### 三、写库结果（实测）

- 行数 896 → **1,078**（7 band × 154 列），列 0..153；原有 896 行 `start_frame` **逐条 0 变动**
- 每 band 末列（153）结束于段尾前 2 帧 → 段窗口仍 5,246（band0 col153 = 5,212..5,243，overhead 5,244/5,245）
- 28 个 overhead 帧（`frame_map.far IS NULL`）= 14 段 × 2，与「每 config row 末尾 2 overhead 帧」一致；`is_overhead` 计数 28 且这 28 行都没有 far
- 复现校验：`law_db.load_far_from_frame_map()` 重算 1,078 行，与库中**逐条 0 差异**（`step03_pip/_q_export_repro.py`）
- 与 CSV 口径的差：`phaseA/frame_index_far.csv` + 10 位掩码重算得每 band 154 列，但最后一列是 34 帧（含 2 个 overhead），库里是 32 —— 已解释，非冲突（`_q_far_csv_check.py`）

### 四、对解码器的影响（`tamper/ref/ref.bit`，945→982 tile）

| 指标 | 修正前 | 修正后 |
|---|---|---|
| active tile | 945 | **982**（= `pips_all.txt` 里 982 个 INT tile） |
| 解码 PIP | 1,789 | **1,886** |
| L1 未解释位 | 234 | 240（仍是 `(1,0,0)`/`(1,1,0)` 两格 × 120 tile） |
| L2 槽位违例 | 0 | **0** |
| 建模覆盖（bit） | 45.25% | **54.49%**（88,358,400 / 162,168,832） |
| 可定位 tile | 44,100 | **53,100**（62,625 里的全部 INT_L/INT_R） |

- **这正是修好它的证据**：新解出的 37 个 tile 贡献 97 条 PIP，而它们没有带来任何 L2 违例、L1 只多出已知的两格标记位。基址若错一帧，读数会整体错位 → L1 爆炸 + L2 大量违例。
- 与真值对账（`_q_verify_pips_after.py`）：`pips_all.txt` 的 INT PIP **1,263** 条，解出 **1,155 = 91.45%**；列 ≥128 的真值 40 条解出 **39**。

### 五、单 bit 穷举重跑（1,633,808 次翻转）

| 类别 | n | 检出 | 率 |
|---|---|---|---|
| off·mux | 560 | 560 | 100% |
| off·other | 2,472 | 2,472 | 100% |
| on·mux | 627,920 | 627,662 | 99.9589% |
| on·other | 1,002,856 | 994,026 | 99.1195% |
| **合计** | **1,633,808** | **1,624,720** | **99.4438%** |

基线解释不了的 240 位不参与「清 0」判定（`off_baseline_skipped`）。与修正前（1,572,246 次 / 99.44%）**率基本不变**，说明新增 37 个 tile 的行为与已建模 tile 一致。

### 六、待办

- `--classes` / `--attack`（PIP 删/加、word50、换源）在 154 列口径下重跑，刷新 `paper/TAMPER_LOCALIZER.md` 的分母
- 远端 `/opt/lzh/...` 的 `v7_law.sqlite` 副本尚未同步这次修改

"""

s = s.rstrip("\n") + "\n\n" + body
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
nums = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)]
print("new:", n, "| sections:", len(nums), "| max:", max(nums),
      "| dup:", len(nums) - len(set(nums)), "| lines:", s.count("\n") + 1,
      "| bad:", s.count("\ufffd"))
