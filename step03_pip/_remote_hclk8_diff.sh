export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/hclk8 || exit 1
python3 - <<'PY'
import json, os
SYNC = b'\xaa\x99\x55\x66'
def payload(path):
    d = open(path,'rb').read()
    i = d.find(SYNC)
    p = i+4
    n = len(d)
    while p+4 <= n:
        h = int.from_bytes(d[p:p+4],'big')
        typ = (h>>29)&7; op = (h>>27)&1; cnt = h & 0x7ffffff
        p += 4
        if typ == 1:
            continue
        if typ == 2:
            w = (1 if op==0 else 0)
            if w == 0:
                p += 4*cnt  # write
                if cnt == 5067776:
                    return d[p-4*cnt:p]
            else:
                p += 4  # read
            continue
        break
    return None
base = payload('out/m_def.bit')
print("payload", len(base) if base else None)
B = int.from_bytes(base,'big')
res = {}
for v in ('y0','y3','y6','y9','y12'):
    f = f'out/m_{v}.bit'
    if not os.path.exists(f): continue
    b = payload(f)
    if b is None or len(b)!=len(base): print(v,"bad"); continue
    x = B ^ int.from_bytes(b,'big')
    xb = x.to_bytes(len(base),'big')
    cells=[]
    for idx,by in enumerate(xb):
        if by:
            for k in range(8):
                if by>>(7-k) & 1:
                    pos = idx*8+k
                    cells.append((pos//3232, (pos%3232)//32, pos%32, (base[idx]>>(7-k))&1, (b[idx]>>(7-k))&1))
    res[v]=dict(n=len(cells), cells=cells)
    print(v, "cells", len(cells), "frames", sorted({c[0] for c in cells}))
json.dump(res, open('out/diff_vs_def.json','w'))
# 绝对字：band4 col33 基址 22118 -> off26=22144
def word(frame, w):
    p = frame*404 + w*4
    return base[p:p+4].hex()
print("\n== absolute words (base m_def)")
for (fr,off) in ((22144,26),(22145,27),(22146,28),(22147,29)):
    print(f"off{off} (frame {fr}):", [ (w, word(fr,w)) for w in (27,28,29,30,76,77,78,79,50,51) ])
PY
