import json
d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8"))
rec = [v for v in d.values() if v["sink"] == "IMUX_L8"][0]["sources"]
# group by row cell
from collections import defaultdict
rows = defaultdict(list)
for s, m in rec.items():
    mm = sorted((f - 31696, b - 2) for f, w, b in m)
    r = [c for c in mm if c[0] <= 5]
    c = tuple(c[0] for c in mm if c[0] >= 6)
    rows[r[0] if r else ()].append((s, c))
for r in sorted(rows, key=lambda x: x[0] if x else 99):
    print("row", r, "->", sorted(rows[r]))
