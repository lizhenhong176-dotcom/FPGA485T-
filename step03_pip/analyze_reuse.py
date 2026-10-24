import json
import itertools

d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\reuse_bits.json"))

srcs = sorted(d)
# drop the constant part (present in every variant)
const = None
for s in srcs:
    cfg = set(tuple(x) for x in d[s]["config"])
    const = cfg if const is None else (const & cfg)
print("constant bits (all sources):", sorted(const))

var = {s: sorted(set(tuple(x) for x in d[s]["config"]) - const) for s in srcs}
print("\nvariable bit counts:", {s: len(v) for s, v in var.items() if len(v) not in (2, 4)} or "all 2 or 4")

# position universe
pos = sorted({p for v in var.values() for p in v})
print("variable positions:", len(pos), pos)

# which positions appear together in >1 source (shared) vs unique
use = {p: [s for s in srcs if p in var[s]] for p in pos}
print("\npositions used by >1 source:")
for p in pos:
    if len(use[p]) > 1:
        print("  ", p, len(use[p]), use[p][:8])

# group by bit number
for b in sorted({p[2] for p in pos}):
    grp = [p for p in pos if p[2] == b]
    print("\nbit=%d frames:" % b, [p[0] for p in grp])
    for s in srcs:
        sel = [p[0] for p in var[s] if p[2] == b]
        if sel:
            print("   %-18s %s" % (s, sel))
