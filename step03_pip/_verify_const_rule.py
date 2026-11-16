import collections
import json
import sqlite3

con = sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro", uri=True)
rows = collections.defaultdict(set)
for fam, src, fo, bit, par in con.execute(
        "select family,src_wire,frame_off,bit,parity from law_cells "
        "where tile_type='INT_L' and sense=1"):
    rows[(fam, src)].add((fo, par, bit))

cg = json.load(open(r"E:/DEEPSEEK/FPGA比特流逆向/v7re/steps/composite_groups.json", encoding="utf-8"))
ok = 0
bad = 0
for fam in ("CLK_L0", "CLK_L1", "CTRL_L0", "CTRL_L1", "GFAN0", "GFAN1"):
    srcs = {s for (f, s) in rows if f == fam}
    const = set.intersection(*[rows[(fam, s)] for s in srcs])
    groups = cg[fam]
    built = 0
    for g in groups:
        core = {tuple(c) for c in g["core"]}
        for s, drop in g.get("drops", {}).items():
            exp = (core - {tuple(drop)}) | const
            built += 1
            if exp == rows[(fam, s)]:
                ok += 1
            else:
                bad += 1
        for s, extra in g.get("extras", {}).items():
            exp = (core | {tuple(extra)}) | const
            built += 1
            if exp == rows[(fam, s)]:
                ok += 1
            else:
                bad += 1
    print(fam, "srcs", len(srcs), "const", len(const), sorted(const), "groups", len(groups), "built", built)
print("TOTAL built", ok + bad, "exact+const", ok, "bad", bad)

# also without const, for the record
ok2 = 0
for fam in ("CLK_L0",):
    srcs = {s for (f, s) in rows if f == fam}
    for g in cg[fam]:
        core = {tuple(c) for c in g["core"]}
        for s, drop in g.get("drops", {}).items():
            ok2 += 1 if (core - {tuple(drop)}) == rows[(fam, s)] else 0
print("CLK_L0 exact without const:", ok2, "/ 12")
