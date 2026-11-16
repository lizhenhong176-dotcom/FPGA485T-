# -*- coding: utf-8 -*-
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))
m24 = {f: d for f, d in fam.items() if len(d) == 24}

reasons = collections.Counter()
for f, d in sorted(m24.items()):
    rows_fr = sorted({fo for cs in d.values() for fo, _, _ in cs if 16 <= fo <= 21})
    code_fr = sorted({fo for cs in d.values() for fo, _, _ in cs if 22 <= fo <= 25})
    bits = {b for cs in d.values() for _, _, b in cs}
    rsn = []
    if len(rows_fr) != 6:
        rsn.append("rows")
    if len(code_fr) != 4:
        rsn.append("codes")
    b0 = min(bits)
    for s, cs in d.items():
        rf = [fo for fo, _, _ in cs if 16 <= fo <= 21]
        if len(rf) != 1:
            rsn.append("src_row_multi")
            break
        r = rf[0] - 16
        rb = [b for fo, _, b in cs if fo == rf[0]][0]
        want = b0 if r in (0, 1, 4, 5) else b0 ^ 1
        if rb != want:
            rsn.append(f"bit_rule_r{r}")
            break
    reasons[tuple(rsn)] += 1
    if rsn and f in ("BYP_ALT0", "FAN_ALT0", "IMUX_L0"):
        print(f, rsn, sorted(d.items())[:2])
print(reasons.most_common())
