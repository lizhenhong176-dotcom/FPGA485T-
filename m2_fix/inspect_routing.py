import sqlite3
from pathlib import Path

path = Path("/data/lzh/v7re/work/refs_20261021/routing/v7_routing.db")
conn = sqlite3.connect(path)
conn.row_factory = sqlite3.Row

tables = [r[0] for r in conn.execute(
    "select name from sqlite_master where type='table' order by name"
)]
for table in tables:
    print("TABLE", table)
    cols = list(conn.execute(f"pragma table_info({table})"))
    for row in cols:
        print("  ", tuple(row))
    try:
        n = conn.execute(f"select count(*) from {table}").fetchone()[0]
        print("  rows", n)
    except Exception as exc:
        print("  count error", exc)
    try:
        rows = list(conn.execute(f"select * from {table} limit 2"))
        for row in rows:
            print("  sample", str(tuple(row))[:600])
    except Exception as exc:
        print("  sample error", exc)


