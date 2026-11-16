set -eu
export LANG=C LC_ALL=C

DB=/opt/lzh/v7re/data/model/v7_model.sqlite
B64=/tmp/framemap.b64
CSV=/tmp/frame_map_export.csv

echo "=== [1] decode payload ==="
base64 -d "$B64" > /tmp/framemap.gz
gunzip -c /tmp/framemap.gz > "$CSV"
echo "csv lines: $(wc -l < "$CSV")"
echo "csv sha256: $(sha256sum "$CSV" | cut -d' ' -f1)"

echo "=== [2] backup remote DB ==="
if [ ! -f "${DB}.bak-20261102-pre-framemap" ]; then
  cp -p "$DB" "${DB}.bak-20261102-pre-framemap"
  echo "backup: ${DB}.bak-20261102-pre-framemap"
else
  echo "backup already exists"
fi

echo "=== [3] import ==="
/opt/lzh/venv/bin/python - "$DB" "$CSV" <<'PY'
import sqlite3, sys, hashlib, re

db_path, csv_path = sys.argv[1], sys.argv[2]

DDL = """
CREATE TABLE frame_map (
    frame_index           INTEGER PRIMARY KEY
        CHECK (frame_index >= 0 AND frame_index <= 50175),
    far                   INTEGER NULL,
    frame_address_source  TEXT NOT NULL
        CHECK (frame_address_source IN ('rapidwright-configarray', 'unresolved')),
    confidence            TEXT NOT NULL
        CHECK (confidence IN ('confirmed', 'unresolved')),
    tile_name             TEXT NULL,
    block_type            TEXT NULL,
    is_overhead           INTEGER NOT NULL DEFAULT 0
        CHECK (is_overhead IN (0, 1)),
    row_number            INTEGER NULL
        CHECK (row_number IS NULL OR (row_number BETWEEN 1 AND 14)),
    block_addr            INTEGER NULL,
    CHECK ((is_overhead = 1) = (far IS NULL)),
    CHECK ((is_overhead = 1) = (block_addr IS NULL)),
    CHECK (block_addr IS NULL OR block_addr % 128 = 0),
    CHECK (far IS NULL OR (far >= 0 AND far <= 2147483647))
)
"""

def parse_int(s):
    s = s.strip()
    if s == "":
        return None
    return int(s, 16) if s.lower().startswith("0x") else int(s)

rows = []
with open(csv_path, newline="") as f:
    header = f.readline().rstrip("\n").split(",")
    expect = ["frame_index","far","frame_address_source","confidence",
              "tile_name","block_type","is_overhead","row_number","block_addr"]
    assert header == expect, "header mismatch: %r" % (header,)
    for ln, line in enumerate(f, start=2):
        line = line.rstrip("\n")
        if not line:
            continue
        p = line.split(",")
        assert len(p) == 9, "line %d: expected 9 fields, got %d" % (ln, len(p))
        rows.append((
            int(p[0]),
            parse_int(p[1]),
            p[2],
            p[3],
            p[4] or None,
            p[5] or None,
            int(p[6]),
            parse_int(p[7]),
            parse_int(p[8]),
        ))

print("parsed rows:", len(rows))
assert len(rows) == 50176, "row count %d != 50176" % len(rows)
assert [r[0] for r in rows] == list(range(50176)), "frame_index not contiguous 0..50175"

con = sqlite3.connect(db_path)
con.execute("PRAGMA foreign_keys=OFF")
fails = []
try:
    con.execute("BEGIN IMMEDIATE")
    con.execute("DROP TABLE IF EXISTS frame_map")
    con.execute(DDL)
    con.executemany("INSERT INTO frame_map VALUES (?,?,?,?,?,?,?,?,?)", rows)
    checks = []
    checks.append(("row count = 50176", con.execute("SELECT COUNT(*) FROM frame_map").fetchone()[0] == 50176))
    checks.append(("far NULL = 28", con.execute("SELECT COUNT(*) FROM frame_map WHERE far IS NULL").fetchone()[0] == 28))
    checks.append(("overhead = 28", con.execute("SELECT COUNT(*) FROM frame_map WHERE is_overhead=1").fetchone()[0] == 28))
    checks.append(("distinct far = 50148", con.execute("SELECT COUNT(DISTINCT far) FROM frame_map").fetchone()[0] == 50148))
    checks.append(("anchor 31748 -> 0x4203A0",
                   con.execute("SELECT far FROM frame_map WHERE frame_index=31748").fetchone()[0] == 0x4203A0))
    checks.append(("anchor 31750 -> 0x4203A2",
                   con.execute("SELECT far FROM frame_map WHERE frame_index=31750").fetchone()[0] == 0x4203A2))
    ovh = con.execute("""SELECT row_number, COUNT(*), MAX(frame_index)-MIN(frame_index)
                         FROM frame_map WHERE is_overhead=1 GROUP BY row_number""").fetchall()
    checks.append(("overhead = 14 rows x 2 adjacent", len(ovh) == 14 and all(r[1] == 2 and r[2] == 1 for r in ovh)))
    checks.append(("block_addr % 128 == 0",
                   con.execute("SELECT COUNT(*) FROM frame_map WHERE block_addr IS NOT NULL AND block_addr % 128 <> 0").fetchone()[0] == 0))
    for name, ok in checks:
        print(("  PASS  " if ok else "  FAIL  ") + name)
        if not ok:
            fails.append(name)
    if fails:
        raise RuntimeError("audits failed")
    con.commit()
    print("committed")
except Exception as e:
    con.rollback()
    print("ROLLBACK:", e)
    raise
finally:
    con.close()
PY

echo "=== [4] final state ==="
/opt/lzh/venv/bin/python - "$DB" <<'PY'
import sqlite3, sys, os
p = sys.argv[1]
c = sqlite3.connect("file:%s?mode=ro" % p, uri=True)
names = [r[0] for r in c.execute("select name from sqlite_master where type='table'")]
print("db size:", os.path.getsize(p))
print("tables:", len(names), "| has frame_map:", "frame_map" in names)
print("frame_map rows:", c.execute("select count(*) from frame_map").fetchone()[0])
print("site_frames rows:", c.execute("select count(*) from site_frames").fetchone()[0])
print("pip_bits rows:", c.execute("select count(*) from pip_bits").fetchone()[0])
c.close()
PY

rm -f /tmp/framemap.gz /tmp/frame_map_export.csv /tmp/framemap.b64
echo "cleanup done"
