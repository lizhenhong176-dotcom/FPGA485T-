# -*- coding: utf-8 -*-
"""A 轨一次性落地：A2 修重号 -> A3/A4 补 §62 -> A1 追加 §64/§65/§66。

规则（STATUS.md §63）：含中文的 UTF-8 文件只用 Python 显式编码读写，绝不走
Get-Content / Set-Content。
"""
import io
import re
import shutil

STATUS = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
T35 = r"E:\DEEPSEEK\FPGA比特流逆向\v7re\steps\T35_COMPOSITE_GROUP_MODEL.md"
BACKUP = r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\_status_before_A_20261107.md"

shutil.copyfile(STATUS, BACKUP)
lines = io.open(STATUS, encoding="utf-8").read().splitlines()

# ---------- A2：4 处重复编号 ----------
RENAME = {
    312: "## 5. 跨类型（INT_L vs INT_R）—— 已完成（2026-10-25）",
    331: "## 6. PIP 复用规律（可执行形式，2026-10-25）",
    1363: "## 35. T8 —— 位流改写器闭环（2026-11-04）",
    1812: "## 52. T21 —— 四个 LUT 的 INIT 映射同构 + 行不变性（2026-11-06，verified）",
}
changed = []
for lineno, expect in RENAME.items():
    assert lines[lineno - 1] == expect, (lineno, lines[lineno - 1])
    new = re.sub(r"^## (\d+)\.", r"## \1b.", lines[lineno - 1])
    lines[lineno - 1] = new
    changed.append((lineno, new))

# ---------- A3/A4：在 §62 末尾（§63 之前）插入口径与 LV_L0 ----------
insert_at = None
for i, l in enumerate(lines):
    if l.startswith("## 63. 环境陷阱"):
        insert_at = i
        break
assert insert_at is not None, "找不到 §63"

BLOCK = """
**口径硬规则（2026-11-07 实测补记）**：`law_cells` 同时存 `sense=1`（必须置位）与
`sense=0`（必须为 0）两类行 —— INT_L 侧 8,900 条 `sense=1` + 3,264 条 `sense=0`，
`sense=0` 覆盖 1,632 个 `(family,src)`（70/172 族）。**任何集合比对必须先过滤 `sense=1`**：
把两类行混在一起会得到「模型集 ≠ 观测集、需再并 3–4 个恒定格」的假象
（本会话实测踩过：`CLK_L0/GCLK_L_B1` 的 5 行里只有 2 行是 `sense=1`，混算即误判）。
按 `sense=1` 口径复算：6 个复合族 24 组 **96/96 精确命中、不符 0、无需任何恒定格**。

**`LV_L0` 归档（T33 遗留项）**：它不是缺失，而是「结构已知、槽位查表」——`v7re/steps/beg_families.json`
里 `LV_L0` 为 `kind=composite`、`complete=true`、10 个源各 2 格（共 7 个不同 cell，无恒定位）；
`composite_groups.json` 里 `LV_L0` 是空列表，即**组模型不适用**（无 core/附加位分解），
故不计入「96 条」口径。`verify_all_pip.py` 的 3,634/3,634、未覆盖 0 已包含它。
"""

lines[insert_at:insert_at] = BLOCK.splitlines()

# ---------- A1：追加 §64/§65/§66 ----------
APPEND = """

## 64. PIP 复用发生在哪一层 + 统计口径纠错（2026-11-07）

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
| 族内严格子集对 | **1,632**（与 `T30_EXACT_MATCH.md` 的 1,632 一致） |

**口径纠错（本会话自纠）**：同一批数据若把 `sense=0` 行也并进观测集，会算出「每源恒 5 格、
cell share `[4,4,4,4,4,4,24,24,24,24]`、平均 3.35 格/feature、70/172 族 4:1 合并、形状 7 类且低族不同」
—— 这些都不是位流的置位事实，而是「置位 + 清零」两类约束混算的结果。
**对外一律用 `sense=1` 口径；引用任何复用数字必须写明口径。**

**未查清项（照写不隐瞒）**：本表形状类里的低位族（`(9,12)×2`、`(7,12)×1`、`(7,10)×1`）与
`step03_pip/REUSE_RULES.md:94-99` 的旧表（`(7,12)×4`、`(9,18)×2`）不完全一致，族总数相同（172）。
差异来源未查（疑为 `law_cells` 在校验轮中重建所致），引用形状类时以本表 + 复算命令为准。

## 65. `(frame_off, parity, bit)` 是什么 + 地址换算链（2026-11-07）

完整解释（术语表 / 物理四层 / 101 word 解剖 / 地址链路 / 真实演算 / 术语对照）见
`step03_pip/CRAM_TERMS_AND_ADDRESSING.md`；提示词 `step03_pip/PROMPT_CRAM_ADDRESS_V1.md`。

- `frame_off`：**tile 内部的帧偏移**（INT tile 0..25；位池 = 26 × 2 × 32 = 1,664 位），`frame = base + frame_off`。
- `parity`：**帧内字对的一半**，`word = 2*(Y%50) + parity`（≥50 则 +1，跳过 word 50 的 ECC 字）。
- `bit`：**word 内第几位**（0..31）。三者合起来 = 一个 tile 内某一位的「tile 内相对坐标」。
- 已验证演算：`INT_L_X8Y20`（col=8、Y=20 ⇒ band 6、base 31,752）→ frame 31,768、word 40/41；
  `INT_R_X37Y199`（col=37、Y=199 ⇒ band 1、base 6,510、`Y%50=49`）→ word 99/100、frame 6,521/6,523。
- 容器：`ref.bit` = 102 字节头 + SYNC `AA995566` + 包流 + FDRI 5,067,776 word = 50,176 帧 × 101 word；
  解析后 `bits.shape = (50176, 101, 32)`；`.bit` 不能线性寻址，必须先解析 Type1/2 包取 FDRI 载荷。

## 66. band / row / tile 的区分与换算（2026-11-07）

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
- **共享边界**：同一帧只装同一 band 内的 50 个 tile 行（各占不同 word）；**跨 band 必然换帧**（base 差 5,246）。
"""

lines.extend(APPEND.splitlines())

new_text = "\n".join(lines) + "\n"
io.open(STATUS, "w", encoding="utf-8", newline="\n").write(new_text)

# ---------- 校验 ----------
txt = io.open(STATUS, encoding="utf-8").read()
heads = {}
for i, l in enumerate(txt.splitlines(), 1):
    m = re.match(r"^## (\d+)b?\.", l)
    if m:
        heads.setdefault(m.group(1), []).append(i)
dups = {k: v for k, v in heads.items() if len(v) > 1}
print("A2 改名:", changed)
print("重复编号:", dups if dups else "无")
print("总行数:", len(txt.splitlines()))
print("§64/§65/§66:", [l for l in txt.splitlines() if l.startswith(("## 64.", "## 65.", "## 66."))])
print("丢失引用计数:", {k: txt.count(k) for k in
      ("CRAM_TERMS_AND_ADDRESSING", "PIP_REUSE_LAYER_EXPLAINED", "CRAM_LAYOUT_DIAGRAM",
       "BAND_ROW_TILE_EXPLAINED", "PROMPT_BAND_ROW_TILE_V2", "PROMPT_CRAM_ADDRESS_V1")})

# ---------- T35 文档补 A3/A4 ----------
t35 = io.open(T35, encoding="utf-8").read()
if "## 6. 口径" not in t35:
    t35 = t35.rstrip() + """

## 6. 口径硬规则：比对必须先过滤 `sense=1`

`law_cells` 同时存两类行：`sense=1`（该位必须置 1）与 `sense=0`（该位必须为 0）。
INT_L 侧 8,900 条 `sense=1` + 3,264 条 `sense=0`，后者覆盖 1,632 个 `(family, src)`、70/172 族。

本次复核在此踩过一次坑：把两类行并进观测集后，`CLK_L0` 的 96 条全部「不等」，
再人为补上「族内恒定 3–4 格」才凑平——那是**假象**。过滤 `sense=1` 后：

```
组模型重建：96 条 精确命中 96  不符 0  恒定格 0
（实例 GCLK_L_B1：core {(0,0,25),(0,0,26),(1,0,24)} 去 (0,0,25) = {(0,0,26),(1,0,24)}，
 即 law_cells 里唯一的 2 条 sense=1 行；另外 3 行是 sense=0 的约束位，不进置位集。）
```

**引用任何复用/命中数字时必须写明口径**：`sense=1` = 置位事实；`全部行` = 置位 + 清零约束。

## 7. `LV_L0` 的归属（T33 遗留项归档）

`LV_L0` 不是缺失项，而是「结构已知、槽位查表」的普通族：

- `v7re/steps/beg_families.json`：`LV_L0` 的 `kind = composite`、`complete = true`，
  10 个源各 2 格，共 7 个不同 cell，无恒定位；
- `v7re/steps/composite_groups.json`：`LV_L0` 是**空列表** → 组模型（core + 附加位）不适用；
- 因此「96 条」口径只含 `CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1` 六族，`LV_L0` 单列；
- `verify_all_pip.py --tile-type INT_L` 的 3,634/3,634、未覆盖 0 已包含它的 10 条 feature。
"""
    io.open(T35, "w", encoding="utf-8", newline="\n").write(t35)
    print("T35 追加完成")
else:
    print("T35 已有该节，跳过")
