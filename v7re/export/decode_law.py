#!/usr/bin/env python3
"""decode_law.py —— 全器件 PIP 解码器（P0a，判据修正版）。

判定口径（2026-10-27 与用户确认）：
  只看 sense=1 的位（PIP 启用时应置 1 的格子）：
    all-ones 且格数 >= --min-cells  → EXACT   （强证据：该 PIP 被使用）
    all-ones 但格数 <  --min-cells  → WEAK    （2~3 格小掩码，随机命中率不可忽略）
    否则                            → 不输出（视作未使用）

可选 --require-zero：额外要求 sense=0 的格子全为 0（更严，先默认关）。

用法：
  python v7re/export/decode_law.py design.bit --out pips.csv
"""
import argparse
import json
import os
import sqlite3
import sys
import time
import csv

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
from bitstream.parser import frames_from_bit  # noqa: E402

BAND_ROWS = 50


def load_cells(db):
    con = sqlite3.connect(db)
    rows = con.execute(
        "SELECT tile_type, family, src_wire, frame_off, bit, sense, parity "
        "FROM law_cells ORDER BY tile_type, family, src_index, frame_off, bit"
    ).fetchall()
    bands = {}
    for band, col, s in con.execute("SELECT band,col,start_frame FROM far_bands"):
        bands.setdefault(band, {})[col] = s
    tiles = {}
    for name, ttype, col, y in con.execute(
            "SELECT tile_name,tile_type,col,y FROM law_tiles"):
        tiles[name] = (ttype, col, y)
    bbr = json.loads(con.execute(
        "SELECT value FROM meta WHERE key='band_by_region'").fetchone()[0])
    con.close()
    return rows, bands, tiles, bbr


def bit_matrix(path):
    frames = frames_from_bit(path)
    arr = np.array(frames, dtype=np.uint32)            # (F, 101)
    bits = np.unpackbits(arr.view(np.uint8).reshape(arr.shape[0], 404),
                         axis=1, bitorder="little")
    return bits.reshape(arr.shape[0], 101, 32)          # 1 = bit set


def word_of(y, parity):
    w = 2 * (y % BAND_ROWS) + parity
    return np.where(w >= 50, w + 1, w)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bit")
    ap.add_argument("--db", default=r"E:\v7work\model\v7_law.sqlite")
    ap.add_argument("--out", default="pips.csv")
    ap.add_argument("--tiles", help="只解码这些 tile（pips json 里的 tile 字段）")
    ap.add_argument("--min-cells", type=int, default=4,
                    help="EXACT 要求的 sense=1 格数下限（默认 4）")
    ap.add_argument("--require-zero", action="store_true",
                    help="额外要求 sense=0 格全为 0")
    a = ap.parse_args()

    t0 = time.time()
    M = bit_matrix(a.bit)
    nframes = M.shape[0]
    print(f"bit matrix {M.shape} = {M.nbytes/1e6:.1f} MB  ({time.time()-t0:.1f}s)")

    cells, bands, tiles, band_by_region = load_cells(a.db)
    if a.tiles:
        wanted = {rec["tile"] for rec in json.load(open(a.tiles))}
        tiles = {k: v for k, v in tiles.items() if k in wanted}
    names = sorted(tiles)
    print(f"tiles={len(names)} law_cells={len(cells)}")

    tt_arr = np.array([tiles[n][0] for n in names])
    col_arr = np.array([tiles[n][1] for n in names], dtype=np.int64)
    y_arr = np.array([tiles[n][2] for n in names], dtype=np.int64)
    band_arr = np.array(band_by_region)[
        np.minimum(y_arr // BAND_ROWS, len(band_by_region) - 1)]

    base_cache = {}
    for tt in ("INT_L", "INT_R"):
        sel = tt_arr == tt
        if not sel.any():
            continue
        b = np.full(len(names), -1, dtype=np.int64)
        bc = bands
        for i in np.nonzero(sel)[0]:
            s = bc.get(int(band_arr[i]), {}).get(int(col_arr[i]), -1)
            b[i] = s
        base_cache[tt] = b

    groups = {}
    for (tt, fam, src, off, bit, sense, parity) in cells:
        groups.setdefault((tt, fam), {}).setdefault(src, []).append(
            (off, bit, sense, parity))

    out_rows = []
    n_exact = n_weak = 0
    for (tt, fam), srcs in groups.items():
        base = base_cache.get(tt)
        if base is None:
            continue
        idx = np.nonzero((tt_arr == tt) & (base >= 0))[0]
        if idx.size == 0:
            continue
        base_t = base[idx]
        y_t = y_arr[idx]
        for src, cl in srcs.items():
            arr = np.array(cl, dtype=np.int64)
            off, bit, sense, parity = (arr[:, 0], arr[:, 1],
                                       arr[:, 2], arr[:, 3])
            m1 = sense > 0
            if not m1.any():
                continue
            frames = base_t[:, None] + off[None, m1]
            words = word_of(y_t[:, None], parity[None, m1])
            f_safe = np.clip(frames, 0, nframes - 1)
            vals = M[f_safe, words, bit[None, m1]] > 0
            ok = (frames >= 0) & (frames < nframes)
            ones = (vals & ok).all(axis=1)
            if a.require_zero:
                m0 = ~m1
                if m0.any():
                    f0 = np.clip(base_t[:, None] + off[None, m0], 0, nframes - 1)
                    v0 = M[f0, word_of(y_t[:, None], parity[None, m0]),
                           bit[None, m0]] > 0
                    zeros = (~v0).all(axis=1)
                    ones &= zeros
            n1 = int(m1.sum())
            if n1 >= a.min_cells:
                sel = np.nonzero(ones)[0]
                for t in sel:
                    out_rows.append((names[idx[t]], fam, src, "EXACT", n1))
                n_exact += sel.size
            else:
                sel = np.nonzero(ones)[0]
                for t in sel:
                    out_rows.append((names[idx[t]], fam, src, "WEAK", n1))
                n_weak += sel.size

    with open(a.out, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["tile", "family", "src", "pattern", "cells1"])
        w.writerows(out_rows)

    print(f"EXACT={n_exact} WEAK={n_weak} ({time.time()-t0:.1f}s) -> {a.out}")


if __name__ == "__main__":
    main()
