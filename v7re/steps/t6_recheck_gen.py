"""T5 复核日志生成器：只跑既有只读脚本与只读 sqlite 查询，把输出按固定段落到 t6_recheck.log。

用途：让 PAIR_IDENTITY_WHY.md 里每个数字都有一条可重跑的命令输出对应。
不改任何上游产物（pair_identity_check.py 只重写它自己的 md/json，内容确定）。
"""
import os
import sqlite3
import subprocess
import time
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
LAW = r"E:\v7work\model\v7_law.sqlite"
LOG = os.path.join(HERE, "t6_recheck.log")
PREFIX = ("IMUX", "BYP_ALT", "FAN_ALT")

out = []


def A(s=""):
    out.append(s)


A("=== T5 独立复核（2026-11-08）===")
A("[1] python pair_identity_check.py")
t0 = time.time()
p = subprocess.run([sys.executable, os.path.join(ROOT, "pair_identity_check.py")],
                   cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace")
elapsed = time.time() - t0
for line in p.stdout.splitlines():
    A(line)
A("EXIT=%d" % p.returncode)
if p.returncode != 0:
    A("[stderr]")
    A(p.stderr)

con = sqlite3.connect("file:%s?mode=ro" % LAW.replace("\\", "/"), uri=True)
q = lambda s, a=(): con.execute(s, a).fetchone()[0]

A("")
A("[2] law_cells 逐 tile_type 计数（sense=1）")
for tt in ("INT_L", "INT_R"):
    A("%s refs=%d cells=%d keys=%d"
      % (tt,
         q("select count(*) from law_cells where sense=1 and tile_type=?", (tt,)),
         q("select count(*) from (select distinct frame_off,bit,parity from law_cells "
           "where sense=1 and tile_type=?)", (tt,)),
         q("select count(*) from (select distinct family,src_wire from law_cells "
           "where sense=1 and tile_type=?)", (tt,))))
A("total_sense1=%d" % q("select count(*) from law_cells where sense=1"))

A("")
A("[3] 口径对账：格坐标（去重）vs (family,cell) 对")
for tt in ("INT_L", "INT_R"):
    cells = q("select count(*) from (select distinct frame_off,bit,parity from law_cells "
              "where sense=1 and tile_type=?)", (tt,))
    pairs = q("select count(*) from (select distinct family,frame_off,bit,parity from law_cells "
              "where sense=1 and tile_type=?)", (tt,))
    A("%s distinct_cells=%d family_cell_pairs=%d diff=%d" % (tt, cells, pairs, pairs - cells))

A("")
A("[4] 差 4 的来源：被 >1 个 family 共用的格")
rows = con.execute(
    "select frame_off,bit,parity,count(distinct family),group_concat(distinct family) "
    "from law_cells where sense=1 and tile_type='INT_L' "
    "group by frame_off,bit,parity having count(distinct family)>1").fetchall()
A("shared_cells=%d" % len(rows))
extra = 0
for fo, b, par, n, fams in rows:
    extra += n - 1
    A("  cell=(%d,%d,%d) families=%d [%s] extra+%d" % (fo, b, par, n, fams, n - 1))
A("total_extra=%d  (pairs - cells = 4)" % extra)

A("")
A("[5] T4 §5.1 INT_R 行口径：被 cells_of 跳过的 INT_R 独占 mux family")
R = {r[0] for r in con.execute(
    "select distinct family from law_cells where sense=1 and tile_type='INT_R'")}
L = {r[0] for r in con.execute(
    "select distinct family from law_cells where sense=1 and tile_type='INT_L'")}
drop = sorted(f for f in R - L if f.startswith(PREFIX))
refs = 0
cells = set()
for f in drop:
    for fo, b, par in con.execute(
            "select frame_off,bit,parity from law_cells "
            "where sense=1 and tile_type='INT_R' and family=?", (f,)):
        refs += 1
        cells.add((fo, b, par))
tot = q("select count(*) from law_cells where sense=1 and tile_type='INT_R'")
A("dropped_families=%d refs=%d cells=%d" % (len(drop), refs, len(cells)))
A("INT_R total_refs=%d  total_refs-dropped=%d  total_cells-dropped_cells=1598-%d=%d"
  % (tot, tot - refs, len(cells), 1598 - len(cells)))
A("样例：%s" % ", ".join(drop[:6]))

A("")
A("[6] 上游产物中的关键行（只读摘录）")


def pick(path, needle, label):
    path = os.path.join(ROOT, path)
    with open(path, encoding="utf-8", errors="replace") as fh:
        for i, line in enumerate(fh, 1):
            if needle in line:
                A("%s %s:%d  %s" % (label, os.path.basename(path), i, line.rstrip()))
                return


pick(r"v7re\steps\t3_probe_out.txt", "190 / 190", "E5")
pick(r"v7re\steps\t3_probe_out.txt", "合计残差位 = 0", "E8")
pick(r"v7re\steps\t3_probe_out.txt", "整窗全等的组 = 6 / 30", "E9")
pick(r"v7re\steps\t3_probe_out.txt", "签名相同的 tile 对 = 46", "E10")
pick(r"v7re\steps\t3_probe_out.txt", "坍缩对数 0", "E11")
pick(r"v7re\steps\t3_probe_out.txt", "有相交的 tile = 0 / 76", "E13")
pick(r"v7re\steps\t3_probe_out.txt", "abs 相同的对 = 0 / 240", "E14")
pick(r"v7re\steps\pair_identity_check.md", "两侧都有且相同 **107**", "E15")

A("")
A("[7] law_cells 列定义（PRAGMA table_info，证实无 col/y/base 三列）")
for cid, name, typ, notnull, dflt, pk in con.execute("PRAGMA table_info(law_cells)"):
    A("  %d  %-10s %-8s notnull=%d pk=%d" % (cid, name, typ or "", notnull, pk))
A("[8] pair_identity_check.py 计时（本轮）")
A("elapsed=%.1f s" % elapsed)
A("has_col=%s has_y=%s has_base=%s"
  % tuple(str(any(r[1] == c for r in con.execute("PRAGMA table_info(law_cells)")))
          for c in ("col", "y", "base")))

with open(LOG, "w", encoding="utf-8", newline="\n") as fh:
    fh.write("\n".join(out) + "\n")
print("wrote", LOG, "lines=", len(out))
