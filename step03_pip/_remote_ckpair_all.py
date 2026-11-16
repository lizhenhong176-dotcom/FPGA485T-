import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
A = frames_from_bit("/opt/lzh/v7re/work/ckpair/out/a.bit")
B = frames_from_bit("/opt/lzh/v7re/work/ckpair/out/b.bit")
rows = []
for fi in range(len(A)):
    for w in range(101):
        if w == 50: continue
        if A[fi][w] != B[fi][w]:
            rows.append((fi, w, A[fi][w], B[fi][w]))
print("total diff", len(rows))
for fi, w, a, b in rows:
    print("frame=%5d word=%3d A=%08x B=%08x" % (fi, w, a, b))