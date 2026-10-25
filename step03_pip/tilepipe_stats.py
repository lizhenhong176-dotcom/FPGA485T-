import collections
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
data = json.load(open(os.path.join(HERE, "tilepipe.json"), encoding="utf-8"))

print("designs:", len(data), "| sources each:", collections.Counter(len(v["sources"]) for v in data.values()))

# per mux aggregate
per_mux = {}
for tag, rec in data.items():
    mux = rec["sink"]
    srcs = rec["sources"]
    per_mux.setdefault(mux, []).append((tag, srcs))

print("\nmuxes:", len(per_mux))

# 1) mask size distribution
sizes = collections.Counter()
for mux, designs in per_mux.items():
    for tag, srcs in designs:
        for s, r in srcs.items():
            sizes[len(r)] += 1
print("mask size distribution (all designs):", dict(sorted(sizes.items())))

# 2) enable cells: cells present in EVERY non-empty source of a mux
print("\nenable cells per mux (present in all non-default sources):")
for mux in sorted(per_mux, key=lambda m: int(m.split("_L")[1]))[:10]:
    designs = per_mux[mux]
    tag, srcs = designs[0]
    nonempty = [set(map(tuple, r)) for r in srcs.values() if r]
    if not nonempty:
        continue
    common = set.intersection(*nonempty)
    print("  %-9s designs=%d sources=%d enable=%s" %
          (mux, len(designs), len(srcs), sorted((f, w, b) for f, w, b in common)))

# 3) reuse: per mux, how many sources share each cell
print("\ncell reuse (max sources sharing one cell), per mux:")
for mux in sorted(per_mux, key=lambda m: int(m.split("_L")[1]))[:12]:
    tag, srcs = per_mux[mux][0]
    cnt = collections.Counter()
    for s, r in srcs.items():
        for f, w, b in r:
            cnt[(f, w, b)] += 1
    top = cnt.most_common(3)
    print("  %-9s %s" % (mux, top))

# 4) are cell sets disjoint across muxes?
cellsets = {}
for mux, designs in per_mux.items():
    cs = set()
    for tag, srcs in designs:
        for s, r in srcs.items():
            cs |= set(map(tuple, r))
    cellsets[mux] = cs
muxes = sorted(cellsets, key=lambda m: int(m.split("_L")[1]))
overlapping = 0
for i in range(len(muxes)):
    for j in range(i + 1, len(muxes)):
        if cellsets[muxes[i]] & cellsets[muxes[j]]:
            overlapping += 1
print("\nmux pairs sharing any cell:", overlapping, "of", len(muxes) * (len(muxes) - 1) // 2)
