#!/usr/bin/env python3
"""diff_carry.py — CARRY4/PRECYINIT 位验证

验证 artix7 segbits 的 CARRY4 CY0 和 PRECYINIT 特征位在 V7 上的位置。

CLBLM_R_X7Y10 / SLICEM_X0:
  block_start = 31716
  offset = 20

预测位置（artix7 segbits_clblm_r.db SLICEM_X0）:
  CARRY4.ACY0 = 30_15 → (31746, 20, 15)
  CARRY4.BCY0 = 01_15 → (31717, 20, 15)
  CARRY4.CCY0 = 30_48 → (31746, 21, 16)
  CARRY4.DCY0 = 30_49 → (31746, 21, 17)
  PRECYINIT.C0 = !00_12 !30_13 !30_14 → (31716,20,12)=0, (31746,20,13)=0, (31746,20,14)=0
  PRECYINIT.C1 =  00_12 !30_13 !30_14 → (31716,20,12)=1, (31746,20,13)=0, (31746,20,14)=0

用法:
  python3 diff_carry.py ref.bit var.bit
"""
import sys, struct

BLOCK_START = 31716
OFFSET = 20
N_FRAMES = 50176
WORDS_PER_FRAME = 101

# Predicted bit positions (frame, word, bit)
PRED = {
    "CARRY4.ACY0": (BLOCK_START + 30, OFFSET + 0, 15),  # 30_15
    "CARRY4.BCY0": (BLOCK_START + 1,  OFFSET + 0, 15),  # 01_15
    "CARRY4.CCY0": (BLOCK_START + 30, OFFSET + 1, 16),  # 30_48
    "CARRY4.DCY0": (BLOCK_START + 30, OFFSET + 1, 17),  # 30_49
    "PRECYINIT.00_12": (BLOCK_START + 0,  OFFSET + 0, 12),
    "PRECYINIT.30_13": (BLOCK_START + 30, OFFSET + 0, 13),
    "PRECYINIT.30_14": (BLOCK_START + 30, OFFSET + 0, 14),
}

def parse_bit_frames(path):
    """Parse .bit → list of N_FRAMES frames, each WORDS_PER_FRAME words (big-endian).
    Copied from bit2fasm_py.py (working parser)."""
    import struct
    SYNC = b"\xAA\x99\x55\x66"
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
                # Type 2 packet follows
                t2 = words[i]; i += 1
                if ((t2 >> 29) & 7) != 2:
                    raise ValueError("expected Type 2 packet: 0x%08X" % t2)
                n = t2 & 0x07FFFFFF
                payload.extend(words[i:i + n])
                i += n
            else:
                payload.extend(words[i:i + cnt])
                i += cnt
        else:
            i += cnt
    # Split into frames
    total_words = N_FRAMES * WORDS_PER_FRAME
    if len(payload) < total_words:
        print("WARNING: FDRI payload %d < expected %d" % (len(payload), total_words))
        payload += [0] * (total_words - len(payload))
    frames = []
    for fi in range(N_FRAMES):
        frame = payload[fi * WORDS_PER_FRAME:(fi + 1) * WORDS_PER_FRAME]
        frames.append(frame)
    return frames

def get_bit(frames, frame_idx, word_idx, bit_idx):
    if frame_idx >= len(frames):
        return 0
    if word_idx >= len(frames[frame_idx]):
        return 0
    return (frames[frame_idx][word_idx] >> bit_idx) & 1

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 diff_carry.py ref.bit var.bit")
        sys.exit(1)
    
    ref_frames = parse_bit_frames(sys.argv[1])
    var_frames = parse_bit_frames(sys.argv[2])
    
    print("=== CARRY4/PRECYINIT 位验证 ===")
    print("CLBLM_R_X7Y10 / SLICEM_X0, block_start=%d, offset=%d" % (BLOCK_START, OFFSET))
    print()
    
    # 1. Check CARRY4 CY0 bits (should be SET in both designs since DI is used)
    print("--- CARRY4 CY0 bits (should be SET=1 when DI is used) ---")
    for name, (f, w, b) in PRED.items():
        if not name.startswith("CARRY4"):
            continue
        ref_val = get_bit(ref_frames, f, w, b)
        var_val = get_bit(var_frames, f, w, b)
        match = "✅" if ref_val == var_val else "⚠️"
        print("  %-20s (%d,%d,%d) ref=%d var=%d %s" % (name, f, w, b, ref_val, var_val, match))
    
    # 2. Check PRECYINIT bits (C0 vs C1)
    print()
    print("--- PRECYINIT bits (C0=ref vs C1=var) ---")
    for name, (f, w, b) in PRED.items():
        if not name.startswith("PRECYINIT"):
            continue
        ref_val = get_bit(ref_frames, f, w, b)
        var_val = get_bit(var_frames, f, w, b)
        toggle = "TOGGLE" if ref_val != var_val else "same"
        print("  %-20s (%d,%d,%d) ref=%d var=%d %s" % (name, f, w, b, ref_val, var_val, toggle))
    
    # 3. Full diff (non-ECC bits only)
    print()
    print("--- Full diff (non-ECC, non-zero) ---")
    diffs = []
    for fi in range(N_FRAMES):
        for wi in range(WORDS_PER_FRAME):
            if wi == 50:  # Skip ECC word
                continue
            r = ref_frames[fi][wi]
            v = var_frames[fi][wi]
            if r != v:
                xor = r ^ v
                for b in range(32):
                    if xor & (1 << b):
                        diffs.append((fi, wi, b, (r >> b) & 1, (v >> b) & 1))
    print("  Total non-ECC diffs: %d" % len(diffs))
    for d in diffs[:20]:
        fi, wi, b, rv, vv = d
        # Check if this is a predicted bit
        pred_name = ""
        for name, (pf, pw, pb) in PRED.items():
            if pf == fi and pw == wi and pb == b:
                pred_name = name
                break
        tag = " ← %s" % pred_name if pred_name else ""
        print("    (%d,%d,%d) %d→%d%s" % (fi, wi, b, rv, vv, tag))
    if len(diffs) > 20:
        print("    ... and %d more" % (len(diffs) - 20))

if __name__ == '__main__':
    main()
