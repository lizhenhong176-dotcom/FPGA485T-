# -*- coding: utf-8 -*-
import sqlite3, json, collections, io

con = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
q = ("select tile_name, count(*) c, min(frame_index), max(frame_index) "
     "from frame_map where tile_name like 'HCLK_CMT%' group by tile_name")
rows = con.execute(q).fetchall()
print("HCLK_CMT tile 数:", len(rows))
for x in rows:
    print("  ", x)
print("frame_map 不同 tile 数:", con.execute(
    "select count(distinct tile_name) from frame_map").fetchone()[0])
print("HCLK_CMT_L 帧:", con.execute(
    "select count(*) from frame_map where tile_name like 'HCLK_CMT_L%'").fetchone()[0])

# 本地是否存有 hclk 差分结果
for p in [r"E:\DEEPSEEK\FPGA比特流逆向\v7re\steps\hclk_sources.json"]:
    d = json.load(io.open(p, encoding="utf-8"))
    print("\nhclk_sources.json 顶层键:", list(d.keys())[:10] if isinstance(d, dict) else type(d))
    if isinstance(d, dict):
        for k, v in list(d.items())[:3]:
            print("  ", k, str(v)[:200])
