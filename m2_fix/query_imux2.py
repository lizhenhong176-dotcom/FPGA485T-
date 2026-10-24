import sqlite3
from pathlib import Path

DB = Path("/data/lzh/v7re/work/refs_20261021/routing/v7_routing.db")
conn = sqlite3.connect(DB)
conn.row_factory = sqlite3.Row
for label, sql in (
    ("target IMUX", "select * from conn_rules where target_wire like '%IMUX%' limit 20"),
    ("wire IMUX", "select * from conn_rules where wire like '%IMUX%' limit 20"),
    ("INT_R IMUX1", "select * from conn_rules where type='INT_R' and wire='IMUX1' limit 20"),
    ("INT_L IMUX1", "select * from conn_rules where type='INT_L' and wire='IMUX_L1' limit 20"),
):
    print("==", label)
    rows = list(conn.execute(sql))
    print("count", len(rows))
    for r in rows:
        print(dict(r))
