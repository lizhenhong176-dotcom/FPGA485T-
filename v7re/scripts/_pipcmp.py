import sys; sys.path.insert(0, ".")
from tamper_localize import World, load_bits
w = World()
A = load_bits(r"..\..\tamper\ref\ref.bit")
B = load_bits(r"..\..\tamper\ref\tamper_init.bit")
actA = set(w.active_tiles(A)); actB = set(w.active_tiles(B))
diff_tiles = 0; pa = pb = 0
for ti in sorted(actA | actB):
    sa = set((f,s) for f,s,_ in w.selected(A, ti))
    sb = set((f,s) for f,s,_ in w.selected(B, ti))
    pa += len(sa); pb += len(sb)
    if sa != sb: diff_tiles += 1
print("tiles:", len(actA), len(actB), "pipA:", pa, "pipB:", pb, "tiles_with_pip_diff:", diff_tiles)
