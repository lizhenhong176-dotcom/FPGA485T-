import sys, glob
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
want = {0x800a:"A", 0x4005:"B", 0x2002:"C", 0x1001:"D"}
pats = ["/opt/lzh/v7re/work/hclk4/out/*.bit", "/opt/lzh/v7re/work/hclk5/out/*.bit",
        "/opt/lzh/v7re/work/hclk6/out/*.bit", "/opt/lzh/v7re/work/hclk8/out/*.bit",
        "/opt/lzh/v7re/work/clkmux3/out/y1_s0.bit", "/opt/lzh/v7re/work/clkmux3/out/y2_s0.bit",
        "/opt/lzh/v7re/work/ckpair/out/*.bit"]
files = []
for p in pats: files += sorted(glob.glob(p))
for fn in files:
    try:
        f = frames_from_bit(fn)
    except Exception as e:
        print("ERR", fn, e); continue
    # 只统计「半字恰好等于标记值」的位点
    hits = 0; where = []
    for fi, row in enumerate(f):
        for w, v in enumerate(row):
            if w == 50: continue
            lo, hi = v & 0xFFFF, v >> 16
            if lo in want or hi in want:
                hits += 1
                if len(where) < 2: where.append((fi, w, "%08x" % v))
    tag = fn.split("/")[-2] + "/" + fn.split("/")[-1]
    print("%-24s markers=%d %s" % (tag, hits, where))