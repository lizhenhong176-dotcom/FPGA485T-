# -*- coding: utf-8 -*-
"""追加 STATUS 一节：band 是什么（自动取下一个可用号）。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(P, encoding="utf-8").read()
ns = [int(m.group(1)) for m in re.finditer(r"(?m)^## (\d+)\.(?!\d)", txt)]
nxt = max(ns) + 1

HEAD = "## " + str(nxt) + ". band 是什么（2026-11-08）\n"

BODY = """
**定义**：band = 把器件纵向切成 **7 段、每段 50 行**；一列在某段里的配置占帧地址空间中一段连续帧号。band 是**帧地址的编址单位**，不是硅片上的物理矩形。定位式：`frame = far_bands[(band, col)].start_frame + frame_off`（INT tile 的 frame_off 0..25）。有了它，62,625 个 tile 的地址只需 **7×128 = 896 条**记录就能算出来。

**实测结构**（`far_bands`，896 行）：7 band × 128 列；每 band 帧窗口 **5,246 帧**首尾相接（band0 0..5245、band1 5246..10491、…、band6 31476..36721，7×5246 = 36,722）；器件总帧数 50,176，差 **13,454** 帧属非 INT 资源（I/O、时钟、配置中心）。

**band ↔ region 是置换**：`region = Y//50`、`band = [6,5,0,1,2,3,4][region]`（`bitwriter.py:56`），所以 `band0` 装 `Y=100..149`（region 2）、`band6` 装 `Y=0..49`（region 0）——band 跟帧地址顺序走，不跟 Y 顺序走。

**三条独立验证**：①`law_tiles` 的 Y 只有 350 个值，`Y//50` 切出 7 桶×50；②一帧 `101 = 25×2 + 1(ECC) + 25×2` ⇒ 装 50 行 ⇒ 一段 50 行；③7 系列 clock region 横跨 50 个 CLB 行、485T 纵向 7 个 region。

**列在 band 内错开**：相邻列 `start_frame` 差不是常数，实测差集 `{28,30,32,36,42}`（band0: col0=0、col1=32、col2=68、col3=104、col127=4324）。**只用 `start_frame`**；`end_frame` 语义未查清（INT_L 列 4,387 vs INT_R 列 27–41），不得引用。

**三个用处**：①定位（与 `word = 2*(Y%50)+parity` 配合算到帧/字/位）；②解释复用地址层根源——同一 (band,col) 的 50 个 tile 共用同一批 26 帧、只差 word；③长线（`LV/LH` 跨 12–23 tile）的活动尺度就是 band。

**边界**：band 不等于 I/O bank / 时钟 bank / 手册 bank；【未测】band 为何是 `[6,5,0,1,2,3,4]` 这个置换（可能涉及列块写入顺序与每 config row 末尾 2 个 overhead 帧），无证据不下结论。

详见 `step03_pip/BAND_WHAT_IT_IS.md`；复算 `step03_pip/_q_far_bands.py`、`_q_row50.py`。

"""

if "band 是**帧地址的编址单位**" not in txt:
    txt = txt.rstrip("\n") + "\n" + HEAD + BODY
    io.open(P, "w", encoding="utf-8", newline="\n").write(txt)

ns2 = [int(m.group(1)) for m in re.finditer(r"(?m)^## (\d+)\.(?!\d)", txt)]
print("added section number:", nxt, "| sections:", len(ns2), "max:", max(ns2),
      "dup:", sorted({n for n in ns2 if ns2.count(n) > 1}), "monotonic:", ns2 == sorted(ns2))
print("lines:", txt.count("\n") + 1, "ufffd:", txt.count("\ufffd"))
