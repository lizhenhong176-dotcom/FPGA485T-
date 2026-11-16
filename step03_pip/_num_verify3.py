import collections
import sqlite3

con = sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro", uri=True)
rows = collections.defaultdict(set)
for fam, src, fo, bit, par in con.execute(
        "select family,src_wire,frame_off,bit,parity from law_cells "
        "where tile_type='INT_L' and sense=1"):
    rows[(fam, src)].add((fo, par, bit))

fams = collections.defaultdict(list)
for (fam, src) in rows:
    fams[fam].append(src)
shape = collections.Counter()
for fam, srcs in fams.items():
    ncells = len({c for s in srcs for c in rows[(fam, s)]})
    shape[(ncells, len(srcs))] += 1
print("(cells, sources) -> families:", sorted(shape.items()))
print("sum families:", sum(shape.values()))

# pattern uniqueness under sense=1
uniq = sum(1 for fam, srcs in fams.items()
           if len({frozenset(rows[(fam, s)]) for s in srcs}) == len(srcs))
print("families with unique pattern per source:", uniq, "/", len(fams))

# subset relations (T30 claim: 1,632 对真子集)
sub = 0
for fam, srcs in fams.items():
    pats = [frozenset(rows[(fam, s)]) for s in srcs]
    for i in range(len(pats)):
        for j in range(len(pats)):
            if i != j and pats[i] < pats[j]:
                sub += 1
print("strict subset pairs within families:", sub)
