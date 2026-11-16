import json
exp = json.load(open("/opt/lzh/step03/fam/expected.json"))
obs = json.load(open("/opt/lzh/step03/fam/famdiff.json"))
ok = bad = empty = 0
detail = []
for name, cells in obs.items():
    ones = {(f, w, b) for f, w, b, s in cells if w != 50}
    e = {(f, w, b) for f, w, b, s in exp.get(name, []) if s == 1}
    if not ones:
        empty += 1; detail.append((name, "EMPTY", 0, len(e))); continue
    if ones <= e:
        ok += 1
    else:
        bad += 1; detail.append((name, "EXTRA", len(ones - e), len(e)))
print("families", len(obs), "OK", ok, "EXTRA", bad, "EMPTY", empty)
for d in detail[:40]:
    print(" ", d)
