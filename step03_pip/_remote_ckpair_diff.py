import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
A = frames_from_bit("/opt/lzh/v7re/work/ckpair/out/a.bit")
B = frames_from_bit("/opt/lzh/v7re/work/ckpair/out/b.bit")
print("frames", len(A), len(B))
diff = {}
for fi in range(len(A)):
    ra, rb = A[fi], B[fi]
    for w in range(101):
        if w == 50: continue
        x = ra[w] ^ rb[w]
        if x:
            diff[(fi, w)] = x
print("cells(words)", len(diff))
# 只打印时钟区附近的帧
for (fi, w) in sorted(diff):
    if 2580 <= fi <= 2600 or 7826 <= fi <= 7850:
        print("frame=%d word=%d A=%08x B=%08x xor=%08x" % (fi, w, A[fi][w], B[fi][w], diff[(fi,w)]))