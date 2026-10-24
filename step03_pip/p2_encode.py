import json
import itertools

d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\reuse_bits.json"))
srcs = sorted(d)
const = set(map(tuple, d["NR1END0"]["config"]))
var = {s: set(map(tuple, d[s]["config"])) - const for s in srcs}
pos = sorted({p for v in var.values() for p in v})
idx = {p: i for i, p in enumerate(pos)}
print("positions:", pos)
print("const:", sorted(const))

# GF(2) rank of the 25 code vectors
rows = []
for s in srcs:
    m = 0
    for p in var[s]:
        m |= 1 << idx[p]
    rows.append((s, m))

basis = []
for s, m in rows:
    x = m
    for b in basis:
        x = min(x, x ^ b)
    if x:
        basis.append(x)
        basis.sort(reverse=True)
print("GF(2) rank:", len(basis), "of", len(rows), "codes,", len(pos), "positions")

# subset relations
subs = [(a, b) for a, b in itertools.permutations(srcs, 2) if var[a] and var[a] < var[b]]
print("strict subset pairs:", subs[:10], "count", len(subs))

# popcount distribution
from collections import Counter
pc = Counter(len(var[s]) for s in srcs)
print("popcount distribution:", dict(pc))

# group by presence of each b3 position
for p in [x for x in pos if x[2] == 3]:
    print("b3 %s used by:" % (p,), [s for s in srcs if p in var[s]])
