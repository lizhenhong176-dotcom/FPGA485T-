import json
def f(L): return 22 + ((L//4)%2), 1 + 8*(L%4) + (L//8)
p6 = json.load(open("p6_bits.json", encoding="utf-8"))
p1 = json.load(open("reuse_bits.json", encoding="utf-8"))
const = set(map(tuple, p1["NR1END0"]["config"]))
def rels(recs, L):
    w, b = f(L)
    return {s: tuple(sorted({(fr-31696, bb-b) for fr, ww, bb in rec["config"] if ww == w})) for s, rec in recs.items()}
tables = {"L8": {s: tuple(sorted({(fr-31696, bb-2) for fr, ww, bb in set(map(tuple, p1[s]["config"])) - const})) for s in p1},
          "L2": rels(p6["A2"], 2), "L7": rels(p6["A1"], 7)}
by_ord = {}
for mux, tab in tables.items():
    for i, s in enumerate(sorted(tab)):
        by_ord.setdefault(i, {})[mux] = tab[s]
match = 0
for i in range(25):
    rec = by_ord.get(i, {})
    vals = list(rec.values())
    if len(vals) == 3 and vals[0] == vals[1] == vals[2]:
        match += 1
    print(i, {m: rec[m] for m in rec})
print("ordinal-identical:", match, "/25")
