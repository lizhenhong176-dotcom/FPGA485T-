# -*- coding: utf-8 -*-
import json, sqlite3, collections, re
def norm(s):
    s = re.sub(r"_(L|R)\b", "", s)
    s = s.replace("_L_", "_").replace("_R_", "_")
    s = re.sub(r"^(IMUX)_L?(\d+)$", r"IMUX\2", s)
    return s
T = json.load(open(r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json", encoding="utf-8"))
tpl = collections.defaultdict(set)
for src, dst, d, i in T["pip_defs"]: tpl[dst].add(norm(src))
tpl_pairs = {(d, s) for d, ss in tpl.items() for s in ss}
con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite"); cur = con.cursor()
cur.execute("select family, src_wire from law_cells where tile_type='INT_L' and sense=1")
law_pairs = {(f, norm(s)) for f, s in cur.fetchall()}
print("tpl_pairs", len(tpl_pairs), "law_pairs_norm", len(law_pairs))
print("law_only", len(law_pairs - tpl_pairs), "tpl_only", len(tpl_pairs - law_pairs))
print("sample law_only", sorted(law_pairs - tpl_pairs)[:6])
print("sample tpl_only", sorted(tpl_pairs - law_pairs)[:6])
con.close()