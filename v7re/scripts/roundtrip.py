#!/usr/bin/env python3
"""roundtrip.py —— 端到端闭环：位流 → PIP 列表 → 用定律重写 → 逐位比对。

与 bitwriter.py 的 `--selftest` 不同，这里**不喂 Vivado 的路由结果**：
PIP 列表完全由位流本身解码得到（mux 区用 T3 定律，其余族用 `law_cells` 查表），
再用同一套规则重写回去，最后与原始位流逐位对比。

这样能回答两个问题：
  1. 从位流反解 PIP 在真实设计上是否可行（漏解多少）；
  2. 2 格 pattern 的歧义在整芯片尺度上会带来多少误判（多解多少）。

用法：
    python roundtrip.py --bit design.bit [--min-cells 4] [--frames 0:26]
"""
import argparse
import collections
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

LAW_DB = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
BAND_ROWS = 50


def load_bits(path):
    frames = frames_from_bit(path)
    arr = np.array(frames, dtype=np.uint32)
    bits = np.unpackbits(arr.view(np.uint8).reshape(arr.shape[0], 404),
                         axis=1, bitorder="little")
    return bits.reshape(arr.shape[0], 101, 32)


def word_of(y, parity):
    w = 2 * (np.asarray(y) % BAND_ROWS) + parity
    return np.where(w >= 50, w + 1, w)


def load_tiles(db):
    """返回 INT tile 的 (names, ttype, col, y) 与地址基址数组。"""
    con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
    bbr = json.loads(con.execute(
        "SELECT value FROM meta WHERE key='band_by_region'").fetchone()[0])
    bands = collections.defaultdict(dict)
    for band, col, start in con.execute("SELECT band,col,start_frame FROM far_bands"):
        bands[band][col] = start
    names, tt, col_a, y_a, base_a = [], [], [], [], []
    for name, ttype, col, y in con.execute(
            "SELECT tile_name,tile_type,col,y FROM law_tiles"):
        if ttype not in ("INT_L", "INT_R"):
            continue
        band = bbr[min(y // BAND_ROWS, len(bbr) - 1)]
        base = bands.get(band, {}).get(col)
        if base is None:
            continue
        names.append(name)
        tt.append(ttype)
        col_a.append(col)
        y_a.append(y)
        base_a.append(base)
    con.close()
    return (names, np.array(tt), np.array(col_a, dtype=np.int64),
            np.array(y_a, dtype=np.int64), np.array(base_a, dtype=np.int64))


def candidates(model, fallback, ttypes):
    """[(ttype, family, src, [(fo,bit,par)...])]，mux 区用定律，其余用查表。"""
    out = []
    for fam, f in model["families"].items():
        pair, par, primary = f["pair"], f["parity"], f["primary"]
        pbit = pair if primary == "P" else pair + 1
        sbit = pair + 1 if primary == "P" else pair
        for src, (r, code) in f["slots"].items():
            row_bit = pbit if r in (0, 1, 4, 5) else sbit
            cells = [(16 + r, row_bit, par)]
            for i, fr in enumerate((25, 24, 23, 22)):
                if code >> i & 1:
                    cells.append((fr, pbit, par))
            for tt in ttypes:
                out.append((tt, fam, src, cells))
    for (fam, src), cl in fallback.items():
        cells = sorted({(fo, bit, par) for (fo, bit, par, se) in cl if se == 1})
        if not cells:
            continue
        for tt in ttypes:
            if fam.startswith(("IMUX", "BYP_ALT", "FAN_ALT")):
                continue          # 已由定律覆盖
            out.append((tt, fam, src, cells))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bit", required=True)
    ap.add_argument("--law", default=os.path.join(ROOT, "steps", "pip_reuse_law.json"))
    ap.add_argument("--law-db", default=LAW_DB)
    ap.add_argument("--min-cells", type=int, default=4)
    ap.add_argument("--frames", default="0:26")
    ap.add_argument("--max-report", type=int, default=10)
    a = ap.parse_args()

    t0 = time.time()
    lo, hi = [int(x) for x in a.frames.split(":")]
    model = json.load(open(a.law, encoding="utf-8"))
    M = load_bits(a.bit)
    names, ttypes, cols, ys, bases = load_tiles(a.law_db)
    print("tile=%d  INT_L=%d  INT_R=%d  (%.1fs)"
          % (len(names), int((ttypes == "INT_L").sum()), int((ttypes == "INT_R").sum()),
             time.time() - t0))

    con = sqlite3.connect("file:%s?mode=ro" % a.law_db, uri=True)
    fb = collections.defaultdict(list)
    for fam, src, ctt, fo, bit, par, se in con.execute(
            "SELECT family, src_wire, tile_type, frame_off, bit, parity, sense "
            "FROM law_cells WHERE tile_type IN ('INT_L','INT_R')"):
        fb[(fam, src)].append((fo, bit, par, se))
    con.close()

    cands = candidates(model, fb, ("INT_L", "INT_R"))
    print("候选 (tile_type, family, src) = %d  (%.1fs)" % (len(cands), time.time() - t0))

    hits = collections.defaultdict(list)
    words = {p: word_of(ys, p) for p in (0, 1)}
    for idx, (tt, fam, src, cells) in enumerate(cands):
        sel = ttypes == tt
        if not sel.any():
            continue
        b = bases[sel]
        per_cell = []
        for (fo, bit, par) in cells:
            per_cell.append(M[b + fo, words[par][sel], bit] > 0)
        allset = np.logical_and.reduce(per_cell)
        if not allset.any():
            continue
        order = np.nonzero(sel)[0]
        for i in np.nonzero(allset)[0]:
            hits[int(order[i])].append((fam, src, len(cells)))
    print("解码完成：%d 个 tile 有命中，总命中 %d 条  (%.1fs)"
          % (len(hits), sum(len(v) for v in hits.values()), time.time() - t0))

    mc = a.min_cells
    built = np.zeros_like(M)
    n_written = n_drop = 0
    for ti, lst in hits.items():
        base = int(bases[ti])
        y = int(ys[ti])
        for fam, src, ncell in lst:
            if ncell < mc:
                n_drop += 1
                continue
            cellset = None
            f = model["families"].get(fam)
            if f:
                r, code = f["slots"][src]
                pair, par, primary = f["pair"], f["parity"], f["primary"]
                pbit = pair if primary == "P" else pair + 1
                sbit = pair + 1 if primary == "P" else pair
                row_bit = pbit if r in (0, 1, 4, 5) else sbit
                cellset = [(16 + r, row_bit, par)]
                for i, fr in enumerate((25, 24, 23, 22)):
                    if code >> i & 1:
                        cellset.append((fr, pbit, par))
            else:
                cellset = [(fo, bit, par) for (fo, bit, par, se) in fb[(fam, src)] if se == 1]
            for (fo, bit, par) in cellset:
                built[base + fo, words[par][ti], bit] = 1
            n_written += 1

    # 比对：只看 INT tile 自己的帧区间（用 tile→base 的唯一 (frame,word) 区域）
    # GCLK 直通使能位：每 tile 一位，位置 (frame_off=0, bit=16, parity=1)，由位流自身判定
    n_gclk = 0
    for ti in range(len(names)):
        base = int(bases[ti])
        w1 = int(words[1][ti])
        if M[base, w1, 16]:
            built[base, w1, 16] = 1
            n_gclk += 1
    print("GCLK 使能位：%d 个 tile" % n_gclk)

    miss = extra = 0
    detail = []
    for ti in range(len(names)):
        base = int(bases[ti])
        y = int(ys[ti])
        for par in (0, 1):
            w = int(words[par][ti])
            orig = M[base + lo:base + hi, w, :]
            new = built[base + lo:base + hi, w, :]
            d = orig != new
            if d.any():
                nm = int((orig & ~new).sum())
                ne = int((new & ~orig).sum())
                miss += nm
                extra += ne
                if len(detail) < a.max_report:
                    detail.append((names[ti], par, nm, ne))
    print("写入 %d 条 PIP（丢弃 %d 条 < %d 格的弱候选）" % (n_written, n_drop, mc))
    print("比对范围 帧%d..%d：漏位 %d，多位 %d" % (lo, hi - 1, miss, extra))
    for d in detail:
        print("   %-16s par%d 漏 %d 多 %d" % d)
    return 0


if __name__ == "__main__":
    sys.exit(main())
