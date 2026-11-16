# -*- coding: utf-8 -*-
"""E3 判读：XOR 线性模型 vs 算术求和模型。"""
import json
import os
import re

MASK = 0x1FFF

SINGLE = {
    0x0: 0x0860, 0x1: 0x1861, 0x2: 0x1862, 0x3: 0x0863,
    0x4: 0x1864, 0x5: 0x0865, 0x6: 0x0866, 0x7: 0x1867,
    0x8: 0x1868, 0x9: 0x0869, 0xA: 0x086A, 0xB: 0x186B,
    0xC: 0x086C, 0xD: 0x186D, 0xE: 0x186E, 0xF: 0x086F,
}
DESC = {
    "e3_a": "同帧 2 位 {w15,w14}",
    "e3_b": "同帧 4 位 {w15..w12}",
    "e3_c": "跨帧控制 31786.w15 + 31787.w15",
    "e3_d": "同帧 2 位 {w14,w13}",
    "e3_e": "同帧全部 16 位 {w15..w0}",
}


def xor_sum(bits):
    v = 0
    for b in bits:
        v ^= SINGLE[b]
    return v & MASK


def add_sum(bits):
    return sum(SINGLE[b] for b in bits) & MASK


root = os.path.dirname(os.path.abspath(__file__))
s = open(os.path.join(root, "_e3_diff_out.txt"), encoding="utf-8", errors="replace").read()
m = re.search(r"E3DIFF_JSON_BEGIN(.*?)E3DIFF_JSON_END", s, re.S)
data = json.loads(m.group(1).strip())
print("frames=%s frame_words=%s  (期望 50176 / 101)" % (data["frames"], data["frame_words"]))
print()
hdr = "%-7s %-24s %-6s %-20s %-8s %-8s %-8s %s" % (
    "变体", "说明", "帧", "word40 置位", "观测", "XOR预测", "ADD预测", "判定")
print(hdr)
print("-" * len(hdr))
tally = {"XOR": 0, "ADD": 0, "OTHER": 0}
for tag in ["e3_a", "e3_b", "e3_c", "e3_d", "e3_e"]:
    v = data["variants"][tag]
    ecc = {int(k): tuple(x) for k, x in v["ecc"].items()}
    real = {}
    for fr, wd, bt in v["content_positions"]:
        if wd == 40:
            real.setdefault(fr, set()).add(bt)
    for fr in sorted(v["frames_touched"]):
        bits = real.get(fr, set())
        obs = ecc[fr][1] if fr in ecc else 0
        xv, av = xor_sum(bits), add_sum(bits)
        if obs == xv and xv != av:
            verdict = "XOR"
        elif obs == av and av != xv:
            verdict = "ADD"
        elif obs == xv == av:
            verdict = "XOR==ADD"
        else:
            verdict = "都不是"
        tally[verdict if verdict in tally else "OTHER"] += 1
        print("%-7s %-24s %-6d %-20s 0x%04X   0x%04X   0x%04X   %s" % (
            tag, DESC[tag] if fr == 31786 else DESC[tag] + " (31787)",
            fr, ",".join(str(x) for x in sorted(bits)), obs, xv, av, verdict))
print()
print("tally:", tally)
print()
print("内容位核对（应只动 word40，且帧集合与预期一致）：")
for tag in ["e3_a", "e3_b", "e3_c", "e3_d", "e3_e"]:
    v = data["variants"][tag]
    words = sorted({w for _, w, _ in v["content_positions"]})
    print("  %-7s frames=%-16s words=%-6s n_content=%d" % (
        tag, v["frames_touched"], words, v["n_content"]))
