#!/usr/bin/env python3
"""init_map_sweep.py —— 由「每个 LUT 各 6 个位平面」的设计差分，重建 CLB LUT INIT 位映射。

原理：
  基线设计 8 个 LUT 的 INIT 全为 0；对 LUT j 的第 k 个构建，把该 LUT 的 INIT 设为
  「索引 i 的第 k 位为 1」的掩码。于是差分中出现的格子集合 S(j,k) 满足：
      格子 c 对应 INIT 索引 i  <=>  对每个 k，c ∈ S(j,k) 当且仅当 i 的第 k 位为 1
  即  i = Σ_k [c ∈ S(j,k)] << k 。
  一次只看一个 LUT，因此不存在「帧 → LUT 归属」的猜测。

用法：
    python init_map_sweep.py --dir . --base b0.bit --out ../steps/clb_init_map_8lut.json
"""
import argparse
import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
from bitstream.parser import frames_from_bit  # noqa: E402

ECC_WORD = 50
BEL = {0: ("SLICE_X12Y20", "A6LUT"), 1: ("SLICE_X12Y20", "B6LUT"),
       2: ("SLICE_X12Y20", "C6LUT"), 3: ("SLICE_X12Y20", "D6LUT"),
       4: ("SLICE_X13Y20", "A6LUT"), 5: ("SLICE_X13Y20", "B6LUT"),
       6: ("SLICE_X13Y20", "C6LUT"), 7: ("SLICE_X13Y20", "D6LUT")}


def cells(path):
    a = np.array(frames_from_bit(path), dtype=np.uint32)
    out = set()
    for f, w in np.argwhere(a):
        w = int(w)
        if w == ECC_WORD:
            continue
        v = int(a[f][w])
        while v:
            b = (v & -v).bit_length() - 1
            out.add((int(f), w, b))
            v &= v - 1
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=".")
    ap.add_argument("--base", default="b0.bit")
    ap.add_argument("--out", default=os.path.join(os.path.dirname(HERE), "steps",
                                                  "clb_init_map_8lut.json"))
    a = ap.parse_args()
    base = cells(os.path.join(a.dir, a.base))
    result = {}
    for j in range(8):
        groups = {}
        for k in range(6):
            p = os.path.join(a.dir, "j%d_k%d.bit" % (j, k))
            if not os.path.exists(p):
                raise SystemExit("缺少 %s" % p)
            s = cells(p) - base
            for c in s:
                groups.setdefault(c, 0)
                groups[c] |= 1 << k
        if len(groups) != 64:
            print("!! LUT j=%d 解出 %d 个格子（期望 64）" % (j, len(groups)))
        idx = {}
        for c, i in groups.items():
            idx[i] = list(c)
        dup = [i for i in idx if i >= 64]
        if dup:
            print("!! LUT j=%d 出现越界索引 %s" % (j, dup[:5]))
        site, bel = BEL[j]
        result["%s/%s" % (site, bel)] = {str(i): idx[i] for i in sorted(idx)}
        frames = sorted({c[0] for c in groups})
        words = sorted({c[1] for c in groups})
        print("j=%d %s/%s：%d 格，帧 %s，字 %s" % (j, site, bel, len(groups), frames, words))
    with open(a.out, "w", encoding="utf-8") as fh:
        json.dump(result, fh, indent=0)
    print("写出 %s" % a.out)


if __name__ == "__main__":
    main()
