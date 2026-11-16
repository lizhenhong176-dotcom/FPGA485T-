#!/usr/bin/env python3
"""Diff DSP ref vs variant, check artix7 segbits predicted positions."""
import struct, sys, os

BLOCK_START = 34884  # block_start(100, 0) for DSP_L_X100Y0
OFFSET = 0           # _word(0, 0) = 0
# Predicted positions (artix7 segbits_dsp_l.db):
#   DSP_0_CEAD.DSP_VCC_L = 27_62  → frame=BS+27, word=OFF+62//32=1, bit=62%32=30
#   DSP_0_CEAD.DSP_GND_L = 26_63  → frame=BS+26, word=OFF+63//32=1, bit=63%32=31
PRED = {
    "DSP_VCC_L_CEAD": (BLOCK_START + 27, OFFSET + 62 // 32, 62 % 32),
    "DSP_GND_L_CEAD": (BLOCK_START + 26, OFFSET + 63 // 32, 63 % 32),
}

def parse_bit_frames(path):
    """Parse .bit → list of 50176 frames, each 101 words."""
    with open(path, "rb") as f:
        data = f.read()
    # Find SYNC 0xAA995566
    sync = b"\xaa\x99\x55\x66"
    idx = data.find(sync)
    if idx < 0:
        raise ValueError("SYNC not found")
    words = struct.unpack(">%dI" % ((len(data) - idx) // 4), data[idx:])
    # Parse packets
    frames = []
    i = 2  # skip 0x00000000
    fdri_data = []
    while i < len(words):
        w = words[i]
        typ = (w >> 29) & 7
        op = (w >> 27) & 3
        addr = (w >> 13) & 0x3FFF
        cnt = w & 0x7FF
        if op == 1:  # READ — header only, skip 1 word
            i += 1
            continue
        if op == 0:  # NOP
            i += 1
            continue
        # op == 2 (WRITE)
        if typ == 1:  # Type1
            if cnt == 0:
                # Type2 follows
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
            if addr == 0x02 or addr == 2:  # FDRI
                fdri_data.extend(payload)
        elif typ == 2:  # Type2
            t2_cnt = cnt
            payload = words[i + 1:i + 1 + t2_cnt]
            i += 1 + t2_cnt
            fdri_data.extend(payload)
        else:
            i += 1 + cnt if cnt > 0 else 1
    nframes = len(fdri_data) // 101
    frames = [fdri_data[j * 101:(j + 1) * 101] for j in range(nframes)]
    return frames

def get_bit(frames, frame_idx, word_idx, bit_idx):
    if frame_idx >= len(frames):
        return None
    w = frames[frame_idx]
    if word_idx >= len(w):
        return None
    return (w[word_idx] >> bit_idx) & 1

def diff_bits(frames_a, frames_b):
    """Return set of (frame, word, bit) that differ."""
    diffs = set()
    for fi in range(min(len(frames_a), len(frames_b))):
        for wi in range(101):
            if wi == 50:  # skip ECC
                continue
            wa = frames_a[fi][wi]
            wb = frames_b[fi][wi]
            if wa != wb:
                xor = wa ^ wb
                for bi in range(32):
                    if xor & (1 << bi):
                        diffs.add((fi, wi, bi))
    return diffs

def main():
    ref_path = sys.argv[1] if len(sys.argv) > 1 else "ref.bit"
    var_path = sys.argv[2] if len(sys.argv) > 2 else "var_cead0.bit"

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
        match = "✅" if ra != rb else "❌"
        print(f"  {name:25s} frame={f} word={w} bit={b}: ref={ra} var={rb} {match}")

    print(f"\n=== Full diff (excluding ECC word 50) ===")
    diffs = diff_bits(ref, var)
    print(f"  Total non-ECC diffs: {len(diffs)}")

    # Group by frame
    by_frame = {}
    for f, w, b in diffs:
        by_frame.setdefault(f, []).append((w, b))
    for f in sorted(by_frame):
        rel = f - BLOCK_START
        items = by_frame[f]
        print(f"  frame {f} (rel={rel}): {len(items)} bits")
        for w, b in sorted(items)[:10]:
            print(f"    word={w} bit={b}")

    # Check which diffs match predictions
    pred_set = set(PRED.values())
    matched = diffs & pred_set
    unmatched = diffs - pred_set
    print(f"\n=== Match summary ===")
    print(f"  Predicted bits that toggled: {len(matched)}/{len(pred_set)}")
    print(f"  Unexpected diffs: {len(unmatched)}")

if __name__ == "__main__":
    main()
