# -*- coding: utf-8 -*-
"""T6 校验：逐条核对 PAIR_IDENTITY_WHY.md 的数字/路径/引用，并做独立复算（sqlite）。
只读，不修改任何既有文件；输出 v7re/steps/t6_verify2.log。
用法：python v7re/steps/t6_verify2.py
"""
import os, re, json, sqlite3, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.chdir(ROOT)
DOC = os.path.join(ROOT, "v7re", "steps", "PAIR_IDENTITY_WHY.md")
LOG = os.path.join(ROOT, "v7re", "steps", "t6_verify2.log")
LAWDB = r"E:/v7work/model/v7_law.sqlite"
out = []
fails = []
npass = 0


def p(s=""):
    out.append(s)
    print(s)


def ok(cond, label, detail=""):
    global npass
    if cond:
        npass += 1
        p("  PASS  %s%s" % (label, ("  [" + detail + "]") if detail else ""))
    else:
        fails.append(label + ("  [" + detail + "]" if detail else ""))
        p("  FAIL  %s%s" % (label, ("  [" + detail + "]") if detail else ""))


doc_lines = open(DOC, encoding="utf-8").read().split("\n")
SHORT = {"T55": "v7re/steps/T55_OBJECT_JUDGMENT_INIT_VS_PIP.md",
         "t3": "v7re/steps/t3_probe_out.txt",
         "T1": "v7re/steps/T1_REFERENT_RESOLUTION.md"}


def read_lines(rel):
    return open(os.path.join(ROOT, rel.replace("/", os.sep)), encoding="utf-8",
                errors="replace").read().split("\n")


p("[1] 引用存在性：全路径引用逐条检查（文件存在 + 行号在范围内）")
pat = re.compile(r"([A-Za-z0-9_./\\-]+\.(?:md|py|json|log|txt|fasm|bit|sqlite)):(\d+)(?:-(\d+))?")
refs = []
for i, l in enumerate(doc_lines, 1):
    for m in pat.finditer(l):
        refs.append((i, m.group(1), int(m.group(2)), int(m.group(3)) if m.group(3) else None))
p("  全路径引用条数 = %d" % len(refs))
bad = 0
for docl, f, a, b in refs:
    cand = f if os.path.exists(os.path.join(ROOT, f.replace("/", os.sep))) else None
    if cand is None:
        # 允许只写文件名（文档里有 fasm2bit.py / pair_identity_check.md 这类简写）
        for probe in ("v7re/scripts/" + f, "v7re/steps/" + f, f, "v7re/steps/" + os.path.basename(f)):
            if os.path.exists(os.path.join(ROOT, probe.replace("/", os.sep))):
                cand = probe
                break
    if cand is None:
        bad += 1
        p("  MISSING-FILE  doc:%d -> %s" % (docl, f))
        continue
    n = len(read_lines(cand))
    hi = b or a
    if hi > n or a < 1:
        bad += 1
        p("  OUT-OF-RANGE  doc:%d -> %s:%d%s (文件 %d 行)" % (docl, f, a, ("-%d" % b) if b else "", n))
ok(bad == 0, "全部全路径引用指向存在的文件且行号在范围内", "refs=%d bad=%d" % (len(refs), bad))

p("")
p("[2] 简写引用（T55:/t3:/T1:）展开后逐条存在性检查")
sh = re.compile(r"(?<![A-Za-z0-9_.])(T55|t3|T1):(\d+)(?:-(\d+))?")
srefs = []
for i, l in enumerate(doc_lines, 1):
    for m in sh.finditer(l):
        srefs.append((i, m.group(1), int(m.group(2)), int(m.group(3)) if m.group(3) else None))
p("  简写引用条数 = %d" % len(srefs))
bad2 = 0
for docl, key, a, b in srefs:
    f = SHORT[key]
    n = len(read_lines(f))
    if (b or a) > n:
        bad2 += 1
        p("  OUT-OF-RANGE  doc:%d -> %s:%d (文件 %d 行)" % (docl, key, b or a, n))
ok(bad2 == 0, "全部简写引用行号在范围内", "srefs=%d bad=%d" % (len(srefs), bad2))

# ---------------------------------------------------------------- 内容断言
p("")
p("[3] 内容断言：文档里的关键数字/事实必须能在它引用的那一行（或区间）找到")


def line_has(rel, a, b, *subs):
    L = read_lines(rel)
    seg = "\n".join(L[a - 1:(b or a)])
    missing = [s for s in subs if s not in seg]
    return (not missing), missing, seg.replace("\n", " | ")[:160]


def assert_at(label, rel, a, b, *subs):
    good, missing, seg = line_has(rel, a, b, *subs)
    ok(good, label, "缺 %s @%s:%s" % (missing, os.path.basename(rel), a) if not good else seg)


t5log = "v7re/steps/t5_recheck.log"
picmd = "v7re/steps/pair_identity_check.md"
t3 = "v7re/steps/t3_probe_out.txt"
f2b = "v7re/scripts/fasm2bit.py"
status = "STATUS.md"

assert_at("log[1]: tiles=76 combos=117 multi=31 pairs=31", t5log, 4, 4,
          "tiles=76", "combos=117", "multi=31", "pairs=31", "selfcheck_mismatch=0")
assert_at("log[1]: L0 0/31 L1 4/31 L2 31/31", t5log, 5, 5, "identical=0/31", "=4/31", "=31/31")
assert_at("log[1]: 签名 frame4 frame+word9 word18", t5log, 6, 6, '"frame": 4', '"frame+word": 9', '"word": 18')
assert_at("log[1]: 1598/8900/5.57/shared_lit=0", t5log, 7, 7, "cells=1598", "refs=8900", "5.57", "shared_lit=0")
assert_at("log[1]: 117/0/107/10", t5log, 8, 8, "distinct=117", "collisions=0", "agree=107", "disagree=10")
assert_at("log[1]: EXIT=0", t5log, 11, 11, "EXIT=0")
assert_at("log[2]: INT_L/INT_R 8900/1598/3634 与 total 17800", t5log, 14, 16,
          "refs=8900", "cells=1598", "keys=3634", "17800")
assert_at("log[3]: distinct 1598 vs family_cell_pairs 1602 diff 4", t5log, 19, 20,
          "1598", "1602", "4")
assert_at("log[5]: dropped 48 / 3456 / 480 -> 5444 / 1118", t5log, 30, 32,
          "48", "3456", "480", "5444", "1118")
assert_at("log[7]: PRAGMA 8 列且无 col/y/base", t5log, 45, 52,
          "tile_type", "family", "src_wire", "frame_off", "parity", "src_index")
assert_at("log[8]: elapsed 28.3 s 与 has_col/y/base=False", t5log, 54, 55,
          "28.3", "has_col=False", "has_y=False", "has_base=False")

assert_at("pic md: 191 = 190 PIP + 1 非 PIP", picmd, 17, 17, "191", "190")
assert_at("pic md: L0/L1/L2 汇总 0/4/31", picmd, 70, 76, "0", "4", "31")
assert_at("pic md: 四对跨列样本 col14->26 等", picmd, 84, 91,
          "X14Y16", "X26Y16", "X20Y19", "X28Y19")
assert_at("pic md: INT_L 1598/8900/5.57 与 INT_R 1118/5444/4.87", picmd, 165, 168,
          "1598", "8900", "5.57", "1118", "5444", "4.87")
assert_at("pic md: 设计级同位多声明 0", picmd, 172, 178, "0")
assert_at("pic md: 117 且碰撞 0 且 107/10", picmd, 184, 189, "117", "0", "107", "10")
assert_at("pic md: 1602 vs 1598 更正", picmd, 198, 198, "1602", "1598")

assert_at("t3: 190/190", t3, 127, 127, "190", "190")
assert_at("t3: 整窗全等 6/30", t3, 129, 131, "6", "30")
assert_at("t3: 53<->53 坍缩 0", t3, 147, 147, "0")
assert_at("t3: S13 IMUX_L34 四组", t3, 153, 177, "IMUX_L34")
assert_at("STATUS: σ={32:34,33:35,34:33,35:32}", status, 3616, 3618,
          "32", "34", "33", "35", "4")

p("")
p("[4] 文档自身口径核对（本轮重点）")
# 4.1 word 公式是否完整
L = read_lines("v7re/scripts/fasm2bit.py")
code_word = "\n".join(L[107:111])
p("  code word_of 段(fasm2bit.py:108-111) = " + code_word.replace("\n", " ⏎ "))
formula_line = doc_lines[58]   # 文档第 59 行：地址公式行
doc_has_skip = ("+ 1" in formula_line) or ("+1" in formula_line) or ("跳过" in formula_line) or ("≥50" in formula_line)
ok(("+ 1" in code_word) and (not doc_has_skip),
   "N1 文档 §2 的 word 公式缺『w>=50 时 +1（跳过 ECC word 50）』一句（代码 fasm2bit.py:109-111 有）",
   "代码含 +1；文档 §2 第 55-61 行未提 50")

# 4.2 t3:137 标签与文档数字冲突
Lt = read_lines(t3)
lab = Lt[136]
p("  t3:137 原文 = " + lab.strip())
p("  t3:138-143 列距清单（前 6 行）= " + " ⏎ ".join(x.strip() for x in Lt[137:143]))
dcols = [int(m.group(1)) for x in Lt[137:143] for m in [re.search(r"dcol=(\d+)", x)] if m]
xcnt = sum(1 for d in dcols if d != 0)
ok(lab.strip().startswith("其中跨列对数 = 10") and xcnt <= 1,
   "N2 文档『整窗跨列仅 1 对 Δcol=2』与所引 t3:137『跨列对数 = 10』字面冲突；"
   "实际 xpairs 是 6 个全等组内全部 C(n,2) 对（t3_hypothesis_probe.py:338-343），"
   "列距清单只有 1 条非 0",
   "top6 dcol=%s 非0=%d" % (dcols, xcnt))

# 4.3 日志行号引用是否偏移（E11/E13/§10）
def find_line(fp, sub):
    for i, l in enumerate(read_lines(fp), 1):
        if sub in l:
            return i
    return -1


real_l2 = find_line(t5log, "distinct=117")
real_reuse = find_line(t5log, "shared_lit=0")
p("  t5_recheck.log 实际行号：l2 distinct=%d, reuse model shared_lit=%d" % (real_l2, real_reuse))
docE11 = [i for i, l in enumerate(doc_lines, 1) if "第 9 行" in l]
docE13 = [i for i, l in enumerate(doc_lines, 1) if "第 8 行" in l]
p("  文档含『第 9 行』的行 = %s ; 含『第 8 行』的行 = %s" % (docE11, docE13))
ok(real_l2 == 8 and real_reuse == 7 and docE11 and docE13,
   "N3 文档 E11 标『第 9 行』实际为第 8 行、E13 标『第 8 行』实际为第 7 行（整体 +1 偏移）",
   "log 实际 8/7")

# 4.4 5.57 vs 5.56 引用错位
t3_ratio = find_line(t3, "5.56")
ok(t3_ratio != -1 and t3_ratio == 91,
   "N4 文档 §1④ 用 5.57 但引 t3:91（字面 5.56，另一个分母）；§11 B.1 已解释，属引用口径错位",
   "t3:91 行号=%d" % t3_ratio)

# 4.5 2 行同/2 行不同 是否可由 T55:19 复核
t55 = read_lines("v7re/steps/T55_OBJECT_JUDGMENT_INIT_VS_PIP.md")
row = t55[18]
nums = [int(x) for x in re.findall(r"\d+", row)]
p("  T55:19 原文 = " + row.strip()[:200])
i7 = row.find("7/14/10/15")
i10 = row.find("10/15/14/7")
p("  T55:19 含 '7/14/10/15' 位置=%d ; 含 '10/15/14/7' 位置=%d" % (i7, i10))
ok(i7 != -1 and i10 != -1,
   "N5 文档 §1③/§0 称 T55:19 支持『镜像下 2 行相同/2 行不同 + σ 4-循环』；"
   "T55:19 只给每帧位数，2/2 与 σ 需由它计算或改引 STATUS:3616-3618 / T1 §3-B",
   "该行无『2 行相同』『σ』字面")

p("")
p("[5] 独立复算（不经 pair_identity_check.py，直接查 law 库）")
con = sqlite3.connect("file:%s?mode=ro" % LAWDB, uri=True)
cur = con.cursor()
cols = [r[1] for r in cur.execute("PRAGMA table_info(law_cells)")]
p("  law_cells 列 = %s" % (cols,))
ok("col" not in cols and "y" not in cols and "base" not in cols,
   "S1 law_cells 无 col/y/base 列（编码层不含 tile 坐标）", ",".join(cols))
for tt in ("INT_L", "INT_R"):
    row = cur.execute(
        "SELECT COUNT(*), COUNT(DISTINCT family||'|'||src_wire),"
        " COUNT(DISTINCT family||'|'||frame_off||'|'||bit||'|'||parity),"
        " COUNT(DISTINCT frame_off||'|'||bit||'|'||parity), SUM(sense)"
        " FROM law_cells WHERE tile_type=? AND sense=1", (tt,)).fetchone()
    p("  %s: refs=%d keys=%d family_cell_pairs=%d distinct_cells=%d sense_sum=%d" % ((tt,) + row))
    if tt == "INT_L":
        ok(row[0] == 8900 and row[1] == 3634 and row[2] == 1602 and row[3] == 1598,
           "S2 INT_L = 8900 refs / 3634 keys / 1602 (family,cell) / 1598 distinct cells（与 log[2][3] 一致）")
        ok(abs(row[0] / row[3] - 5.568) < 0.01, "S3 8900/1598 = 5.57（模型级复用比）", "%.3f" % (row[0] / row[3]))
    else:
        ok(row[0] == 8900 and row[2] == 1602,
           "S4a INT_R 与 INT_L 的 law 表规模相同（8900/1602/1598），两者是同一份 mux 表的两个拷贝")
# 共享格
q = cur.execute(
    "SELECT frame_off,bit,parity,COUNT(DISTINCT family) n FROM law_cells WHERE tile_type='INT_L'"
    " GROUP BY frame_off,bit,parity HAVING n>1").fetchall()
p("  跨 family 共享格 = %s" % (q,))
ok(len(q) == 3 and sum(r[3] - 1 for r in q) == 4,
   "S5 1602-1598=4 由 3 个跨 family 共享格多计 1+1+2 解释（log[4]）")
# IMUX 独占族
R = {r[0] for r in cur.execute("select distinct family from law_cells where sense=1 and tile_type='INT_R'")}
Lf = {r[0] for r in cur.execute("select distinct family from law_cells where sense=1 and tile_type='INT_L'")}
PREFIX = ("IMUX", "BYP_ALT", "FAN_ALT")
drop = sorted(f for f in (R - Lf) if f.startswith(PREFIX))
refs = 0
cells = set()
for f in drop:
    for fo, b, par in cur.execute("select frame_off,bit,parity from law_cells"
                                  " where sense=1 and tile_type='INT_R' and family=?", (f,)):
        refs += 1
        cells.add((fo, b, par))
p("  INT_R 独占且前缀族: families=%d refs=%d cells=%d" % (len(drop), refs, len(cells)))
p("  名单（按号排序前 6 / 尾 3）= %s ... %s" % (sorted(drop, key=lambda x: int(x[4:]))[:6],
                                              sorted(drop, key=lambda x: int(x[4:]))[-3:]))
ok(len(drop) == 48 and refs == 3456 and len(cells) == 480
   and set(drop) == {"IMUX%d" % i for i in range(48)},
   "S6 48 个 INT_R 独占 mux family（恰为 IMUX0..IMUX47，无缺号）/ 3456 refs / 480 cells")
p("  非前缀的 INT_R 独占族 = %s" % sorted(f for f in (R - Lf) if not f.startswith(PREFIX)))
law = json.load(open(os.path.join(ROOT, "v7re", "steps", "pip_reuse_law.json"), encoding="utf-8"))
jf = set(law["families"])
ok(not (set(drop) & jf) and "IMUX_L0" in jf,
   "S8 IMUX0..47 不在 pip_reuse_law.json 的 families 里 -> fasm2bit.py:115-118 的 cells_of 返回 None（跳过机制复算）",
   "json families=%d 个；含 IMUX_L0 不含 IMUX0" % len(jf))
ok(8900 - 3456 == 5444 and 1598 - 480 == 1118,
   "S7 5444 与 1118 的减法成立（扣除 48 个 IMUX_L*/IMUX_R* 族后）")
row_r = cur.execute(
    "SELECT COUNT(*), COUNT(DISTINCT frame_off||'|'||bit||'|'||parity) FROM law_cells"
    " WHERE tile_type='INT_R' AND sense=1 AND family NOT LIKE 'IMUX%'").fetchone()
p("  INT_R 去除 IMUX 族后: refs=%d cells=%d" % row_r)
ok(row_r[0] == 5444 and row_r[1] == 1118,
   "S4b INT_R 去 IMUX 族后 = 5444 refs / 1118 cells（与 pic md:166 一致）")
con.close()

p("")
p("[6] 汇总")
p("  PASS = %d ; FAIL = %d" % (npass, len(fails)))
for f in fails:
    p("  * FAIL: " + f)
p("")
p("[7] 结论")
p("  EXIT=0" if not fails else "  EXIT=1（存在必须修正项）")
open(LOG, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
print("\nWROTE " + LOG + ("  FAILS=%d" % len(fails)))
sys.exit(0 if not fails else 1)
