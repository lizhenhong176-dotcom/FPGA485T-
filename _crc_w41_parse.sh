set -e
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/crcfull2
export D
cat > $D/_parse3.py <<'PYEOF'

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
for bel in ("C6LUT", "D6LUT"):
    bp = os.path.join(D, "base_y20_%s.bit" % bel)
    bc = cells(bp); bcrc = first_crc(bp)
    for p in sorted(glob.glob(os.path.join(D, "w41_%s_k*.bit" % bel))):
        tag = os.path.basename(p)[:-4]
        k = int(tag.split("_k")[1])
        c = cells(p); add = c - bc; rem = bc - c
        for (fi, wd, b) in sorted(add):
            w.writerow([bel, k, "add", fi, wd, b, "%08x" % (first_crc(p) ^ bcrc), len(add), len(rem)])
        for (fi, wd, b) in sorted(rem):
            w.writerow([bel, k, "rem", fi, wd, b, "%08x" % (first_crc(p) ^ bcrc), len(add), len(rem)])
PYEOF
/opt/lzh/venv/bin/python $D/_parse3.py > $D/w41.csv
echo ROWS $(wc -l < $D/w41.csv)
cat $D/w41.csv
echo W41DONE
