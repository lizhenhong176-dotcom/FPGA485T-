import json, re
def f(L): return 22 + ((L//4)%2), 1 + 8*(L%4) + (L//8)
p6 = json.load(open("p6_bits.json", encoding="utf-8"))
p1 = json.load(open("reuse_bits.json", encoding="utf-8"))
const = set(map(tuple, p1["NR1END0"]["config"]))
def rels(recs, L):
    w, b = f(L)
    return {s: sorted({(fr-31696, bb-b) for fr, ww, bb in rec["config"] if ww == w}) for s, rec in recs.items()}
l8 = {s: sorted({(fr-31696, bb-2) for fr, ww, bb in set(map(tuple, p1[s]["config"])) - const}) for s in p1}
groups = {"L8": l8, "L2": rels(p6["A2"], 2), "L7": rels(p6["A1"], 7)}
fam = {}
for mux, table in groups.items():
    for src, pat in table.items():
        base = re.sub(r"\d+$", "", src)
        fam.setdefault(base, {}).setdefault(mux, []).append((src, pat))
for base in sorted(fam):
    print("== " + base)
    for mux in ["L8", "L2", "L7"]:
        for src, pat in fam[base].get(mux, []):
            print("   %-4s %-20s %s" % (mux, src, pat))
