import sqlite3
from pathlib import Path

DB = Path("/data/lzh/v7re/work/refs_20261021/routing/v7_routing.db")
conn = sqlite3.connect(DB)
conn.row_factory = sqlite3.Row
for label, sql in (
    ("tileconn CLBLL_L", "select * from tileconn where dst_type='CLBLL_L' limit 10"),
    ("tileconn CLBLM_L", "select * from tileconn where dst_type='CLBLM_L' limit 10"),
    ("tileconn INT_L->CLBLL", "select * from tileconn where type? limit 3"),
):
    pass
rows = list(conn.execute("select * from tileconn where dst_type='CLBLL_L' limit 10"))
print("tileconn CLBLL_L count", len(rows))
for r in rows: print(dict(r))
print("-- distinct dst types with CLB")
for r in conn.execute("select dst_type,count(*) n from tileconn where dst_type like 'CLB%' group by dst_type"):
    print(dict(r))
print("-- tileconn where wires mention IMUX")
n=0
for r in conn.execute("select * from tileconn where wires like '%IMUX%' limit 10"):
    print(dict(r)); n+=1
print("n",n)
