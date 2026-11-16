# -*- coding: utf-8 -*-
import json, sqlite3, collections

GRID = r"E:\v7work\db\prjxray\xc7vx485t\tilegrid.json"
MODEL = r"E:\v7work\model\v7_model.sqlite"
LAW = r"E:\v7work\model\v7_law.sqlite"

g = json.load(open(GRID, encoding="utf-8"))
cnt = collections.Counter(v.get("type") for v in g.values())
print("类型数:", len(cnt), "总计:", sum(cnt.values()))
for k, v in cnt.most_common():
    print(f"  {k:<26} {v}")

con = sqlite3.connect(MODEL)
cols = [r[1] for r in con.execute("pragma table_info(pip_bits)")]
print("\npip_bits 列:", cols)
tc = "tile_type" if "tile_type" in cols else cols[0]
tn = "tile_name" if "tile_name" in cols else None
print("pip_bits 总数:", con.execute("select count(*) from pip_bits").fetchone()[0])
if "source" in cols:
    for r in con.execute("select source, count(*) from pip_bits group by source"):
        print("   source:", r)
print("pip_bits 样例:", con.execute("select * from pip_bits limit 2").fetchall())
con2 = sqlite3.connect(LAW)
print("\nlaw_tiles 全部类型:", [r for r in con2.execute(
    "select tile_type, count(*) from law_tiles group by tile_type order by 2 desc")])
