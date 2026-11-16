# -*- coding: utf-8 -*-
"""A0：核对外部实验（ffg1157-3）观测到的 HCLK_CMT 帧号能否落在本器件（ffg1761）的坐标里。"""
import json, sqlite3, collections

GRID = r"E:\v7work\db\prjxray\xc7vx485t\tilegrid.json"
LAW = r"E:\v7work\model\v7_law.sqlite"

g = json.load(open(GRID, encoding="utf-8"))
hclk = {k: v for k, v in g.items() if v.get("type", "").startswith("HCLK_CMT")}
print("本地 ffg1761 tilegrid 里的 HCLK_CMT 实例:", len(hclk))
cols = collections.Counter()
for k, v in sorted(hclk.items(), key=lambda kv: (kv[1]["grid_x"], kv[1]["grid_y"])):
    print(f"  {k:<24} grid_x={v['grid_x']:<4} grid_y={v['grid_y']}")
    cols[v["grid_x"]] += 1
print("按 grid_x 分组:", dict(cols))

con = sqlite3.connect(LAW)
bands = con.execute("select band, col, start_frame, frames from far_bands order by band, col").fetchall()
print("\nfar_bands 行数:", len(bands))
by_band = collections.defaultdict(list)
for b, c, s, n in bands:
    by_band[b].append((c, s, n))

def locate(frame):
    for b, lst in sorted(by_band.items()):
        base = lst[0][1]
        end = max(s + (n or 0) for _, s, n in lst)
        if base <= frame < end:
            for c, s, n in lst:
                if s <= frame < s + (n or 0):
                    return b, c, frame - s, n
    return None

for f in (22144, 22145, 22147, 32636, 32637, 32638, 32639, 35528, 35585):
    print(f"  frame {f} -> band/far_col/frame_off/frames = {locate(f)}")
