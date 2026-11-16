# -*- coding: utf-8 -*-
"""Global check: for every data frame, minor == frame - start_frame(band,col)?"""
import sqlite3
m = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
l = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
starts = {(b, c): s for b, c, s, fr in l.execute("select band, col, start_frame, frames from far_bands")}
ok = bad = oh = 0
bad_ex = []
for fi, far, isoh in m.execute("select frame_index, far, is_overhead from frame_map"):
    if far is None or isoh: oh += 1; continue
    block = (far >> 23) & 7; top = (far >> 22) & 1; row = (far >> 17) & 0x1F
    col = (far >> 7) & 0x3FF; minor = far & 0x7F
    band = {(0,0,0):0,(0,0,1):1,(0,0,2):2,(0,0,3):3,(0,0,4):4,(0,1,0):5,(0,1,1):6}.get((block,top,row))
    if band is None: bad += 1; bad_ex.append((fi,"band",block,top,row)); continue
    base = starts.get((band, col))
    if base is None: bad += 1; bad_ex.append((fi,"nocol",band,col)); continue
    if fi - base == minor: ok += 1
    else:
        bad += 1
        if len(bad_ex) < 5: bad_ex.append((fi, "mismatch", base, minor, fi-base))
print("data_frames_ok", ok, "bad", bad, "overhead", oh)
print("examples", bad_ex[:5])