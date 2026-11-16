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
fam = "CLK_L0"
print("json keys of one group:", json.dumps(cg[fam][0], ensure_ascii=False)[:400])
for g in cg[fam]:
    core = {tuple(c) for c in g["core"]}
    print("\ncore", sorted(core))
    for s, drop in g.get("drops", {}).items():
        print("  drop", s, "cell", drop, "pred", sorted(core - {tuple(drop)}), "obs", sorted(rows[(fam, s)]))
    for s, extra in g.get("extras", {}).items():
        print("  extra", s, "cell", extra, "pred", sorted(core | {tuple(extra)}), "obs", sorted(rows[(fam, s)]))
