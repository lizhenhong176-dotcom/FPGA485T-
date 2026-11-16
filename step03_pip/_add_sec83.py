# -*- coding: utf-8 -*-
"""追加 STATUS §83：row 0..49 的含义与 50 的来源。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(P, encoding="utf-8").read()

SEC = """
## 83. row 0..49 是什么意思、50 是怎么来的（2026-11-08）

**含义**：`row = Y % 50` 是**这个 tile 在本 band 内的第几个器件行**（0..49），不是整片 y 坐标。整片 y 坐标 `Y = 50 × region + row`，`region = Y // 50`（0..6）。band ↔ region 是实测排列 `band_by_region = [6,5,0,1,2,3,4]`（`bitwriter.py:56`），所以 `band0` 装的是 `Y=100..149`（region 2）。

**50 从哪来——三条独立证据指向同一个数**：

1. 【数据事实】`law_tiles` 62,625 行，Y 只有 **350 个值（0..349）**，`Y//50` 恰好切成 **7 桶、每桶正好 50 个 Y**（`_q_row50.py`）→ 50 是行轴上的真实分割，不是随便取的。
2. 【算术必然】一帧 **101 word**；每个 row 要 2 个 word（parity 0/1），另 1 个 word 是 ECC → 可用 `100 = 2 × 50` → **一帧正好装 50 个 row**。反过来：`101 = 25×2 + 1 + 25×2`。
3. 【硬件事实】7 系列一个 clock region 横跨 **50 个 CLB 行**，XC7VX485T 纵向共 **7 个 region**（7×50 = 350）。所以本仓库的 `band` 就是 clock region。

**word 布局实测**（`word = 2*(Y%50)+parity`，≥50 则 +1）：

| row | parity0 word | parity1 word |
|---|---|---|
| 0 | 0 | 1 |
| 23 | 46 | 47 |
| 24 | 48 | 49 |
| 25 | 51 | 52 |
| 49 | 99 | 100 |

`row 0..24` 占 word `0..49`，`row 25..49` 占 word `51..100`，**word 50（ECC）夹在中间**，50 个 row 用满 100 个数据 word（`_q_row50.py` 实测：用到 100 个 word，唯一缺 50）。这条与 `prjxray_ref/PRJXRAY_COMPARE.md` §5 反推的 `offset = 2*(Y%50) + [Y%50>=25]` 完全一致。

**独立交叉验证**：`far_bands` 每个 band 恰好 **5,246 帧**且首尾相接（band0 0..5245、band1 5246..10491、…、band6 31476..36721）；`row_frames=5246` 就是「一个 band 的帧数」。

【推断】ECC word 落在中间而不是末尾，可能是因为一帧在物理上被分成两半（各 25 row × 2 word），校验字夹在中间。【未测】这条没有直接证据，不得讲成必然。

**三个 row 别混**（§74）：tile 的 `Y`（0..349）／band 内行号 `Y%50`（0..49）／帧内 `word` 槽位（0..100）。

复算 `step03_pip/_q_row50.py`。

"""

if "## 83. row 0..49 是什么意思" not in txt:
    txt = txt.rstrip("\n") + "\n" + SEC
    io.open(P, "w", encoding="utf-8", newline="\n").write(txt)

ns = [int(m.group(1)) for m in re.finditer(r"(?m)^## (\d+)\.(?!\d)", txt)]
print("sections:", len(ns), "max:", max(ns), "dup:", sorted({n for n in ns if ns.count(n) > 1}), "monotonic:", ns == sorted(ns))
print("lines:", txt.count("\n") + 1, "ufffd:", txt.count("\ufffd"))
