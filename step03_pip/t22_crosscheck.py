#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""T22 交叉自证：用 T19 的 64 单最小项锁引脚表按 (bel, Y) 规则平移，比对 T22 实测差分集。"""
import json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
TABLE = os.path.join(ROOT, "v7re", "steps", "clb_init_locked_x12y20_a6lut.json")
RAW = os.path.join(HERE, "t22_diff_raw.txt")
VAL = 0xDEADBEEFCAFEBABE
Y = 26

def word_for(y, parity=0):
    w = 2 * (y % 50) + parity
    return w + 1 if w >= 50 else w

def main():
    table = json.load(open(TABLE, encoding="utf-8"))
    pred = set()
    for k, (f, _w, b) in table.items():
        if (VAL >> int(k)) & 1:
            pred.add((f, word_for(Y), b))
    raw = open(RAW, encoding="utf-8").read()
    m = re.search(r"JSON_BEGIN\s*(\[.*?\])\s*JSON_END", raw, re.S)
    res = json.loads(m.group(1))
    act, ecc = set(), set()
    for f, words in res[0]["frames"].items():
        for w, bits in words.items():
            for b in bits:
                (ecc if int(w) == 50 else act).add((int(f), int(w), b))
    missing, extra = pred - act, act - pred
    print("pred=%d act=%d missing=%d extra=%d ecc=%d word=%s" % (len(pred), len(act), len(missing), len(extra), len(ecc), sorted({p[1] for p in pred})))
    if missing: print("MISSING", sorted(missing)[:10])
    if extra: print("EXTRA", sorted(extra)[:10])
    nc = res[1]
    print("neg_ctrl_frames=%d neg_ctrl_bits=%d" % (nc["n_frames"], nc["n_bits"]))
    ok = not missing and not extra and nc["n_frames"] == 0
    print("RESULT", "PASS" if ok else "FAIL")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())
