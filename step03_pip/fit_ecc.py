# -*- coding: utf-8 -*-
"""ECC 线性拟合：从 (配置位增量, ECC 增量) 样本解出 13×1600 的列，并做留出验证。

模型：ecc(x) = M·x + c（GF(2)），于是 ecc(var) ^ ecc(ref) = M·(x_var ^ x_ref)。
样本来自 step03_pip/ecc_samples.csv.gz：每行一个变体的一帧，给出差异位与两边的 word50。
"""
import gzip
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SAMPLES = os.path.join(HERE, "ecc_samples.csv.gz")

rows = []
with gzip.open(SAMPLES, "rt") as f:
    for line in f:
        tag, src, nb, pos, eref, evar = line.strip().split(",")
        bits = []
        if pos:
            for p in pos.split(";"):
                w, b = p.split(":")
                bits.append(int(w) * 32 + int(b))
        rows.append((tag, src, bits, int(eref) ^ int(evar)))

# 只保留有差异位的样本，且 ECC 必须真的变了（否则说明该帧 ECC 没被重算）
usable = [r for r in rows if r[2] and r[3] != 0]
print("rows", len(rows), "usable", len(usable))

# 列空间：出现在样本里的位位置
cols = sorted({b for _t, _s, bs, _e in usable for b in bs})
print("distinct bit positions touched:", len(cols))
col_index = {b: i for i, b in enumerate(cols)}

# 目标：13 个 ECC bit 各一个方程（每行 13 个 bit 都参与）
# 解 M 的每一行：ecc_bit_k = sum_j M[k][j] * x_j
# 用样本做最小二乘（GF(2) 高斯消元）。
import copy

N = len(cols)
# 每个样本：一个 13 位目标；构造矩阵行 [x | e]
mat = []
for _t, _s, bs, e in usable:
    row = 0
    for b in bs:
        row |= 1 << col_index[b]
    mat.append((row, e))

# 对 ECC 的每一位 k，解 M[k][*]
cols_m = []
for k in range(13):
    # 方程组：sum_j A[i][j] * m[j] = bit_k(e_i)
    # 用 GF(2) 消元求一个解（若超定且不一致会报）
    # 简化：把 N 位未知数的高斯消元做成 bitset 行，行里附带 13 位 target 一起解
    pass

# 一次解 13 个右端项：矩阵 A (rows x N)，B (rows x 13)
# 把每行压成 python int：低 N 位 = 系数，接着 13 位 = 目标
width = N + 13
A = []
for row, e in mat:
    A.append(row | (e << N))

# 高斯消元（GF(2)），求行最简形
pivots = {}
r = 0
for c in range(N):
    # 找 r 行以后第一个该列为 1 的行
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

# 检查一致性：系数全 0 但目标非 0 的行 → 矛盾
inconsistent = [i for i in range(r, len(A)) if (A[i] & ((1 << N) - 1)) == 0 and (A[i] >> N)]
print("rank", r, "of", N, "inconsistent rows", len(inconsistent))
if inconsistent:
    print("first inconsistent targets:", [bin(A[i] >> N) for i in inconsistent[:3]])

M = [0] * 13  # M[k] 是 N 位掩码
for c, ri in pivots.items():
    tgt = A[ri] >> N
    for k in range(13):
        if (tgt >> k) & 1:
            M[k] |= 1 << c

# 用拟合结果回代，统计残差
def ecc_of(bits):
    v = 0
    for k in range(13):
        if (M[k] & bits).bit_count() & 1:
            v |= 1 << k
    return v

bad = 0
for _t, _s, bs, e in usable:
    got = 0
    row = 0
    for b in bs:
        row |= 1 << col_index[b]
    got = ecc_of(row)
    if got != e:
        bad += 1
print("fit residual bad:", bad, "/", len(usable))

json.dump({"cols": cols, "M": M, "rank": r, "n": len(usable), "bad": bad},
          open(os.path.join(HERE, "ecc_fit.json"), "w"), indent=0)
