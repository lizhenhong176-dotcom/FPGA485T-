#!/usr/bin/env python3
"""verify_superposition.py —— T4：多 PIP 同时开启时，用 T3 定律「先预测、再对账」。

思路（不依赖 Vivado 解码器）：
  1. 从 Vivado 的 `get_pips -of_objects <net>` 导出文件里取出该设计真正打开的 IMUX PIP；
  2. 用 `pip_reuse_law.json` 的定律算出每个 PIP 应当置位的 (frame, word, bit)；
  3. 在真实 bitstream 里逐位核对：设计里打开的 PIP —— 全部预测位必须为 1；
     同 tile 内未被设计使用的 PIP —— 不允许出现「全部预测位都为 1」（否则不可区分）。

这一步回答的是：48 条 PIP 同时生效时，位仍然是「逐条 pattern 的并集」吗（线性叠加）。

用法：
  python verify_superposition.py --bit _full8.bit --pips _full8.pips --law v7re/steps/pip_reuse_law.json
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


def bit_matrix(path):
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
    """'net TILE/TILE.SRC->>DST' → [(tile, src, dst)]，只保留 IMUX 目的。"""
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
        if dst.startswith("IMUX"):
            out.append((tile, src, dst))
    return out


def predict(model, family, src):
    f = model["families"].get(family)
    if not f:
        return None
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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bit", required=True)
    ap.add_argument("--pips", required=True)
    ap.add_argument("--law", default=os.path.join(ROOT, "steps", "pip_reuse_law.json"))
    ap.add_argument("--law-db", default=LAW_DB)
    a = ap.parse_args()

    model = json.load(open(a.law, encoding="utf-8"))
    M = bit_matrix(a.bit)
    pips = parse_pips(a.pips)
    used = collections.defaultdict(set)
    for tile, src, dst in pips:
        used[tile].add((dst, src))

    tot = ok = 0
    missing = []
    for tile in sorted(used):
        tb = tile_base(a.law_db, tile)
        if not tb:
            print("!! tile 无地址:", tile)
            continue
        ttype, base, y = tb
        # 该 tile 内所有 IMUX family 的全部源（用于负对照）
        fams = {f for f in model["families"] if f.startswith("IMUX")}
        allpairs = {(f, s) for f in fams for s in model["families"][f]["slots"]}
        for fam, src in sorted(used[tile]):
            pred = predict(model, fam, src)
            if pred is None:
                missing.append((tile, fam, src))
                continue
            tot += 1
            bits = []
            for (fo, bit, par) in sorted(pred):
                w = word_of(y, par)
                bits.append(int(M[base + fo, w, bit]))
            if all(bits):
                ok += 1
            else:
                missing.append((tile, fam, src, bits))
        # 负对照：未被使用的 (family, src) 中，有多少条的全部预测位也都是 1
        fp = 0
        for fam, src in allpairs - used[tile]:
            pred = predict(model, fam, src)
            if not pred:
                continue
            if all(M[base + fo, word_of(y, par), bit] for (fo, bit, par) in pred):
                fp += 1
        print("%-16s family 在用=%2d  tile 内全部候选=%d  负对照(全 1 误命中)=%d"
              % (tile, len(used[tile]), len(allpairs), fp))

    print("\n结果：设计的 %d 条 IMUX PIP 中 %d 条的预测位全部为 1" % (tot, ok))
    for m in missing[:10]:
        print("   未命中:", m)
    return 0 if (tot and ok == tot) else 1


if __name__ == "__main__":
    sys.exit(main())
