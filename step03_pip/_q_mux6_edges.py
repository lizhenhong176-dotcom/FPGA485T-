# -*- coding: utf-8 -*-
import json, io, sqlite3, collections, re
TC = json.load(io.open(r"E:\v7work\db\prjxray\xc7vx485t\tileconn.json", encoding="utf-8"))
# 建立 INT_L 侧 wire -> [(自身在 A 侧 or B 侧, delta 指向对端)]
idx = collections.defaultdict(list)
for e in TC:
    tts = e.get("tile_types") or []
    gd = e.get("grid_deltas") or [0, 0]
    for a, b in e.get("wire_pairs") or []:
        if "INT_L" in tts:
            # 若 a 属于 INT_L 侧（假设顺序与 tile_types 对应）
            if tts[0] == "INT_L": idx[a].append((gd[0], gd[1], b, tts[1] if len(tts) > 1 else "?"))
            if tts[-1] == "INT_L": idx[b].append((-gd[0], -gd[1], a, tts[0] if tts else "?"))
print("INT_L wire 有对外连接的:", len(idx))

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite"); cur = con.cursor()
cur.execute("SELECT family, src_wire, frame_off FROM law_cells WHERE tile_type='INT_L' AND sense=1")
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo in cur.fetchall(): fam[f][s].add(fo)
mux = {f: v for f, v in fam.items() if len(v) == 24}

def line_sources(srcs):
    out = []
    for s, fos in srcs.items():
        grp = [x for x in fos if 16 <= x <= 21]
        if len(grp) == 1 and grp[0] <= 19: out.append((grp[0], s))
    return out

# 先看 IMUX_L40 的行 → 到达边
for f in ["IMUX_L40", "IMUX_L0", "BYP_ALT0"]:
    print("==", f)
    rows = collections.defaultdict(list)
    for r, s in line_sources(mux[f]):
        rows[r].append((s, idx.get(s, [])))
    for r in sorted(rows):
        print("  row %d:" % r)
        for s, e in rows[r]:
            d = sorted({(x[0], x[1]) for x in e})
            print("     %-16s deltas=%s" % (s, d[:4]))