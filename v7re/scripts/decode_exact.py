#!/usr/bin/env python3
"""decode_exact.py —— 用「族内精确匹配」解码 INT PIP（任务 3）。

判据对比：
  * 旧判据（roundtrip.py / decode_law.py）：候选源的所有 sense=1 格都为 1 → 判为使用。
    由于同族内存在 1,632 对「pattern 真子集」关系（70/172 个家族受影响），
    子集源会被误判成使用 —— 这就是 full8 上 92 条误判的来源。
  * 新判据（本脚本）：把该 family 的全部 sense=1 格收成一个「位域」，
    读出位域内的实际 0/1 图案，然后要求候选源的 pattern **与观察值完全相等**。
    跨 family 零共享（1,598/1,598 独占）保证位域内只有本族的位，
    所以「恰好相等」是充分必要条件，不再有子集歧义。

用法：
  python decode_exact.py --bit _full8.bit
  python decode_exact.py --bit _full8.bit --pips _full8.pips   # 与路由真值对账
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


def load_bits(path):
    a = np.array(frames_from_bit(path), dtype=np.uint32)
    bits = np.unpackbits(a.view(np.uint8).reshape(a.shape[0], 404),
                         axis=1, bitorder="little")
    return bits.reshape(a.shape[0], 101, 32)


def word_of(y, parity):
    w = 2 * (y % BAND_ROWS) + parity
    return np.where(w >= 50, w + 1, w)


def load_tiles(db):
    con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
    bbr = json.loads(con.execute(
        "SELECT value FROM meta WHERE key='band_by_region'").fetchone()[0])
    bands = {}
    for band, col, start in con.execute("SELECT band,col,start_frame FROM far_bands"):
        bands.setdefault(band, {})[col] = start
    names, ttypes, ys, bases = [], [], [], []
    for name, tt, col, y in con.execute(
            "SELECT tile_name, tile_type, col, y FROM law_tiles "
            "WHERE tile_type IN ('INT_L','INT_R')"):
        band = bbr[min(y // BAND_ROWS, len(bbr) - 1)]
        start = bands.get(band, {}).get(col)
        if start is None:
            continue
        names.append(name); ttypes.append(tt); ys.append(y); bases.append(start)
    con.close()
    return (np.array(names), np.array(ttypes), np.array(ys), np.array(bases, dtype=np.int64))


def load_families(db):
    """(tile_type, family) -> {src: set(cells)} ；cells = (frame_off, parity, bit)"""
    con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
    fams = collections.defaultdict(lambda: collections.defaultdict(set))
    for tt, fam, src, fo, par, bit in con.execute(
            "SELECT tile_type, family, src_wire, frame_off, parity, bit "
            "FROM law_cells WHERE tile_type IN ('INT_L','INT_R') AND sense=1"):
        fams[(tt, fam)][src].add((fo, par, bit))
    con.close()
    return fams


def gclk_pass(M, names, ttypes, ys, bases, got):
    """GCLK 直通：每个接入时钟的 tile 在 (frame_off=0, parity=1, bit=16) 置 1。

    该位只是「本 tile 有 GCLK 接入」的使能，不编码线号；线号由同 tile 的
    `CLK_L*` family 的选中源给出（形如 `GCLK_L_B11_WEST`），据此可还原出
    真实 PIP `GCLK_L_B11 ->> GCLK_L_B11_WEST`。
    """
    idx = {n: i for i, n in enumerate(names)}
    out = []
    seen = set()
    for tile, fam, src in got:
        if not fam.startswith("CLK_L"):
            continue
        i = idx[tile]
        if not M[int(bases[i]), int(word_of(int(ys[i]), 1)), 16]:
            continue
        if not src.startswith("GCLK_L_B"):
            continue
        line = src.rsplit("_", 1)[0]          # GCLK_L_B11_WEST -> GCLK_L_B11
        key = (tile, line)
        if key in seen:
            continue
        seen.add(key)
        out.append((tile, src, line))
    return out


def decode(M, names, ttypes, ys, bases, fams, want=("INT_L", "INT_R")):
    out = []
    for (tt, fam), srcs in fams.items():
        if tt not in want:
            continue
        sel = np.nonzero(ttypes == tt)[0]
        if sel.size == 0:
            continue
        domain = sorted({c for cells in srcs.values() for c in cells})
        base_t, y_t = bases[sel], ys[sel]
        obs = np.zeros((sel.size, len(domain)), dtype=bool)
        for j, (fo, par, bit) in enumerate(domain):
            obs[:, j] = M[base_t + fo, word_of(y_t, par), bit] > 0
        pats = {}
        for src, cells in srcs.items():
            v = np.zeros(len(domain), dtype=bool)
            for c in cells:
                v[domain.index(c)] = True
            pats[src] = v
        for i in range(sel.size):
            row = obs[i]
            if not row.any():
                continue
            hit = [s for s, v in pats.items() if np.array_equal(v, row)]
            for s in hit:
                out.append((names[sel[i]], fam, s))
    return out


def ground_truth(pips_path):
    truth = set()
    for line in open(pips_path, encoding="utf-8", errors="replace"):
        p = line.split()
        if len(p) < 2 or "->>" not in p[1] or "/" not in p[1]:
            continue
        tile, rest = p[1].split("/", 1)
        if not tile.startswith(("INT_L_", "INT_R_")):
            continue
        src, dst = rest.split("->>")
        src = src.split(".", 1)[1] if "." in src else src
        truth.add((tile, dst, src))
    return truth


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bit", required=True)
    ap.add_argument("--pips", default=None)
    ap.add_argument("--law-db", default=LAW_DB)
    ap.add_argument("--no-gclk", action="store_true", help="不做 GCLK 直通还原")
    a = ap.parse_args()

    M = load_bits(a.bit)
    names, ttypes, ys, bases = load_tiles(a.law_db)
    fams = load_families(a.law_db)
    got = decode(M, names, ttypes, ys, bases, fams)
    if not a.no_gclk:
        got += gclk_pass(M, names, ttypes, ys, bases, got)
    dec = {(t, f, s) for t, f, s in got}
    print("%s：精确匹配解出 %d 条 PIP" % (os.path.basename(a.bit), len(dec)))

    if a.pips and os.path.exists(a.pips):
        truth = ground_truth(a.pips)
        tp = dec & truth
        fp = dec - truth
        fn = truth - dec
        prec = 100.0 * len(tp) / max(len(dec), 1)
        rec = 100.0 * len(tp) / max(len(truth), 1)
        print("  对账：真值 %d  命中 %d  多 %d  漏 %d" % (len(truth), len(tp), len(fp), len(fn)))
        print("  精确率 %.1f%%  召回率 %.1f%%" % (prec, rec))
        for x in sorted(fp)[:5]:
            print("    多:", x)
        for x in sorted(fn)[:5]:
            print("    漏:", x)


if __name__ == "__main__":
    main()
