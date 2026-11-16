# -*- coding: utf-8 -*-
import sqlite3

for db in (r"E:\v7work\model\v7_model.sqlite", r"E:\v7work\model\v7_law.sqlite"):
    m = sqlite3.connect(db)
    print("==", db)
    tables = [r[0] for r in m.execute("select name from sqlite_master where type='table'")]
    for t in tables:
        cols = [r[1] for r in m.execute(f"pragma table_info({t})")]
        hit = [c for c in cols if "bank" in c.lower() or "col" in c.lower()]
        print(f"  {t}: {cols}" + (f"   <<< {hit}" if hit else ""))
