#!/usr/bin/env python3
"""crc_delta.py —— 用学到的位签名表对 .bit 做 CRC 增量重算（T79）。

原理：CRC 对数据位是 GF(2) 线性的：CRC(A)^CRC(B) = XOR_{p in A△B} c(p)。
结构假设已被逐条否定（T79），因此只认"位置 -> 32 位签名"这张表。
注意：word 50 是帧级 ECC，其变化由数据位引起，签名表里已包含这部分影响，
所以只按数据位求增量，跳过 ECC 位本身。

用法：
    python crc_delta.py --base orig.bit --edit new.bit --out fixed.bit
"""
import argparse
import io
import json
import sys

import os

import numpy as np

FRAME_WORDS = 101


def find_sync(data):
    i = data.find(b"\xaa\x99\x55\x66")
    if i < 0:
        raise SystemExit("no sync word")
    return i


def crc_packet_offset(data):
    i = find_sync(data)
    words = np.frombuffer(data[i + 4:], dtype=">u4")
    for k in range(2, len(words) - 1):
        if int(words[k]) == 0x30000001:
            return i + 4 + 4 * k + 4, int(words[k + 1])
    raise SystemExit("no 0x30000001 packet")


def cells_of(path):
    """(frame, word, bit) 集合，word 50（帧级 ECC）不计入。"""
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from bitstream.parser import frames_from_bit
    fr = np.array(frames_from_bit(path), dtype=np.uint32)
    out = set()
    for fi in range(fr.shape[0]):
        row = fr[fi]
        for w in range(FRAME_WORDS):
            if w == 50:
                continue
            v = int(row[w])
            while v:
                b = (v & -v).bit_length() - 1
                out.add((fi, w, b))
                v &= v - 1
    return out


def diff_positions(pa, pb):
    """返回 (改动数据位位置列表, 忽略的 ECC 位个数)。位置 = frame*101*32 + word*32 + bit。"""
    ca, cb = cells_of(pa), cells_of(pb)
    changed = ca ^ cb
    pos = [f * FRAME_WORDS * 32 + w * 32 + b for (f, w, b) in changed]
    return sorted(pos), 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--table", default=r"v7re/steps/crc_table.json")
    ap.add_argument("--base", required=True)
    ap.add_argument("--edit", required=True)
    ap.add_argument("--out")
    ap.add_argument("--allow-unknown", action="store_true")
    a = ap.parse_args()

    tab = {int(k): int(v) for k, v in json.load(io.open(a.table, encoding="utf-8")).items()}
    pos, skipped = diff_positions(a.base, a.edit)
    allpos = pos
    unknown = [p for p in pos if p not in tab]
    delta = 0
    for p in pos:
        if p in tab:
            delta ^= tab[p]

    data = bytearray(open(a.edit, "rb").read())
    off, old = crc_packet_offset(bytes(data))
    new = old ^ delta
    data[off:off + 4] = new.to_bytes(4, "big")

    print("改动位 %d（其中 ECC 位 %d 已跳过）；数据位已知 %d；未知 %d"
          % (len(allpos), skipped, len(pos) - len(unknown), len(unknown)))
    if unknown:
        print("  未知位置示例:", unknown[:5])
        if not a.allow_unknown:
            print("  拒绝写出（--allow-unknown 可强制，但 CRC 会错）")
            return 2
    print("CRC %08x -> %08x" % (old, new))
    if a.out:
        open(a.out, "wb").write(bytes(data))
        print("写出", a.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
