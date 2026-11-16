#!/usr/bin/env python3
"""ecc_model.py —— 建 ECC 数据项模型 L：位置 → 13 位签名。

原理（见 STATUS §32–§34）：
    word50 = ECC(data) ⊕ marker(far 低位)
    ECC(data) = XOR_{p ∈ 置位位置} L[p]     （p = word*32 + bit，跳过 word 50）
marker 只在行/块边界帧非零，因此求解时用「迭代剔除法」把被 marker 污染的方程丢出去。

做法：
  1. 从若干 bitstream 取所有「数据非零」帧 → 方程 (置位集合, ECC 低 13 位)；
  2. GF(2) 消元；有不符的方程就丢掉再解，直到全部一致；
  3. 输出 L 到 JSON。

用法：
    python ecc_model.py --bits _c0.bit ... --out v7re/steps/ecc_model.json
"""
import argparse
import glob
import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
from bitstream.parser import frames_from_bit  # noqa: E402

ECC_WORD = 50
ECC_BITS = 0x1FFF
NEXC = 32


def frame_equations(path):
    a = np.array(frames_from_bit(path), dtype=np.uint32)
    out = []
    for fi in range(a.shape[0]):
        row = a[fi]
        mask = 0
        for w in range(row.shape[0]):
            if w == ECC_WORD:
                continue
            v = int(row[w])
            while v:
                b = (v & -v).bit_length() - 1
                mask |= 1 << (w * NEXC + b)
                v &= v - 1
        if mask:
            out.append((mask, int(row[ECC_WORD]) & ECC_BITS))
    return out


def solve(equations):
    basis = {}
    contradicted = False
    for mask, val in equations:
        while mask:
            p = mask.bit_length() - 1
            if p in basis:
                m2, v2 = basis[p]
                mask ^= m2
                val ^= v2
            else:
                basis[p] = (mask, val)
                break
        else:
            if val:
                contradicted = True
    sol = {}
    for p in sorted(basis):
        mask, val = basis[p]
        m = mask & ~(1 << p)
        v = val
        while m:
            q = m.bit_length() - 1
            m &= ~(1 << q)
            v ^= sol.get(q, 0)
        sol[p] = v
    return sol, contradicted


def evaluate(mask, sol):
    v = 0
    m = mask
    while m:
        p = m.bit_length() - 1
        m &= ~(1 << p)
        if p not in sol:
            return None
        v ^= sol[p]
    return v


def build(bits, verbose=True):
    eqs = []
    for b in bits:
        eqs.extend(frame_equations(b))
    if verbose:
        print("初始方程 %d 条" % len(eqs))
    cur = eqs
    for it in range(8):
        sol, contra = solve(cur)
        keep = [(m, v) for (m, v) in cur if evaluate(m, sol) == v]
        dropped = len(cur) - len(keep)
        if verbose:
            print("  第 %d 轮：秩 %d，矛盾 %s，保留 %d，剔除 %d"
                  % (it + 1, len(sol), contra, len(keep), dropped))
        if dropped == 0:
            break
        cur = keep
    return sol, cur


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bits", nargs="*", default=None)
    ap.add_argument("--out", default=os.path.join(os.path.dirname(HERE), "steps", "ecc_model.json"))
    a = ap.parse_args()
    bits = a.bits or sorted(glob.glob("_*.bit"))
    bits = [b for b in bits if os.path.exists(b)]
    print("训练 bitstream: %s" % [os.path.basename(b) for b in bits])
    sol, kept = build(bits)
    positions = {}
    for mask, _v in kept:
        m = mask
        while m:
            p = m.bit_length() - 1
            m &= ~(1 << p)
            positions[p] = sol.get(p)
    model = {
        "ecc_bits": ECC_BITS,
        "word": ECC_WORD,
        "positions": {str(p): v for p, v in positions.items() if v is not None},
        "note": "位置 p = word*32+bit；值 = 该位置单独置位时 ECC 的贡献（XOR 线性）",
    }
    with open(a.out, "w", encoding="utf-8") as fh:
        json.dump(model, fh, indent=0)
    print("写出 %s，位置 %d 个" % (a.out, len(model["positions"])))


if __name__ == "__main__":
    main()
