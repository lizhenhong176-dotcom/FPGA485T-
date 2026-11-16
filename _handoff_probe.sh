set -u
export LANG=C LC_ALL=C
echo "== host =="; hostname; df -h /opt/lzh | tail -1
echo "== dbs =="
ls -la /opt/lzh/v7re/data/model/ 2>/dev/null || echo "NO data/model"
ls -la /opt/lzh/v7re/ 2>/dev/null | head -20
echo "== counts =="
P=/opt/lzh/venv/bin/python
$P - <<PYEOF
import sqlite3, os
for db in ("/opt/lzh/v7re/data/model/v7_model.sqlite", "/opt/lzh/v7re/data/model/v7_law.sqlite"):
    if not os.path.exists(db):
        print(db, "MISSING"); continue
    c=sqlite3.connect(db)
    t=[r[0] for r in c.execute("select name from sqlite_master where type='table' order by name")]
    print("--", db, round(os.path.getsize(db)/1048576,1), "MB", len(t), "tables")
    for n in ("frame_map","site_frames","sites","site_pins","law_cells","clb_blocks"):
        if n in t:
            try: print("   %-14s %s"%(n, c.execute("select count(*) from %s"%n).fetchone()[0]))
            except Exception as e: print("   %s ERR %s"%(n,e))
    c.close()
PYEOF
echo "== work dirs =="
ls -d /opt/lzh/v7re/work/*/ 2>/dev/null | head -40
