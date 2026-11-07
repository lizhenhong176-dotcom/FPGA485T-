import json, sys
sys.path.insert(0,'/opt/lzh/v7re')
from bitstream.frames import load_frames, diff_frame_indices

B='/opt/lzh/v7re/work/t23'
def diff(a,b):
    fa=load_frames(f'{B}/{a}/{a}.bit'); fb=load_frames(f'{B}/{b}/{b}.bit')
    idx=diff_frame_indices(fa,fb)
    out={}
    nbits=0
    for i in idx:
        per={}
        for w in range(101):
            x=fa[i][w]^fb[i][w]
            if x:
                bits=[bit for bit in range(32) if (x>>bit)&1]
                per[str(w)]=bits
                nbits+=len(bits)
        out[str(i)]=per
    return {"pair":f"{a}__vs__{b}","n_frames":len(idx),"n_bits":nbits,"frames":out}

res=[diff('l0_y20','lr_y20'), diff('l0_y20','l0b_y20')]
print("JSON_BEGIN")
print(json.dumps(res))
print("JSON_END")
