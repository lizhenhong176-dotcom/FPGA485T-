# -*- coding: utf-8 -*-
"""用全部 tag 的样本拟合 ECC 列向量，输出 ecc_table.json（"word:bit" -> 13 位列）。"""
import gzip
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SAMPLES = os.path.join(HERE, "ecc_samples_all.csv.gz")
OUT = os.path.join(HERE, "ecc_table.json")
REPORT = os.path.join(HERE, "ecc_fit_report.json")

rows = []
with gzip.open(SAMPLES, "rt") as f:
    for line in f:
        tag, src, nb, pos, eref, evar = line.strip().split(",")
        bits = []
        if pos:
            for p in pos.split(";"):
                w, b = p.split(":")
                bits.append(int(w) * 32 + int(b))
        rows.append((tag, src, bits, int(eref), int(evar)))

usable = [r for r in rows if r[2] and (r[3] ^ r[4]) != 0]
print("rows", len(rows), "usable", len(usable))

cols = sorted({b for _t, _s, bs, _e, _v in usable for b in bs})
idx = {b: i for i, b in enumerate(cols)}
N = len(cols)
print("distinct positions:", N)

A = []
for _t, _s, bs, eref, evar in usable:
    row = 0
    for b in bs:
        row |= 1 << idx[b]
    A.append(row | ((eref ^ evar) << N))

pivots = {}
r = 0
for c in range(N):
    sel = None
    for i in range(r, len(A)):
        if (A[i] >> c) & 1:
            sel = i
            break
    if sel is None:
        continue
    A[r], A[sel] = A[sel], A[r]
    for i in range(len(A)):
        if i != r and ((A[i] >> c) & 1):
            A[i] ^= A[r]
    pivots[c] = r
    r += 1

inconsistent = [i for i in range(r, len(A)) if (A[i] & ((1 << N) - 1)) == 0 and (A[i] >> N)]
print("rank", r, "of", N, "inconsistent", len(inconsistent))

M = [0] * 13
for c, ri in pivots.items():
    tgt = A[ri] >> N
    for k in range(13):
        if (tgt >> k) & 1:
            M[k] |= 1 << c

table = {}
for i, pos in enumerate(cols):
    v = 0
    for k in range(13):
        if (M[k] >> i) & 1:
            v |= 1 << k
    table["%d:%d" % (pos // 32, pos % 32)] = v

bad = 0
for _t, _s, bs, eref, evar in usable:
    row = 0
    for b in bs:
        row |= 1 << idx[b]
    got = 0
    for k in range(13):
        if (M[k] & row).bit_count() & 1:
            got |= 1 << k
    if got != (eref ^ evar):
        bad += 1

json.dump(table, open(OUT, "w"), indent=0, sort_keys=True)
json.dump({"positions": N, "rank": r, "samples": len(usable), "bad": bad,
           "inconsistent": len(inconsistent)}, open(REPORT, "w"), indent=1)
print("residual bad:", bad, "wrote", OUT, len(table), "positions")
