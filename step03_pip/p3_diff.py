import glob
import json
import os
import sys

sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

R = "/opt/lzh/step03/reuse3"
out = {}
for ref in sorted(glob.glob(os.path.join(R, "ref_*.bit"))):
    tag = os.path.basename(ref)[4:-4]
    ref_frames = frames_from_bit(ref)
    out[tag] = {}
    for v in sorted(glob.glob(os.path.join(R, "v_%s_*.bit" % tag))):
        src = os.path.basename(v)[len("v_%s_" % tag):-4]
        cur = frames_from_bit(v)
        frames = diff_frame_indices(ref_frames, cur)
        cfg = [[f, w, b] for f in frames for w, b in diff_bits_in_frame(ref_frames, cur, f) if w != 50]
        out[tag][src] = {"frames": frames, "config": cfg}
        print("%s %-18s frames=%s cfg=%s" % (tag, src, frames, cfg))
json.dump(out, open(os.path.join(R, "p3_bits.json"), "w"), indent=1)
print("wrote p3_bits.json")
