set -u
/opt/lzh/venv/bin/python - <<'PY'
import sqlite3, json
c=sqlite3.connect("/opt/lzh/v7re/data/model/v7_model.sqlite")
c.row_factory=sqlite3.Row
out={}
for t in ["imux_codes","pip_bits","bit_map"]:
    rows=[dict(r) for r in c.execute(f"select * from {t} limit 5000")]
    out[t]=rows
    print(t, len(rows), list(rows[0].keys()) if rows else None)
json.dump(out, open("/mnt/c/Users/S.tschai/pull/model_tables.json","w"), indent=1)
PY