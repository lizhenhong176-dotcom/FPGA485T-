"""§5.6 multi-source verifier. Compares measured cells vs pip_law.predict_family
and checks in-domain uniqueness (different sources -> different cell-sets).
Usage: _verify_multi.py <famdiff.json> <spec.json> <tile>
"""
import json, sys, collections
sys.path.insert(0, r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip")
import pip_law
DIFF, SPEC, TILE = sys.argv[1], sys.argv[2], sys.argv[3]
def jload(path):
    b = open(path, "rb").read()
    if b[:2] in (b"\xff\xfe", b"\xfe\xff"):
        s = b.decode("utf-16")
    elif b[:3] == b"\xef\xbb\xbf":
        s = b.decode("utf-8-sig")
    else:
        s = b.decode("utf-8")
    return json.loads(s)
diff = jload(DIFF)
spec = jload(SPEC)
name2 = {n: (f, s) for f, s, n in spec}
pred = pip_law.predict_family  # (tile, family, wire) -> [(f,w,b,sense)]
def cset(cells):
    return frozenset((c[0], c[1], c[2]) for c in cells)
fam_actual = collections.defaultdict(dict)
verdict = collections.Counter()
mism = []
for name, cells in diff.items():
    if name not in name2:
        continue
    fam, src = name2[name]
    act = cset(tuple(c) for c in cells)
    prd = cset(pred(TILE, fam, src))
    if not prd:
        verdict["NO_PRED"] += 1; mism.append((fam, src, "no prediction")); continue
    if act == prd:
        verdict["EXACT"] += 1
    elif prd <= act:
        verdict["SUB"] += 1; mism.append((fam, src, "pred subset, extra %d" % (len(act - prd))))
    elif act <= prd:
        verdict["SUBSET_ACT"] += 1; mism.append((fam, src, "act subset, missing %d" % (len(prd - act))))
    else:
        verdict["MIX"] += 1; mism.append((fam, src, "mix +%d/-%d" % (len(act - prd), len(prd - act))))
    fam_actual[fam][src] = act
# uniqueness: within family, all measured srcs distinct cell-sets
uniq_bad = []
for fam, d in fam_actual.items():
    seen = {}
    for src, cs in d.items():
        if cs in seen:
            uniq_bad.append((fam, src, "same cells as " + seen[cs]))
        seen[cs] = src
print("TILE", TILE, "variants", len(diff))
print("verdict", dict(verdict))
print("families measured", len(fam_actual), "avg src/fam",
      round(sum(len(d) for d in fam_actual.values()) / max(1, len(fam_actual)), 2))
print("UNIQ violations", len(uniq_bad))
for x in uniq_bad[:20]:
    print("  ", x)
print("MISMATCH (non-EXACT)", len(mism))
for x in mism[:30]:
    print("  ", x)
