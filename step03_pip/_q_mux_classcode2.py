# -*- coding: utf-8 -*-
import sys, collections, re
sys.path.insert(0, r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip")
import gen_mux, gen_slots


def cls2(s):
    if re.match(r"^(NE|NW|SE|SW)", s):
        return "diag"
    if re.match(r"^(NL|SL|EL|WL)", s):
        return "rlineL"
    if re.match(r"^(NR|SR|ER|WR)", s):
        return "rlineR"
    if re.match(r"^(EE|WW|NN|SS)\d", s):
        return "axis"
    if s.startswith(("LOGIC_OUTS", "GFAN")):
        return "logic"
    if s.startswith(("BYP_", "FAN_")):
        return "bounce"
    return "other:" + s


fam = gen_slots.load()
m24 = {f: d for f, d in fam.items() if len(d) == 24}
glob = collections.defaultdict(collections.Counter)
others = collections.Counter()
for f, d in m24.items():
    dec = gen_mux.decompose({s: set(cs) for s, cs in d.items()})
    slots, b0, p = dec
    for s, (r, c) in slots.items():
        k = cls2(s)
        if k.startswith("other"):
            others[s] += 1
        glob[(k, r)][c] += 1
print("class x row -> code:")
for k in sorted(glob, key=str):
    if k[0] in ("bounce", "logic"):
        continue
    print("   ", k, dict(glob[k]))
print("\n未被分类的源：", dict(others))
