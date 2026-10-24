import sys
from pathlib import Path

sys.path.insert(0, "/data/lzh/v7re")
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame

a = Path(sys.argv[1])
b = Path(sys.argv[2])
pips_a = set((a / "pips.txt").read_text().split())
pips_b = set((b / "pips.txt").read_text().split())
sym = pips_a ^ pips_b
print("pip_symdiff", len(sym))
print("only_a")
for x in sorted(pips_a - pips_b):
    print(" ", x)
print("only_b")
for x in sorted(pips_b - pips_a):
    print(" ", x)
fa = load_frames(a / "design.bit")
fb = load_frames(b / "design.bit")
fr = diff_frame_indices(fa, fb)
positions = set()
for i in fr:
    positions.update(diff_bits_in_frame(fa, fb, i))
print("frames", fr)
print("positions", sorted(positions))
print("data_bits", sorted(p for p in positions if p[0] != 50))
