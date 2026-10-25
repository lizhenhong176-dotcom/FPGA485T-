import glob
import json
import os
import re
import sys

sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

R = "/opt/lzh/step03/tilepipe"
out = {}
for ref in sorted(glob.glob(os.path.join(R, "ref_*.bit"))):
    tag = os.path.basename(ref)[4:-4]
    try:
        fr = frames_from_bit(ref)
    except Exception as exc:  # noqa: BLE001
        print("skip ref", tag, exc)
        continue
    sink = ""
    sp = os.path.join(R, tag + ".sink")
    if os.path.exists(sp):
        m = re.search(r"IMUX_L\d+", open(sp).read())
        sink = m.group(0) if m else ""
    rec = {}
    for f in sorted(os.listdir(R)):
        if not f.startswith("v_%s_" % tag) or not f.endswith(".bit"):
            continue
        src = f[len("v_%s_" % tag):-4]
        try:
            fa = frames_from_bit(os.path.join(R, f))
        except Exception:  # noqa: BLE001
            continue
        frames = diff_frame_indices(fr, fa)
        cfg = [[x, w, b] for x in frames for w, b in diff_bits_in_frame(fr, fa, x) if w != 50]
        rec[src] = cfg
    out[tag] = {"sink": sink, "sources": rec}
    print("%-30s %-9s src=%d" % (tag, sink, len(rec)))
json.dump(out, open(os.path.join(R, "tilepipe.json"), "w"), indent=1)
print("wrote tilepipe.json")
