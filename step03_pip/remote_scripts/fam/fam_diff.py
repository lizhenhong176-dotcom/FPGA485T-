import sys, json, os
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

REF = sys.argv[1]
VARS = sys.argv[2:]
fr = frames_from_bit(REF)
W = 101
def cells(a, b):
    out = []
    for i in range(len(a)):
        for j in range(W):
            x, y = a[i][j], b[i][j]
            if x != y:
                d = x ^ y
                bits = [k for k in range(32) if (d >> k) & 1]
                for k in bits:
                    out.append((i, j, k))
    return out

base = fr
res = {}
for v in VARS:
    name = os.path.basename(v).replace(".bit", "")
    res[name] = cells(base, frames_from_bit(v))
print(json.dumps(res))
