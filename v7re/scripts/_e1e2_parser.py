#!/usr/bin/env python3
"""E1+E2（权威版）：用 bitstream.parser 精确解帧，核对 frame 31784..31787。"""
import io
import json
import os
import sys
import numpy as np
from collections import defaultdict

ROOT = r"E:\DEEPSEEK\FPGA比特流逆向\v7re"
sys.path.insert(0, ROOT)
from bitstream.parser import frames_from_bit  # noqa

DIR = r"E:\DEEPSEEK\FPGA比特流逆向\_crc"
STEPS = os.path.join(ROOT, "steps")
FRAMES = [31784, 31785, 31786, 31787]
ECC = 50


def load(p):
    return np.array(frames_from_bit(p), dtype=np.uint32)


def nz(row):
    d, e = set(), set()
    for w in range(len(row)):
        v = int(row[w])
        while v:
            b = (v & -v).bit_length() - 1
            (e if w == ECC else d).add((w, b))
            v &= v - 1
    return d, e


base = load(os.path.join(DIR, "c_base.bit"))
print("base frames:", base.shape, flush=True)

ref = defaultdict(set)
for k in json.load(io.open(os.path.join(STEPS, "crc_positions.json"), encoding="utf-8")):
    f, w, b = k.split(":")
    ref[int(f)].add((int(w), int(b)))
print("ref 位置数:", {f: len(ref[f]) for f in FRAMES}, flush=True)
for f in FRAMES:
    print("  ref frame %d: %s" % (f, sorted(ref[f])), flush=True)

print("\n== base 4 帧 ==", flush=True)
for f in FRAMES:
    d, e = nz(base[f])
    print("  frame %d data=%d ecc=%d word50=0x%08X %s" % (f, len(d), len(e), int(base[f, ECC]), sorted(d)[:6]), flush=True)

print("\n== 全 64 份差分（parser 版）==", flush=True)
per_frame = defaultdict(set)
two_cell = 0
recs = []
for k in range(64):
    p = os.path.join(DIR, "c%02d.bit" % k)
    if not os.path.exists(p):
        continue
    a = load(p)
    ch = []
    for f in FRAMES:
        db, _ = nz(base[f]); da, _ = nz(a[f])
        for (w, b) in (db ^ da):
            ch.append((f, w, b))
    # 4 帧以外是否也有变化
    out = 0
    for i in range(a.shape[0]):
        if i in FRAMES:
            continue
        if not np.array_equal(a[i], base[i]):
            out += 1
    recs.append((k, ch, out))
    if len(ch) == 1:
        per_frame[ch[0][0]].add((ch[0][1], ch[0][2]))
    else:
        two_cell += 1
    if k < 4 or len(ch) != 1:
        print("  c%02d cells=%d outside=%d %s" % (k, len(ch), out, ch[:3]), flush=True)

print("\n单格 %d / 64，多格 %d" % (64 - two_cell, two_cell), flush=True)

print("\n== 单最小项位置分布 ==", flush=True)
allpos = set()
for f in per_frame:
    allpos |= {(f, w, b) for (w, b) in per_frame[f]}
print("位置总数(去重后)", len(allpos), flush=True)
for f in FRAMES:
    ws = sorted({w for (w, b) in per_frame[f]})
    print("  frame %d: %d 位置 words=%s" % (f, len(per_frame[f]), ws), flush=True)

print("\n== E2: word50 命中 ==", flush=True)
h = [p for p in allpos if p[1] == ECC]
print("  ", len(h), h[:5], flush=True)

print("\n== E1: 三对的有效非零约束 ==", flush=True)
for i in range(3):
    f0, f1 = FRAMES[i], FRAMES[i + 1]
    p0, p1 = per_frame[f0], per_frame[f1]
    n0 = sum(1 for (w, b) in p0 if (int(base[f0, w]) >> b) & 1)
    n1 = sum(1 for (w, b) in p1 if (int(base[f1, w]) >> b) & 1)
    print("  pair%d %d->%d 左%d位置非零%d 右%d位置非零%d %s"
          % (i, f0, f1, len(p0), n0, len(p1), n1,
             "全零对(零约束)" if n0 == 0 and n1 == 0 else "有效"), flush=True)
