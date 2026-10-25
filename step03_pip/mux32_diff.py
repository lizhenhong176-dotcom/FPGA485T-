import glob
import json
import os
import re
import sys

sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

R = "/opt/lzh/step03/reuse5"
out = {}
for a in sorted(glob.glob(os.path.join(R, "a_*.bit"))):
    tag = os.path.basename(a)[2:-4]
    r = os.path.join(R, "r_%s.bit" % tag)
    if not os.path.exists(r):
        continue
    sink = ""
    sp = os.path.join(R, tag + ".sink")
    if os.path.exists(sp):
        t = open(sp).read()
        m = re.search(r"IMUX_L\d+", t)
        sink = m.group(0) if m else ""
    fa = frames_from_bit(a)
    fr = frames_from_bit(r)
    frames = diff_frame_indices(fa, fr)
    cfg = [[f, w, b] for f in frames for w, b in diff_bits_in_frame(fa, fr, f) if w != 50]
    out[tag] = {"sink": sink, "frames": frames, "config": cfg}
    print("%-28s %-9s %s" % (tag, sink, cfg))

json.dump(out, open(os.path.join(R, "mux32.json"), "w"), indent=1)

by_sink = {}
for tag, rec in out.items():
    if rec["sink"]:
        by_sink.setdefault(rec["sink"], []).extend(rec["config"])
print("\n== IMUX -> (word,bit) ==")
for sink in sorted(by_sink, key=lambda s: int(s.split("_L")[1])):
    pos = sorted({(w, b) for _f, w, b in by_sink[sink]})
    print("%-10s %s" % (sink, pos))
json.dump({k: sorted({(w, b) for _f, w, b in v}) for k, v in by_sink.items()},
          open(os.path.join(R, "mux32_fields.json"), "w"), indent=1)
