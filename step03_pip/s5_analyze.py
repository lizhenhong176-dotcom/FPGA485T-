#!/usr/bin/env python
"""S5 analysis: compare measured CARRY4/PRECYINIT/AOUTMUX bits at SLICE_X10Y20
(CBLM_R tile, SLICEM_X0 site, base frame 31716, words 40/41) against
site_cells.json predictions.

Inputs (fetched from remote /opt/lzh/step03/s5/): s5_diff.json, s5_words.json
Usage: python s5_analyze.py [dir_with_jsons]
"""
import json, sys, os

BASE = 31716
W0, W1 = 40, 41

PRED = {
    "PRECYINIT": {
        "C0":  [(0, W0, 12, 0), (30, W0, 13, 0), (30, W0, 14, 0)],
        "C1":  [(0, W0, 12, 1), (30, W0, 13, 0), (30, W0, 14, 0)],
        "CIN": [(0, W0, 12, 0), (30, W0, 13, 1), (30, W0, 14, 0)],
        "AX":  [(0, W0, 12, 0), (30, W0, 13, 0), (30, W0, 14, 1)],
    },
    "CARRY4": {
        "ACY0": [(30, W0, 15, 1)],
        "BCY0": [(1, W0, 15, 1)],
        "CCY0": [(30, W1, 16, 1)],
        "DCY0": [(30, W1, 17, 1)],
    },
    # AOUTMUX SLICEM_X0: bits (30,w40) 6,7,8,11 with per-source senses
    "AOUTMUX": {
        "O6":  [(30, W0, 6, 0), (30, W0, 7, 0), (30, W0, 8, 0), (30, W0, 11, 1)],
        "O5":  [(30, W0, 6, 1), (30, W0, 7, 0), (30, W0, 8, 0), (30, W0, 11, 1)],
        "A5Q": [(30, W0, 6, 0), (30, W0, 7, 1), (30, W0, 8, 0), (30, W0, 11, 0)],
        "CY":  [(30, W0, 6, 1), (30, W0, 7, 0), (30, W0, 8, 1), (30, W0, 11, 0)],
        "XOR": [(30, W0, 6, 0), (30, W0, 7, 0), (30, W0, 8, 1), (30, W0, 11, 0)],
        "F7":  [(30, W0, 6, 1), (30, W0, 7, 1), (30, W0, 8, 0), (30, W0, 11, 0)],
    },
}

VARIANT_SOURCE = {
    "pre_c0": ("PRECYINIT", "C0"), "pre_c1": ("PRECYINIT", "C1"),
    "pre_ax": ("PRECYINIT", "AX"), "pre_cin": ("PRECYINIT", "CIN"),
    "cy0_lut": ("CARRY4", "CY0_LUT"), "cy0_di": ("CARRY4", "CY0_DI"),
    "a_o6": ("AOUTMUX", "O6"), "a_o5": ("AOUTMUX", "O5"),
    "a_a5q": ("AOUTMUX", "A5Q"), "a_xor": ("AOUTMUX", "XOR"),
    "a_cy": ("AOUTMUX", "CY"), "a_f7": ("AOUTMUX", "F7"),
}

def getval(words, off, w, bit):
    x = str(BASE + off)
    if x not in words:
        return None
    word = words[x][0 if w == W0 else 1]
    return (word >> bit) & 1

def main():
    d = sys.argv[1] if len(sys.argv) > 1 else "."
    words = json.load(open(os.path.join(d, "s5_words.json")))
    diff = json.load(open(os.path.join(d, "s5_diff.json")))

    print("=== per-variant predicted bit values vs measured ===")
    for v, (fam, src) in VARIANT_SOURCE.items():
        if v not in words:
            print(v, "MISSING words"); continue
        preds = PRED.get(fam, {}).get(src)
        if preds is None:
            # cy0_lut/cy0_di: just dump all CARRY4 predicted positions values
            preds = [p for s2 in PRED["CARRY4"].values() for p in s2]
        meas = [(p[0], p[1], p[2], getval(words[v], *p[:3])) for p in preds]
        bad = [m for m in meas if m[3] != p_sense(m, preds)]
        print(v, fam, src, "->", meas)

    print("\n=== measured diffs (from s5_diff.json) ===")
    for k, cfg in diff.items():
        print(k, "->", [(c[0] - BASE, c[1], c[2]) for c in cfg])

def p_sense(m, preds):
    for p in preds:
        if (p[0], p[1], p[2]) == (m[0], m[1], m[2]):
            return p[3]
    return None

if __name__ == "__main__":
    main()
