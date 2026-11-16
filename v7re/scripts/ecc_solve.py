#!/usr/bin/env python3
"""ecc_solve.py —— 用 GF(2) 线性代数解出帧级 ECC 的每位置签名 S_b。

模型（已由 T7 证明为线性）：
    对任一帧：  XOR_{p ∈ 置位位置} S_p  ==  ECC(帧)
其中位置 p = word*32 + bit（word 0..100，跳过 50；bit 0..31），S_p 是 32 位未知向量。

做法：
  1. 扫一批 bitstream，取所有「数据字非零」的帧，得到方程 (置位集合, ECC)；
  2. 按最高位主元做 GF(2) 消元，回代求出 S_p（自由变量取 0）；
  3. 用未参与求解的帧/设计做留出验证。

用法：
    python ecc_solve.py --bits _c0.bit _c1.bit ...            # 求解 + 一致性
    python ecc_solve.py --bits _*.bit --holdout _full8.bit   # 留出验证
"""
import argparse
import collections
import glob
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
from bitstream.parser import frames_from_bit  # noqa: E402

ECC_WORD = 50
NEXC = 32


def frame_equations(path):
    """→ [(mask, ecc)]，mask 的位 p = word*32+bit。"""
    a = np.array(frames_from_bit(path), dtype=np.uint32)
    out = []
    for fi in range(a.shape[0]):
        row = a[fi]
        ecc = int(row[ECC_WORD])
        mask = 0
        for w in range(0, a.shape[1]):
            if w == ECC_WORD:
                continue
            v = int(row[w])
            while v:
                b = (v & -v).bit_length() - 1
                mask |= 1 << (w * NEXC + b)
                v &= v - 1
        if mask:
            out.append((mask, ecc, fi))
    return out


def solve(equations):
    """GF(2) 消元；返回 {位置: 值}，以及是否出现矛盾。"""
    basis = {}          # 主元位置 -> (mask, val)
    contradicted = False
    for mask, val, _fi in equations:
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
    for p in sorted(basis):                      # 主元从低位到高位回代
        mask, val = basis[p]
        m = mask & ~(1 << p)
        v = val
        while m:
            q = m.bit_length() - 1
            m &= ~(1 << q)
            if q in sol:
                v ^= sol[q]
        sol[p] = v
    return sol, contradicted, len(basis)


def predict(mask, sol):
    if mask & ~sum((1 << p) for p in sol):
        pass
    v = 0
    m = mask
    missing = 0
    while m:
        p = m.bit_length() - 1
        m &= ~(1 << p)
        if p in sol:
            v ^= sol[p]
        else:
            missing += 1
    return v, missing


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bits", nargs="*", default=None)
    ap.add_argument("--holdout", nargs="*", default=None,
                    help="不参与求解、只做验证的 bitstream")
    ap.add_argument("--out-model", default=None)
    a = ap.parse_args()

    bits = a.bits or sorted(glob.glob("_*.bit"))
    bits = [b for b in bits if os.path.exists(b)]
    hold = [h for h in (a.holdout or []) if os.path.exists(h)]
    if hold:
        bits = [b for b in bits if b not in hold]
    print("训练 bitstream: %d 个  %s" % (len(bits), [os.path.basename(b) for b in bits]))
    if hold:
        print("留出 bitstream: %d 个  %s" % (len(hold), [os.path.basename(h) for h in hold]))

    eqs = []
    for b in bits:
        eqs.extend(frame_equations(b))
    positions = set()
    for mask, _v, _f in eqs:
        m = mask
        while m:
            p = m.bit_length() - 1
            m &= ~(1 << p)
            positions.add(p)
    print("方程 %d 条，涉及位置 %d 个" % (len(eqs), len(positions)))

    sol, contra, rank = solve(eqs)
    print("消元：秩 %d / 未知数 %d，矛盾=%s" % (rank, len(positions), contra))

    # 训练一致性
    ok = bad = miss = 0
    for mask, val, fi in eqs:
        v, m = predict(mask, sol)
        if m:
            miss += 1
        elif v == val:
            ok += 1
        else:
            bad += 1
    print("训练集：一致 %d，不符 %d，缺签名 %d" % (ok, bad, miss))

    if hold:
        hok = hbad = hmiss = 0
        for h in hold:
            for mask, val, fi in frame_equations(h):
                v, m = predict(mask, sol)
                if m:
                    hmiss += 1
                elif v == val:
                    hok += 1
                else:
                    hbad += 1
        print("留出集：一致 %d，不符 %d，缺签名 %d" % (hok, hbad, hmiss))

    if a.out_model:
        with open(a.out_model, "w", encoding="utf-8") as fh:
            fh.write("pos,%s\n" % ",".join("ecc_bit%d" % i for i in range(32)))
            for p in sorted(sol):
                fh.write("%d,%s\n" % (p, ",".join(str((sol[p] >> i) & 1) for i in range(32))))
        print("模型写出:", a.out_model)


if __name__ == "__main__":
    main()
