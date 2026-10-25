set -u
/opt/lzh/venv/bin/python - <<'PY'
import sqlite3, json
c=sqlite3.connect("/opt/lzh/v7re/data/model/v7_model.sqlite")
tabs=[r[0] for r in c.execute("select name from sqlite_master where type='table' order by name")]
out={}
for t in tabs:
    try: out[t]=c.execute(f"select count(*) from {t}").fetchone()[0]
    except Exception as e: out[t]=str(e)[:30]
json.dump(out, open("/mnt/c/Users/S.tschai/pull/table_counts.json","w"), indent=1)
print(json.dumps(out))
PY