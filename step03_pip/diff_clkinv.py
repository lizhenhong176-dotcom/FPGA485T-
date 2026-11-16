#!/usr/bin/env python3
"""Diff ref.bit vs v_clkinv.bit and check CLKINV position.
Usage: python3 diff_clkinv.py ref.bit v_clkinv.bit
"""
import sys, struct, zlib

def parse_bit_frames(path):
    """Parse .bit → list of 50176 frames × 101 words (big-endian uint32)."""
    data = open(path, "rb").read()
    sync = b"\xaa\x99\x55\x66"
    idx = data.find(sync)
    if idx < 0:
        raise ValueError("no sync word")
    words = []
    i = idx + 4
    n = len(data) // 4
    while i + 1 < n:
        w = struct.unpack_from(">I", data, i*4)[0]
        typ = (w >> 29) & 7
        op = (w >> 27) & 3
        if typ == 1:
            addr = (w >> 13) & 0x3FFF
            cnt = w & 0x7FF
            if op == 2:  # WRITE
                if cnt == 0:
                    # Type2 follows
                    i += 1
                    w2 = struct.unpack_from(">I", data, i*4)[0]
                    t2_cnt = w2 & 0x07FFFFFF
                    i += 1
                    for j in range(t2_cnt):
                        words.append(struct.unpack_from(">I", data, (i+j)*4)[0])
                    i += t2_cnt
                else:
                    i += 1
                    for j in range(cnt):
                        words.append(struct.unpack_from(">I", data, (i+j)*4)[0])
                    i += cnt
            elif op == 1:  # READ — header only, skip 1 word
                i += 1
            elif op == 0:  # NOP
                i += 1
            else:
                i += 1
        else:
            i += 1
    # Trim to 50176 * 101
    total = 50176 * 101
    if len(words) < total:
        raise ValueError(f"only {len(words)} words, expected {total}")
    frames = []
    for fi in range(50176):
        frames.append(words[fi*101:(fi+1)*101])
    return frames

def bit_set(frames, frame, word, bit):
    if frame < 0 or frame >= len(frames):
        return 0
    if word < 0 or word >= len(frames[frame]):
        return 0
    return (frames[frame][word] >> bit) & 1

def main():
    ref_path = sys.argv[1]
    var_path = sys.argv[2]
    ref = parse_bit_frames(ref_path)
    var = parse_bit_frames(var_path)

    # CLKINV for SLICEM_X0 @ CLBLM_R_X7Y10
    # artix7: CLKINV 01_51 → col=1, bitidx=51
    # block_start(7,10) = 31716
    # frame = 31716 + 1 = 31717
    # offset = _word(10,0) = 20
    # word = 20 + 51//32 = 21
    # bit = 51%32 = 19
    BLOCK_START = 31716
    CLKINV_FRAME = BLOCK_START + 1   # 31717
    CLKINV_WORD = 20 + 51 // 32      # 21
    CLKINV_BIT = 51 % 32             # 19

    print("=== CLKINV Prediction (artix7) ===")
    print("  CLKINV bit: frame=%d word=%d bit=%d (col=1 bitidx=51)" % (
        CLKINV_FRAME, CLKINV_WORD, CLKINV_BIT))
    print("  artix7: CLKINV active → bit=1, NOCLKINV → bit=0")
    print()

    ref_val = bit_set(ref, CLKINV_FRAME, CLKINV_WORD, CLKINV_BIT)
    var_val = bit_set(var, CLKINV_FRAME, CLKINV_WORD, CLKINV_BIT)
    print("  ref (NOCLKINV): bit=%d" % ref_val)
    print("  var (CLKINV):   bit=%d" % var_val)
    print("  artix7 prediction: ref=0 var=1")
    print()

    if ref_val == 0 and var_val == 1:
        print("  CLKINV: MATCH (artix7 polarity)")
    elif ref_val == 1 and var_val == 0:
        print("  CLKINV: MATCH with INVERTED polarity (V7: CLKINV→bit=0, NOCLKINV→bit=1)")
    elif ref_val == var_val:
        print("  CLKINV: NO CHANGE (neither matches prediction)")
    else:
        print("  CLKINV: UNEXPECTED pattern")
    print()

    # Also check all non-ECC diffs
    print("=== All non-ECC diffs (word != 50) ===")
    diffs = []
    for fi in range(50176):
        for wi in range(101):
            if wi == 50:
                continue
            r = (ref[fi][wi])
            v = (var[fi][wi])
            if r != v:
                for b in range(32):
                    rb = (r >> b) & 1
                    vb = (v >> b) & 1
                    if rb != vb:
                        diffs.append((fi, wi, b, rb, vb))
    print("  Total non-ECC diffs: %d" % len(diffs))
    for fi, wi, b, rb, vb in diffs:
        mark = ""
        if fi == CLKINV_FRAME and wi == CLKINV_WORD and b == CLKINV_BIT:
            mark = " ← CLKINV position"
        print("    frame=%d word=%d bit=%d: %d→%d%s" % (fi, wi, b, rb, vb, mark))

if __name__ == "__main__":
    main()
