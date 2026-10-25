import glob, json, os, sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame
R="/opt/lzh/step03/sweep1"
out={}
for v in sorted(glob.glob(os.path.join(R,"S_*.bit"))):
    tag=os.path.basename(v)[:-4]
    ref=os.path.join(R,"ref_%s.bit"%tag)
    if not os.path.exists(ref): continue
    fr=frames_from_bit(ref); fa=frames_from_bit(v)
    out[tag]=[[x,w,b] for x in diff_frame_indices(fr,fa) for w,b in diff_bits_in_frame(fr,fa,x) if w!=50]
json.dump(out, open("/mnt/c/Users/S.tschai/sweep_obs.json","w"))
print("designs",len(out))