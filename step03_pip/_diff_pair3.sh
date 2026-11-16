set -u
cd /opt/lzh/v7re/work/partpair
/opt/lzh/venv/bin/python - <<'PY'
import sys, json
sys.path.insert(0,'/opt/lzh/v7re')
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame
base='/opt/lzh/v7re/work/partpair/'
fa=list(load_frames(base+'b0_1157/b0_1157.bit')); fr=list(load_frames(base+'r_1157/r_1157.bit'))
d=list(diff_frame_indices(fa,fr))
w50=[]; w40=[]
for f in d:
    for w,b in diff_bits_in_frame(fa,fr,f):
        (w50 if w==50 else w40).append([f,b])
print('W50COUNT', len(w50)); print('W50', json.dumps(w50))
print('W40COUNT', len(w40))
p0=list(load_frames(base+'b0_1761/b0_1761.bit'))
dp=list(diff_frame_indices(fa,p0))
print('PART_RANGE', min(dp), max(dp))
print('PART_TOUCH_31784_31787', [f for f in dp if 31784<=f<=31787])
# how many of the 133 frames are in the X12Y20 block base 31716 ?
print('IN_BLOCK_BASE31716', len([f for f in dp if 31716<=f<31716+101]))
print('PART_HEAD_FRAMES', dp[:6], 'PART_TAIL', dp[-6:])
PY
