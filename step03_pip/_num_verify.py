import collections
import statistics
import sqlite3

con = sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro", uri=True)
rows = collections.defaultdict(set)
for fam, src, fo, bit, par in con.execute(
        "select family,src_wire,frame_off,bit,parity from law_cells "
        "where tile_type='INT_L' and sense=1"):
    rows[(fam, src)].add((fo, par, bit))

cells = collections.defaultdict(set)  # cell -> features
for fs, cs in rows.items():
    for c in cs:
        cells[c].add(fs)

sharing = collections.Counter(len(v) for v in cells.values())
featsize = collections.Counter(len(v) for v in rows.values())
print("features(sense=1):", len(rows), "distinct cells:", len(cells))
print("cells per feature distribution:", sorted(featsize.items()))
print("features per cell distribution:", sorted(sharing.items()))
print("avg cells/feature: %.2f" % (sum(len(v) for v in rows.values()) / len(rows)))
print("avg features/cell: %.2f" % (sum(len(v) for v in cells.values()) / len(cells)))

fams = collections.defaultdict(list)
for (fam, src) in rows:
    fams[fam].append(src)
print("families:", len(fams))
print("family size distribution:", sorted(collections.Counter(len(v) for v in fams.values()).items()))

# distinct cell-sets per family (pattern uniqueness)
uniq = 0
merged = 0
detail = collections.Counter()
for fam, srcs in fams.items():
    pats = {frozenset(rows[(fam, s)]) for s in srcs}
    detail[(len(srcs), len(pats))] += 1
    if len(pats) == len(srcs):
        uniq += 1
    else:
        merged += 1
print("families with unique pattern per src:", uniq, " merged:", merged)
print("(srcs, patterns) -> families:", sorted(detail.items()))

# cross-family cell sharing
cellfams = collections.defaultdict(set)
for (fam, src), cs in rows.items():
    for c in cs:
        cellfams[c].add(fam)
shared = sum(1 for c, f in cellfams.items() if len(f) > 1)
print("cells shared by >1 family:", shared, "/", len(cellfams))
