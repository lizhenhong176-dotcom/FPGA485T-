import glob, json, os, sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame
R = "/opt/lzh/step03/blkcol"
ref = os.path.join(R, "ref_T16.bit")
fr = frames_from_bit(ref)
out = {}
for v in sorted(glob.glob(os.path.join(R, "v_T16_*.bit"))):
    s = os.path.basename(v)[len("v_T16_"):-4]
    fa = frames_from_bit(v)
    frames = diff_frame_indices(fr, fa)
    out[s] = [[x, w, b] for x in frames for w, b in diff_bits_in_frame(fr, fa, x) if w != 50]
json.dump(out, open(os.path.join(R, "t16.json"), "w"), indent=1)
fr_all = sorted({f for m in out.values() for f, w, b in m})
print("frames", fr_all[0], fr_all[-1], "count", len(fr_all))
print("words", sorted({w for m in out.values() for f, w, b in m}))
print("GFAN0", out.get("GFAN0"))
