# -*- coding: utf-8 -*-
"""在真实位流的时钟尾部帧里扫「一热槽位字段」的特征值（0xd800 未选 / 0xda00 选中）。"""
import sys, collections
sys.path.insert(0, r"E:\DEEPSEEK\FPGA比特流逆向\v7re")
from bitstream.parser import frames_from_bit  # noqa: E402

BIT = r"E:\DEEPSEEK\FPGA比特流逆向\tamper\ref\ref.bit"
fr = frames_from_bit(BIT)      # fr[frame][word] = 32bit int
print("frames", len(fr), "words/frame", len(fr[0]))

BASE = 22118   # band4 col33（HCLK_CMT_X88Y338）
hits = []
for off in range(26, 30):
    for w in range(101):
        v = fr[BASE + off][w]
        hi, lo = (v >> 16) & 0xFFFF, v & 0xFFFF
        if hi in (0xD800, 0xDA00) or lo in (0xD800, 0xDA00):
            hits.append((off, w, hi, lo))
print("含 0xd800/0xda00 半区的字：", len(hits))
by = collections.defaultdict(list)
for off, w, hi, lo in hits:
    tag = ("H" if hi in (0xD800, 0xDA00) else "") + ("L" if lo in (0xD800, 0xDA00) else "")
    by[off].append((w, tag, hex(hi), hex(lo)))
for off in sorted(by):
    print(f"off{off}: {len(by[off])} 字")
    for t in by[off]:
        print("   ", t)
