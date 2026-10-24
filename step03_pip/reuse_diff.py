import json
import sys

sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

P = "/opt/lzh/step03/reuse"
REF = "/opt/lzh/step03/pip1/b.bit"   # baseline with the IMUX_L8 PIP removed
ref = frames_from_bit(REF)

import glob
import os

out = {}
for path in sorted(glob.glob(os.path.join(P, "v_*.bit"))):
    src = os.path.basename(path)[2:-4]
    cur = frames_from_bit(path)
    frames = diff_frame_indices(ref, cur)
    cfg, ecc = [], []
    for f in frames:
        for w, b in diff_bits_in_frame(ref, cur, f):
            (ecc if w == 50 else cfg).append([f, w, b])
    out[src] = {"frames": frames, "config": cfg, "ecc_count": len(ecc)}
    print("%-18s frames=%-14s cfg=%2d ecc=%2d %s" % (src, frames, len(cfg), len(ecc), cfg[:6]))

json.dump(out, open(os.path.join(P, "reuse_bits.json"), "w"), indent=1)
print("wrote reuse_bits.json")
