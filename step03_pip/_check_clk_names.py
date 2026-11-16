# -*- coding: utf-8 -*-
import io
import json
import sqlite3

beg = json.load(io.open(r"E:\DEEPSEEK\FPGA比特流逆向\v7re\steps\beg_families.json", encoding="utf-8"))["families"]
mux = json.load(io.open(r"E:\DEEPSEEK\FPGA比特流逆向\v7re\steps\pip_reuse_law.json", encoding="utf-8"))["families"]

for f in ("CLK_L0", "CLK0"):
    if f in beg:
        print(f, "beg sources:", sorted(beg[f]["sources"])[:8], "n=", len(beg[f]["sources"]))
    if f in mux:
        print(f, "mux slots:", sorted(mux[f]["slots"])[:8], "n=", len(mux[f]["slots"]))

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
for tt, fam in (("INT_L", "CLK_L0"), ("INT_R", "CLK0")):
    rows = [r[0] for r in con.execute(
        "select distinct src_wire from law_cells where tile_type=? and family=? order by src_wire", (tt, fam))]
    print(tt, fam, len(rows), rows)
