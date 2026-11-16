# -*- coding: utf-8 -*-
"""把 BEG 变体 32 族规则写进 PIP_REUSE_STRUCTURE.md（§14）与 STATUS.md（自动 max+1）。"""
import io, re, os

ROOT = r"E:\DEEPSEEK\FPGA比特流逆向"
DOC = os.path.join(ROOT, "step03_pip", "PIP_REUSE_STRUCTURE.md")
ST = os.path.join(ROOT, "STATUS.md")

SEC14 = """

## §14 BEG 变体 32 族的列归属：方向桶 + 长线表（2026-11-09）

### 14.1 结论

【数据事实】96 个 20 源 BEG 族里，64 个「纯净族」（列=几何类别）此前已覆盖；剩 **32 个变体族**
（`EE4BEG0..3`、`WW4BEG0..3`、`NE6/NN6/NW6/SE6/SS6/SW6` 各 `0..3`）的列归属**不是**几何类别。
现在这 32 族的 **640/640 条 (源→列) 归属全部由名字推出，0 差异**（INT_L 与 INT_R 各 32/32）。

### 14.2 规则（只吃名字）

| 列 | 内容 | 判定方式 |
|---|---|---|
| C0 / C1 | 6 条 `len2` 线按「轴(EE/WW/NN/SS) vs 斜(NE/NW/SE/SW)」3+3 分组，各配 2 个 `LOGIC_OUTS` | 方向位 `b(D)`：D∈{EE,NE,WW,SW} → 轴进 C1；D∈{NN,NW,SE,SS} → 轴进 C0 |
| C0 / C1 的逻辑格 | `L_i`、`L_{i+4}` 与 `L_{i+8}`、`L_{i+12}` 跟随同一 `b(D)` 分列（`i` = 族序号 0..3） | 同上 |
| C2 | 2 条长线（族序号决定，4 行表）+ 3 条长距离线（方向桶表） | 见 14.3 |
| C3 | 余下 3 条长距离线 + `L≥16` 的两格：`16+((i+2) mod 4)` 与 `+4` | 同上 |

### 14.3 两张常数表

**长线表（4 行，跨全部 8 个方向通用）**

| 族序号 | 长线 |
|---|---|
| 0 | `LH12`, `LV_L0` |
| 1 | `LH6`, `LV_L9` |
| 2 | `LVB_L0`, `LVB_L12` |
| 3 | `LH0`, `LV_L18` |

**方向桶表（4 桶 × 3 条长距离线，决定 C2）**

| 桶（族方向 D） | C2 的长距离线 |
|---|---|
| {EE, SE} | `EE4`, `NE6`, `SW6` |
| {WW, NW} | `WW4`, `NE6`, `SW6` |
| {NE, NN} | `EE4`, `NE6`, `WW4` |
| {SS, SW} | `EE4`, `SW6`, `WW4` |

【推断】两张表的行数（4+4）与 mux 侧「16 种配置 × 4 族」同量级：都不是逐族数据，而是族类常数。
【未测】这两个桶为什么按 {EE,SE}/{WW,NW}/{NE,NN}/{SS,SW} 分组（对应哪条物理通道），未查。

### 14.4 复算

```
python step03_pip/gen_slots.py                 # [BEG] 纯定律 96/96，需回落 0（其中变体规则 32/32）
python step03_pip/gen_slots.py --tile INT_R    # 同
```
实现：`gen_slots.py::beg_variant_cols()`（`AXIS2/FLIP2/LONG_TBL/BUCKET_TBL` 四个常量 + 一条逻辑八位组规则）。

### 14.5 对三档账目的影响

| 档 | 旧 | 新 |
|---|---|---|
| 公式 | 2,816/3,634 = 77.5% | **3,456/3,634 = 95.1%**（mux 1,536 + BEG 1,920） |
| 表 | 736（BEG 变体 640 + 复合 96） | **96**（只剩 6 个复合族的组模型） |
| 未解 | 82（6 长线族） | 82（不变） |

> 边界：`len2` 侧只覆盖 6 条 `len2` 线齐全的族；INT_R 需先做线名归一（`LOGIC_OUTS0`→`LOGIC_OUTS_L0`、`LV0`→`LV_L0`）。
"""


def add_section14():
    txt = io.open(DOC, encoding="utf-8").read()
    if "§14 BEG 变体" in txt:
        print("§14 已存在，跳过")
        return
    if not txt.endswith("\n"):
        txt += "\n"
    io.open(DOC, "w", encoding="utf-8").write(txt + SEC14)
    print("已追加 PIP_REUSE_STRUCTURE.md §14，现", len(io.open(DOC, encoding="utf-8").read().splitlines()), "行")


STATUS_SEC = """## __N__. BEG 变体 32 族列归属收口：640/640 由名字推出（2026-11-09）

【数据事实】96 个 20 源 BEG 族中最后 32 个「变体族」（`EE4BEG0..3`、`WW4BEG0..3`、`NE6/NN6/NW6/SE6/SS6/SW6` 各 `0..3`）的列归属此前只能逐族查表；现在**全部由名字推出，640/640 条 (源→列) 0 差异**，INT_L 与 INT_R 各 32/32。

规则（实现在 `step03_pip/gen_slots.py::beg_variant_cols()`）：
- C0/C1：6 条 `len2` 按「轴 vs 斜」3+3；方向位 `b(D)`：{EE,NE,WW,SW} 轴进 C1，{NN,NW,SE,SS} 轴进 C0；`LOGIC_OUTS` 的 `L_i/L_{i+4}` 与 `L_{i+8}/L_{i+12}` 跟随同一方向位。
- C2：长线（4 行表，仅由族序号定）+ 方向桶表（4 桶）给出的 3 条长距离线。
- C3：余下 3 条长距离线 + `L≥16` 的两格（`16+((i+2) mod 4)` 与 `+4`）。

复算：
```
python step03_pip/gen_slots.py                 # [mux] 64/64；[BEG] 96/96，需回落 0（变体规则 32/32）
python step03_pip/gen_slots.py --tile INT_R    # 同（需线名归一：LOGIC_OUTS0→LOGIC_OUTS_L0、LV0→LV_L0）
```

三档账更新：公式 **3,456/3,634 = 95.1%**（原 2,816 = 77.5%）；表只剩复合 6 族 96 条；未解仍 82 条（6 个长线族）。

边界：只覆盖 `len2` 六线齐全的族；两张常数表（4+4 行）为什么按该桶分组【未测】；6 个长线族与 6 个复合族仍未进「公式」档。

详见 `step03_pip/PIP_REUSE_STRUCTURE.md` §14。
"""


def add_status():
    txt = io.open(ST, encoding="utf-8", newline="").read()
    if "BEG 变体 32 族列归属收口" in txt:
        print("STATUS 已有该节，跳过")
        return
    nums = [int(m) for m in re.findall(r"^## (\d+)\.", txt, re.M)]
    n = max(nums) + 1
    nl = "\r\n" if "\r\n" in txt else "\n"
    sec = STATUS_SEC.replace("__N__", str(n)).replace("\n", nl)
    if not txt.endswith(nl):
        txt += nl
    with io.open(ST, "w", encoding="utf-8", newline="") as fh:
        fh.write(txt + nl + sec)
    after = io.open(ST, encoding="utf-8", newline="").read()
    print("STATUS 追加 §%d，现 %d 行，ufffd=%d" % (n, after.count(nl), after.count("\ufffd")))


add_section14()
add_status()
