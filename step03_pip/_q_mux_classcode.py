# -*- coding: utf-8 -*-
import sys, collections
sys.path.insert(0, r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip")
import gen_mux, gen_slots

fam = gen_slots.load()
m24 = {f: d for f, d in fam.items() if len(d) == 24}
bad = 0
for f, d in sorted(m24.items())[:3]:
    dec = gen_mux.decompose({s: set(cs) for s, cs in d.items()})
    slots, b0, p = dec
    tab = collections.defaultdict(set)
    for s, (r, c) in slots.items():
        tab[(gen_slots.line_class(s), r)].add(c)
    print(f, "primary bit", b0, "parity", p)
    for k in sorted(tab, key=str):
        print("   ", k, sorted(tab[k]))
# 全局：每个 (class, row) 的 code 集合
glob = collections.defaultdict(collections.Counter)
for f, d in m24.items():
    dec = gen_mux.decompose({s: set(cs) for s, cs in d.items()})
    slots, b0, p = dec
    for s, (r, c) in slots.items():
        glob[(gen_slots.line_class(s), r)][c] += 1
print("\n(class, row) -> code 分布：")
for k in sorted(glob, key=str):
    print("   ", k, dict(glob[k]))
