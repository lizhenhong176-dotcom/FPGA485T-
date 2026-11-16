#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""远端：把每个 .bit 里所有置 1 的配置位导出成 `frame word bit` 文本（纯 python，无 numpy）。

FDRI 载荷 = 5,067,776 字 × 4 B；第 i 帧 = payload[404i : 404(i+1)]，第 j 字 = 大端 4 B。
"""
import io
import os
import struct
import sys

SYNC = b"\xaa\x99\x55\x66"
NWORD = 5067776
FRAME_BYTES = 404


def payload(path):
    raw = io.open(path, "rb").read()
    i = raw.find(SYNC)
    if i < 0:
        raise SystemExit("no sync in " + path)
    p = i + 4
    while p + 4 <= len(raw):
        h = struct.unpack_from(">I", raw, p)[0]
        if (h >> 29) & 0x7 == 2:                      # Type2
            op = (h >> 27) & 0x3
            cnt = h & 0x7FFFFFF
            if op == 2 and cnt == NWORD:              # FDRI write
                return raw[p + 4:p + 4 + cnt * 4]
            p += 4 + cnt * 4
            continue
        if (h >> 29) & 0x7 == 1:                      # Type1
            op = (h >> 27) & 0x3
            cnt = h & 0x7FF
            p += 4 if op in (0, 1) else 4 + cnt * 4
            continue
        p += 4
    raise SystemExit("no FDRI in " + path)


def dump(path, out):
    pl = payload(path)
    nf = len(pl) // FRAME_BYTES
    lines = []
    for f in range(nf):
        base = f * FRAME_BYTES
        for w in range(101):
            v = struct.unpack_from(">I", pl, base + w * 4)[0]
            if not v:
                continue
            while v:
                b = (v & -v).bit_length() - 1
                lines.append("%d %d %d" % (f, w, b))
                v &= v - 1
    io.open(out, "w", encoding="utf-8").write("\n".join(lines) + "\n")
    return nf, len(lines)


if __name__ == "__main__":
    d = sys.argv[1]
    for fn in sorted(os.listdir(d)):
        if not fn.endswith(".bit"):
            continue
        name = fn[:-4]
        nf, n = dump(os.path.join(d, fn), os.path.join(d, name + ".cells.txt"))
        print("%-14s frames %d  set_bits %d" % (name, nf, n))
