# -*- coding: utf-8 -*-
"""LUT6 INIT 编解码器（位级，7 系列，A6LUT）。

实测（2026-10-25，X10Y10 A6LUT，485T）：
基址帧 B=31748，第 k 位（k=0..63，k 即 INIT 位号 = I0+2I1+4I2+8I3+16I4+32I5）落在

    df  = 2*(1 - ((k>>3)&1)) + (k&1)          -> 帧 B+df
    bit = 15 - 4*(k>>4) - ((k>>1)&3)          -> 字 20 的 bit 位

64 个 (df,bit) 两两不同，正好铺满 4 帧 × 字 20 的低 16 位。

用法::

    python lut_codec.py read  x.bit --base 31748
    python lut_codec.py write in.bit out.bit --init 64'h1 --base 31748
"""
from __future__ import annotations

import argparse
import json
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, "v7re"))

WORD = 20
BASE_DEFAULT = 31748
MASK64 = (1 << 64) - 1


def pos(k: int, base: int = BASE_DEFAULT):
    df = 2 * (1 - ((k >> 3) & 1)) + (k & 1)
    bit = 15 - 4 * (k >> 4) - ((k >> 1) & 3)
    return base + df, bit


def load_frames(path):
    from bitstream.parser import frames_from_bit
    return frames_from_bit(path)


def read_init(frames, base=BASE_DEFAULT):
    v = 0
    for k in range(64):
        fr, bit = pos(k, base)
        if (frames[fr][WORD] >> bit) & 1:
            v |= 1 << k
    return v


def encode(frames, init, base=BASE_DEFAULT):
    init &= MASK64
    for k in range(64):
        fr, bit = pos(k, base)
        if (init >> k) & 1:
            frames[fr][WORD] |= 1 << bit
        else:
            frames[fr][WORD] &= ~(1 << bit)


def fdri_payload_span(data: bytes):
    pos_ = data.find(b"\xAA\x99\x55\x66")
    if pos_ < 0:
        raise ValueError("no sync")
    start = pos_ + 4
    nwords = (len(data) - start) // 4
    words = struct.unpack(">%dI" % nwords, data[start:start + nwords * 4])
    i = 0
    ps = pe = None
    while i < len(words):
        h = words[i]
        i += 1
        typ, op, addr, cnt = (h >> 29) & 7, (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF
        if typ == 2:
            i += h & 0x7FFFFFF
            continue
        if typ != 1:
            break
        if op == 0:
            continue
        if op == 1:
            i += 1
            continue
        if addr == 0x02:
            if cnt == 0:
                n = words[i] & 0x7FFFFFF
                i += 1
            else:
                n = cnt
            if ps is None:
                ps = start + i * 4
            i += n
            pe = start + i * 4
            continue
        i += cnt
    return ps, pe


def write_bit(src, dst, init, base=BASE_DEFAULT, ecc=True):
    data = bytearray(open(src, "rb").read())
    frames = load_frames(src)
    old = [list(f) for f in frames]
    encode(frames, init, base)
    patched = 0
    if ecc:
        from imux_ecc import patch_frames
        patched = patch_frames(frames, old)
    ps, pe = fdri_payload_span(bytes(data))
    flat = b"".join(struct.pack(">I", w) for fr in frames for w in fr)
    if len(flat) != pe - ps:
        raise ValueError("payload size mismatch %d vs %d" % (len(flat), pe - ps))
    data[ps:pe] = flat
    open(dst, "wb").write(bytes(data))
    return patched


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("read")
    r.add_argument("bit")
    r.add_argument("--base", type=int, default=BASE_DEFAULT)
    w = sub.add_parser("write")
    w.add_argument("src")
    w.add_argument("dst")
    w.add_argument("--init", required=True)
    w.add_argument("--base", type=int, default=BASE_DEFAULT)
    w.add_argument("--no-ecc", dest="ecc", action="store_false")
    ns = ap.parse_args()
    if ns.cmd == "read":
        print("0x%016x" % read_init(load_frames(ns.bit), ns.base))
        return 0
    init = int(ns.init, 0)
    n = write_bit(ns.src, ns.dst, init, ns.base, ns.ecc)
    print("wrote %s init=0x%016x ecc_patched=%d" % (ns.dst, init & MASK64, n))
    return 0


if __name__ == "__main__":
    sys.exit(main())
