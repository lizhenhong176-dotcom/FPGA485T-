#!/usr/bin/env python3
"""law_db.py —— 把 PIP 规律灌进 SQLite，供全器件解码器查询。

表：
  law_cells(tile_type, family, src_wire, frame_off, bit, sense, parity, src_index)
  far_bands(band, col, start_frame, end_frame)
  law_tiles(tile_name, tile_type, col, y, clock_region)
  meta(key, value)

用法：
  python v7re/export/law_db.py [--db E:\\v7work\\model\\v7_law.sqlite]
                               [--cells step03_pip/all_cells.json]
                               [--model E:\\v7work\\model\\v7_model.sqlite]
"""
import argparse
import csv
import json
import os
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
PROJECT = os.path.dirname(ROOT)
sys.path.insert(0, os.path.join(PROJECT, "step03_pip"))
from pip_law import BAND_BY_REGION, N_BANDS, ROW_FRAMES  # noqa: E402

BAND_ROWS = 50
DEFAULT_DB = r"E:\v7work\model\v7_law.sqlite"
DEFAULT_CELLS = os.path.join(PROJECT, "step03_pip", "all_cells.json")
DEFAULT_FAR = os.path.join(PROJECT, "phaseA", "frame_index_far.csv")
DEFAULT_MODEL = r"E:\v7work\model\v7_model.sqlite"

SCHEMA = """
DROP TABLE IF EXISTS law_cells;
CREATE TABLE law_cells (
  tile_type TEXT NOT NULL,
  family    TEXT NOT NULL,
  src_wire  TEXT NOT NULL,
  frame_off INTEGER NOT NULL,
  bit       INTEGER NOT NULL,
  sense     INTEGER NOT NULL,
  parity    INTEGER NOT NULL,
  src_index INTEGER,
  PRIMARY KEY (tile_type, family, src_wire, frame_off, bit)
);
CREATE INDEX ix_law_family ON law_cells(tile_type, family);

DROP TABLE IF EXISTS far_bands;
CREATE TABLE far_bands (
  band        INTEGER NOT NULL,
  col         INTEGER NOT NULL,
  start_frame INTEGER NOT NULL,
  end_frame   INTEGER NOT NULL,
  PRIMARY KEY (band, col)
);

DROP TABLE IF EXISTS law_tiles;
CREATE TABLE law_tiles (
  tile_name    TEXT PRIMARY KEY,
  tile_type    TEXT NOT NULL,
  col          INTEGER NOT NULL,
  y            INTEGER NOT NULL,
  clock_region INTEGER NOT NULL
);

DROP TABLE IF EXISTS meta;
CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);
"""


def load_far(path):
    by_band = {}
    with open(path, newline="") as fh:
        for r in csv.DictReader(fh):
            row = int(r["row"])
            band = row - 1
            if band < 0 or band >= N_BANDS:
                continue
            col = (int(r["block_addr"], 16) >> 7) & 0x7F
            fi = int(r["frame_index"])
            e = by_band.setdefault(band, {}).setdefault(col, [fi, fi])
            e[0] = min(e[0], fi)
            e[1] = max(e[1], fi)
    return by_band


def load_cells(path):
    rows = []
    with open(path) as fh:
        for c in json.load(fh):
            rows.append((c["tile_type"], c["family"], c["src_wire"],
                         int(c["frame_off"]), int(c["bit"]), int(c["sense"]),
                         int(c["parity"])))
    return rows


def load_tiles(model_db):
    if not os.path.exists(model_db):
        return []
    con = sqlite3.connect(model_db)
    try:
        return con.execute(
            "SELECT tile_name, type, grid_x, grid_y, clock_region "
            "FROM tiles WHERE type LIKE 'INT_%'").fetchall()
    finally:
        con.close()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default=DEFAULT_DB)
    ap.add_argument("--cells", default=DEFAULT_CELLS)
    ap.add_argument("--far", default=DEFAULT_FAR)
    ap.add_argument("--model", default=DEFAULT_MODEL)
    a = ap.parse_args()

    os.makedirs(os.path.dirname(os.path.abspath(a.db)), exist_ok=True)
    if os.path.exists(a.db):
        os.remove(a.db)
    con = sqlite3.connect(a.db)
    con.executescript(SCHEMA)

    bands = load_far(a.far)
    ncols = 0
    for band, cols in bands.items():
        for col, (s, e) in cols.items():
            con.execute("INSERT INTO far_bands VALUES (?,?,?,?)", (band, col, s, e))
            ncols += 1

    cells = load_cells(a.cells)
    # src_index：同一 (tile_type, family) 内按 src_wire 首次出现顺序编号
    seen = {}
    payload = []
    for (tt, fam, src, off, bit, sense, parity) in cells:
        k = (tt, fam)
        if src not in seen.setdefault(k, []):
            seen[k].append(src)
        payload.append((tt, fam, src, off, bit, sense, parity,
                        seen[k].index(src)))
    con.executemany("INSERT OR REPLACE INTO law_cells VALUES (?,?,?,?,?,?,?,?)", payload)

    tiles = load_tiles(a.model)
    for name, ttype, gx, gy, cr in tiles:
        con.execute("INSERT OR REPLACE INTO law_tiles VALUES (?,?,?,?,?)",
                    (name, ttype, gx, gy, cr))

    con.executemany("INSERT OR REPLACE INTO meta VALUES (?,?)", [
        ("band_by_region", json.dumps(BAND_BY_REGION)),
        ("row_frames", str(ROW_FRAMES)),
        ("band_rows", str(BAND_ROWS)),
        ("n_cells", str(len(payload))),
        ("n_far", str(ncols)),
        ("n_tiles", str(len(tiles))),
    ])
    con.commit()
    print(f"law db: {a.db}")
    print(f"  law_cells {len(payload)} rows / {len(seen)} family-instances")
    print(f"  far_bands {ncols} rows; law_tiles {len(tiles)} rows")
    con.close()


if __name__ == "__main__":
    main()
