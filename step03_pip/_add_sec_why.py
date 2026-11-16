# -*- coding: utf-8 -*-
import io, re
ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
assert "\ufffd" not in txt
n = max(int(m) for m in re.findall(r"(?m)^## (\d+)\.", txt)) + 1
sec = """## __N__. 两个「为什么」的初步答案（2026-11-13）

### 1. 为什么覆盖率停在 97.7% 而不是 100%

【数据事实】剩余 82 条 feature 全在 6 个长线族（`LH0` 12 / `LH12` 12 / `LVB_L0` 18 / `LVB_L12` 18 / `LV_L0` 10 / `LV_L18` 12），它们的**源不是本 tile 的普通线，而是别的长线与长线的端点线**：
- `LH0` 的 12 个源 = `EE4END3, ER1END3, LH12, LV_L0, LV_L18, LV_L9, NE2END3, NE6END3, NW2END3, SR1END3, SS6END3, SW6END3`；
- `LVB_L0` 的 18 个源里含 `LH0, LH12, LH6, LVB_L12, LV_L0, LV_L18`；
- `LV_L18` 含 `LH0, LH12, LH6, LV_L0`。

【数据事实】这 6 族也是**唯一**存在跨族共享格的族：`(1,6,0) ∈ {LH0, LV_L0, LV_L18}`、`(0,2,0) ∈ {LH0, LV_L0}`、`(0,9,0) ∈ {LV_L0, LV_L18}`（`_q_longline_why.py`）。

【推断】所以这 82 条编码的是**长线之间的邻接关系**（谁与谁相邻、哪一段接哪一段），属于「器件布线拓扑的数据」，不是名字的派生量。要把它公式化，需要额外数据源（长线的物理次序/坐标），而当前工具链没有暴露：`templates/*.json` 的 `pip_defs` 第三字段 `delayIndex` 在 INT 全为 0，RapidWright 也没有 mux 内部或长线相邻关系的 API（`PIP_BIT_REUSE_REPORT.md` §6 记录过这一点）。

⇒ 结论：97.7% 是「名字可派生」的上界；剩下 2.3% 是拓扑数据。**不写成 100% 是诚实，不是没做完**。

### 2. 码集 `{1,2,7,11}` 的结构（`_q_longline_why.py`）

【数据事实】4 个合法列码两两异或后 popcount 恒为 **2**：
`1^2=3(2位)`、`1^7=6(2位)`、`1^11=10(2位)`、`2^7=5(2位)`、`2^11=9(2位)`、`7^11=12(2位)` → **最小汉明距离 = 2**。
【数据事实】任取一个合法码、翻转任意 1 位，得到的 7 个 4 位字 `{0,3,5,6,9,10,15}` **全部非法**。
⇒ 【推断】码集的设计使其具备**单比特错误可检出**性质（检错、不纠错）；这与篡改实验中「mux 区清位方向单 bit 检出 100%」是同一事实的编码论表述。
【数据事实】码集还存在子集关系：`1 ⊂ 11`（0001 ⊂ 1011）、`2 ⊂ 7`（0010 ⊂ 0111）——与全表统计的 1,632 对族内严格子集同源。
【推断】这不是最大码集（4 位、距离 2 的最大规模是 8），说明码集还受别的约束（候选：4 个线长类别只能两两正交到 2 位；成因未测）。

"""
sec = sec.replace("__N__", str(n))
io.open(ST, "w", encoding="utf-8", newline="").write(txt.rstrip() + "\n\n" + sec)
t = io.open(ST, encoding="utf-8", newline="").read()
print("section", n, "bytes", len(t.encode("utf-8")), "ufffd", t.count("\ufffd"))