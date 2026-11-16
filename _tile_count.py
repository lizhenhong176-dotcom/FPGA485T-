import collections
import io
import sys

rows = [l.strip() for l in io.open(sys.argv[1], encoding="utf-8")
        if l.strip() and not l.strip().startswith("#")]
per_tile = collections.Counter(r.split(".")[0] for r in rows)
per_fam = collections.Counter(r.split(".")[1] for r in rows if r.count(".") >= 2)
print("总行数 %d，涉及 tile %d 个，family %d 个" % (len(rows), len(per_tile), len(per_fam)))
print("tile 明细：")
for t, c in per_tile.most_common(12):
    print("   %-22s %d" % (t, c))
print("family 前 8：", per_fam.most_common(8))
