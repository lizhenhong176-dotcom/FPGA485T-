import json
import os
import sys

sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

R = "/opt/lzh/step03/reuse6"
TAGS = {"A1": 7, "A2": 2}
out = {}
for tag in TAGS:
    ref = os.path.join(R, "ref_%s.bit" % tag)
    if not os.path.exists(ref):
        print("missing", ref)
        continue
    fr = frames_from_bit(ref)
    out[tag] = {}
    for f in os.listdir(R):
        if not f.startswith("v_%s_" % tag) or not f.endswith(".bit"):
            continue
        src = f[len("v_%s_" % tag):-4]
        fa = frames_from_bit(os.path.join(R, f))
        frames = diff_frame_indices(fr, fa)
        cfg = [[x, w, b] for x in frames for w, b in diff_bits_in_frame(fr, fa, x) if w != 50]
        out[tag][src] = {"frames": frames, "config": cfg}
    print(tag, "sources", len(out[tag]))
json.dump(out, open(os.path.join(R, "p6_bits.json"), "w"), indent=1)
print("wrote p6_bits.json")
