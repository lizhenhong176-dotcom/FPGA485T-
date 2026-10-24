import sqlite3
from pathlib import Path

DB = Path("/data/lzh/v7re/work/refs_20261021/routing/v7_routing.db")
conn = sqlite3.connect(DB)
conn.row_factory = sqlite3.Row
for target in ("CLBLL_IMUX1", "CLBLL_IMUX8", "CLBLL_IMUX9",
               "CLBLL_IMUX16", "CLBLL_IMUX24", "CLBLL_IMUX25"):
    print("==", target)
    rows = list(conn.execute(
        "select type,wire,dx,dy,target_type from conn_rules where target_wire=? limit 20",
        (target,),
    ))
    print("count", len(rows))
    for r in rows:
        print(dict(r))
print("distinct CLBLL target wires")
for r in conn.execute(
    "select target_wire,count(*) n from conn_rules where target_type='CLBLL_L' group by target_wire order by n desc limit 10"
):
    print(dict(r))
