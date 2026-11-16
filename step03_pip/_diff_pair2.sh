set -u
cd /opt/lzh/v7re/work/partpair
/opt/lzh/venv/bin/python - <<'PY'
import sys, json, collections
sys.path.insert(0,'/opt/lzh/v7re')
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame
base='/opt/lzh/v7re/work/partpair/'
fa=list(load_frames(base+'b0_1157/b0_1157.bit')); fr=list(load_frames(base+'r_1157/r_1157.bit'))
d=list(diff_frame_indices(fa,fr))
cells=[]
w50=[]
for f in d:
    for w,b in diff_bits_in_frame(fa,fr,f):
        (cells if w==40 else w50).append([f,w,b])
print('INIT_CELLS', json.dumps(cells))
print('W50', json.dumps(w50))
p0=list(load_frames(base+'b0_1761/b0_1761.bit'))
dp=list(diff_frame_indices(fa,p0))
hist=collections.Counter()
perframe={}
for f in dp:
    bs=diff_bits_in_frame(fa,p0,f)
    perframe[f]=len(bs)
    for w,b in bs: hist[w]+=1
print('PART_NFRAMES', len(dp), 'BITSFOR', sum(perframe.values()))
print('PART_WORDHIST', json.dumps(dict(sorted(hist.items()))))
print('PART_PERFRAME_SAMPLE', json.dumps({str(k):perframe[k] for k in list(perframe)[:20]}))
print('PART_FRAME_RANGE', min(dp), max(dp))
print('PART_TOUCHES_CLB_FRAMES', [f for f in dp if 31784<=f<=31787])
PY
