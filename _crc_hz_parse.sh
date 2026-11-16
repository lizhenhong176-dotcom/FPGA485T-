set -e
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/crcfull2
export D
cat > $D/_parse2.py <<'PYEOF'

import sys, os, struct, glob, csv
import numpy as np
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
D = "/opt/lzh/v7re/work/crcfull2"
def first_crc(p):
    d = open(p, "rb").read(); i = d.find(b"\x30\x00\x00\x01")
    return struct.unpack(">I", d[i+4:i+8])[0] if i >= 0 else -1
def cells(p):
    a = np.array(frames_from_bit(p), dtype=np.uint32); out = set()
    for fi in np.nonzero(a.any(axis=1))[0]:
        for w in np.nonzero(a[fi])[0]:
            if w == 50: continue
            v = int(a[fi, w])
            while v:
                b = (v & -v).bit_length() - 1; out.add((int(fi), int(w), b)); v &= v - 1
    return out
w = csv.writer(sys.stdout)
for y in (20, 30):
    for bel in ("A6LUT","B6LUT","C6LUT","D6LUT"):
        bp = os.path.join(D, "base_y%d_%s.bit" % (y, bel))
        bc = cells(bp); bcrc = first_crc(bp)
        for k in (1, 3):
            p = os.path.join(D, "hz%d_%s_k%d.bit" % (y, bel, k))
            if not os.path.exists(p): continue
            c = cells(p); add = c - bc; rem = bc - c
            for (fi, wd, b) in sorted(add):
                w.writerow([y, bel, k, "add", fi, wd, b, "%08x" % (first_crc(p) ^ bcrc), len(add), len(rem)])
            for (fi, wd, b) in sorted(rem):
                w.writerow([y, bel, k, "rem", fi, wd, b, "%08x" % (first_crc(p) ^ bcrc), len(add), len(rem)])
PYEOF
/opt/lzh/venv/bin/python $D/_parse2.py > $D/hz.csv
echo ROWS $(wc -l < $D/hz.csv)
cat $D/hz.csv
echo HZDONE
