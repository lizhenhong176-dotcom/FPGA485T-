#!/usr/bin/env python3
"""E1+E2 直接核查：CLB 语料里 frame 31784..31787 的真实非零位分布。

E1: 三对连续帧里有没有"全零对"（0 = M·0 对任意 M 成立，不构成约束）
E2: 那 16 个位置里有没有 word 50（帧级 ECC）；ECC 本身是线性函数，
    混进来会让 rank 好看但不是帧间硬件映射
"""
import os
import sys
import numpy as np
from collections import defaultdict

ROOT = r"E:\DEEPSEEK\FPGA比特流逆向\v7re"
sys.path.insert(0, ROOT)
from bitstream.parser import frames_from_bit  # noqa

DIR = r"E:\DEEPSEEK\FPGA比特流逆向\_crc"
FRAMES = [31784, 31785, 31786, 31787]
ECC_WORD = 50


def cells_in(a, fi):
    """该帧所有非零 (word,bit)，含 word50 单独返回。"""
    row = a[fi]
    data, ecc = set(), set()
    for w in range(a.shape[1]):
        v = int(row[w])
        while v:
            b = (v & -v).bit_length() - 1
            (ecc if w == ECC_WORD else data).add((w, b))
            v &= v - 1
    return data, ecc


def load(path):
    return np.array(frames_from_bit(path), dtype=np.uint32)


base_p = os.path.join(DIR, "c_base.bit")
print("base:", base_p, "exists=", os.path.exists(base_p), flush=True)
base = load(base_p)
print("shape:", base.shape, flush=True)

print("\n== 每帧非零数据位数 / word50 值（base）==")
for fi in FRAMES:
    d, e = cells_in(base, fi)
    eccv = int(base[fi, ECC_WORD])
    print("  frame %d  data_bits=%2d  ecc_ones=%2d  word50=0x%08X" % (fi, len(d), len(e), eccv))

# 全 4 帧 union
union = set()
for fi in FRAMES:
    d, _ = cells_in(base, fi)
    for (w, b) in d:
        union.add((fi, w, b))
print("\nbase 里这 4 帧的 位置并集: %d 个" % len(union))
byfr = defaultdict(list)
for (fi, w, b) in sorted(union):
    byfr[fi].append((w, b))
for fi in FRAMES:
    print("  frame %d: %s" % (fi, byfr[fi]))

print("\n== 每个 cNN.bit 相对 base 的差分格 ==")
per_frame = defaultdict(set)
cells_of_var = []
nfiles = 0
multi = []
for k in range(64):
    p = os.path.join(DIR, "c%02d.bit" % k)
    if not os.path.exists(p):
        continue
    nfiles += 1
    a = load(p)
    changed = []
    for fi in FRAMES:
        db, _ = cells_in(base, fi)
        dv, _ = cells_in(a, fi)
        for c in (db ^ dv):
            changed.append((fi, c[0], c[1]))
    # 也检查这 4 帧以外是否有变化（应当没有）
    outside = 0
    for fi in range(a.shape[0]):
        if fi in FRAMES:
            continue
        if not np.array_equal(a[fi], base[fi]):
            outside += 1
    tag = "1CELL" if (len(changed) == 1 and outside == 0) else "cells%d/outside%d" % (len(changed), outside)
    if tag != "1CELL":
        multi.append((k, tag, changed[:3]))
    for (fi, w, b) in changed:
        per_frame[fi].add((w, b))
    if k < 8 or tag != "1CELL":
        print("  c%02d  %-18s %s" % (k, tag, changed[:2]))

print("\n单格样本: %d / %d  （异常 %d 个）" % (nfiles - len(multi), nfiles, len(multi)))
if multi:
    for m in multi[:6]:
        print("   异常:", m)

print("\n== 64 个单最小项落在哪些位置 ==")
allpos = set()
for fi in per_frame:
    allpos |= per_frame[fi]
print("  位置总数: %d  （应为 64）" % len(allpos))
for fi in FRAMES:
    ws = sorted({w for (w, b) in per_frame[fi]})
    bits = sorted({b for (w, b) in per_frame[fi]})
    print("  frame %d: %2d 个位置  words=%s  bits=%s" % (fi, len(per_frame[fi]), ws, bits))

print("\n== E2: 有没有 word 50 ==")
hit50 = [p for p in allpos if p[1] == ECC_WORD]
print("  命中 word50 的位置数:", len(hit50), hit50[:5])

print("\n== E1: 三对连续帧，各自在“16 位置”上的非零位数 ==")
for i, (f0, f1) in enumerate(zip(FRAMES, FRAMES[1:])):
    p0 = per_frame[f0]
    p1 = per_frame[f1]
    n0_base = sum(1 for (w, b) in p0 if (base[f0, w] >> b) & 1)
    n1_base = sum(1 for (w, b) in p1 if (base[f1, w] >> b) & 1)
    print("  pair %d: 31784+%d->31785+%d  左位置%d(非零%d) 右位置%d(非零%d)  %s"
          % (i, i, i, len(p0), n0_base, len(p1), n1_base,
             "全零对(无约束)" if (n0_base == 0 and n1_base == 0) else "有效"))

print("\n== base 里 4 帧的 word50 ===")
for fi in FRAMES:
    print("  frame %d  word50=0x%08X" % (fi, int(base[fi, ECC_WORD])))
