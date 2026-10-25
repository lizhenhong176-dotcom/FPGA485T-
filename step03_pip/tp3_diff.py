import glob
import json
import os
import re
import sys

sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

R = "/opt/lzh/step03/tilepipe3"
out = {}
for ref in sorted(glob.glob(os.path.join(R, "ref_*.bit"))):
    tag = os.path.basename(ref)[4:-4]
    fr = frames_from_bit(ref)
    sink = ""
    sp = os.path.join(R, tag + ".dcp")
    src_map = {}
    mk = os.path.join(R, "mk_%s.log" % tag)
    if os.path.exists(mk):
        m = re.search(r"sink (IMUX\w+)", open(mk).read())
        sink = m.group(1) if m else ""
    out[tag] = {"sink": sink, "sources": {}}
    for v in sorted(glob.glob(os.path.join(R, "v_%s_*.bit" % tag))):
        src = os.path.basename(v)[len("v_%s_" % tag):-4]
        fa = frames_from_bit(v)
        frames = diff_frame_indices(fr, fa)
        cfg = [[x, w, b] for x in frames for w, b in diff_bits_in_frame(fr, fa, x) if w != 50]
        out[tag]["sources"][src] = cfg
    print(tag, sink, len(out[tag]["sources"]))

json.dump(out, open(os.path.join(R, "tp3.json"), "w"), indent=1)
print("wrote tp3.json")
