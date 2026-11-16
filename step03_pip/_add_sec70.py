# -*- coding: utf-8 -*-
"""给 STATUS.md 追加 §70：歧义/复用可解性评估。"""
import io

STATUS = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"

SEC = """## 70. 歧义/复用可解性评估：三层判定 + 最大阻碍（2026-11-07）

文档 `step03_pip/AMBIGUITY_SOLVABILITY.md`；提示词 `step03_pip/PROMPT_AMBIGUITY_SOLVABILITY_V1.md` → `_V2.md`。

**三层判定**：

| 层 | 判定 | 证据 |
|---|---|---|
| (a) mux 是否启用 | 条件可解 | `min-cells 2` 精确 67.4% / 召回 96.0%；`min-cells 4` 精确 100% / 召回 19.7%（`T6B_DISAMBIGUATION.md`） |
| (b) 选了哪个源 | 单 feature 独立判定**不可解**；联立后**未证明** | 同族严格子集对 **1,632**；2,818 个 2 格 feature 中 **816** 个被同族另一 feature 严格包含，跨族包含 **0**（`step03_pip/_q_subset_pairs.py`） |
| (c) 整条路径唯一 | **未证明** | 无构造性反例，也无唯一性证明 |

**关键区分**：位集嵌套说明「只看本 mux 的格子不够」，**不等于**信息论下界——观测里仍有额外信息（不属于小 feature 的那些格是 0 还是 1），
把 172 个 mux 的互斥约束联立后是否唯一，尚未求解。
**已确证的物理事实**：1,598 个 cell 被 3,634 个 feature 共用（均值 5.57），所以「读一位即知谁选中」不成立，必须全局一致性求解。

**最大阻碍 = ECC 与帧地址耦合未闭合**（`STATUS.md` §32/§34：`ECC = L(data) ⊕ A(frame_addr)`，`A` 未定）。
它挡住三件事：生成任意可加载位流、TM2 的上板端到端验证、全芯片重综合残差收敛（现差 53 字）。
数据层缺 16,979,200 行 `site_frames` 排第二：只影响 CLB 侧广度，不阻断 INT 侧闭环。

**三条互斥路径**：P1 联立求解打歧义（2–3 人日，纯本地，**唯一能产出「歧义下界」实证**：必须给出逐位相同的两条合法配置对，只给多解组计数不算下界）；
P2 闭合 ECC 地址项（5–7 人日，需远端 Vivado + 板卡）；P3 补数据层（4–6 人日，先 `VACUUM INTO` 备份）。
"""

txt = io.open(STATUS, encoding="utf-8").read()
assert "## 70. 歧义/复用可解性评估" not in txt
io.open(STATUS, "w", encoding="utf-8", newline="\n").write(txt.rstrip() + "\n\n" + SEC)
print("ok; lines:", len(io.open(STATUS, encoding="utf-8").read().splitlines()))
