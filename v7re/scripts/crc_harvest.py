#!/usr/bin/env python3
"""crc_harvest.py —— 从所有「单最小项」位流里收集 CRC 位置贡献 c(p)。

做法：每组（同一基线的 64 个单最小项设计）内，逐个文件与基线差分；
若差分只涉及 **1 个数据位置**（word50 之外），则
    c(p) = CRC(file) ^ CRC(base)
直接得到该位置的 CRC 贡献。多个组取并集，覆盖不同 slice / 不同位置的位。

输出：v7re/steps/crc_positions.json  {"<pos>": <32 位值>, ...}
用法：python v7re/scripts/crc_harvest.py [--out ...] [--groups _sb,_lk,...]
"""
import argparse
import glob
import json
import os
import struct
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
from bitstream.parser import parse_bit  # noqa: E402

FRAME_WORDS = 101
ECC_WORD = 50
NEXC = 32
CRC_CMD = 0x30000001


def load_words(path):
    b = parse_bit(path)
    return list(b.payload_words)


def crc_value(words):
    """取第一个 0x30000001（写 CRC 寄存器）之后那个字。payload 之外。"""
    n = len(words)
    for i in range(n - 1, max(n - 40, 0), -1):
        pass
    return None


def crc_of(path):
    data = open(path, "rb").read()
    sync = data.find(b"\xAA\x99\x55\x66")
    n = (len(data) - sync - 4) // 4
    words = struct.unpack(">%dI" % n, data[sync + 4:sync + 4 + 4 * n])
    # 取**第一个** 0x30000001（写 CRC 寄存器）——随设计变；末尾那个是常量
    for i in range(len(words) - 1):
        if words[i] == CRC_CMD:
            return words[i + 1]
    return None


def payload_words(path):
    b = parse_bit(path)
    return list(b.payload_words)


def frame_matrix(words, nframes):
    a = np.array(words[:nframes * FRAME_WORDS], dtype=np.uint32)
    return a.reshape(nframes, FRAME_WORDS)


def diff_positions(A, B):
    """返回两个帧矩阵之间不同的数据位置集合（跳过 word50）。"""
    d = A != B
    d[:, ECC_WORD] = False
    pos = set()
    for f, w in np.argwhere(d):
        x = int(A[f][w]) ^ int(B[f][w])
        base = int(w) * NEXC
        while x:
            b = (x & -x).bit_length() - 1
            pos.add((int(f), base // NEXC, b))   # (frame, word, bit) 绝对
            x &= x - 1
    return pos


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(ROOT, "steps", "crc_positions.json"))
    ap.add_argument("--groups", default="_sb,_lk,_clbll,_t24,_sr4,_m2,_initbits")
    a = ap.parse_args()

    out = {}
    if os.path.exists(a.out):
        out = {k: v for k, v in json.load(open(a.out, encoding="utf-8")).items()}

    for g in a.groups.split(","):
        d = g.strip()
        if not d or not os.path.isdir(d):
            continue
        bits = sorted(glob.glob(os.path.join(d, "**", "*.bit"), recursive=True))
        if len(bits) < 3:
            continue
        # 基线：文件名里带 base / z / b0 的，否则取第一个
        base = None
        for p in bits:
            name = os.path.basename(p).lower()
            if "base" in name or name.startswith("b0") or "_z" in name:
                base = p
                break
        base = base or bits[0]
        base_crc = crc_of(base)
        if base_crc is None:
            print("%-10s 基线无 CRC，跳过" % d)
            continue
        W = payload_words(base)
        nframes = len(W) // FRAME_WORDS
        A = frame_matrix(W, nframes)
        added = 0
        for p in bits:
            if p == base:
                continue
            c = crc_of(p)
            if c is None:
                continue
            Wp = payload_words(p)
            if len(Wp) // FRAME_WORDS != nframes:
                continue
            B = frame_matrix(Wp, nframes)
            pos = diff_positions(A, B)
            if len(pos) != 1:
                continue
            f, w, b = next(iter(pos))
            key = "%d:%d:%d" % (f, w, b)
            val = c ^ base_crc
            if key not in out:
                out[key] = val
                added += 1
        print("%-10s 文件 %d，新增位置 %d，累计 %d" % (d, len(bits), added, len(out)))

    with open(a.out, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=0)
    print("写出 %s：%d 个位置" % (a.out, len(out)))


if __name__ == "__main__":
    main()
