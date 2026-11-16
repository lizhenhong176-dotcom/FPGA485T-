# -*- coding: utf-8 -*-
import io
import json
import re
import sqlite3
import sys
import collections
import os

HERE = os.path.join(r"E:\DEEPSEEK\FPGA比特流逆向", "v7re", "scripts")
sys.path.insert(0, HERE)
from verify_all_pip import norm_name, load_cells  # noqa: E402

mux = json.load(open(os.path.join(r"E:\DEEPSEEK\FPGA比特流逆向", "v7re", "steps", "pip_reuse_law.json"), encoding="utf-8"))
beg = json.load(open(os.path.join(r"E:\DEEPSEEK\FPGA比特流逆向", "v7re", "steps", "beg_families.json"), encoding="utf-8"))["families"]
mux_fams, beg_fams = set(mux["families"]), set(beg)

cellsR = load_cells(r"E:\v7work\model\v7_law.sqlite", "INT_R")
cellsL = load_cells(r"E:\v7work\model\v7_law.sqlite", "INT_L")

missing = collections.Counter()
uncovered_fams = collections.Counter()
for (fam, src), got in cellsR.items():
    f2 = norm_name(fam, mux_fams, beg_fams)
    s2 = norm_name(src, mux_fams, beg_fams)
    if f2 in mux["families"]:
        ok = s2 in mux["families"][f2]["slots"]
    elif f2 in beg:
        ok = s2 in beg[f2]["sources"]
    else:
        uncovered_fams[fam] += 1
        continue
    if not ok:
        missing[(fam, src)] += 1

print("缺源条目数:", sum(missing.values()), "涉及族:", len({f for f, _ in missing}))
print("未覆盖族:", dict(uncovered_fams))
print("缺源样例:")
for (f, s), _ in list(missing.items())[:15]:
    print("  ", f, s, "| INT_L 同族源:", [x for x in {s for (ff, s) in cellsL if ff == f}][:6])
