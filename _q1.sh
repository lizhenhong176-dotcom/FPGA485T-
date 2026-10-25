set -u
echo "=== HOST ==="; hostname; date -Is
echo "=== DB ==="; ls -l --time-style=full-iso /opt/lzh/v7re/data/model/v7_model.sqlite
python3 - <<'PY'
import sqlite3
c=sqlite3.connect('file:/opt/lzh/v7re/data/model/v7_model.sqlite?mode=ro',uri=True)
for t in [r[0] for r in c.execute("select name from sqlite_master where type='table' order by name")]:
    try: n=c.execute('select count(*) from "%s"'%t).fetchone()[0]
    except Exception as e: n='ERR %s'%e
    print('%-16s %s'%(t,n))
PY
echo "=== RECENT (3d) ==="
find /opt/lzh/step03 /opt/lzh/v7re -maxdepth 2 -newermt '-3 days' -type f -printf '%TY-%Tm-%Td %TH:%TM %10s %p\n' 2>/dev/null | sort -r | head -40