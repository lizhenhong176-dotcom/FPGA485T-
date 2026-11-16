import sqlite3
con = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
names = [r[0] for r in con.execute("SELECT name FROM sqlite_master WHERE type='table'")]
print(names)
for n in names:
    c = con.execute("SELECT COUNT(*) FROM %s" % n).fetchone()[0]
    print(n, c)
