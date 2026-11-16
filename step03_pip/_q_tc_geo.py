# -*- coding: utf-8 -*-
"""G3：INT_L 的对外连接几何 —— 每个 wire 连到哪些 (dx,dy) 邻居。"""
import json, collections

TC = r"E:\v7work\db\prjxray\xc7vx485t\tileconn.json"
d = json.load(open(TC, encoding="utf-8"))

idx = collections.defaultdict(list)   # (tile_type, wire) -> [(dx,dy,other_tile,other_wire)]
for e in d:
    tt = e["tile_types"]
    dx, dy = e["grid_deltas"]
    for a, b in e["wire_pairs"]:
        idx[(tt[0], a)].append((dx, dy, tt[1], b))
        idx[(tt[1], b)].append((dx, dy, tt[0], a))

int_keys = [k for k in idx if k[0].startswith("INT")]
print("INT 相关 tile 类型：", sorted({k[0] for k in int_keys}))
print("INT_L wire 数：", len([k for k in idx if k[0] == "INT_L"]))

def show(w, n=6):
    v = idx.get(("INT_L", w))
    print("  ", w.ljust(22), "无连接" if not v else
          [(dx, dy, ow) for dx, dy, _, ow in v][:n], "" if not v or len(v) <= n else f"(共 {len(v)})")

for w in ["IMUX_L40", "BYP_ALT0", "SS2END0", "EE2END0", "WL1END0", "WR1END0",
          "BYP_BOUNCE_N3_3", "LOGIC_OUTS_L0", "GFAN0"]:
    show(w)

# dy 取值分布 + 方向语义检查
dyset = collections.Counter()
for (tt, w), v in idx.items():
    if tt != "INT_L":
        continue
    for dx, dy, _, _ in v:
        dyset[(dx, dy)] += 1
print("\n(INT_L 出边) dx,dy 组合前 12：", dyset.most_common(12))
