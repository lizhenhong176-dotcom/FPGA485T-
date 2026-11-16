import json, collections, os, statistics
cands = ["/opt/lzh/step03/all_cells.json", "/opt/lzh/step03/fam/all_cells.json",
         "/opt/lzh/step03/famr/all_cells.json"]
p = next((c for c in cands if os.path.exists(c)), None)
print("using", p)
if p is None:
    print("MISSING all_cells.json on remote"); raise SystemExit
recs = json.load(open(p, encoding="utf-8-sig"))
print("records", len(recs), "keys", list(recs[0].keys()))
print("tile_type", dict(collections.Counter(r["tile_type"] for r in recs)))
srckey = "src" if "src" in recs[0] else ("wire" if "wire" in recs[0] else None)
print("srckey", srckey)
fam = collections.defaultdict(set)
for r in recs:
    fam[(r["tile_type"], r["family"])].add(r[srckey])
nonimux = {k: v for k, v in fam.items() if "IMUX" not in k[1]}
cnt = [len(v) for v in nonimux.values()]
print("nonimux families", len(nonimux), "src/fam min", min(cnt), "med", statistics.median(cnt), "max", max(cnt))
lt = sorted({k for k in nonimux if k[0] == "INT_L"})
rt = sorted({k for k in nonimux if k[0] == "INT_R"})
print("INT_L nonimux fams", len(lt), "INT_R nonimux fams", len(rt))
# families with <3 sources (cannot do 3-5)
lt3 = [k for k in lt if len(nonimux[k]) < 3]
print("INT_L fams with <3 src", len(lt3), lt3[:10])
for k in lt[:4]:
    print("SAMPLE", k[1], sorted(nonimux[k])[:8])
