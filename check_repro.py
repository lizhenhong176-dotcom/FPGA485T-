import sys
from pathlib import Path

sys.path.insert(0, "/data/lzh/v7re")
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame

d = Path(sys.argv[1])
old = load_frames(d / "design_run1.bit")
new = load_frames(d / "design.bit")
frames = diff_frame_indices(old, new)
print(d.name, "old_vs_new_frames", frames)
for i in frames:
    print("bits", i, sorted(diff_bits_in_frame(old, new, i)))
