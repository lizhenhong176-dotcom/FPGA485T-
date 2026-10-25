set -u
echo "=== HOST ==="; hostname; date -Is; uname -r
echo "=== DB ==="
ls -l --time-style=full-iso /opt/lzh/v7re/data/model/v7_model.sqlite
python3 - <<'PY'
import sqlite3
db='/opt/lzh/v7re/data/model/v7_model.sqlite'
c=sqlite3.connect('file:%s?mode=ro'%db, uri=True)
tabs=[r[0] for r in c.execute("select name from sqlite_master where type='table' order by name")]
for t in tabs:
    try: n=c.execute('select count(*) from "%s"'%t).fetchone()[0]
    except Exception as e: n='ERR %s'%e
    print('%-16s %s'%(t,n))
PY
echo "=== RECENT (3d) ==="
find /opt/lzh/step03 /opt/lzh/v7re -maxdepth 2 -newermt '-3 days' -type f -printf '%TY-%Tm-%Td %TH:%TM %10s %p\n' 2>/dev/null | sort -r | head -40