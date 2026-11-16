# -*- coding: utf-8 -*-
"""把 P1（BEG 族两轴结构）写进 PIP_REUSE_STRUCTURE.md 与 STATUS.md。"""
import io, re, os

BASE = r"E:\DEEPSEEK\FPGA比特流逆向"
DOC = os.path.join(BASE, "step03_pip", "PIP_REUSE_STRUCTURE.md")
STATUS = os.path.join(BASE, "STATUS.md")

SEC12 = """
## 12. BEG 侧（96 个 20 源族）：同一条定律的第二个实例

### 12.1 判定方法
每个 20 源族视为一张二分图：源 = 边，它占的两个 **cell**（`(frame_off, parity, bit)`，bit 参与区分） = 两端点。
先 2-着色判二分，再验完全性（每个节点与对侧所有节点都相邻）。**不看族名、不看帧号。**

### 12.2 结构：96/96 完全二分
| 形态 | 族数 | 说明 |
|---|---|---|
| `K(5,4)` | 64 | P 侧 5 组（各 4 源）＋ Q 侧 4 列（各 5 源） |
| `K(4,5)` | 32 | 同为 5×4 网格，只是哪侧是 5 取决于该族用几个 bit |

20 源 = 5 × 4，与 mux 侧的 24 源 = 6 × 4 **同构**，只是网格小一档。

### 12.3 P 轴（5 组）= 源的方向令牌
**96/96 族成立**：同一方向令牌的所有源落在同一个 P 组，且该组恒为「1 个方向上的直连源 + 该方向的长线 + 1 个 `LOGIC_OUTS`」。
例：`EE2BEG0` 的 P 组 = `{EE2,EE4,LOGIC_OUTS_L8,LOGIC_OUTS_L12}`、`{SE2,SE6,EL1,LOGIC_OUTS_L4}`、
`{SS2,SS6,ER1,LOGIC_OUTS_L0}`、`{NE2,NE6,NL1,LOGIC_OUTS_L22}`、`{NN2,NN6,NR1,LOGIC_OUTS_L18}`。
方向组与帧的对应逐族不同（`EE2BEG0`：EE→11、SE→9/bit6、SS→9/bit7、NE→6、NN→10），这个映射有 54 种签名。

### 12.4 Q 轴（4 列）= 源的几何类别
- **64/96 族四列纯净**：`line+logic` / `len4+len6` / `len2` / `logic`（line 只有 4 个源、logic 有 6 个，故 1 个 logic 并进 line 列）。
- **32/96 族是变体体制**：把 `len2` 按方向拆成两列，并混入 `LH*/LV_*` 长线（如 `SS6BEG1` 的列 = `len2+logic`、`len2+logic`、`len4+len6+other`、`len6+logic`）。

### 12.5 对缺口账的更新
| 口径 | 旧值 | 新值 |
|---|---|---|
| 几何槽位由「族名+源名」直接可推 | 1,024 / 1,536 (mux 侧) | **2,304 / 2,944 = 78.3%**（mux 1,024 + BEG 1,280） |
| 需逐族规则的槽位 | 512 / 1,536 | **640 / 2,944 = 21.7%**（BEG 的 32 个长线变体族） |

### 12.6 边界
- 只测 INT_L（INT_R 的族名/源名按 §11 的归一化规则等价，未逐条重跑）。
- 「P 轴 = 方向」是**数据事实**（96/96 命中）；「为什么是这 5 个方向」与 Q 列为何这样分组属【未测】，不得讲成因果。
- 32 个变体族尚未给出可执行的列归属规则，只给出定性描述。

### 12.7 复算命令
```
python step03_pip/_p1_beg_bip.py     # 二分结构分布
python step03_pip/_p1_beg_law.py     # P 轴 = 方向令牌 96/96、Q 轴纯度、配置签名
python step03_pip/_p1_beg_qaxis.py   # Q 列几何类别签名
```
"""

P1_STATUS = """## {n}. P1：BEG 侧 96 个族的复用结构（2026-11-08）

**结论一句话**：96 个 20 源 BEG 族全部是完全二分 5×4 网格，P 轴 96/96 由源的方向令牌决定、Q 轴 64/96 为「几何类别四列」——与 mux 侧 6×4 同构，复用定律的第二个实例成立。

# 一、结构（`step03_pip/_p1_beg_bip.py`）

| 形态 | 族数 |
|---|---|
| `K(5,4)` | 64 |
| `K(4,5)` | 32 |
| 非二分 | 0 |

20 源 = 5 × 4；mux 侧 24 源 = 6 × 4。

# 二、两轴归属（`_p1_beg_law.py`）

| 轴 | 判据 | 命中 |
|---|---|---|
| P（5 组） | 同方向令牌的源恒在同一组 | **96 / 96 族** |
| Q（4 列） | 列内几何类别一致（line 4 个 + logic 6 个，故 1 个 logic 并入 line 列） | **64 / 96 族** |
| Q（变体） | len2 按方向拆两列、混入 `LH*/LV_*` 长线 | 32 / 96 族 |
| 配置签名 | 方向组 → 帧 的映射 | 54 种（每种 1–2 族） |

# 三、缺口账更新

- 旧：几何槽位可推 **1,024 / 1,536 = 66.7%**（只有 mux 侧）。
- 新：**2,304 / 2,944 = 78.3%**（mux 1,024 + BEG 1,280）；剩余 640 条 = BEG 的 32 个长线变体族，只做到定性。

# 四、边界

- 只测 INT_L；「P 轴 = 方向」是数据事实，其成因、32 个变体族的列规则均【未测】。
- 不能据此声称「复用已完全解释」：复合族/长线族（12 个）与跨 tile 类型仍在 P2/P4。

# 五、复算

`python step03_pip/_p1_beg_bip.py` / `_p1_beg_law.py` / `_p1_beg_qaxis.py`

"""


def main():
    doc = io.open(DOC, encoding="utf-8").read()
    assert "## 12. BEG" not in doc
    io.open(DOC, "w", encoding="utf-8", newline="\n").write(doc.rstrip() + "\n" + SEC12)

    st = io.open(STATUS, encoding="utf-8").read()
    nums = [int(m) for m in re.findall(r"^## (\d+)\.", st, re.M)]
    n = max(nums) + 1
    body = P1_STATUS.format(n=n)
    st = st.rstrip() + "\n\n" + body
    io.open(STATUS, "w", encoding="utf-8", newline="\n").write(st)
    print("DOC lines:", len(io.open(DOC, encoding="utf-8").read().splitlines()))
    print("STATUS section:", n, "lines:", len(st.splitlines()), "ufffd:", st.count("\ufffd"))


main()
