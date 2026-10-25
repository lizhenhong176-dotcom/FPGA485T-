import json
d = json.load(open(r"step03_pip\reuse_bits.json", encoding="utf-8"))
F0 = 31696
rows = {}
for src, rec in d.items():
    cells = sorted({(f - F0) * 2 + (b - 2) for f, w, b in rec["config"] if w == 22 and b in (2, 3)})
    rows[src] = cells
for src in sorted(rows):
    print("%-18s %s" % (src, rows[src]))
from collections import Counter
print("\ncell-index usage:")
c = Counter(i for v in rows.values() for i in v)
print(dict(sorted(c.items())))
print("\npopcount:", dict(Counter(len(v) for v in rows.values())))
json.dump(rows, open(r"step03_pip\source_cells_IMUX_L8.json", "w"), indent=1)
