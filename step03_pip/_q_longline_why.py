# -*- coding: utf-8 -*-
import sqlite3, itertools, collections, re
DB = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(DB); cur = con.cursor()
fams = ["LH0","LH12","LVB_L0","LVB_L12","LV_L0","LV_L18"]
print("== 码集 {1,2,7,11} 的距离 ==")
codes = [1,2,7,11]
for a,b in itertools.combinations(codes,2):
    print("  %2d ^ %2d = %2d  popcount %d" % (a,b,a^b,bin(a^b).count("1")))
print("  min distance =", min(bin(a^b).count("1") for a,b in itertools.combinations(codes,2)))
print("  与合法码距离 1 的 4 位字:", sorted({c ^ (1<<i) for c in codes for i in range(4)} ))
print()
print("== 长线族：源 -> 2 格 ==")
for f in fams:
    cur.execute("SELECT src_wire, frame_off, sense, bit, parity FROM law_cells WHERE tile_type='INT_L' AND family=? AND sense=1 ORDER BY src_wire, frame_off", (f,))
    rows = cur.fetchall()
    bysrc = collections.OrderedDict()
    for s, fo, se, b, p in rows:
        bysrc.setdefault(s, []).append((fo,b,p))
    print("--", f, "源数", len(bysrc), "格数", len({c for v in bysrc.values() for c in v}))
    print("   " + " | ".join("%s→%s" % (s, ",".join("%d/%d/%d" % c for c in v)) for s, v in list(bysrc.items())[:6]))
    # 方向类别
    def dcls(s):
        m = re.match(r"([NSEW]{1,2})", s)
        return m.group(1) if m else "?"
    groups = collections.defaultdict(list)
    for s in bysrc: groups[dcls(s)].append(s)
    print("   方向类:", {k: len(v) for k,v in sorted(groups.items())})
con.close()