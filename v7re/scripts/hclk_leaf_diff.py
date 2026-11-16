#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""T91 —— HCLK_L 叶子时钟 mux（16 源）的位差分探针。

用法：
    python v7re/scripts/hclk_leaf_diff.py <A.bit> <B.bit> [--control C.bit]

输出：
  1) 两文件在「数据字」上的差分格（frame, word, bit），已跳过帧级 ECC 字 word 50；
  2) 按帧聚簇（相邻帧间隔 <= GAP 视为同簇），打印每簇的帧范围与格数；
  3) 若给 --control（A 的同类对照），打印 (A,B) 与 (A,C) 的簇差异，
     用于把「目标 PIP 造成的格」从「其它布线噪声」里分出来。
"""
import argparse
import collections
import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(_ROOT, "v7re"))
from bitstream.parser import frames_from_bit  # noqa: E402

ECC_WORD = 50
GAP = 64


def cells(path):
    frames = frames_from_bit(path)
    out = []
    for fi, row in enumerate(frames):
        for w, val in enumerate(row):
            if w == ECC_WORD:
                continue
            if val:
                out.append((fi, w, int(val) & 0xFFFFFFFF))
    return frames, out


def diff(a_frames, a_cells, b_frames, b_cells):
    amap = {(f, w): v for f, w, v in a_cells}
    bmap = {(f, w): v for f, w, v in b_cells}
    keys = set(amap) | set(bmap)
    res = []
    for k in sorted(keys):
        x = amap.get(k, 0) ^ bmap.get(k, 0)
        if x:
            for bit in range(32):
                if x >> bit & 1:
                    res.append((k[0], k[1], bit))
    return res


def clusters(cells_list):
    if not cells_list:
        return []
    frames = sorted({c[0] for c in cells_list})
    groups = [[frames[0]]]
    for f in frames[1:]:
        if f - groups[-1][-1] <= GAP:
            groups[-1].append(f)
        else:
            groups.append([f])
    out = []
    for g in groups:
        lo, hi = g[0], g[-1]
        sel = [c for c in cells_list if lo <= c[0] <= hi]
        out.append((lo, hi, len(sel), sel))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("a")
    ap.add_argument("b")
    ap.add_argument("--control", default=None)
    ap.add_argument("--show", type=int, default=6, help="每簇最多打印多少格")
    args = ap.parse_args()

    fa, ca = cells(args.a)
    fb, cb = cells(args.b)
    d = diff(fa, ca, fb, cb)
    print("A=%s  B=%s" % (os.path.basename(args.a), os.path.basename(args.b)))
    print("diff cells (data words only): %d" % len(d))
    for lo, hi, n, sel in clusters(d):
        print("  cluster frames %d..%d  cells=%d" % (lo, hi, n))
        for c in sel[:args.show]:
            print("     (%d,%d,%d)" % c)

    if args.control:
        fc, cc = cells(args.control)
        d2 = diff(fa, ca, fc, cc)
        print()
        print("CONTROL A vs %s : diff cells %d" % (os.path.basename(args.control), len(d2)))
        s1 = set(d)
        s2 = set(d2)
        extra = sorted(s1 - s2)
        print("  cells in A/B but not in A/control: %d" % len(extra))
        for lo, hi, n, sel in clusters(extra):
            print("  extra cluster frames %d..%d  cells=%d" % (lo, hi, n))
            for c in sel[:args.show]:
                print("     (%d,%d,%d)" % c)
    return 0


if __name__ == "__main__":
    sys.exit(main())
