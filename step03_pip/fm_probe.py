import sqlite3, json
con = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
for t in ["frame_map", "blocks", "regions"]:
    try:
        cols = [r[1] for r in con.execute("PRAGMA table_info(%s)" % t)]
        n = con.execute("SELECT COUNT(*) FROM %s" % t).fetchone()[0]
        print(t, n, cols[:12])
    except Exception as e:
        print(t, "ERR", e)
try:
    rows = con.execute("SELECT * FROM frame_map LIMIT 3").fetchall()
    print(rows)
except Exception as e:
    print("frame_map sample ERR", e)
