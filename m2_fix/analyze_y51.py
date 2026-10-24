from pathlib import Path
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame

base = Path("data/m2/validation/clbll_l_y51")
a = load_frames(base / "a3/design.bit")
b = load_frames(base / "a5/design.bit")
d = diff_frame_indices(a, b)
print("frames", len(a), len(b), "diff_frames", d)
allbits = []
for f in d:
    bits = diff_bits_in_frame(a, b, f)
    allbits.extend((f, w, bit) for w, bit in bits)
    print("frame", f, "bits", bits)
print("count", len(allbits))
print("word50", [(f, w, bit) for f, w, bit in allbits if w == 50])
print("non50", [(w, bit) for f, w, bit in allbits if w != 50])
p1 = set((base / "a3/pips.txt").read_text().split())
p2 = set((base / "a5/pips.txt").read_text().split())
print("pips_symdiff", len(p1 ^ p2))
print("pips_a3", sorted(p1))
print("pips_a5", sorted(p2))
