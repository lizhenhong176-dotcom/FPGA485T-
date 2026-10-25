import json
from collections import Counter, defaultdict

def f(L):
    return 22 + ((L // 4) % 2), 1 + 8 * (L % 4) + (L // 8)

# ---- 1) 5x5 coverage test on IMUX_L8 ----
cells = json.load(open("source_cells_IMUX_L8.json", encoding="utf-8"))
G1 = {0, 2, 5, 8, 10}
G2 = {8, 10, 14, 16, 18}
print("== 5x5 hypothesis ==")
coords = {}
for s, cs in cells.items():
    a = [c for c in cs if c in G1 and c not in (7, 12)]
    b = [c for c in cs if c in G2 and c not in (7, 12)]
    coords[s] = (tuple(a), tuple(b))
for s in sorted(coords):
    print("%-18s G1=%s G2=%s" % (s, coords[s][0], coords[s][1]))
uniq = len(set(coords.values()))
print("distinct coord tuples:", uniq, "sources:", len(coords))

# ---- 2) cross-mux consistency ----
d = json.load(open("p3_bits.json", encoding="utf-8"))
bymux = {}
for tag, variants in d.items():
    # tag like A1..A6 ; mux number from p3 known map
    pass
print("\n== cross-mux (p3) ==")
# mux number known: A1->7 A2->2 A3->1 A4->11 A5->8 A6->4
M = {"A1": 7, "A2": 2, "A3": 1, "A4": 11, "A5": 8, "A6": 4}
per = defaultdict(dict)
for tag, variants in d.items():
    L = M[tag]
    w, b = f(L)
    for src, rec in variants.items():
        rel = sorted({(fr - 31696, bb - b) for fr, ww, bb in rec["config"] if ww == w})
        per[src][tag] = rel
for src in sorted(per):
    tags = per[src]
    if len(tags) > 1:
        print("%-18s %s" % (src, {t: v for t, v in tags.items()}))
