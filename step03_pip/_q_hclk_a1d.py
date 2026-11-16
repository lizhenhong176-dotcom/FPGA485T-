# -*- coding: utf-8 -*-
"""A1：22144/22145/22147/35528 这些帧在 site_frames 里属于谁（CLB 站点 INI T 位？）。"""
import sqlite3, collections

MODEL = r"E:\v7work\model\v7_model.sqlite"
con = sqlite3.connect(MODEL)
frames = (22144, 22145, 22146, 22147, 32636, 32637, 32638, 32639, 35528, 35585)

for f in frames:
    rows = con.execute(
        "select site, bel, feature, word, bit, source from site_frames where frame=? limit 6",
        (f,)).fetchall()
    n = con.execute("select count(*) from site_frames where frame=?", (f,)).fetchone()[0]
    sites = con.execute("select count(distinct site) from site_frames where frame=?", (f,)).fetchone()[0]
    print(f"frame {f}: site_frames 行 {n}, 站点 {sites}")
    for r in rows:
        print("   ", r)

# 这些列上的 CLB 站点名，验证是否 col 33 -> CLBLM_R_X33Y*
print("\n样例站点（frame 22144）:",
      con.execute("select distinct site from site_frames where frame=22144 limit 8").fetchall())
