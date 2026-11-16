# -*- coding: utf-8 -*-
"""A1 修正：把撞号的三节改成 §65/§66/§67，并补上两处丢失指针。"""
import io
import re

STATUS = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
lines = io.open(STATUS, encoding="utf-8").read().splitlines()

MARK = "## 64. PIP 复用发生在哪一层 + 统计口径纠错（2026-11-07）"
idx = lines.index(MARK)
head = lines[:idx]
print("截断于第", idx + 1, "行；保留", len(head), "行")

APPEND = """## 65. PIP 复用发生在哪一层（含统计口径纠错）（2026-11-07）

解释文档 `step03_pip/PIP_REUSE_LAYER_EXPLAINED.md`（191 行，本行即丢失指针的重挂）；
提示词 `step03_pip/PROMPT_PIP_REUSE_LAYER_V1.md`。

**层次**：`tile`（类型 + col + Y）→ `family`（目的 wire，INT 侧 172 个）→ `feature`（`family, src_wire`，3,634 条）
→ `cell`（`(frame_off, parity, bit)`，1,598 个）。**复用发生在 feature 之间**：同一个 cell 被多个 feature 置 1；
`family` 是复用的边界单位，跨 family 共享只有 **3/1,598** 个 cell。

**【数据事实】按 `sense=1`（置位集）口径实测**（`law_cells`，INT_L）：

| 量 | 值 |
|---|---|
| feature 数 / 不同 cell 数 | 3,634 / 1,598 |
| 每 feature 的 cell 数 | 2 格 × 2,818、4 格 × 816，均值 **2.45** |
| 每 cell 被几个 feature 置 1 | 2→2、3→28、4→910、5→384、6→134、12→12、18→128，均值 **5.57** |
| `(cell 数, 源数)` 形状 | `(9,20)×96`、`(10,24)×64`、`(8,16)×6`、`(9,12)×2`、`(9,18)×2`、`(7,12)×1`、`(7,10)×1`（共 7 类） |
| 族内「每源 pattern 互不相同」 | **172/172** |
| 族内严格子集对 | **1,632**（与 `v7re/steps/T30_EXACT_MATCH.md` 一致） |

**口径纠错（本会话自纠）**：同一批数据若把 `sense=0` 行也并进观测集，会算出「每源恒 5 格、
cell share `[4,4,4,4,4,4,24,24,24,24]`、平均 3.35 格/feature、70/172 族 4:1 合并」
—— 那些不是位流的置位事实，而是「置位 + 清零」两类约束混算的结果。
**对外一律用 `sense=1` 口径；引用任何复用数字必须写明口径。**

**未查清项（照写不隐瞒）**：本表低位族（`(9,12)×2`、`(7,12)×1`、`(7,10)×1`）与
`step03_pip/REUSE_RULES.md:94-99` 的旧表（`(7,12)×4`、`(9,18)×2`）不完全一致，族总数同为 172，
差异来源未查（疑为 `law_cells` 在校验轮中重建所致）；引用形状类时以本表 + 复算命令为准。

## 66. `(frame_off, parity, bit)` 是什么 + 地址换算链（2026-11-07）

完整解释见 `step03_pip/CRAM_TERMS_AND_ADDRESSING.md`（217 行：术语表 / 物理四层 / 101 word 解剖 /
地址链路 / 真实演算 / 术语对照）；**可视化**见 `step03_pip/CRAM_LAYOUT_DIAGRAM.html`
（两段内联 SVG：帧-word-tile 共享关系 + `IMUX_L40` 位域；生成脚本 `step03_pip/_build_diagram.py`）；
提示词 `step03_pip/PROMPT_CRAM_ADDRESS_V1.md`。

- `frame_off`：**tile 内部的帧偏移**（INT tile 0..25；位池 = 26 × 2 × 32 = 1,664 位），`frame = base + frame_off`。
- `parity`：**帧内字对的一半**，`word = 2*(Y%50) + parity`（≥50 则 +1，跳过 word 50 的 ECC 字）。
- `bit`：**word 内第几位**（0..31）。三者合起来 = 一个 tile 内某一位的「tile 内相对坐标」。
- 已验证演算：`INT_L_X8Y20`（col=8、Y=20 ⇒ band 6、base 31,752）→ frame 31,768、word 40/41；
  `INT_R_X37Y199`（col=37、Y=199 ⇒ band 1、base 6,510、`Y%50=49`）→ word 99/100、frame 6,521/6,523。
- 容器：`ref.bit` = 102 字节头 + SYNC `AA995566` + 包流 + FDRI 5,067,776 word = 50,176 帧 × 101 word；
  解析后 `bits.shape = (50176, 101, 32)`；`.bit` 不能线性寻址，必须先解析 Type1/2 包取 FDRI 载荷。

## 67. band / row / tile 的区分与换算（2026-11-07）

完整解释与自检清单见 `step03_pip/BAND_ROW_TILE_EXPLAINED.md`；提示词
`step03_pip/PROMPT_BAND_ROW_TILE_V2.md`（V1 同名，V2 末尾附改动清单）。

- **tile**：配置阵列里的块实例，唯一标识是 `tile_name`（类型 + col + Y）。**【数据事实】**同一 `(col,Y)`
  上可并存多个 tile（`col=20` 的 700 个 tile 全是 `INT_L_X20Yn` 与 `INT_INTERFACE_L_X20Yn` 成对）。
- **band**：**帧地址上连续的 5,246 帧**。**【数据事实】**band 0 = 帧 0..5245、band 1 = 5246..10491、…、
  band 6 = 31476..36721，7×5246 = 36,722；器件 50,176 帧，差额 13,454 帧属非 INT 列。
- **region vs band**：`region = Y//50`（物理纵向，0..6），`band = band_by_region[region]`，
  置换表 `[6,5,0,1,2,3,4]`（`v7re/scripts/bitwriter.py:56`）。band 号跟**帧地址顺序**，不跟 Y 顺序，
  故 band 0 对应 Y=100..149。
- **row 三义**：①tile 的 `Y`（0..349）②band 内行号 `Y%50`（0..49，一行 2 个 word）③帧内 config row（101 word）。
- **共享边界**：同一帧只装同一 band 内的 50 个 tile 行（各占不同 word）；**跨 band 必然换帧**（base 差 5,246）。"""

lines = head + [""] + APPEND.splitlines()
io.open(STATUS, "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")

txt = io.open(STATUS, encoding="utf-8").read()
nums = {}
for i, l in enumerate(txt.splitlines(), 1):
    m = re.match(r"^## (\d+)\.", l)
    if m:
        nums.setdefault(int(m.group(1)), []).append(i)
dups = {k: v for k, v in nums.items() if len(v) > 1}
print("总行数:", len(txt.splitlines()))
print("纯数字编号重复:", dups if dups else "无")
print("末尾章节:", [l for l in txt.splitlines()[-200:] if l.startswith("## ")][-4:])
print("指针计数:", {k: txt.count(k) for k in
      ("PIP_REUSE_LAYER_EXPLAINED", "CRAM_LAYOUT_DIAGRAM", "CRAM_TERMS_AND_ADDRESSING", "BAND_ROW_TILE_EXPLAINED")})
