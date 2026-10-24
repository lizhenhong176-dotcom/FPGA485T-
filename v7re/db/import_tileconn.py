"""Import the canonical tile-connection rules (step 2) into the routing DB.

Source: E:\\v7work\\routing\\step02\\rules.db (learned by learn_corridor.py and
merged by merge_sqlite.py). Each row becomes one tileconn row plus an artifact
record, so the DB is self-describing about where the numbers came from.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sqlite3
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--rules-db", default=r"E:\v7work\routing\step02\rules.db")
    ap.add_argument("--db", default=r"E:\v7work\routing\v7_routing.db")
    ap.add_argument("--validation", default=r"E:\v7work\routing\step02\validation.json")
    args = ap.parse_args()

    rules_db = Path(args.rules_db)
    db = Path(args.db)
    if not rules_db.exists():
        print(f"missing {rules_db}")
        return 1
    src = sqlite3.connect(f"file:{rules_db}?mode=ro", uri=True)
    stats = json.loads(dict(src.execute("SELECT k, v FROM meta").fetchall())["stats"])
    dst = sqlite3.connect(db)
    dst.executescript((ROOT / "db" / "schema_routing.sql").read_text(encoding="utf-8"))

    t0 = time.time()
    dst.execute("DELETE FROM tileconn")
    batch = []
    total = 0
    for family, corridor, dx, dy, dst_type, wires in src.execute(
            "SELECT family, corridor, dx, dy, dst, wires FROM rules"):
        batch.append((family, corridor, dx, dy, dst_type, wires))
        if len(batch) >= 50_000:
            dst.executemany("INSERT OR REPLACE INTO tileconn VALUES (?,?,?,?,?,?)", batch)
            total += len(batch)
            batch.clear()
    if batch:
        dst.executemany("INSERT OR REPLACE INTO tileconn VALUES (?,?,?,?,?,?)", batch)
        total += len(batch)
    src.close()

    validation = {}
    vpath = Path(args.validation)
    if vpath.exists():
        validation = json.loads(vpath.read_text(encoding="utf-8"))

    now = time.strftime("%Y-%m-%dT%H:%M:%S")
    dst.execute("INSERT OR REPLACE INTO meta VALUES (?,?)",
                ("tileconn", json.dumps({"rows": total, "source": str(rules_db),
                                         "stats": stats, "validation": validation})))
    dst.execute("INSERT OR REPLACE INTO stages VALUES (?,?,?,?,?,?)",
                ("s02_tileconn", "device", "done", now, now,
                 json.dumps({"rows": total, "stats": stats})))
    for path in (rules_db, vpath):
        if path.exists():
            dst.execute("INSERT OR REPLACE INTO artifacts VALUES (?,?,?,?)",
                        ("s02_tileconn", str(path), path.stat().st_size, sha256(path)))
    dst.commit()
    dst.close()
    print(json.dumps({"tileconn_rows": total, "seconds": round(time.time() - t0, 1),
                      "validation": validation}, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
