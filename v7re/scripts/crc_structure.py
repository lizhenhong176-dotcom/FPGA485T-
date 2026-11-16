#!/usr/bin/env python3
"""crc_structure.py —— 从单最小项语料里提取 c(p)，并检验结构假设。

语料：base(INIT=0) + c00..c63(INIT=1<<k)，LOC/BEL/LOCK_PINS 固定。
每份与 base 差分应恰好 1 个数据格 p=(frame_off,parity,bit)，同时 CRC 变化 = c(p)。
假设检验：c(p) 是否可由 GF(2) 线性/移位结构给出。
"""
import argparse, os, sys, struct
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
from bitstream.parser import frames_from_bit


def crc_of(path):
    data = open(path, "rb").read()
    i = data.find(b"\xaa\x99\x55\x66")
    if i < 0:
        raise SystemExit("no sync")
    words = np.frombuffer(data[i+4:], dtype=">u4")
    prev = None
    for k in range(2, len(words) - 1):
        if int(words[k]) == 0x30000001:
            return int(words[k+1])
    raise SystemExit("no crc packet: " + path)


def cells(path):
    fr = np.array(frames_from_bit(path), dtype=np.uint32)
    out = set()
    for fi in range(fr.shape[0]):
        row = fr[fi]
        for w in range(101):
            if w == 50:
                continue
            v = int(row[w])
            while v:
                b = (v & -v).bit_length() - 1
                out.add((fi, w, b))
                v &= v - 1
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=r"E:\DEEPSEEK\FPGA比特流逆向\_crc")
    ap.add_argument("--base", default="c_base.bit")
    a = ap.parse_args()
    bp = os.path.join(a.dir, a.base)
    bc = cells(bp)
    bcrc = crc_of(bp)
    rows = []
    for k in range(64):
        p = os.path.join(a.dir, "c%02d.bit" % k)
        if not os.path.exists(p):
            continue
        c = cells(p)
        add = sorted(c - bc)
        rm = sorted(bc - c)
        rows.append((k, add, rm, crc_of(p) ^ bcrc))
    print("== 每份差分 ==")
    one = 0
    for k, add, rm, d in rows:
        flag = "1CELL" if (len(add) == 1 and len(rm) == 0) else ("add%d/rm%d" % (len(add), len(rm)))
        one += 1 if flag == "1CELL" else 0
        print("  c%02d  %-10s CRC^=0x%08x  %s" % (k, flag, d, add[:3]))
    print("\n单格样本: %d / %d" % (one, len(rows)))
    return rows


if __name__ == "__main__":
    main()
