import json, os, shutil, sqlite3, sys, collections

DB = "/opt/lzh/v7re/data/model/v7_model.sqlite"
SRC = "/opt/lzh/step03/tilepipe/tilepipe.json"
TAG = "tilepipe_20261025"

# 1) backup
bak = DB + ".bak-20261025"
if not os.path.exists(bak):
    shutil.copy2(DB, bak)
    print("backup", os.path.getsize(bak))

con = sqlite3.connect(DB)
cols = [r[1] for r in con.execute("PRAGMA table_info(sites)")]
print("sites cols", cols)
tcol = "tile"
site_tile = {s: t for s, t in con.execute("SELECT site, %s FROM sites" % tcol)}

d = json.load(open(SRC, encoding="utf-8-sig"))
rows, miss = [], set()
for tag, rec in sorted(d.items()):
    site = tag.rsplit("_", 1)[0].rsplit("_", 1)[0]
    tile = site_tile.get(site)
    if tile is None:
        miss.add(site); continue
    sink = rec["sink"]
    for src, bits in sorted(rec["sources"].items()):
        if not bits:
            rows.append(("xc7vx485t", tile, src, sink, -1, -1, -1, 0, TAG))
            continue
        for frame, word, bit in bits:
            rows.append(("xc7vx485t", tile, src, sink, frame, word, bit, 1, TAG))

print("tags", len(d), "rows", len(rows), "missing", sorted(miss))
if miss:
    sys.exit(2)

con.execute("DELETE FROM pip_bits WHERE source=?", (TAG,))
con.executemany("INSERT INTO pip_bits(device,tile,wire_a,wire_b,frame,word,bit,value,source) "
                "VALUES(?,?,?,?,?,?,?,?,?)", rows)
con.commit()
print("pip_bits total", con.execute("SELECT count(*) FROM pip_bits").fetchone()[0])
print("by source", list(con.execute("SELECT source,count(*) FROM pip_bits GROUP BY source")))
print("distinct mux", con.execute(
    "SELECT count(*) FROM (SELECT DISTINCT tile,wire_b FROM pip_bits WHERE source=?)", (TAG,)).fetchone()[0])
con.close()
