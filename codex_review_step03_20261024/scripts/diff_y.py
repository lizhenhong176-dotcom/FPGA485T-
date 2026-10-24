import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame
a = frames_from_bit(sys.argv[1])
b = frames_from_bit(sys.argv[2])
idx = diff_frame_indices(a, b)
print("frames:", idx)
for f in idx:
    print(f"frame {f}:", diff_bits_in_frame(a, b, f))
