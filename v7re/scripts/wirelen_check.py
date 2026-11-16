#!/usr/bin/env python3
"""wirelen_check.py —— 用「线长编码律」在多 tile 上做独立检验。

定律（T53）：48 个 IMUX 族的列码由两件事决定
  * 族编号段奇偶：`(i // 8) % 2`
  * 源的方向类别：DIAG(NE/SE/NW/SW) / ORTH(NN/SS/EE/WW) / R(NR/SR/ER/WR) / L(NL/SL/EL/WL)
    (i//8) 偶 → DIAG:1 ORTH:2 R:7 L:11
    (i//8) 奇 → DIAG:2 ORTH:1 R:11 L:7
列码 → 帧：1→{25}、2→{24}、7→{23,24,25}、11→{22,24,25}

线长类别由源名里的数字给出：1=SINGLE、2=DOUBLE、4=QUAD、6=SIX。
定律要求：列码 1/2 的族只接 DOUBLE 线，列码 7/11 的族只接 SINGLE 线。

两项检验（都不查 law_cells，纯用名字 + 位流）：
  A) 名字一致性：每个 (tile, family, src) 实例，预测列码的线长类别须等于 src 名里的长度；
  B) 位一致性：预测的列帧格在真实位流里必须为 1。

用法：
  python wirelen_check.py --pips _tilecov/cov.pips --bit _tilecov/cov.bit
"""
import argparse
import collections
import json
import os
import re
import sqlite3
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
from bitstream.parser import frames_from_bit  # noqa: E402

LAW_DB = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
BAND_ROWS = 50
COL_FRAMES = {1: (25,), 2: (24,), 7: (23, 24, 25), 11: (22, 24, 25)}
KIND_OF_LEN = {1: "SINGLE", 2: "DOUBLE", 4: "QUAD", 6: "SIX"}
COL_KIND = {1: "DOUBLE", 2: "DOUBLE", 7: "SINGLE", 11: "SINGLE"}
DIRS = (("DIAG", "NE|SE|NW|SW"), ("ORTH", "NN|SS|EE|WW"),
        ("R", "NR|SR|ER|WR"), ("L", "NL|SL|EL|WL"))
RE_SRC = re.compile(r"^(NE|SE|NW|SW|NN|SS|EE|WW|NR|SR|ER|WR|NL|SL|EL|WL)(\d)")


def family_index(fam):
    m = re.match(r"^IMUX(?:_L)?(\d+)$", fam)
    return int(m.group(1)) if m else None


def classify(src):
    """→ (方向类别, 线长类别) 或 (None, None)"""
    m = RE_SRC.match(src)
    if not m:
        return None, None
    d = m.group(1)
    for cls, pat in DIRS:
        if re.fullmatch(pat, d):
            return cls, KIND_OF_LEN.get(int(m.group(2)))
    return None, None


def predict_col(fam, src):
    i = family_index(fam)
    cls, kind = classify(src)
    if i is None or cls is None:
        return None, None, None
    seg = (i // 8) % 2
    if seg == 0:
        col = {"DIAG": 1, "ORTH": 2, "R": 7, "L": 11}[cls]
    else:
        col = {"DIAG": 2, "ORTH": 1, "R": 11, "L": 7}[cls]
    return col, kind, COL_KIND[col]


def load_tiles(db):
    con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
    tiles = {n: (t, c, y) for n, t, c, y in
             con.execute("SELECT tile_name,tile_type,col,y FROM law_tiles")}
    bbr = json.loads(con.execute(
        "SELECT value FROM meta WHERE key='band_by_region'").fetchone()[0])
    bands = {}
    for band, col, st in con.execute("SELECT band,col,start_frame FROM far_bands"):
        bands[(band, col)] = st
    con.close()
    return tiles, bands, bbr


def word_of(y, parity):
    w = 2 * (y % BAND_ROWS) + parity
    return w + 1 if w >= 50 else w


def parse_pips(path):
    out = []
    for line in open(path, encoding="utf-8", errors="replace"):
        p = line.split()
        if len(p) < 2 or "->>" not in p[1] or "/" not in p[1]:
            continue
        tile, rest = p[1].split("/", 1)
        src, dst = rest.split("->>")
        src = src.split(".", 1)[1] if "." in src else src
        out.append((tile, src, dst))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pips", required=True)
    ap.add_argument("--bit", required=True)
    ap.add_argument("--law-db", default=LAW_DB)
    a = ap.parse_args()

    tiles, bands, bbr = load_tiles(a.law_db)
    pips = parse_pips(a.pips)

    # A) 名字一致性
    seen = set()
    ok = bad = skip = 0
    bad_list = []
    for tile, src, fam in pips:
        if family_index(fam) is None:
            skip += 1
            continue
        key = (tile, fam, src)
        if key in seen:
            continue
        seen.add(key)
        col, kind, need = predict_col(fam, src)
        if col is None:
            skip += 1
            continue
        if kind == need:
            ok += 1
        else:
            bad += 1
            if len(bad_list) < 8:
                bad_list.append((tile, fam, src, col, kind, need))
    print("A) 名字一致性：一致 %d，不一致 %d，跳过 %d（总实例 %d）" % (ok, bad, skip, len(seen)))
    for b in bad_list:
        print("   不一致:", b)

    # B) 位一致性
    LAW = json.load(open(os.path.join(ROOT, "steps", "pip_reuse_law.json"),
                         encoding="utf-8"))["families"]
    M = np.array(frames_from_bit(a.bit), dtype=np.uint32)
    bits = np.unpackbits(M.view(np.uint8).reshape(M.shape[0], 404),
                         axis=1, bitorder="little").reshape(M.shape[0], 101, 32)
    tot = hit = 0
    miss = collections.Counter()
    for tile, fam, src in seen:
        i = family_index(fam)
        if i is None:
            continue
        col, kind, need = predict_col(fam, src)
        if col is None:
            continue
        t = tiles.get(tile)
        if not t:
            continue
        tt, c, y = t
        band = bbr[min(y // BAND_ROWS, len(bbr) - 1)]
        base = bands.get((band, c), -1)
        if base < 0:
            continue
        # 位对：族参数取 pip_reuse_law.json 的 (pair, parity, primary)，只用来定位「哪一位」
        fp = LAW.get(fam)
        if not fp:
            continue
        pair, parity, primary = fp["pair"], fp["parity"], fp["primary"]
        minbit = pair if primary == "P" else pair + 1
        w = word_of(y, parity)
        for fo in COL_FRAMES[col]:
            tot += 1
            if bits[base + fo, w, minbit]:
                hit += 1
            else:
                miss[(fo, minbit)] += 1
    print("B) 列格置位：命中 %d / %d（%.2f%%）" % (hit, tot, 100.0 * hit / tot if tot else 0))
    if miss:
        print("   未命中分布:", dict(list(miss.items())[:8]))


if __name__ == "__main__":
    main()
