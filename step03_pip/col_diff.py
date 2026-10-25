import glob, json, os, sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame
R = os.environ["R"]; TAG = os.environ["TAG"]; COL = os.environ["COL"]
ref = os.path.join(R, "ref_%s.bit" % TAG)
fr = frames_from_bit(ref); out = {}
for v in sorted(glob.glob(os.path.join(R, "v_%s_*.bit" % TAG))):
    s = os.path.basename(v)[len("v_%s_" % TAG):-4]
    fa = frames_from_bit(v)
    out[s] = [[x, w, b] for x in diff_frame_indices(fr, fa) for w, b in diff_bits_in_frame(fr, fa, x) if w != 50]
json.dump(out, open("/mnt/c/Users/S.tschai/col_%s.json" % COL, "w"), indent=1)
fr_all = sorted({f for m in out.values() for f, w, b in m})
print("COL", COL, "frames", fr_all[0], fr_all[-1], "GFAN0", out.get("GFAN0"))