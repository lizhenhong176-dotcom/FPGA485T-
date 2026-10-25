"""把 pip_bits 表导成 CSV（迁移后的口径：默认源 kind=default、坐标为空）。

用法：python export_pip_csv.py [--db PATH]
产出：step03_pip/out/pip_bits.csv、step03_pip/out/bit_map_tilepipe.csv
"""
import argparse
import csv
import os
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
DB = r"E:\v7work\model\v7_model.sqlite"

ap = argparse.ArgumentParser()
ap.add_argument("--db", default=DB)
a = ap.parse_args()
os.makedirs(OUT, exist_ok=True)
con = sqlite3.connect(a.db)

rows = list(con.execute("""
    SELECT device,tile,wire_a,wire_b,frame,word,bit,value,source,kind,note
    FROM pip_bits ORDER BY tile, wire_b, wire_a, COALESCE(frame,-1), COALESCE(word,-1), COALESCE(bit,-1)
"""))
with open(os.path.join(OUT, "pip_bits.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["device", "tile", "wire_a", "wire_b", "frame", "word", "bit", "value", "source", "kind", "note"])
    w.writerows([tuple("" if v is None else v for v in r) for r in rows])
print("pip_bits.csv", len(rows), "rows", os.path.getsize(os.path.join(OUT, "pip_bits.csv")), "B")

bits = list(con.execute("""
    SELECT device, frame, word, bit, 'pip:'||tile||'|'||wire_a||'->>'||wire_b, value, source
    FROM pip_bits_mapped ORDER BY frame, word, bit
"""))
with open(os.path.join(OUT, "bit_map_tilepipe.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["device", "frame", "word", "bit", "feature", "value", "source"])
    w.writerows(bits)
print("bit_map_tilepipe.csv", len(bits), "rows", os.path.getsize(os.path.join(OUT, "bit_map_tilepipe.csv")), "B")
con.close()
sys.exit(0)
