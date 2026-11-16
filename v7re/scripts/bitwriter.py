#!/usr/bin/env python3
"""bitwriter.py —— T5 v1：由 PIP 列表写出配置位（只覆盖 mux 区，帧 16–25）。

能力边界（v1 明确声明）：
  * 支持 family：IMUX_L0..47、BYP_ALT0..7、FAN_ALT0..7（帧 16–25 的网格族，
    地址与位由 `pip_reuse_law.json` 的定律算出）；
  * 不支持：帧 0–15 的时钟/控制族（12 个复合码族）与帧 2–7 的 BEG6/4 —— 这些仍走查表；
  * 只写 `sense=1` 位；`sense=0` 位在本区不参与（清空后自然为 0）。

命令：
  # 往返自检：把某 tile 的 mux 区清空 → 只用 PIP 列表重写 → 与原始位流逐位比对
  python bitwriter.py --selftest --bit _full8.bit --pips _full8.pips
"""
import argparse
import collections
import json
import os
import sqlite3
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
from bitstream.parser import frames_from_bit  # noqa: E402

LAW_DB = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
BAND_ROWS = 50
GRID_FRAMES = tuple(range(16, 26))


def load_bits(path):
    frames = frames_from_bit(path)
    arr = np.array(frames, dtype=np.uint32)
    bits = np.unpackbits(arr.view(np.uint8).reshape(arr.shape[0], 404),
                         axis=1, bitorder="little")
    return bits.reshape(arr.shape[0], 101, 32)


def word_of(y, parity):
    w = 2 * (y % BAND_ROWS) + parity
    return w + 1 if w >= 50 else w


def tile_base(db, tile_name):
    con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
    row = con.execute("SELECT tile_type, col, y FROM law_tiles WHERE tile_name=?",
                      (tile_name,)).fetchone()
    if not row:
        con.close()
        return None
    ttype, col, y = row
    bbr = json.loads(con.execute(
        "SELECT value FROM meta WHERE key='band_by_region'").fetchone()[0])
    band = bbr[min(y // BAND_ROWS, len(bbr) - 1)]
    r = con.execute("SELECT start_frame FROM far_bands WHERE band=? AND col=?",
                    (band, col)).fetchone()
    con.close()
    if not r:
        return None
    return ttype, int(r[0]), y


def parse_pips(path):
    out = []
    for line in open(path, encoding="utf-8", errors="replace"):
        parts = line.split()
        if len(parts) < 2:
            continue
        pip = parts[1]
        if "->>" not in pip or "/" not in pip:
            continue
        tile, rest = pip.split("/", 1)
        src, dst = rest.split("->>")
        src = src.split(".", 1)[1] if "." in src else src
        out.append((tile, src, dst))
    return out


def load_fallback(db):
    """帧 0–15 等非 mux 区 family 的查表数据：(family, src) -> [(fo, bit, par, sense)]。"""
    con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
    tab = collections.defaultdict(list)
    for fam, src, fo, bit, par, se in con.execute(
            "SELECT family, src_wire, frame_off, bit, parity, sense FROM law_cells "
            "WHERE tile_type IN ('INT_L','INT_R')"):
        tab[(fam, src)].append((fo, bit, par, se))
    con.close()
    return tab


def predict(model, family, src, fallback=None):
    """mux 区用定律；其余 family 用查表。返回 {(frame_off, bit, parity)} 或 None。"""
    f = model["families"].get(family)
    if f:
        sl = f["slots"].get(src)
        if not sl:
            return None
        r, code = sl
        pair, par, primary = f["pair"], f["parity"], f["primary"]
        pbit = pair if primary == "P" else pair + 1
        sbit = pair + 1 if primary == "P" else pair
        row_bit = pbit if r in (0, 1, 4, 5) else sbit
        cells = {(16 + r, row_bit, par)}
        for i, fr in enumerate((25, 24, 23, 22)):
            if code >> i & 1:
                cells.add((fr, pbit, par))
        return cells
    if fallback:
        cl = fallback.get((family, src))
        if cl:
            return {(fo, bit, par) for (fo, bit, par, se) in cl if se == 1}
    return None


def clear_region(M, base, y, lo=16, hi=26):
    """把该 tile 的帧 lo..hi-1 × 该 y 的两个字清零。"""
    for par in (0, 1):
        w = word_of(y, par)
        M[base + lo:base + hi, w, :] = 0


# GCLK 直通族（prjxray INT 表未覆盖）：每 tile 一位，位置实验测定
GCLK_PASS_BIT = (0, 16)     # (frame_off, bit)，parity 固定 1


def write_pips(M, base, y, pips, model, unknown, fallback=None):
    """按 PIP 列表置位；返回成功写入的条数。"""
    ok = 0
    for src, fam in pips:
        if fam.startswith("GCLK_L_B"):
            fo, bit = GCLK_PASS_BIT
            M[base + fo, word_of(y, 1), bit] = 1
            ok += 1
            continue
        cells = predict(model, fam, src, fallback)
        if cells is None:
            unknown.append((fam, src))
            continue
        for (fo, bit, par) in cells:
            M[base + fo, word_of(y, par), bit] = 1
        ok += 1
    return ok


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bit")
    ap.add_argument("--pips")
    ap.add_argument("--law", default=os.path.join(ROOT, "steps", "pip_reuse_law.json"))
    ap.add_argument("--law-db", default=LAW_DB)
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--frames", default="16:26", help="自检范围，默认 mux 区 16:26")
    ap.add_argument("--with-table", action="store_true",
                    help="帧 0–15 等非 mux 区 family 走 law_cells 查表")
    a = ap.parse_args()

    model = json.load(open(a.law, encoding="utf-8"))
    fallback = load_fallback(a.law_db) if a.with_table else None
    lo, hi = [int(x) for x in a.frames.split(":")]
    M = load_bits(a.bit)
    pips = parse_pips(a.pips)
    by_tile = collections.defaultdict(list)
    for tile, src, dst in pips:
        if a.with_table or dst.startswith(("IMUX", "BYP_ALT", "FAN_ALT")):
            by_tile[tile].append((src, dst))

    if a.selftest:
        total_ok = total_bad = 0
        for tile in sorted(by_tile):
            tb = tile_base(a.law_db, tile)
            if not tb:
                print("!! 无地址:", tile)
                continue
            ttype, base, y = tb
            before = M[base + lo:base + hi, :, :].copy()
            clear_region(M, base, y, lo, hi)
            unknown = []
            n = write_pips(M, base, y, by_tile[tile], model, unknown, fallback)
            after = M[base + lo:base + hi, :, :]
            diff = int(np.count_nonzero(before != after))
            total_ok += (diff == 0)
            total_bad += (diff != 0)
            print("%-16s PIP=%2d 写入=%2d 未知=%s 往返差异位=%d %s"
                  % (tile, len(by_tile[tile]), n, unknown or "无", diff,
                     "PASS" if diff == 0 else "FAIL"))
        print("\n往返自检：%d 个 tile PASS，%d 个 FAIL" % (total_ok, total_bad))
        return 0 if total_bad == 0 else 1
    print("v1 只提供 --selftest；写入接口见 write_pips()")
    return 0


if __name__ == "__main__":
    sys.exit(main())
