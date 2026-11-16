# -*- coding: utf-8 -*-
import sqlite3, collections, io

con = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
q = ("select tile, wire_a, wire_b, frame, word, bit, kind, note from pip_bits "
     "where tile like 'CLBLL_L%' limit 5")
print("CLBLL_L 样例:")
for r in con.execute(q):
    print("  ", r)

c = collections.Counter(r[0] for r in con.execute(
    "select wire_b from pip_bits where tile like 'CLBLL_L%'"))
print("\n目的 wire 前 12:", c.most_common(12))
c2 = collections.Counter(r[0] for r in con.execute(
    "select tile from pip_bits where tile like 'CLBLL_L%'"))
print("覆盖 tile 数:", len(c2), list(c2.items())[:3])

s = io.open(r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md", encoding="utf-8").read().splitlines()
print("\n相关 STATUS 行:")
for i, l in enumerate(s, 1):
    if "全类型" in l or "T44" in l:
        print(i, l[:160])
