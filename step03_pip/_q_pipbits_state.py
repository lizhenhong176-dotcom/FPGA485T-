import sqlite3
m = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
print([r[0] for r in m.execute("select name from sqlite_master where type='table'")])
cols = [r[1] for r in m.execute("PRAGMA table_info(pip_bits)")]
print("pip_bits cols:", cols)
if "source" in cols:
    for r in m.execute("select source,count(*) from pip_bits group by source order by 2 desc limit 8"):
        print("src", r)
print("tile types:", [r for r in m.execute(
    "select tile_type,count(*) from pip_bits group by tile_type order by 2 desc limit 8")] if "tile_type" in cols else "n/a")
