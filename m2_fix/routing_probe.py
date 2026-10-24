import json
import sqlite3
from pathlib import Path

DB = Path("/data/lzh/v7re/work/refs_20261021/routing/v7_routing.db")
TEMPLATES = DB.parent / "out_routing" / "templates"
conn = sqlite3.connect(DB)
conn.row_factory = sqlite3.Row

print("== conn_rules target types ==")
for row in conn.execute(
    "select target_type, count(*) n from conn_rules group by target_type order by n desc"
):
    print(dict(row))

print("== conn_rules to CLBLL_L sample ==")
for row in conn.execute(
    "select * from conn_rules where target_type='CLBLL_L' limit 20"
):
    print(dict(row))

print("== templates ==")
for typ in ("CLBLL_L", "CLBLM_L", "INT_L", "INT_R"):
    p = TEMPLATES / (typ + ".json")
    print(typ, p.exists(), p.stat().st_size if p.exists() else None)
    if not p.exists():
        continue
    d = json.loads(p.read_text())
    print("  wires", d["wires"], "pips", d["pips"])
    for pip in d["pip_defs"]:
        if pip[1] in ("CLBLL_L_A3", "CLBLL_L_A5", "CLBLL_LL_A3", "CLBLL_LL_A5"):
            print("  sitepip", pip)
    for pip in d["pip_defs"]:
        if pip[0] in ("CLBLL_IMUX1", "CLBLL_IMUX25"):
            print("  imuxpip", pip)
