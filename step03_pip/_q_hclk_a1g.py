# -*- coding: utf-8 -*-
"""A1：tilegrid 的 grid_x 与 law_tiles 的 col（FAR 列）换算。"""
import json, sqlite3, collections

GRID = r"E:\v7work\db\prjxray\xc7vx485t\tilegrid.json"
LAW = r"E:\v7work\model\v7_law.sqlite"
g = json.load(open(GRID, encoding="utf-8"))
con = sqlite3.connect(LAW)

for name in ("INT_L_X8Y20", "INT_R_X37Y199", "INT_L_X144Y186", "INT_R_X71Y6"):
    t = g.get(name)
    row = con.execute("select col, y, tile_type from law_tiles where tile_name=?", (name,)).fetchone()
    print(f"{name}: tilegrid={t}, law(col,y,type)={row}")

# 建立 (tile_type, X 数字) -> law col 的映射，看 grid_x 与 col 的差
pairs = []
for name, v in g.items():
    if v["type"] in ("INT_L", "INT_R"):
        row = con.execute("select col from law_tiles where tile_name=?", (name,)).fetchone()
        if row:
            pairs.append((v["type"], v["grid_x"], row[0]))
pairs.sort()
print("\nINT 上 (grid_x -> col) 前 12:", pairs[:12])
print("差值统计:", collections.Counter(c - x for _, x, c in pairs).most_common(6))
print("INT 列数:", len(set(c for _, _, c in pairs)), "grid_x 范围:",
      min(x for _, x, _ in pairs), max(x for _, x, _ in pairs))

# HCLK_CMT 的 grid_x 在 INT 列中的位置
for x in (88, 305):
    near = [p for p in pairs if abs(p[1] - x) <= 2]
    print(f"\ngrid_x={x} 附近的 INT 列:", near[:6])
