set -u
cd /opt/lzh/v7re/work/partpair
/opt/lzh/venv/bin/python - <<'PY'
import sys, json
sys.path.insert(0,'/opt/lzh/v7re')
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame
base='/opt/lzh/v7re/work/partpair/'
pairs=[('det_1157','b0_1157/b0_1157.bit','b0b_1157/b0b_1157.bit'),
       ('part_zero','b0_1157/b0_1157.bit','b0_1761/b0_1761.bit'),
       ('init_1157','b0_1157/b0_1157.bit','r_1157/r_1157.bit'),
       ('init_1761','b0_1761/b0_1761.bit','r_1761/r_1761.bit'),
       ('part_rand','r_1157/r_1157.bit','r_1761/r_1761.bit')]
out={}
for name,a,b in pairs:
    fa=list(load_frames(base+a)); fb=list(load_frames(base+b))
    d=list(diff_frame_indices(fa,fb))
    rec={'nframes_a':len(fa),'nframes_b':len(fb),'ndiff':len(d),'frames':d[:200]}
    if len(d)<=8:
        rec['bits']={str(fr):diff_bits_in_frame(fa,fb,fr) for fr in d}
    out[name]=rec
print('JSONBEGIN')
print(json.dumps(out,default=str))
print('JSONEND')
PY
