"""把 tilepipe.json（36 个 IMUX × 25 源）入库并导出可传输的 CSV。

用法：python ingest_tilepipe.py [--dry]
产出：step03_pip/out/pip_bits_tilepipe.csv、bit_map_tilepipe.csv
同时写本地库 E:\\v7work\\model\\v7_model.sqlite。
"""
import json, os, sqlite3, sys, csv

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "tilepipe.json")
DB = r"E:\v7work\model\v7_model.sqlite"
OUT = os.path.join(HERE, "out")
SRC_TAG = "tilepipe_20261025"

os.makedirs(OUT, exist_ok=True)
d = json.load(open(SRC, encoding="utf-8-sig"))

con = sqlite3.connect(DB)
site_tile = {s: t for s, t in con.execute("SELECT site, tile FROM sites")}

pip_rows, bit_rows = [], []
missing = []
for tag, rec in sorted(d.items()):
    # tag = SLICE_X8Y11_A6LUT_A1
    site, bel, pin = tag.rsplit("_", 1)[0].rsplit("_", 1)[0], tag.split("_")[-2], tag.split("_")[-1]
    site = tag[: -len("_" + bel + "_" + pin)]
    tile = site_tile.get(site)
    if tile is None:
        missing.append(site)
        continue
    sink = rec["sink"]  # IMUX_L7
    for src, bits in sorted(rec["sources"].items()):
        if not bits:
            # 「默认源」：一个配置位都不设 -> kind='default'，坐标留 NULL（不写魔数）
            pip_rows.append(("xc7vx485t", tile, src, sink, None, None, None, 0, SRC_TAG, "default"))
            continue
        for frame, word, bit in bits:
            pip_rows.append(("xc7vx485t", tile, src, sink, frame, word, bit, 1, SRC_TAG, "route"))
            bit_rows.append(("xc7vx485t", frame, word, bit,
                             "pip:%s|%s->>%s" % (tile, src, sink), 1, SRC_TAG))

print("tags", len(d), "pip rows", len(pip_rows), "bit rows", len(bit_rows), "missing sites", set(missing))

if "--dry" in sys.argv:
    sys.exit(0)

con.execute("DELETE FROM pip_bits WHERE source=?", (SRC_TAG,))
con.execute("DELETE FROM bit_map WHERE source=?", (SRC_TAG,))
con.executemany(
    "INSERT INTO pip_bits(device,tile,wire_a,wire_b,frame,word,bit,value,source,kind) "
    "VALUES(?,?,?,?,?,?,?,?,?,?)", pip_rows)
# bit_map 的 (device,frame,word,bit) 是 UNIQUE，而同一个 tile 里多个 mux 共用帧窗口，
# 同一 (frame,word,bit) 会对应多条 PIP，1:1 放不下 —— 只在 CSV 里保留全量，不写 bit_map。
# con.executemany("INSERT INTO bit_map(...)", bit_rows)
con.commit()
print("local pip_bits", con.execute("SELECT count(*) FROM pip_bits").fetchone()[0],
      "bit_map", con.execute("SELECT count(*) FROM bit_map").fetchone()[0])

for name, rows in (("pip_bits_tilepipe.csv", pip_rows), ("bit_map_tilepipe.csv", bit_rows)):
    with open(os.path.join(OUT, name), "w", newline="", encoding="utf-8") as f:
        csv.writer(f).writerows(rows)
    print("wrote", name, os.path.getsize(os.path.join(OUT, name)))
con.close()
