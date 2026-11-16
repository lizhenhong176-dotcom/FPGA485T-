# -*- coding: utf-8 -*-
import sqlite3, collections
l = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
q = lambda s: l.execute(s).fetchall()
for tt in ("INT_L", "INT_R"):
    feats = q("select count(*) from (select family, src_wire from law_cells where tile_type=? and sense=1 group by family, src_wire)" % (), ) if False else None
    n_feat = l.execute("select count(*) from (select distinct family, src_wire from law_cells where tile_type=? and sense=1)", (tt,)).fetchone()[0]
    n_fam = l.execute("select count(distinct family) from law_cells where tile_type=? and sense=1", (tt,)).fetchone()[0]
    n_src = l.execute("select count(distinct src_wire) from law_cells where tile_type=? and sense=1", (tt,)).fetchone()[0]
    n_cell = l.execute("select count(*) from (select distinct frame_off, parity, bit from law_cells where tile_type=? and sense=1)", (tt,)).fetchone()[0]
    n_rec = l.execute("select count(*) from law_cells where tile_type=? and sense=1", (tt,)).fetchone()[0]
    z_rec = l.execute("select count(*) from law_cells where tile_type=? and sense=0", (tt,)).fetchone()[0]
    z_cell = l.execute("select count(*) from (select distinct frame_off, parity, bit from law_cells where tile_type=? and sense=0)", (tt,)).fetchone()[0]
    # 每族不同格之和
    per = l.execute("select family, count(*) from (select distinct family, frame_off, parity, bit from law_cells where tile_type=? and sense=1) group by family", (tt,)).fetchall()
    fam_sum = sum(n for _, n in per)
    print("%s: fam=%d feat=%d src=%d cells=%d rec=%d | zero_rec=%d zero_cells=%d | sum_per_family_cells=%d" % (tt, n_fam, n_feat, n_src, n_cell, n_rec, z_rec, z_cell, fam_sum))
    # sense=0 的格是否 ⊆ sense=1 的格
    s1 = set(l.execute("select distinct frame_off, parity, bit from law_cells where tile_type=? and sense=1", (tt,)).fetchall())
    s0 = set(l.execute("select distinct frame_off, parity, bit from law_cells where tile_type=? and sense=0", (tt,)).fetchall())
    print("   zero_cells subset of one_cells:", len(s0 & s1), "/", len(s0))
l.close()