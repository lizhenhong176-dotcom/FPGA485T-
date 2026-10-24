import json, itertools
d = json.load(open("p3_bits.json"))
pools = {}
for tag, variants in d.items():
    pos = set()
    for src, rec in variants.items():
        for f, w, b in rec["config"]:
            pos.add((w, b))
    pools[tag] = pos
    print(tag, "sources", len(variants), "words", sorted({p[0] for p in pos}), "positions", len(pos))
print()
for a, b in itertools.combinations(sorted(pools), 2):
    inter = pools[a] & pools[b]
    print(a, b, "shared (word,bit):", sorted(inter))

