"""judge_r.py —— 用 pip_law 的预测核对 INT_R 124 个家族的实测差分。"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pip_law

TILE = "INT_R_X7Y10"
obs = json.load(open(os.path.join(HERE, "famdiff_r.json")))
allrec = json.load(open(os.path.join(HERE, "all_cells.json")))
families = sorted({r["family"] for r in allrec if r["tile_type"] == "INT_R"},
                  key=len, reverse=True)

ok = bad = empty = extra = 0
bad_list = []
for name, cells in sorted(obs.items()):
    stem = name[len("v_"):]
    family = next(f for f in families if stem.startswith(f + "_"))
    src = stem[len(family) + 1:]
    ones = {(f, w, b) for f, w, b in cells}
    rows = pip_law.predict_family(TILE, family, src)
    exp = {(f, w, b) for f, w, b, s in rows if s == 1}
    if not ones:
        empty += 1
        bad_list.append((name, "EMPTY", []))
        continue
    if ones <= exp:
        ok += 1
    else:
        extra += 1
        bad_list.append((name, "EXTRA", sorted(ones - exp)[:3]))
for name, kind, detail in bad_list[:12]:
    print(f"  [{kind}] {name} {detail}")
print(f"INT_R 家族: {ok}/{ok + extra + empty}  PASS, EXTRA {extra}, EMPTY {empty}")
