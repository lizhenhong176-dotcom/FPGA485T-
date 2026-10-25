import glob, json, os, sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame
R = "/opt/lzh/step03/tilepipe4"
out = {}
for ref in sorted(glob.glob(os.path.join(R, "ref_*.bit"))):
    tag = os.path.basename(ref)[4:-4]
    fr = frames_from_bit(ref)
    src = {}
    for v in sorted(glob.glob(os.path.join(R, "v_%s_*.bit" % tag))):
        s = os.path.basename(v)[len("v_%s_" % tag):-4]
        fa = frames_from_bit(v)
        src[s] = [[x, w, b] for x in diff_frame_indices(fr, fa) for w, b in diff_bits_in_frame(fr, fa, x) if w != 50]
    out[tag] = {"sources": src}
json.dump(out, open("/mnt/c/Users/S.tschai/tp4.json", "w"), indent=1)
print("designs", len(out))