# -*- coding: utf-8 -*-
import json, sqlite3, collections
T = json.load(open(r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json", encoding="utf-8"))
pips = T["pip_defs"]
fam = collections.defaultdict(list)
for src, dst, delay, inv in pips: fam[dst].append(src)
mux = {k: v for k, v in fam.items() if len(v) > 1}
direct = {k: v for k, v in fam.items() if len(v) == 1}
print("total_pips", len(pips), "dst", len(fam), "mux_families", len(mux), "mux_pips", sum(len(v) for v in mux.values()), "direct", len(direct))
con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite"); cur = con.cursor()
cur.execute("select count(*), count(distinct family) from law_cells where tile_type='INT_L' and sense=1")
feat, nf = cur.fetchone(); print("law sense1 features", feat, "families", nf)
vcc = sum(1 for k, v in mux.items() if any(s.upper().startswith("VCC") for s in v))
vccp = sum(1 for k, v in mux.items() for s in v if s.upper().startswith("VCC"))
print("families_with_VCC", vcc, "VCC_pips", vccp, "mux_pips-VCC", sum(len(v) for v in mux.values()) - vccp)
con.close()