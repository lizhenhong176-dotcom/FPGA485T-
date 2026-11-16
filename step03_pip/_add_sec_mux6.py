# -*- coding: utf-8 -*-
import io, re
ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
assert "\ufffd" not in txt
n = max(int(m) for m in re.findall(r"(?m)^## (\d+)\.", txt)) + 1
sec = """## __N__. 「mux 为什么是 6 行」的分解（2026-11-13）

**结论先行**：6 = **4 个「线源槽」+ 1 个「旁路槽」+ 1 个「本地槽」**；其中 2 个槽的名字可解释，另 4 个槽只知其划分、不知其语义。

### 实测（`_q_mux6_sig.py`、`_q_mux6_verify.py`，`law_cells` INT_L sense=1）
- 64 个 24 源族，**64/64 族每一行（`frame_off` 16..21）都恰好 4 个源**；6 × 4 = 24，组格总数 1,536 = 24 × 64 ✔。
- 每 `(行, 列码)` 格恰 1 个源（列码 ∈ {1,2,7,11}），即 6×4 网格**满填、无空洞**。
- **第 20、21 行的构成对 64 族完全一致**：恒为「4 个 bounce 类（2×`BYP_BOUNCE` + 2×`FAN_BOUNCE`）」与「4 个本地类（1×`GFAN` + 3×`LOGIC_OUTS`）」，两行谁在上随族交替。
- **第 16..19 行装的是 16 个「线源」**（方向 END 线，如 `EE2END0`、`NL1END0`、`SR1END_N3_3`），每行 4 个；其**行归属随族变化**：64 族去重后恰 **16 种签名、每种 4 族**——与 §11 的「16 种配置 × 4 族」是同一个 16。

### 判读
- 【数据事实】「6」不是一个均匀的维度，而是 **`4（线）+1（旁路）+1（本地）`** 的拼合；旁路/本地两行由名字直接决定，线源四行的排列是族参数（已由 §11 的 `(前缀, i//8, i%2)` 规则给出）。
- 【数据事实】**否定**一个自然猜测：这 4 行**不是**「四个方向」。实测每行混装多个方向（例 `IMUX_L40` 第 16 行 = `EE2END0`(E)、`NL1END0`(NL)、`SE2END0`(SE)、`SR1END_N3_3`(SR)），故「6 行 = 6 个方向分组」的说法不成立（`PIP_BIT_REUSE_REPORT.md` 里把它列为语义猜测，此处正式否证）。
- 【推断】线源四行的语义（为什么恰 4 组）仍未解；候选是「到达边」或「IMUX 内部四段驱动」，两者都缺直接证据，标未测。

### 复算
`python step03_pip\\_q_mux6_sig.py`（打印 16 种签名）、`python step03_pip\\_q_mux6_verify.py`（每行 4 源、20/21 行构成）。

"""
sec = sec.replace("__N__", str(n))
io.open(ST, "w", encoding="utf-8", newline="").write(txt.rstrip() + "\n\n" + sec)
t = io.open(ST, encoding="utf-8", newline="").read()
print("section", n, "bytes", len(t.encode("utf-8")), "ufffd", t.count("\ufffd"))