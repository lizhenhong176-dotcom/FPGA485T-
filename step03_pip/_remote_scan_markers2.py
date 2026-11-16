import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
want = {0x800a:"A0",0x4005:"B0",0x2002:"C0",0x1001:"D0"}
for name in ["a","b"]:
    f = frames_from_bit("/opt/lzh/v7re/work/ckpair/out/%s.bit" % name)
    hits = []
    for fi, row in enumerate(f):
        for w, v in enumerate(row):
            if w == 50: continue
            lo, hi = v & 0xFFFF, v >> 16
            if lo in want or hi in want:
                hits.append((fi, w, want.get(lo) or want.get(hi), "%08x" % v))
    print("== %s: %d hits" % (name, len(hits)))
    for h in hits[:20]: print("   frame=%5d word=%3d %s %s" % h)