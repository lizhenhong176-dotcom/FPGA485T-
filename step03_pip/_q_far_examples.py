# -*- coding: utf-8 -*-
import sqlite3
con = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite"); cur = con.cursor()
def dec(far):
    return dict(block=(far>>23)&7, top=(far>>22)&1, row=(far>>17)&0x1F, col=(far>>7)&0x3FF, minor=far&0x7F)
for f in (31752, 31753, 31768, 6510, 6521):
    cur.execute("select far, is_overhead, tile_name from frame_map where frame_index=?", (f,))
    r = cur.fetchone()
    if not r: print(f, "MISSING"); continue
    far, oh, tn = r
    if far is None: print(f, "overhead", oh, tn); continue
    d = dec(far)
    print("frame %-6d far=0x%08x block=%d top=%d row=%d col=%-3d minor=%-2d oh=%s tile=%s" % (f, far, d['block'], d['top'], d['row'], d['col'], d['minor'], oh, tn))
con.close()