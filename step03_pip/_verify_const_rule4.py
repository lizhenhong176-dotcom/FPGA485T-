import sqlite3

con = sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro", uri=True)
print("law_cells INT_L rows by sense:", con.execute(
    "select sense, count(*) from law_cells where tile_type='INT_L' group by sense").fetchall())
print("pairs with sense=0:", con.execute(
    "select count(distinct family||'|'||src_wire) from law_cells where tile_type='INT_L' and sense=0").fetchone()[0])
print("pairs total:", con.execute(
    "select count(distinct family||'|'||src_wire) from law_cells where tile_type='INT_L'").fetchone()[0])
print("families with sense=0 rows:", con.execute(
    "select count(distinct family) from law_cells where tile_type='INT_L' and sense=0").fetchone()[0])
print("sense=1 cells per pair (top 5):", con.execute(
    "select family, src_wire, count(*) c from law_cells where tile_type='INT_L' and sense=1 "
    "group by family, src_wire order by c desc limit 5").fetchall())
print("sense=0 cells per pair (top 5):", con.execute(
    "select family, src_wire, count(*) c from law_cells where tile_type='INT_L' and sense=0 "
    "group by family, src_wire order by c desc limit 5").fetchall())
