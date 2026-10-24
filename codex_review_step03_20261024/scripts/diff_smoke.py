import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

P = "/opt/lzh/v7re/work/probe_smoke"
a = frames_from_bit(f"{P}/a.bit")
b = frames_from_bit(f"{P}/b.bit")
idx = diff_frame_indices(a, b)
print("probe_smoke diff frames:", idx)
for f in idx:
    bits = diff_bits_in_frame(a, b, f)
    print(f"  frame {f}: {len(bits)} bits w={sorted(set(w for w,_ in bits))} first={bits[:8]} last={bits[-4:]}")
