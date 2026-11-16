# -*- coding: utf-8 -*-
import json
import io
import sqlite3

b = json.load(io.open(r"E:\DEEPSEEK\FPGA比特流逆向\v7re\steps\beg_families.json", encoding="utf-8"))
fam = b["families"]
print("families", len(fam))
k0 = list(fam)[0]
print("sample key", k0, json.dumps(fam[k0], ensure_ascii=False)[:400])

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
q = "select count(distinct family) from law_cells where tile_type=?"
print("law_cells families:", [(tt, con.execute(q, (tt,)).fetchone()[0]) for tt in ("INT_L", "INT_R")])

for f in ("EE2BEG0", "BYP_ALT0", "IMUX_L40"):
    for tt in ("INT_L", "INT_R"):
        rows = [r[0] for r in con.execute(
            "select distinct src_wire from law_cells where tile_type=? and family=?", (tt, f))]
        print(tt, f, "srcs", len(rows), rows[:10])
    v = fam.get(f)
    print("  model:", (json.dumps(v, ensure_ascii=False)[:200] if v else "MISSING"))
