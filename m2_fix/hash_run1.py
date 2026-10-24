from pathlib import Path
from bitstream.frames import load_frames, frame_hash

base = Path("data/m2/fam/clbll_l/pin_a3")
print("design", frame_hash(load_frames(base / "design.bit")))
print("run1  ", frame_hash(load_frames(base / "design_run1.bit")))
