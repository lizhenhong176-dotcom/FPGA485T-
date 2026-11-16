#!/usr/bin/env python3
"""tile_pip_lawscan.py —— 对 prjxray segbits 做「PIP 编码形状」普查。

目标：把 INT 那套分类（6×4 网格 / 完全二分 / one-hot）推到所有 tile 类型，
先离线给出每类的形状与可生成性，再决定哪些需要实测。

用法：
    python tile_pip_lawscan.py --dir prjxray_ref/artix7 --out v7re/steps/tile_pip_lawscan.json
"""
import argparse
import collections
import json
import os
import re
import sys


def parse_segbits(path):
    """→ {(tile, family, src): [(frame_off, parity, bit, sense), ...]}"""
    cells = collections.defaultdict(list)
    tile_type = None
    for line in open(path, encoding="utf-8", errors="replace"):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        feature = parts[0]
        seg = feature.split(".")
        if len(seg) < 3:
            continue
        tile_type = seg[0]
        family = seg[1]
        src = ".".join(seg[2:])
        for tok in parts[1:]:
            sense = 1
            if tok.startswith("!"):
                sense = 0
                tok = tok[1:]
            if "_" not in tok:
                continue
            fo, wb = tok.split("_", 1)
            try:
                fo = int(fo)
                wb = int(wb)
            except ValueError:
                continue
            word = wb // 32
            bit = wb % 32
            cells[(tile_type, family, src)].append((fo, word, bit, sense))
    return cells


def analyze(cells):
    fam_of = collections.defaultdict(lambda: collections.defaultdict(set))
    for (t, fam, src), cs in cells.items():
        for (fo, w, b, sense) in cs:
            if sense:
                fam_of[(t, fam)][src].add((fo, w, b))
    out = []
    for (t, fam), srcs in fam_of.items():
        allc = set().union(*srcs.values()) if srcs else set()
        persrc = collections.Counter(len(v) for v in srcs.values())
        out.append({
            "tile_type": t, "family": fam,
            "sources": len(srcs), "cells": len(allc),
            "cells_per_source": dict(persrc),
            "frames": sorted({c[0] for c in allc}),
            "words": sorted({c[1] for c in allc}),
            "bits": sorted({c[2] for c in allc}),
        })
    return out


def shape(rec):
    """粗分类：one-hot / 一对一 / 多对多"""
    n = rec["sources"]
    per = rec["cells_per_source"]
    if len(per) == 1:
        k = next(iter(per))
        if k == 1 and rec["cells"] == n:
            return "one-hot(每源 1 格)"
        if k == 1:
            return "一对一(有共享)"
    if rec["cells"] and n:
        return "多格(%.1f 格/源, %d 源 → %d 格)" % (rec["cells"] / n, n, rec["cells"])
    return "空"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=os.path.join("prjxray_ref", "artix7"))
    ap.add_argument("--out", default=os.path.join("v7re", "steps", "tile_pip_lawscan.json"))
    a = ap.parse_args()

    summary = {}
    allrec = []
    for p in sorted(os.listdir(a.dir)):
        if not (p.startswith("segbits_") and p.endswith(".db")):
            continue
        cells = parse_segbits(os.path.join(a.dir, p))
        recs = analyze(cells)
        allrec += recs
        tt = sorted({r["tile_type"] for r in recs})
        per = collections.Counter(shape(r).split("(")[0] for r in recs)
        summary[p] = {"tile_types": tt, "families": len(recs), "shapes": dict(per)}
        print("%-26s tile=%s  family=%4d  %s" % (p, ",".join(tt), len(recs), dict(per)))

    with open(a.out, "w", encoding="utf-8") as fh:
        json.dump({"summary": summary, "families": allrec}, fh, indent=1, ensure_ascii=False)
    print("写出 %s（%d 个 family）" % (a.out, len(allrec)))


if __name__ == "__main__":
    main()
