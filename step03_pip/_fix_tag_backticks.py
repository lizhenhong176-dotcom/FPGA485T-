# -*- coding: utf-8 -*-
"""修回四处定位标签里的行内代码反引号（上一次经 PowerShell 传参被当转义吃掉）。"""
import io

files = [
    (r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\PIP_REUSE_WHERE_AND_LAW.md",
     "> 定位：**项目主线正文档（PIP 复用分析）** —— 复用发生在哪几层 + 七条规律。主线边界见 `STATUS.md §97`。"),
    (r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\PIP_REUSE_STRUCTURE.md",
     "> 定位：**项目主线正文档（PIP 复用分析·结构篇）** —— 复用度=列重、7 谱型、乘积结构、`frame_row=16+r` 推导。主线边界见 `STATUS.md §97`。"),
    (r"E:\DEEPSEEK\FPGA比特流逆向\paper\TAMPER_LOCALIZER.md",
     "> 定位：**旁支文档**（不是项目主线）。主线 = PIP 复用分析，见 `STATUS.md §97` 与 `step03_pip/PIP_REUSE_WHERE_AND_LAW.md`。本文是复用规律的一个下游应用。"),
    (r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\AMBIGUITY_SOLVABILITY.md",
     "> 定位：**主线副产品**（可解性判定）—— 复用表完备性的证据之一，不是主线目标。主线边界见 `STATUS.md §97`。"),
]

for p, line in files:
    ls = io.open(p, encoding="utf-8").read().split("\n")
    for i, l in enumerate(ls):
        if l.startswith("> 定位："):
            ls[i] = line
            break
    io.open(p, "w", encoding="utf-8", newline="\n").write("\n".join(ls))
    print("fixed", p.split("\\")[-1], "|", ls[2][:60])
