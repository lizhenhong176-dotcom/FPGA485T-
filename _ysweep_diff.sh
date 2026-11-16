export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/ysweep
cd $D || exit 1
/opt/lzh/venv/bin/python - <<'PY'
import sys, os, numpy as np
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
base = np.array(frames_from_bit("base/top.bit"), dtype=np.uint32)
print("word,inst,row,frame,bit,ecc")
for inst in (0, 1):
    for r in range(50):
        p = "w_%d_%d/top.bit" % (inst, r)
        if not os.path.exists(p):
            continue
        a = np.array(frames_from_bit(p), dtype=np.uint32)
        w = 2 * r + inst
        if w >= 50: w += 1
        fw = np.argwhere(a != base)
        cells = [(int(f), int(ww)) for f, ww in fw if int(ww) == w]
        if len(cells) != 1:
            print("# w_%d_%d 本 row 字差异 %d 处: %s" % (inst, r, len(cells), cells[:4]))
            continue
        f, _ = cells[0]
        diff = int(a[f][w]) ^ int(base[f][w])
        n = bin(diff).count("1")
        if n != 1:
            print("# w_%d_%d 字内 %d 位: 0x%x" % (inst, r, n, diff))
            continue
        b = diff.bit_length() - 1
        print("%d,%d,%d,%d,%d,0x%x" % (w, inst, r, f, b, int(a[f][50])))
PY