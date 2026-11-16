set -e
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/crcfull2
export D
O=/opt/lzh/v7re/work/crcfull2_diff
rm -rf $O; mkdir -p $O; cd $O
cat > $D/_parse.py <<'PYEOF'

import sys, os, struct, glob, csv
import numpy as np
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

D = "/opt/lzh/v7re/work/crcfull2"

def first_crc(path):
    with open(path, "rb") as f:
        data = f.read()
    i = data.find(b"\x30\x00\x00\x01")
    if i < 0 or i + 8 > len(data):
        return -1
    return struct.unpack(">I", data[i+4:i+8])[0]

def cells(path):
    a = np.array(frames_from_bit(path), dtype=np.uint32)
    rows = np.nonzero(a.any(axis=1))[0]
    out = set()
    for fi in rows:
        nzw = np.nonzero(a[fi])[0]
        for w in nzw:
            if w == 50:
                continue
            v = int(a[fi, w])
            while v:
                b = (v & -v).bit_length() - 1
                out.add((int(fi), int(w), b))
                v &= v - 1
    return out

y = int(sys.argv[1])
w = csv.writer(sys.stdout)
base = os.path.join(D, "base_y%d.bit" % y)
bc = cells(base)
bcrc = first_crc(base)
for p in sorted(glob.glob(os.path.join(D, "y%d_*.bit" % y))):
    tag = os.path.basename(p)[:-4]
    parts = tag.split("_")
    bel = parts[1]
    k = parts[2][1:]
    c = cells(p)
    crc = first_crc(p)
    add = c - bc
    rem = bc - c
    for (fi, wd, b) in sorted(add):
        w.writerow([tag, y, bel, k, "add", fi, wd, b, "%08x" % crc, "%08x" % bcrc])
    for (fi, wd, b) in sorted(rem):
        w.writerow([tag, y, bel, k, "rem", fi, wd, b, "%08x" % crc, "%08x" % bcrc])
PYEOF
seq 0 49 | xargs -P 8 -I{} sh -c '/opt/lzh/venv/bin/python $D/_parse.py {} > y{}.csv'
cat y*.csv > all.csv
echo ROWS $(wc -l < all.csv)
echo CRCDIFF_DONE
