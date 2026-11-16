# -*- coding: utf-8 -*-
"""tamper/README.md 更新：945→982 tile、补 154 列口径的 JSON 清单、加检测器 bug 说明。"""
import io

P = r"E:\DEEPSEEK\FPGA比特流逆向\tamper\README.md"
s = io.open(P, encoding="utf-8").read()

EDITS = [
    ("| `ref/ref.bit` | 参考位流，20,273,538 B，13,426 个置位，945 个 active INT tile，1,812 条 PIP |",
     "| `ref/ref.bit` | 参考位流，20,273,538 B，13,426 个置位，**982 个 active INT tile**，1,812 条 PIP |"),
    ("| `ex_ref.json`、`ex_full8.json` | §4 | 单 bit 穷举（`ref`：1,572,246 次翻转，99.44% 检出） |",
     "| `ex_ref.json`、`ex_full8.json` | §4 | 单 bit 穷举（128 列口径） |\n"
     "| `exhaustive_ref_154col.json` | §4 | 单 bit 穷举（**154 列口径**：`ref` 1,633,808 次翻转，99.4438% 检出） |"),
    ("| `atk_ref300_v2.json`、`atk_full8_v2.json` | §5.1/§5.2 | 幽灵 mux 0 检出；换源 8.33% / 6.0%（修正统计 bug 后） |",
     "| `atk_ref300_v2.json`、`atk_full8_v2.json` | §5.1/§5.2 | 128 列口径，**已作废见下** |\n"
     "| `atk_ref300_154col_fixed.json`、`atk_full8_154col_fixed.json` | §5.1/§5.2 | 154 列口径 + 基线比对修正：幽灵 mux **0/300**、换源 **6.0%**（有共享格 15.2% / 无共享 0.5%） |\n"
     "| `classes_ref300_154col.json` | §5.3/§5.4 | 154 列口径：整条 PIP 删除 8/300 = 2.67%、空槽添加 0/300、word50 0/300 |\n"
     "| `delta_init_154col.json` | §5.5 | 154 列口径下 `ref` vs `tamper_init`：1,092 bit 差异、建模区 0 个 |"),
]
miss = []
for old, new in EDITS:
    if old not in s:
        miss.append(old[:40])
        continue
    s = s.replace(old, new, 1)

s = s.replace(
    "- `atk_ref.json`、`atk_ref300.json`、`atk_ref300.log` —— 换源统计 bug 未修时的数字",
    "- `atk_ref300_154col.json`、`atk_ref300_154col.log` —— 检测器**未减基线**时跑出的数字\n"
    "  （幽灵 mux 一度报 300/300 = 100%），成因见报告文末修订记录\n"
    "- `atk_ref.json`、`atk_ref300.json`、`atk_ref300.log` —— 换源统计 bug 未修时的数字", 1)

io.open(P, "w", encoding="utf-8", newline="\n").write(s)
print("miss:", miss, "| lines:", s.count("\n") + 1)
