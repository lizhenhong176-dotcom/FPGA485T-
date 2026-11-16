#!/usr/bin/env python3
"""
diff_ff.py — 比较两个比特流的位差异，验证 FF INIT 位是否落在 artix7 segbits 预测位置。

用法：python3 diff_ff.py ref.bit var.bit FF_NAME
  FF_NAME = AFF / BFF / CFF / DFF

输出：差异位数、每个差异的 (frame, word, bit)、是否匹配预测。
"""
import sys, struct

SYNC = b"\xAA\x99\x55\x66"
FRAME_WORDS = 101

def parse_bit_frames(path):
    """返回 list[list[int]]：50,176 帧 × 101 字。"""
    data = open(path, "rb").read()
    pos = data.find(SYNC)
    if pos < 0:
        raise ValueError("sync word not found")
    words = list(struct.unpack(">%dI" % ((len(data) - pos - 4) // 4), data[pos + 4:]))
    payload = []
    i = 0
    while i < len(words):
        h = words[i]; i += 1
        typ = (h >> 29) & 7
        op = (h >> 27) & 3
        addr = (h >> 13) & 0x3FFF
        cnt = h & 0x7FF
        if typ == 2:
            n = h & 0x07FFFFFF
            payload.extend(words[i:i + n])
            i += n
            continue
        if typ != 1:
            break
        if op == 0:  # NOP
            continue
        if op == 1:  # READ: skip 1 word
            i += 1
            continue
        # op == 2: WRITE
        if addr == 0x02:  # FDRI
            if cnt == 0:
                t2 = words[i]; i += 1
                if ((t2 >> 29) & 7) != 2:
                    raise ValueError("expected Type 2 packet")
                n = t2 & 0x07FFFFFF
                payload.extend(words[i:i + n])
                i += n
            else:
                payload.extend(words[i:i + cnt])
                i += cnt
        else:
            i += cnt
    n_frames = len(payload) // FRAME_WORDS
    return [payload[k * FRAME_WORDS:(k + 1) * FRAME_WORDS] for k in range(n_frames)]

# Predicted positions from artix7 segbits_clblm_r.db for CLBLM_R_X7Y10 / SLICEM_X0
# block_start(7, 10) = 31716, offset = _word(10, 0) = 20
BLOCK_START = 31716
OFFSET = 20

def segbits_to_pos(col, bitidx):
    """artix7 segbits (col, bitidx) → (frame, word, bit)"""
    frame = BLOCK_START + col
    rel_word = bitidx // 32
    bit = bitidx % 32
    word = OFFSET + rel_word
    return (frame, word, bit)

PREDICTIONS = {
    'AFF': {
        'ZINI': segbits_to_pos(31, 3),    # 31_03
        'ZRST': segbits_to_pos(30, 12),   # 30_12
    },
    'BFF': {
        'ZINI': segbits_to_pos(31, 28),   # 31_28
        'ZRST': segbits_to_pos(30, 30),   # 30_30
    },
    'CFF': {
        'ZINI': segbits_to_pos(31, 33),   # 31_33
        'ZRST': segbits_to_pos(30, 33),   # 30_33
    },
    'DFF': {
        'ZINI': segbits_to_pos(31, 58),   # 31_58
        'ZRST': segbits_to_pos(30, 50),   # 30_50
    },
}


def main():
    ref_path = sys.argv[1]
    var_path = sys.argv[2]
    ff_name = sys.argv[3].upper()
    
    ref = parse_bit_frames(ref_path)
    var = parse_bit_frames(var_path)
    
    print("ref frames: %d, var frames: %d" % (len(ref), len(var)))
    
    diffs = []
    for f in range(min(len(ref), len(var))):
        for w in range(101):
            rw = ref[f][w]
            vw = var[f][w]
            if rw != vw:
                xor = rw ^ vw
                for b in range(32):
                    if xor & (1 << b):
                        old_bit = (rw >> b) & 1
                        new_bit = (vw >> b) & 1
                        diffs.append((f, w, b, old_bit, new_bit))
    
    print("total diffs: %d" % len(diffs))
    
    preds = PREDICTIONS[ff_name]
    zini_pos = preds['ZINI']
    zrst_pos = preds['ZRST']
    
    print("\n=== Predictions for %s (SLICEM_X0 @ CLBLM_R_X7Y10) ===" % ff_name)
    print("  ZINI: frame=%d word=%d bit=%d  (expect 0->1)" % zini_pos)
    print("  ZRST: frame=%d word=%d bit=%d  (expect 1->0)" % zrst_pos)
    
    print("\n=== All diffs ===")
    zini_match = False
    zrst_match = False
    extra_diffs = []
    for (f, w, b, old, new) in diffs:
        pos = (f, w, b)
        tag = ""
        if pos == zini_pos and old == 0 and new == 1:
            tag = " <-- ZINI MATCH"
            zini_match = True
        elif pos == zrst_pos and old == 1 and new == 0:
            tag = " <-- ZRST MATCH"
            zrst_match = True
        else:
            extra_diffs.append((f, w, b, old, new))
        print("  frame=%d word=%d bit=%d: %d->%d%s" % (f, w, b, old, new, tag))
    
    print("\n=== Verdict ===")
    if zini_match and zrst_match:
        print("  ZINI: PASS")
        print("  ZRST: PASS")
    else:
        if not zini_match:
            print("  ZINI: FAIL (expected at %s)" % (zini_pos,))
        if not zrst_match:
            print("  ZRST: FAIL (expected at %s)" % (zrst_pos,))
    
    if extra_diffs:
        print("  EXTRA diffs: %d (may be routing noise)" % len(extra_diffs))
        for d in extra_diffs[:10]:
            print("    frame=%d word=%d bit=%d: %d->%d" % d)
    else:
        print("  EXTRA diffs: 0")


if __name__ == '__main__':
    main()
