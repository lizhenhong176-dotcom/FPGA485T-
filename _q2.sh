set -u
echo "=== step03 dir ==="; ls -lt --time-style=+%F_%T /opt/lzh/step03 | sed -n '1,20p'
echo "=== v7re dir ==="; ls -lt --time-style=+%F_%T /opt/lzh/v7re | sed -n '1,20p'
echo "=== newer than 7d ==="
find /opt/lzh/step03 /opt/lzh/v7re -maxdepth 2 -newermt '-7 days' -type f -printf '%TY-%Tm-%Td %TH:%TM %10s %p\n' 2>/dev/null | sort -r | sed -n '1,30p'
echo "=== git ==="
cd /opt/lzh/v7re 2>/dev/null && { git log -3 --oneline 2>&1 | sed -n '1,5p'; git status --short 2>&1 | sed -n '1,20p'; } || echo "no git repo"
echo "=== model dir ==="; ls -l --time-style=+%F_%T /opt/lzh/v7re/data/model/
echo "=== stages/meta ==="
python3 - <<'PY'
import sqlite3
c=sqlite3.connect('file:/opt/lzh/v7re/data/model/v7_model.sqlite?mode=ro',uri=True)
print('meta:', c.execute('select * from meta').fetchall()[:17])
print('stages:', c.execute('select * from stages').fetchall())
PY