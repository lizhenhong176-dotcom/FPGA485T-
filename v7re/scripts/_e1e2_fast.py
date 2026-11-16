#!/usr/bin/env python3
"""E1+E2 直接核查（快速版，纯字节差分 + numpy，不跑完整 parser）。

输出：
  A. base 里 frame 31784..31787 的非零数据位 / word50
  B. 64 个 cNN.bit 相对 base 的差分（数据格 / ECC 格 / 包头 CRC 字）
  C. 那 64 个单最小项位置落在哪
  D. E2：有没有 word 50
  E. E1：三对各有多少有效非零约束
"""
import io
import json
import os
import numpy as np
from collections import defaultdict

DIR = r"E:\DEEPSEEK\FPGA比特流逆向\_crc"
STEPS = r"E:\DEEPSEEK\FPGA比特流逆向\v7re\steps"
SYNC = b"\xaa\x99\x55\x66"
FRAME_WORDS = 101
ECC_WORD = 50
FRAMES = [31784, 31785, 31786, 31787]


def sync_off(buf):
    return buf.find(SYNC)


def payload_matrix(buf, word_skip):
    """从 sync 之后 + word_skip 个字起，按 101 字切帧。"""
    off = sync_off(buf) + 4 + 4 * word_skip
    words = np.frombuffer(buf[off:], dtype=">u4").astype(np.uint32)
    n = (len(words) // FRAME_WORDS) * FRAME_WORDS
    return words[:n].reshape(-1, FRAME_WORDS), off


def nz(a, fi):
    row = a[fi]
    data, ecc = set(), set()
    for w in range(FRAME_WORDS):
        v = int(row[w])
        while v:
            b = (v & -v).bit_length() - 1
            (ecc if w == ECC_WORD else data).add((w, b))
            v &= v - 1
    return data, ecc


base_buf = open(os.path.join(DIR, "c_base.bit"), "rb").read()
print("base bytes:", len(base_buf), "sync@", sync_off(base_buf), flush=True)

# --- 对齐：用 crc_positions.json 里 frame 31784 的键做校验 ---
table = json.load(io.open(os.path.join(STEPS, "crc_positions.json"), encoding="utf-8"))
ref = defaultdict(set)
for k in table:
    f, w, b = k.split(":")
    ref[int(f)].add((int(w), int(b)))
print("crc_positions.json 共 %d 键；frame 31784 有 %d 个位置" % (len(table), len(ref[31784])), flush=True)
print("  样例:", sorted(ref[31784])[:8], flush=True)

best = None
for skip in range(0, 20):
    a, off = payload_matrix(base_buf, skip)
    if a.shape[0] <= max(FRAMES):
        continue
    d, _ = nz(a, 31784)
    if d and d == ref[31784]:
        best = (skip, a.shape[0], off)
        break
    if best is None:
        best = (skip, a.shape[0], off)
print("对齐: word_skip=%s 帧数=%s payload_off=%s  (是否与表一致: %s)"
      % (best[0], best[1], best[2], None), flush=True)

skip = best[0]
A, POFF = payload_matrix(base_buf, skip)
print("采用 word_skip=%d，%d 帧" % (skip, A.shape[0]), flush=True)

print("\n== A. base 里 4 帧的内容 ==", flush=True)
for fi in FRAMES:
    d, e = nz(A, fi)
    print("  frame %d  data_bits=%2d  ecc_bits=%2d  word50=0x%08X  %s"
          % (fi, len(d), len(e), int(A[fi, ECC_WORD]), sorted(d)[:6]), flush=True)

print("\n== B. 64 个 cNN.bit 的字节级差分 ==", flush=True)
def off_to_cell(o):
    """payload 内字节偏移 -> (frame, word, bit)"""
    rel = o - POFF
    if rel < 0:
        return None
    f = rel // (FRAME_WORDS * 4)
    r = rel % (FRAME_WORDS * 4)
    w = r // 4
    byte_in_word = r % 4
    if f >= A.shape[0]:
        return None
    return (f, w, (3 - byte_in_word) * 8)  # 大端，仅给字节起始位，稍后定位具体 bit


per_frame = defaultdict(set)
bad = []
for k in range(64):
    p = os.path.join(DIR, "c%02d.bit" % k)
    if not os.path.exists(p):
        continue
    buf = open(p, "rb").read()
    if len(buf) != len(base_buf):
        bad.append((k, "len %d" % len(buf)))
        continue
    diff = [i for i in range(0, len(buf), 1) if buf[i] != base_buf[i]]
    datacells, ecccells, head = [], [], []
    for o in diff:
        c = off_to_cell(o)
        if c is None:
            head.append(o)
            continue
        f, w, b0 = c
        # 在该字节 8 个 bit 里找出实际翻转的位
        for bb in range(8):
            mask = 1 << (7 - bb)
            if (buf[o] & mask) != (base_buf[o] & mask):
                bit = b0 + bb
                if w == ECC_WORD:
                    ecccells.append((f, w, bit))
                else:
                    datacells.append((f, w, bit))
    if len(datacells) == 1:
        per_frame[datacells[0][0]].add((datacells[0][1], datacells[0][2]))
    else:
        bad.append((k, "datacells=%d ecc=%d head=%d" % (len(datacells), len(ecccells), len(head))))
    if k < 6 or len(datacells) != 1:
        print("  c%02d  diff_bytes=%d  data=%s  ecc=%d  head=%d"
              % (k, len(diff), datacells[:2], len(ecccells), len(head)), flush=True)

print("\n单数据格样本: %d / 64  异常 %d" % (sum(len(v) for v in per_frame.values()), len(bad)), flush=True)
for b in bad[:8]:
    print("   异常:", b, flush=True)

print("\n== C. 64 个单最小项的位置分布 ==", flush=True)
allpos = set()
for fi in per_frame:
    allpos |= {(fi, w, b) for (w, b) in per_frame[fi]}
print("  位置总数: %d" % len(allpos), flush=True)
for fi in FRAMES:
    ws = sorted({w for (w, b) in per_frame[fi]})
    bs = sorted({b for (w, b) in per_frame[fi]})
    print("  frame %d: %2d 个位置  words=%s  bits=%s" % (fi, len(per_frame[fi]), ws, bs), flush=True)

print("\n== D(E2). 有没有 word 50 ==", flush=True)
h50 = [p for p in allpos if p[1] == ECC_WORD]
print("  命中 word50 的位置数: %d  %s" % (len(h50), h50[:5]), flush=True)

print("\n== E(E1). 三对连续帧的有效非零约束 ==", flush=True)
for i, (f0, f1) in enumerate(zip(FRAMES, FRAMES[1:])):
    p0, p1 = per_frame[f0], per_frame[f1]
    n0 = sum(1 for (w, b) in p0 if (int(A[f0, w]) >> b) & 1)
    n1 = sum(1 for (w, b) in p1 if (int(A[f1, w]) >> b) & 1)
    print("  pair%d  %d->%d  左 %d位置/非零%d  右 %d位置/非零%d  %s"
          % (i, f0, f1, len(p0), n0, len(p1), n1,
             "★全零对(零约束)" if n0 == 0 and n1 == 0 else "有效"), flush=True)
