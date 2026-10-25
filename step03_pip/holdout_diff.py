import glob, json, os, re, sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame
R = "/opt/lzh/step03/reuse6"
out = {}
for a in sorted(glob.glob(os.path.join(R, "a_*.bit"))):
    tag = os.path.basename(a)[2:-4]
    r = os.path.join(R, "r_%s.bit" % tag)
    if not os.path.exists(r):
        continue
    sink = ""
    sp = os.path.join(R, tag + ".sink")
    if os.path.exists(sp):
        m = re.search(r"((?:IMUX_L|IMUX)\d+)", open(sp).read())
        sink = m.group(1) if m else ""
    fa, fr = frames_from_bit(a), frames_from_bit(r)
    frames = diff_frame_indices(fa, fr)
    cfg = [[f, w, b] for f in frames for w, b in diff_bits_in_frame(fa, fr, f) if w != 50]
    out[tag] = {"sink": sink, "frames": frames, "config": cfg}
    print("%-28s %-8s %s" % (tag, sink, cfg))
json.dump(out, open(os.path.join(R, "holdout.json"), "w"), indent=1)
