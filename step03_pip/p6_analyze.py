import json
def f(L): return 22 + ((L//4)%2), 1 + 8*(L%4) + (L//8)
MUX = {"L7": (7, "A1"), "L2": (2, "A2"), "L8": (8, None)}
p6 = json.load(open("p6_bits.json", encoding="utf-8"))
# L8 data from P1 (25 sources)
p1 = json.load(open("reuse_bits.json", encoding="utf-8"))
const = set(map(tuple, p1["NR1END0"]["config"]))

def rels(recs, L):
    w, b = f(L)
    out = {}
    for s, rec in recs.items():
        out[s] = sorted({(fr - 31696, bb - b) for fr, ww, bb in rec["config"] if ww == w})
    return out

l8 = {}
for s in p1:
    cfg = set(map(tuple, p1[s]["config"])) - const
    l8[s] = sorted({(fr - 31696, bb - 2) for fr, ww, bb in cfg})
r = {"L8": l8}
for name, (L, tag) in [("L7", (7, "A1")), ("L2", (2, "A2"))]:
    r[name] = rels(p6[tag], L)

for name in ["L8", "L7", "L2"]:
    print("==", name, "distinct patterns:", len({tuple(v) for v in r[name].values()}))
common = set(r["L8"]) & set(r["L7"]) & set(r["L2"])
print("common sources:", len(common))
same = [s for s in common if tuple(r["L8"][s]) == tuple(r["L7"][s]) == tuple(r["L2"][s])]
print("identical pattern across 3 muxes:", len(same))
for s in sorted(common)[:8]:
    print("%-18s L8=%s L7=%s L2=%s" % (s, r["L8"][s], r["L7"][s], r["L2"][s]))
