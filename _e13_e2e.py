# -*- coding: utf-8 -*-
"""端到端：用 F 表模型重算真实 .bit 里每一帧的 word50，与文件中的值逐帧比对。

这是"公式对不对"的最终判据 —— 之前所有实验都只动了 word40 的 bit12..15，
本脚本会把 bit0..31 全部走一遍，顺便暴露 bit>=16 是否还服从同一形式。
"""
import collections
import json
import struct
import sys

SYNC = b"\xaa\x99\x55\x66"
FW = 101
ECC_W = 50

doc = json.load(open(r"v7re\steps\e6_ecc_table.json", encoding="utf-8"))
F = {int(k): int(v) for k, v in doc["F"].items()}


def par(x):
    return bin(int(x)).count("1") & 1


def col(word, bit):
    return F[word] ^ bit ^ (0x1000 if par(bit) else 0)


def frames_of(path):
    raw = open(path, "rb").read()
    i = raw.find(SYNC)
    n = (len(raw) - i - 4) // 4
    w = struct.unpack(">%dI" % n, raw[i + 4:i + 4 + n * 4])
    out = []
    k = 0
    while k < len(w):
        h = w[k]
        typ = (h >> 29) & 7
        op = (h >> 27) & 3
        cnt = h & 0x7FF
        k += 1
        if typ == 2:
            c = h & 0x7FFFFFF
            out.extend(w[k:k + c])
            k += c
            continue
        if typ != 1:
            continue
        if op == 2 and cnt:
            k += cnt
        elif op == 1:
            k += 1
    nfr = len(out) // FW
    return [out[f * FW:(f + 1) * FW] for f in range(nfr)]


def recompute(frame):
    acc = 0
    for word in range(FW):
        if word == ECC_W:
            continue
        v = frame[word]
        if not v:
            continue
        hi = v >> 16
        b = 0
        while v:
            if v & 1:
                acc ^= col(word, b)
            v >>= 1
            b += 1
        if hi:
            pass
    return acc & 0x1FFF


def main(path):
    frames = frames_of(path)
    nz = [f for f in frames if any(f[:50]) or any(f[51:])]
    print("%s：%d 帧，非零帧 %d" % (path, len(frames), len(nz)))
    stat = collections.Counter()
    bad_hi = []
    bad_all = []
    for fi, f in enumerate(frames):
        if not (any(f[:50]) or any(f[51:])):
            continue
        has_hi = any((v >> 16) for w, v in enumerate(f) if w != ECC_W)
        got = recompute(f)
        ok = got == f[ECC_W]
        stat[("hi" if has_hi else "lohi", ok)] += 1
        if not ok:
            (bad_hi if has_hi else bad_all).append(
                (fi, hex(got), hex(f[ECC_W]), hex(f[ECC_W] ^ got)))
    print("  结果：")
    for k, v in sorted(stat.items()):
        print("    %-8s ok=%s : %d" % (k[0], k[1], v))
    if bad_all:
        print("  低 16 位仍失配的前 5 例：", bad_all[:5])
    if bad_hi:
        print("  含 bit>=16 的失配前 5 例：", bad_hi[:5])
    return stat


if __name__ == "__main__":
    for p in sys.argv[1:]:
        main(p)
