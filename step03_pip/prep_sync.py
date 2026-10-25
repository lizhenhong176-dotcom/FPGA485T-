import sqlite3, os, shutil
src = r"E:\v7work\model\v7_model.sqlite"
c = sqlite3.connect(src)
c.execute("pragma wal_checkpoint(FULL)")
c.close()
dst = r"E:\v7work\model\v7_model_for_sync.sqlite"
shutil.copyfile(src, dst)
print("size", os.path.getsize(dst))
d = sqlite3.connect(dst)
print("rows", d.execute("select count(*) from pip_bits").fetchone()[0], d.execute("select count(*) from bit_map").fetchone()[0])
print("integrity", d.execute("pragma integrity_check").fetchone()[0])
