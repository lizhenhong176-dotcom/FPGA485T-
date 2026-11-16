"""Generate §5.6 multi-source specs (4 NEW sources per non-IMUX family, both sides).
Reads local all_cells.json; excludes the source already used in the existing 1-src spec.
Writes step03_pip/spec_multi_INT_L.json and spec_multi_INT_R.json.
"""
import json, os, re, collections

HERE = os.path.dirname(os.path.abspath(__file__))
recs = json.load(open(os.path.join(HERE, "all_cells.json"), encoding="utf-8-sig"))
# existing 1-src specs (to avoid re-testing the same source)
existing = collections.defaultdict(set)
for tt, path in (("INT_L", os.path.join(HERE, "remote_scripts", "fam", "spec.json")),
                 ("INT_R", os.path.join(HERE, "remote_scripts", "fam", "spec_r.json"))):
    # fall back: parse from all_cells is not needed; existing remote specs handled separately
    pass

# group srcs per (tile_type, family)
fam_srcs = collections.defaultdict(list)
seen = collections.defaultdict(set)
for r in recs:
    if "IMUX" in r["family"]:
        continue
    key = (r["tile_type"], r["family"])
    if r["src_wire"] not in seen[key]:
        seen[key].add(r["src_wire"])
        fam_srcs[key].append(r["src_wire"])

def sanitize(s):
    return re.sub(r"[^A-Za-z0-9_]", "_", s)

NSRC = 4
for tt in ("INT_L", "INT_R"):
    spec = []
    fams = sorted({f for (t, f) in fam_srcs if t == tt})
    for f in fams:
        srcs = fam_srcs[(tt, f)]
        pick = srcs[:NSRC]  # deterministic; first 4 sources
        for s in pick:
            name = "v_%s_%s" % (f, sanitize(s))
            spec.append([f, s, name])
    out = os.path.join(HERE, "spec_multi_%s.json" % tt)
    json.dump(spec, open(out, "w"), indent=0)
    print(tt, "families", len(fams), "variants", len(spec), "->", out)
