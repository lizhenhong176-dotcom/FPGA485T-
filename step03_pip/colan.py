import glob, json, os
csvs = glob.glob("/opt/lzh/**/frame_index_far.csv", recursive=True)
path = csvs[0]
rows = []
with open(path) as f:
    hdr = f.readline()
    for line in f:
        p = line.strip().split(",")
        if len(p) >= 6:
            try: rows.append((int(p[0], 0), int(p[3]), int(p[4]), int(p[5])))
            except Exception: pass
bases = sorted(set(r[3] for r in rows))
def block_of(frame):
    b = [x for x in bases if x <= frame]
    return b[-1] if b else None
for p in sorted(glob.glob("/mnt/c/Users/S.tschai/col_*.json")):
    col = os.path.basename(p)[4:-5]
    d = json.load(open(p))
    if "GFAN0" not in d: continue
    g = d["GFAN0"]
    fr = sorted({x[0] for x in g})
    base = block_of(fr[0])
    print("col", col, "base", base, "GFAN0", sorted((x[0]-base, x[2]) for x in g))