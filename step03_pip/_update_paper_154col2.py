# -*- coding: utf-8 -*-
"""第二遍：论文里剩余的旧口径数字（945 / 1,789 / 234 / 0/945 / 2.04%）。"""
import io

P = r"E:\DEEPSEEK\FPGA比特流逆向\paper\TAMPER_LOCALIZER.md"
s = io.open(P, encoding="utf-8").read()

EDITS = [
    ("   —— 检测器**完全沉默**。2.04% 的检出全部来自**共享格附带损伤**：被清的格子同时",
     "   —— 检测器**完全沉默**。2.67% 的检出全部来自**共享格附带损伤**：被清的格子同时"),
    ("本方法不覆盖（§5.5 用 Vivado 造的真实篡改位流证明：1,092 bit 改动、布线 945/945",
     "本方法不覆盖（§5.5 用 Vivado 造的真实篡改位流证明：1,092 bit 改动、布线 982/982"),
    ("3. **规模**：真实设计只有 1 个（1,812 PIP / 945 tile），器件是单颗 V7。",
     "3. **规模**：真实设计只有 1 个（1,812 PIP / 982 tile），器件是单颗 V7。"),
    ("python tamper_localize.py --check ../../tamper/ref/ref.bit   # 基线 L1=234(白名单后0) L2=0",
     "python tamper_localize.py --check ../../tamper/ref/ref.bit   # 基线 L1=240(白名单后0) L2=0"),
    ("- 反向：**2 bit** 就能伪造一条合法连接且 0 检出；整条空槽 PIP 添加 0/945 检出；\n"
     "word50 单 bit 0/945 检出；",
     "- 反向：**2 bit** 就能伪造一条合法连接且 0 检出；整条空槽 PIP 添加 0/300 检出；\n"
     "word50 单 bit 0/300 检出；"),
    ("布线 945/945 tile 完全一致、检测器输出逐字等价 —— 给出攻击成本下界与适用边界，",
     "布线 982/982 tile 完全一致、检测器输出逐字等价 —— 给出攻击成本下界与适用边界，"),
]
miss = []
for old, new in EDITS:
    if old not in s:
        miss.append(old.splitlines()[0][:50])
        continue
    s = s.replace(old, new, 1)
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("miss:", miss)
print("remaining:", [ln for ln in s.splitlines() if "2.04%" in ln or "0/945" in ln or "945/945" in ln or ("945" in ln and "→" not in ln)])
