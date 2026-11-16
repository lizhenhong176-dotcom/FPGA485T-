#!/usr/bin/env python3
"""Verify 12 missing INT_R IMUX indices via cross-type prediction."""
import struct, sys, json

# Predicted positions (INT_L + 108)
PREDICTIONS = {
    "IMUX22": {"src": "BYP_BOUNCE2",      "pos": [(31809, 23, 19), (31813, 23, 19)]},
    "IMUX28": {"src": "BYP_BOUNCE0",      "pos": [(31808, 23, 4), (31813, 23, 4)]},
    "IMUX29": {"src": "BYP_BOUNCE1",      "pos": [(31808, 23, 12), (31812, 23, 12)]},
    "IMUX31": {"src": "BYP_BOUNCE3",      "pos": [(31808, 23, 28), (31812, 23, 28)]},
    "IMUX32": {"src": "BYP_BOUNCE_N3_2",  "pos": [(31809, 22, 5), (31813, 22, 5)]},
    "IMUX35": {"src": "BYP_BOUNCE1",      "pos": [(31809, 22, 29), (31812, 22, 29)]},
    "IMUX38": {"src": "BYP_BOUNCE2",      "pos": [(31809, 23, 21), (31813, 23, 21)]},
    "IMUX40": {"src": "BYP_BOUNCE_N3_2",  "pos": [(31808, 22, 6), (31812, 22, 6)]},
    "IMUX43": {"src": "BYP_BOUNCE1",      "pos": [(31808, 22, 30), (31813, 22, 30)]},
    "IMUX44": {"src": "BYP_BOUNCE0",      "pos": [(31808, 23, 6), (31813, 23, 6)]},
    "IMUX45": {"src": "BYP_BOUNCE1",      "pos": [(31808, 23, 14), (31812, 23, 14)]},
    "IMUX47": {"src": "BYP_BOUNCE3",      "pos": [(31808, 23, 30), (31812, 23, 30)]},
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

def main():
    ref_path = sys.argv[1] if len(sys.argv) > 1 else "ref.bit"
    var_path = sys.argv[2] if len(sys.argv) > 2 else "var_cd.bit"

    print(f"Parsing {ref_path}...")
    ref = parse_bit_frames(ref_path)
    print(f"  {len(ref)} frames")
    print(f"Parsing {var_path}...")
    var = parse_bit_frames(var_path)
    print(f"  {len(var)} frames")

    print(f"\n=== Predicted IMUX positions (INT_L + 108) ===")
    match_count = 0
    total = 0
    for name, info in sorted(PREDICTIONS.items(), key=lambda x: int(x[0].replace("IMUX",""))):
        for fi, wi, bi in info["pos"]:
            rv = get_bit(ref, fi, wi, bi)
            vv = get_bit(var, fi, wi, bi)
            toggle = "TOGGLE" if rv != vv else "SAME"
            match = "✅" if rv != vv else "❌"
            print(f"  {name:8s} ({fi},{wi},{bi}): ref={rv} var={vv} {toggle} {match}")
            total += 1
            if rv != vv:
                match_count += 1

    print(f"\n=== Summary ===")
    print(f"  Predicted bits that toggled: {match_count}/{total}")
    print(f"  Result: {'ALL MATCH ✅' if match_count == total else 'SOME MISMATCH ❌'}")

    # Also show all diffs in the INT_R region (frames 31800-31820)
    print(f"\n=== All diffs in frame range 31800-31820 (excluding ECC) ===")
    for fi in range(31800, min(31821, len(ref))):
        if fi >= len(var):
            break
        for wi in range(101):
            if wi == 50:
                continue
            if ref[fi][wi] != var[fi][wi]:
                xor = ref[fi][wi] ^ var[fi][wi]
                for bi in range(32):
                    if xor & (1 << bi):
                        print(f"  frame={fi} word={wi} bit={bi}")

if __name__ == "__main__":
    main()
