#!/usr/bin/env python3
"""reg_decode.py —— 解码器回归 + 空设计校准（P0a 任务 1/2）。

任务 1：ref_S_40_11.bit 是“删光 net n1 全部 PIP”的空路由位流 → 解码输出应 ≈0。
任务 2：tilepipe 的 12 个变体位流，每个换入一条已知 PIP（v_TAG_SRC.bit）→
        解码输出应包含 (INT_L_X6Y11, IMUX_Lx, SRC)。
"""
import csv
import json
import subprocess
import sys
import os

HERE = os.path.dirname(os.path.abspath(__file__))
DEC = os.path.join(HERE, "..", "v7re", "export", "decode_law.py")
BITS = os.path.join(HERE, "regbits")
TILE = "INT_L_X6Y11"   # tilepipe1 的全部设计都在这块 tile

expect = json.load(open(os.path.join(HERE, "reg_sample.json")))["expect"]

def decode(bitfile, outcsv):
    r = subprocess.run([sys.executable, DEC, bitfile, "--out", outcsv],
                       capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    tail = [l for l in r.stdout.strip().splitlines() if l.startswith("EXACT")]
    rows = list(csv.DictReader(open(outcsv, newline="")))
    return tail[0] if tail else r.stdout[-200:], rows

# ---- 任务 1：空设计校准 ----
print("== EMPTY CALIBRATION: ref_S_40_11.bit (all PIPs removed)")
summary, rows = decode(os.path.join(BITS, "ref_S_40_11.bit"),
                       os.path.join(HERE, "reg_empty.csv"))
print("  ", summary)
for r in rows[:12]:
    print("   ", r["tile"], r["family"], r["src"], r["pattern"], r["cells1"])
print(f"   total rows: {len(rows)}")

# ---- 任务 2：变体回归 ----
print("== REGRESSION: 12 variants, expect (tile, sink, src) hit")
ok = miss = 0
for tag, sink, src in expect:
    f = os.path.join(BITS, f"v_{tag}_{src}.bit")
    if not os.path.exists(f):
        print(f"   [skip] {tag}_{src}: file missing")
        continue
    outcsv = os.path.join(HERE, "reg_out.csv")
    summary, rows = decode(f, outcsv)
    hit = any(r["tile"] == TILE and r["family"] == sink and r["src"] == src
              for r in rows)
    n = len(rows)
    print(f"   [{'HIT ' if hit else 'MISS'}] {sink}/{src:22s} rows={n:3d}  {summary.split(' (')[0]}")
    ok += hit; miss += (not hit)
print(f"   == regression: {ok} hit / {ok+miss} ({ok/(ok+miss)*100:.0f}%)")
