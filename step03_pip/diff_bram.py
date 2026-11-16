#!/usr/bin/env python3
"""Diff BRAM ref vs variant, check artix7 segbits predicted positions."""
import struct, sys

# BRAM_L_X114Y0: col=114, Y=0, block_start=35356, offset=0
BLOCK_START = 35356
OFFSET = 0

# Predicted positions (artix7 segbits_bram_l.db):
#   RAMB18_Y0.IN_USE = 27_99 27_100 (both should be SET when BRAM is placed)
#   RAMB18_Y0.ZINIT_A[0] = 27_73 → toggles when INIT_A[0] changes
#   RAMB18_Y0.ZSRVAL_A[0] = 27_74
PRED = {
    "IN_USE_0": (BLOCK_START + 27, OFFSET + 99 // 32, 99 % 32),    # frame 35383, word 3, bit 3
    "IN_USE_1": (BLOCK_START + 27, OFFSET + 100 // 32, 100 % 32),   # frame 35383, word 3, bit 4
    "ZINIT_A0": (BLOCK_START + 27, OFFSET + 73 // 32, 73 % 32),     # frame 35383, word 2, bit 9
    "ZSRVAL_A0": (BLOCK_START + 27, OFFSET + 74 // 32, 74 % 32),    # frame 35383, word 2, bit 10
}

def parse_bit_frames(path):
    with open(path, "rb") as f:
        data = f.read()
    sync = b"\xaa\x99\x55\x66"
    idx = data.find(sync)
    if idx < 0:
        raise ValueError("SYNC not found")
    words = struct.unpack(">%dI" % ((len(data) - idx) // 4), data[idx:])
    frames = []
    i = 2
    fdri_data = []
    while i < len(words):
        w = words[i]
        typ = (w >> 29) & 7
        op = (w >> 27) & 3
        addr = (w >> 13) & 0x3FFF
        cnt = w & 0x7FF
        if op == 1:
            i += 1
            continue
        if op == 0:
            i += 1
            continue
        if typ == 1:
            if cnt == 0:
                i += 1
                if i >= len(words):
                    break
                t2 = words[i]
                t2_cnt = t2 & 0x07FFFFFF
                i += 1
                payload = words[i:i + t2_cnt]
                i += t2_cnt
            else:
                payload = words[i + 1:i + 1 + cnt]
                i += 1 + cnt
            if addr == 2:
                fdri_data.extend(payload)
        elif typ == 2:
            t2_cnt = cnt
            payload = words[i + 1:i + 1 + t2_cnt]
            i += 1 + t2_cnt
            fdri_data.extend(payload)
        else:
            i += 1 + cnt if cnt > 0 else 1
    nframes = len(fdri_data) // 101
    return [fdri_data[j * 101:(j + 1) * 101] for j in range(nframes)]

def get_bit(frames, fi, wi, bi):
    if fi >= len(frames) or wi >= len(frames[fi]):
        return None
    return (frames[fi][wi] >> bi) & 1

def diff_bits(fa, fb):
    diffs = set()
    for fi in range(min(len(fa), len(fb))):
        for wi in range(101):
            if wi == 50:
                continue
            if fa[fi][wi] != fb[fi][wi]:
                xor = fa[fi][wi] ^ fb[fi][wi]
                for bi in range(32):
                    if xor & (1 << bi):
                        diffs.add((fi, wi, bi))
    return diffs

def main():
    ref_path = sys.argv[1] if len(sys.argv) > 1 else "ref.bit"
    var_path = sys.argv[2] if len(sys.argv) > 2 else "var_init1.bit"

    print(f"Parsing {ref_path}...")
    ref = parse_bit_frames(ref_path)
    print(f"  {len(ref)} frames")
    print(f"Parsing {var_path}...")
    var = parse_bit_frames(var_path)
    print(f"  {len(var)} frames")

    print(f"\n=== Predicted positions (BLOCK_START={BLOCK_START}, OFFSET={OFFSET}) ===")
    for name, (f, w, b) in PRED.items():
        ra = get_bit(ref, f, w, b)
        rb = get_bit(var, f, w, b)
        match = "TOGGLE" if ra != rb else "SAME"
        print(f"  {name:15s} frame={f} word={w} bit={b}: ref={ra} var={rb} {match}")

    print(f"\n=== Full diff (excluding ECC word 50) ===")
    diffs = diff_bits(ref, var)
    print(f"  Total non-ECC diffs: {len(diffs)}")

    by_frame = {}
    for f, w, b in diffs:
        by_frame.setdefault(f, []).append((w, b))
    for f in sorted(by_frame):
        rel = f - BLOCK_START
        items = by_frame[f]
        print(f"  frame {f} (rel={rel}): {len(items)} bits")
        for w, b in sorted(items)[:15]:
            print(f"    word={w} bit={b}")

if __name__ == "__main__":
    main()
