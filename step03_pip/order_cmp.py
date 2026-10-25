import json, re
tt = json.load(open(r"E:\v7work\db\prjxray\xc7vx485t\tile_type_INT_L.json", encoding="utf-8"))
order = {}
for p in tt["pips"]:
    for L in (2, 7, 8):
        if p.endswith("->IMUX_L%d" % L):
            src = p.split(".")[1].split("->")[0]
            order.setdefault(L, []).append(src)

def f(L): return 22 + ((L//4)%2), 1 + 8*(L%4) + (L//8)
p1 = json.load(open("reuse_bits.json", encoding="utf-8"))
p6 = json.load(open("p6_bits.json", encoding="utf-8"))
const = set(map(tuple, p1["NR1END0"]["config"]))
def masks(recs, L):
    w, b = f(L)
    return {s: tuple(sorted({(fr-31696, bb-b) for fr, ww, bb in rec["config"] if ww == w})) for s, rec in recs.items()}
tabs = {8: {s: tuple(sorted({(fr-31696, bb-2) for fr, ww, bb in set(map(tuple, p1[s]["config"])) - const})) for s in p1},
        2: masks(p6["A2"], 2), 7: masks(p6["A1"], 7)}
for L in (2, 7, 8):
    print("L%d order len %d" % (L, len(order.get(L, []))))
same = 0
for i in range(25):
    row = {}
    for L in (2, 7, 8):
        src = order[L][i]
        row[L] = tabs[L].get(src, "MISSING")
    if row[2] == row[7] == row[8]:
        same += 1
    print(i, order[8][i][:16], "L8", row[8], "| L2", row[2], "| L7", row[7])
print("identical at ordinal:", same)
