#!/usr/bin/env python3
"""crc_learn.py —— 用「成对位流」学习尾部 CRC 的逐位置贡献。

原理：
  CRC 对报文位是 GF(2) 仿射的：CRC(A) ^ CRC(B) = XOR_{p ∈ A△B} c(p)
  其中 c(p) 是「第 p 位单独翻转对 CRC 的贡献」，与文件无关。
  因此任意两个位流都给出一个关于 c(p) 的线性方程。
  用 N 份同一设计的位流可得到 C(N,2) 个方程 —— 足以解出 c(p)。

用法：
  python crc_learn.py --bits a.bit b.bit ...        # 学习并写模型
  python crc_learn.py --model crc_model.json --bits ... --verify
"""
import argparse
import glob
import itertools
import json
import os
import struct
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))

SYNC = b"\xAA\x99\x55\x66"
FRAME_WORDS = 101


def load_words(path):
    d = open(path, "rb").read()
    s = d.find(SYNC)
    if s < 0:
        raise SystemExit("no sync: %s" % path)
    n = (len(d) - s - 4) // 4
    return np.frombuffer(d[s + 4:s + 4 + 4 * n], dtype=">u4").astype(np.uint32)


def crc_value(words):
    idx = np.nonzero(words == 0x30000001)[0]
    if len(idx) == 0:
        raise SystemExit("no CRC packet")
    return int(words[idx[0] + 1])


def diff_positions(a, b):
    """返回 (word_index, bit) 形式的差异位置（只到 32 位粒度的字级）。"""
    d = a ^ b
    nz = np.nonzero(d)[0]
    return int(nz[0]), nz, d[nz]


def gf2_solve(eqs, nvars, nbits=32):
    """eqs: [(positions, crc_delta)]；逐位解出 c(p) 的每个 bit。"""
    sol = [dict() for _ in range(nbits)]
    for bit in range(nbits):
        basis = {}
        bad = 0
        for poss, delta in eqs:
            mask = 0
            for p in poss:
                mask ^= 1 << p
            val = (delta >> bit) & 1
            while mask:
                h = mask.bit_length() - 1
                if h in basis:
                    m2, v2 = basis[h]
                    mask ^= m2
                    val ^= v2
                else:
                    basis[h] = (mask, val)
                    break
            else:
                if val:
                    bad += 1
        for h in sorted(basis):
            mask, val = basis[h]
            m = mask & ~(1 << h)
            v = val
            while m:
                q = m.bit_length() - 1
                m &= ~(1 << q)
                v ^= sol[bit].get(q, 0)
            sol[bit][h] = v
    return sol, bad


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bits", nargs="*", default=None)
    ap.add_argument("--model", default=os.path.join(HERE, "..", "steps", "crc_model.json"))
    ap.add_argument("--build", action="store_true")
    ap.add_argument("--verify", action="store_true")
    a = ap.parse_args()
    files = a.bits or sorted(glob.glob("_s[0-9]*.bit"))
    files = [f for f in files if os.path.exists(f)]
    print("样本 %d 份：%s ..." % (len(files), [os.path.basename(f) for f in files[:4]]))

    W = {f: load_words(f) for f in files}
    C = {f: crc_value(W[f]) for f in files}
    base_len = len(next(iter(W.values())))
    for f in files:
        if len(W[f]) != base_len:
            raise SystemExit("字数不一致: %s" % f)

    # 收集所有出现过的位置
    pos_set = set()
    pairs = []
    for f1, f2 in itertools.combinations(files, 2):
        _, idx, _ = diff_positions(W[f1], W[f2])
        for i in idx:
            d = int(W[f1][i] ^ W[f2][i])
            while d:
                b = (d & -d).bit_length() - 1
                pos_set.add(int(i) * 32 + b)
                d &= d - 1
        pairs.append((f1, f2))
    pos_list = sorted(pos_set)
    pid = {p: i for i, p in enumerate(pos_list)}
    print("位置总数 %d，文件对数 %d" % (len(pos_list), len(pairs)))

    eqs = []
    for f1, f2 in pairs:
        _, idx, vals = diff_positions(W[f1], W[f2])
        poss = []
        for i, v in zip(idx, vals):
            d = int(v)
            while d:
                b = (d & -d).bit_length() - 1
                poss.append(pid[int(i) * 32 + b])
                d &= d - 1
        eqs.append((poss, C[f1] ^ C[f2]))
    sol, bad = gf2_solve(eqs, len(pos_list))
    print("求解完成：每 bit 解出位置数 =", [len(s) for s in sol][:8], "...；矛盾方程 =", bad)

    model = {"n_positions": len(pos_list),
             "positions": [p for p in pos_list],
             "sol": [dict((str(k), v) for k, v in s.items()) for s in sol]}
    with open(a.model, "w", encoding="utf-8") as fh:
        json.dump(model, fh)
    print("写出 %s" % a.model)


if __name__ == "__main__":
    main()
