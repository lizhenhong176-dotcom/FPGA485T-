import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

a = frames_from_bit("/opt/lzh/step03/pip1/a.bit")
b = frames_from_bit("/opt/lzh/step03/pip1/b.bit")
print("frames a/b:", len(a), len(b))
idx = diff_frame_indices(a, b)
print("diff frames:", idx)
for f in idx:
    bits = diff_bits_in_frame(a, b, f)
    print(f"frame {f}: {len(bits)} bits -> {bits}")
