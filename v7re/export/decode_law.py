#!/usr/bin/env python3
"""decode_law.py —— 全器件 PIP 解码器（P0a）。

把一份 .bit 摊成 (frames, 101, 32) 的位矩阵，再用 law_cells 里的
(tile_type, family, src) → (frame_off, bit, sense, parity) 规则，
对每个 INT tile × 每个家族实例做向量化预测，判定：

  EXACT = 该实例的所有预测位都与 sense 一致（PIP 被使用）
  SUB   = 部分一致（可能是共用位 / 规则偏差）
  EMPTY = 全部不一致（PIP 未使用）

用法：
  python v7re/export/decode_law.py design.bit --out pips.csv
  python v7re/export/decode_law.py design.bit --tiles pips.json --out pips.csv
"""
import argparse
import csv
import json
import os
import sqlite3
import sys
import time

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
    for band, col, s, e in con.execute("SELECT band,col,start_frame,end_frame FROM far_bands"):
        bands.setdefault(band, {})[col] = s
    tiles = {}
    for name, ttype, col, y, cr in con.execute(
            "SELECT tile_name,tile_type,col,y,clock_region FROM law_tiles"):
        tiles[name] = (ttype, col, y)
    band_by_region = json.loads(
        con.execute("SELECT value FROM meta WHERE key='band_by_region'").fetchone()[0])
    con.close()
    return rows, bands, tiles, band_by_region


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
    ap.add_argument("--max-tiles", type=int, default=0)
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
    if a.max_tiles:
        names = names[:a.max_tiles]
    print(f"tiles={len(names)} law_cells={len(cells)}")

    # tile 侧数组
    tt_arr = np.array([tiles[n][0] for n in names])
    col_arr = np.array([tiles[n][1] for n in names], dtype=np.int64)
    y_arr = np.array([tiles[n][2] for n in names], dtype=np.int64)

    def base_frames(tt_mask):
        region = np.minimum(y_arr // BAND_ROWS, len(band_by_region) - 1)
        band = np.array(band_by_region)[region]
        base = np.zeros(len(names), dtype=np.int64)
        for i in range(len(names)):
            b = band[i]
            base[i] = bands.get(b, {}).get(int(col_arr[i]), -1)
        return base

    base_cache = {}
    out_rows = []
    # 按 (tile_type, family) 分组
    groups = {}
    for (tt, fam, src, off, bit, sense, parity) in cells:
        groups.setdefault((tt, fam), {}).setdefault(src, []).append((off, bit, sense, parity))

    n_exact = n_sub = n_empty = 0
    for (tt, fam), srcs in groups.items():
        idx = np.nonzero(tt_arr == tt)[0]
        if idx.size == 0:
            continue
        if tt not in base_cache:
            base_cache[tt] = base_frames(tt_arr == tt)
        base = base_cache[tt][idx]
        y = y_arr[idx]
        for src, cl in srcs.items():
            arr = np.array(cl, dtype=np.int64)
            off, bit, sense, parity = arr[:, 0], arr[:, 1], arr[:, 2], arr[:, 3]
            frames = base[:, None] + off[None, :]        # (n, c)
            ok_frame = (frames >= 0) & (frames < nframes)
            words = word_of(y[:, None], parity[None, :])  # (n, c)
            f_safe = np.clip(frames, 0, nframes - 1)
            vals = M[f_safe, words, bit[None, :]] > 0
            match = vals == (sense[None, :] > 0)
            match &= ok_frame
            total = match.shape[1]
            hits = match.sum(axis=1)
            pat = np.where(hits == total, "EXACT", np.where(hits > 0, "SUB", "EMPTY"))
            for i, t in enumerate(idx):
                p = pat[i]
                if p == "EXACT":
                    n_exact += 1
                elif p == "SUB":
                    n_sub += 1
                else:
                    n_empty += 1
                if p != "EMPTY":
                    out_rows.append((names[t], fam, src, p, int(hits[i]), total))
        if (len(out_rows) and len(out_rows) % 200000 < 1000):
            print(f"  ... {fam}: rows={len(out_rows)}", flush=True)

    with open(a.out, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["tile", "family", "src", "pattern", "hits", "cells"])
        w.writerows(out_rows)

    print(f"EXACT={n_exact} SUB={n_sub} EMPTY={n_empty} "
          f"({time.time()-t0:.1f}s) -> {a.out}")


if __name__ == "__main__":
    main()
