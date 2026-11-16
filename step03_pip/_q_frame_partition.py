# -*- coding: utf-8 -*-
import sqlite3, collections
con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite"); cur = con.cursor()
cur.execute("select family, count(distinct src_wire), group_concat(distinct frame_off) from law_cells where tile_type='INT_L' and sense=1 group by family")
by = collections.defaultdict(lambda: [0, set(), set()])
for fam, nsrc, fos in cur.fetchall():
    g = {24:'mux(64)',20:'BEG(96)',16:'复合(6)',18:'长线(2)',12:'长线(3)',10:'长线(1)'}.get(nsrc, 'other')
    fo = {int(x) for x in fos.split(",")}
    by[g][0] += 1; by[g][1] |= fo
    by[g][2].add((min(fo), max(fo)))
for g, (n, fo, ranges) in sorted(by.items()):
    print("%-10s families=%-3d frame_off union=%-28s ranges=%s" % (g, n, sorted(fo), sorted(ranges)))
con.close()