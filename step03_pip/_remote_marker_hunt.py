import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

targets = {0x800a: "A", 0x4005: "B", 0x2002: "C", 0x1001: "D",
           0x800a0000: "A-hi", 0x40050000: "B-hi", 0x20020000: "C-hi", 0x10010000: "D-hi"}
files = ["/opt/lzh/v7re/work/hclk8/out/p_72.bit",
         "/opt/lzh/v7re/work/hclk4/out/g0.bit",
         "/opt/lzh/v7re/work/clkmux3/out/y1_s0.bit"]
for fn in files:
    f = frames_from_bit(fn)
    hits = []
    for fi, row in enumerate(f):
        for w, v in enumerate(row):
            if w == 50:
                continue
            if v in targets:
                hits.append((fi, w, targets[v]))
    print(fn.split("/")[-2] + "/" + fn.split("/")[-1], "hits", len(hits))
    for h in hits[:24]:
        print("   frame=%d word=%d marker=%s" % h)