cd /opt/lzh/step03/tilepipe 2>/dev/null && { echo "tilepipe: bits=$(ls *.bit 2>/dev/null|wc -l)"; ls tilepipe.json 2>/dev/null; ps aux | grep -c "[t]ilepipe_run"; }
DB=/opt/lzh/v7re/data/model/v7_model.sqlite
ls -l $DB
command -v sqlite3 || echo "no sqlite3 cli"
/opt/lzh/venv/bin/python - <<'PY'
import sqlite3
db="/opt/lzh/v7re/data/model/v7_model.sqlite"
c=sqlite3.connect(db)
for t in ("pip_bits","bit_map","site_frames","meta"):
    try:
        cols=[r[1] for r in c.execute("PRAGMA table_info(%s)"%t)]
        n=c.execute("SELECT count(*) FROM %s"%t).fetchone()[0]
        print(t, n, cols)
        if t=="pip_bits":
            for row in c.execute("SELECT * FROM pip_bits LIMIT 3"): print("  ", row)
    except Exception as e:
        print(t, "ERR", e)
print("meta:", list(c.execute("SELECT key,value FROM meta")))
PY