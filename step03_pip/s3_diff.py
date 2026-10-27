import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

pairs = [
    ("base10", "k0_10"), ("base10", "k1_10"),
    ("base11", "k0_11"), ("base11", "k1_11"),
    ("base52", "k0_52"), ("base52", "k1_52"),
    ("base53", "k0_53"), ("base53", "k1_53"),
]
for base, var in pairs:
    fa = frames_from_bit(base + ".bit")
    fb = frames_from_bit(var + ".bit")
    frames = diff_frame_indices(fa, fb)
    cfg = [[x, w, b] for x in frames for w, b in diff_bits_in_frame(fa, fb, x) if w != 50]
    print(var, "vs", base, "→", cfg)
