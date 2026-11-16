# -*- coding: utf-8 -*-
import io

DOC = r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\PIP_REUSE_STRUCTURE.md"
STATUS = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"

d = io.open(DOC, encoding="utf-8").read()
old = "| 线类 → 列码 | `axis`/`diag` → {1,2}、`rline` → {7,11}、旁路源 → 任意（它们占 4/5 行） |"
new = ("| 线类 ↔ 列码（族内一一对应） | **64 / 64**：`axis`/`diag` 占码对 {1,2}、`rlineL`/`rlineR` 占码对 {7,11}，"
       "**对内哪个类拿哪个码逐族互换**（每族 1 位）；旁路源不参与（占行 4/5） |")
assert old in d
d = d.replace(old, new)
io.open(DOC, "w", encoding="utf-8", newline="\n").write(d)

s = io.open(STATUS, encoding="utf-8").read()
old2 = "| 线类 → 列码 | axis/diag→{1,2}、rline→{7,11}、旁路源→任意 |"
new2 = ("| 线类 ↔ 列码 | **64 / 64**：axis/diag 占码对 {{1,2}}、rlineL/rlineR 占码对 {{7,11}}，对内标签逐族互换（每族 1 位）；旁路源占行 4/5 不参与 |")
assert old2 in s
s = s.replace(old2, new2)
io.open(STATUS, "w", encoding="utf-8", newline="\n").write(s)
print("ok")
