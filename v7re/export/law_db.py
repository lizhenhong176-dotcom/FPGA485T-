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
import re
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

DROP TABLE IF EXISTS law_ppips;
CREATE TABLE law_ppips (
  tile_type TEXT NOT NULL,
  family    TEXT NOT NULL,
  src_wire  TEXT NOT NULL,
  kind      TEXT NOT NULL,   -- 'default' | 'always' | 'hint'
  PRIMARY KEY (tile_type, family, src_wire)
);

DROP TABLE IF EXISTS meta;
CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);

-- S4：CLB site 特征位（来自 step03_pip/site_cells.json，artix7 表迁移 + V7 受控实验验证）
DROP TABLE IF EXISTS clb_cells;
CREATE TABLE clb_cells (
  tile_type  TEXT NOT NULL,      -- CLBLL_L / CLBLL_R / CLBLM_L / CLBLM_R
  family     TEXT NOT NULL,      -- 'SLICEM_X0.ALUT'（含 site 实例前缀）
  src_wire   TEXT NOT NULL,      -- 'INIT[00]' / 'AX' / 'O5' ...
  frame_off  INTEGER NOT NULL,
  bit        INTEGER NOT NULL,
  sense      INTEGER NOT NULL,
  parity     INTEGER NOT NULL,
  -- 注意：多 bit 编码（如 AFFMUX 四 bit）同 (family,src) 有多行，PK 必须含 (frame_off,bit)
  PRIMARY KEY (tile_type, family, src_wire, frame_off, bit)
);

-- CLB 块基址：(gridCol, band) → 基帧（block_tiles.csv + frame_index_far.csv）
DROP TABLE IF EXISTS clb_blocks;
CREATE TABLE clb_blocks (
  grid_col    INTEGER NOT NULL,
  band        INTEGER NOT NULL,
  base_frame  INTEGER NOT NULL,
  PRIMARY KEY (grid_col, band)
);

-- SLICE → (tileType, gridCol, inst, Y)。inst 按 slice 名 X 奇偶（偶→X0，奇→X1），
-- 不取 getSites() 顺序（_L tile 会颠倒）。
DROP TABLE IF EXISTS clb_tiles;
CREATE TABLE clb_tiles (
  slice_name  TEXT PRIMARY KEY,
  tile_type   TEXT NOT NULL,
  grid_col    INTEGER NOT NULL,
  inst        INTEGER NOT NULL,
  y           INTEGER NOT NULL
);
"""

CLB_TILES_CSV = os.path.join(PROJECT, "phaseA", "clb_tiles.csv")
BLOCK_TILES_CSV = os.path.join(PROJECT, "phaseA", "block_tiles.csv")
SITE_CELLS_JSON = os.path.join(PROJECT, "step03_pip", "site_cells.json")



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


def load_ppips(prjxray_ref):
    """artix7 ppips_int_{l,r}.db → 伪 PIP（无配置位）：default/always/hint。"""
    out = []
    for fname, ttype in (("ppips_int_l.db", "INT_L"), ("ppips_int_r.db", "INT_R")):
        p = os.path.join(prjxray_ref, fname)
        if not os.path.exists(p):
            continue
        with open(p) as fh:
            for line in fh:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                feat, kind = line.split()
                seg = feat.split(".")
                if len(seg) != 3:
                    continue
                out.append((ttype, seg[1], seg[2], kind))
    return out


def load_tiles(model_db):
    """tile 名里的 X/Y 才是 pip_law 用的坐标；grid_x/grid_y 是另一套布局坐标。"""
    if not os.path.exists(model_db):
        return []
    con = sqlite3.connect(model_db)
    try:
        rows = con.execute(
            "SELECT tile_name, type FROM tiles WHERE type LIKE 'INT_%'").fetchall()
    finally:
        con.close()
    out = []
    for name, ttype in rows:
        m = re.search(r"_X(\d+)Y(\d+)$", name)
        if not m:
            continue
        out.append((name, ttype, int(m.group(1)), int(m.group(2)), 0))
    return out


def load_clb_parts():
    """S4 集成：CLB site 特征 + 块基址 + slice 归属，全部进 v7_law.sqlite。

    规则（受控实验定论，见 step03_pip/S2_S3_SITE_LAYOUT.md 勘误后版本）：
      frame = clb_blocks[(gridCol, Y//50)] + frame_off
      word  = 2*(Y%50) + (Y%50>=25) + parity（word 50 = ECC，公式永不产生）
      inst  = slice 名 X 奇偶（偶→X0，奇→X1；getSites() 顺序不可靠）
    """
    import re as _re

    cells = []
    for row in json.load(open(SITE_CELLS_JSON, encoding="utf-8")):
        cells.append((row["tile_type"], row["family"], row["src_wire"],
                      int(row["frame_off"]), int(row["bit"]),
                      int(row["sense"]), int(row["parity"])))

    fi = {}
    for r in csv.DictReader(open(DEFAULT_FAR, encoding="utf-8")):
        if r["kind"] == "block":
            fi.setdefault(int(r["block_addr"], 16), []).append(int(r["frame_index"]))
    blocks = {}
    for r in csv.DictReader(open(BLOCK_TILES_CSV, encoding="utf-16")):
        if not r["subType"].startswith(("CLBLL", "CLBLM")):
            continue
        addr = int(r["far"], 16)
        if addr not in fi:
            continue
        m = _re.search(r"_X\d+Y(\d+)$", r["bottomTile"])
        if not m:
            continue
        ylo = int(m.group(1))
        blocks[(int(r["tileColumn"]), ylo // 50)] = min(fi[addr])

    tiles = []
    for r in csv.DictReader(open(CLB_TILES_CSV, encoding="utf-8")):
        for sk in ("site0", "site1"):
            s = r[sk]
            if not s:
                continue
            m = _re.match(r"SLICE_X(\d+)Y(\d+)$", s)
            if not m:
                continue
            x = int(m.group(1))
            tiles.append((s, r["type"], int(r["gridCol"]),
                          0 if x % 2 == 0 else 1, int(m.group(2))))
    return cells, blocks, tiles


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default=DEFAULT_DB)
    ap.add_argument("--cells", default=DEFAULT_CELLS)
    ap.add_argument("--far", default=DEFAULT_FAR)
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--prjxray-ref", default=os.path.join(PROJECT, "prjxray_ref", "artix7"))
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

    con.executemany("INSERT OR REPLACE INTO law_ppips VALUES (?,?,?,?)",
                    load_ppips(a.prjxray_ref))

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
        ("n_ppips", "108"),
    ])

    clb_cells, clb_blocks, clb_tiles = load_clb_parts()
    con.executemany("INSERT OR REPLACE INTO clb_cells VALUES (?,?,?,?,?,?,?)",
                    clb_cells)
    con.executemany("INSERT OR REPLACE INTO clb_blocks VALUES (?,?,?)",
                    [(gc, b, base) for (gc, b), base in clb_blocks.items()])
    con.executemany("INSERT OR REPLACE INTO clb_tiles VALUES (?,?,?,?,?)",
                    clb_tiles)
    con.executemany("INSERT OR REPLACE INTO meta VALUES (?,?)", [
        ("n_clb_cells", str(len(clb_cells))),
        ("n_clb_blocks", str(len(clb_blocks))),
        ("n_clb_tiles", str(len(clb_tiles))),
    ])
    con.commit()
    print(f"law db: {a.db}")
    print(f"  law_cells {len(payload)} rows / {len(seen)} family-instances")
    print(f"  far_bands {ncols} rows; law_tiles {len(tiles)} rows")
    print(f"  law_ppips {con.execute('SELECT COUNT(*) FROM law_ppips').fetchone()[0]} rows")
    print(f"  clb_cells {len(clb_cells)}; clb_blocks {len(clb_blocks)}; "
          f"clb_tiles {len(clb_tiles)}")
    con.close()


if __name__ == "__main__":
    main()
