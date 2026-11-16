export LANG=C LC_ALL=C
WH=/opt/lzh/v7re/work/word50
cat > $WH/diff.py <<'PY'
import sys, collections
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
WH = "/opt/lzh/v7re/work/word50"
base = frames_from_bit(WH + "/e0/top.bit")
print("frames:", len(base), "words:", len(base[0]))
LO, HI = 31716, 31752
for nm in ("e1","e2","e3","e4","e5"):
    x = frames_from_bit(WH + "/%s/top.bit" % nm)
    diff = [(i,w,b) for i,(fb,fx) in enumerate(zip(base,x)) if fb!=fx
            for w,(p,q) in enumerate(zip(fb,fx)) if p!=q for b in range(32) if (p^q)>>b&1]
    inblk = [d for d in diff if LO <= d[0] < HI]
    print("\n=== %s  总差分 %d  本 CLB 块内 %d" % (nm, len(diff), len(inblk)))
    byw = collections.defaultdict(list)
    for i,w,b in inblk: byw[(i,w)].append(b)
    for k in sorted(byw): print("   frame %d word %d bits %s" % (k[0], k[1], byw[k]))
    other = collections.Counter(d[1] for d in diff if not (LO <= d[0] < HI))
    print("   块外(按 word 统计前6):", other.most_common(6))
PY
/opt/lzh/venv/bin/python $WH/diff.py
