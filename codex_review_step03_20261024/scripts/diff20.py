import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

P = "/opt/lzh/step03/pip2"
a = frames_from_bit(f"{P}/a20.bit")
b = frames_from_bit(f"{P}/b20.bit")
idx = diff_frame_indices(a, b)
print("frames:", idx)
for f in idx:
    bits = diff_bits_in_frame(a, b, f)
    print(f"frame {f}: {bits}")
