import json
p6 = json.load(open("p6_bits.json", encoding="utf-8"))
p1 = json.load(open("reuse_bits.json", encoding="utf-8"))
const = set(map(tuple, p1["NR1END0"]["config"]))
def raw(recs):
    return {s: sorted({(fr, bb) for fr, ww, bb in rec["config"]}) for s, rec in recs.items()}
tabs = {"L8": {s: sorted({(fr, bb) for fr, ww, bb in set(map(tuple, p1[s]["config"])) - const}) for s in p1},
        "L2": raw(p6["A2"]), "L7": raw(p6["A1"])}
norm = {}
for mux, tab in tabs.items():
    bits = [b for v in tab.values() for _f, b in v]
    frames = [f for v in tab.values() for f in [x[0] for x in v]]
    b0, f0 = min(bits), min(frames)
    norm[mux] = {s: tuple(sorted({(f - f0, b - b0) for f, b in v})) for s, v in tab.items()}
    print(mux, "b0", b0, "f0", f0)
same = 0
for i in range(25):
    got = {}
    for mux in norm:
        s = sorted(norm[mux])[i]
        got[mux] = norm[mux][s]
    if got["L2"] == got["L7"]:
        same += 1
    print(i, got["L8"], got["L2"], got["L7"], "L2==L7" if got["L2"] == got["L7"] else "")
print("L2==L7 at ordinal:", same)
