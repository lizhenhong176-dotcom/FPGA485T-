# -*- coding: utf-8 -*-
"""T6 独立复跑：把 pair_identity_check.py 跑两遍到全新目录 _t6_clean2，比较 sha256。
只读仓库产物 + 新建 _t6_clean2/ 与 v7re/steps/t6_rerun2.log，不修改任何既有文件。
用法：python v7re/steps/t6_rerun2.py
"""
import os, subprocess, hashlib, time, shutil, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.chdir(ROOT)
CLEAN = os.path.join(ROOT, "_t6_clean2")
if os.path.isdir(CLEAN):
    shutil.rmtree(CLEAN)
os.makedirs(CLEAN)
LOG = os.path.join(ROOT, "v7re", "steps", "t6_rerun2.log")
out = []


def p(s=""):
    out.append(s)
    print(s)


def sha(fp):
    return hashlib.sha256(open(fp, "rb").read()).hexdigest()


p("[1] 复跑环境（T6 独立复跑；输出写入全新目录 _t6_clean2，不覆盖仓库产物）")
p("  ROOT = %s" % ROOT)
p("  python = %s" % sys.version.split()[0])
p("  pair_identity_check.py sha256 = %s" % sha(os.path.join(ROOT, "pair_identity_check.py")))

runs = []
for i in (1, 2):
    md = os.path.join(CLEAN, "pic_run%d.md" % i)
    js = os.path.join(CLEAN, "pic_run%d.json" % i)
    cmd = [sys.executable, "pair_identity_check.py", "--out-md", md, "--out-json", js]
    t0 = time.time()
    r = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    el = time.time() - t0
    runs.append((i, cmd, r.returncode, el, md, js, r.stdout))
    p("")
    p("[2.%d] run%d  EXIT=%d  elapsed=%.1f s" % (i, i, r.returncode, el))
    p("  cmd = %s" % " ".join(cmd))
    p("  sha256 md   = %s" % (sha(md) if os.path.exists(md) else "MISSING"))
    p("  sha256 json = %s" % (sha(js) if os.path.exists(js) else "MISSING"))

repo_md = os.path.join(ROOT, "v7re", "steps", "pair_identity_check.md")
repo_js = os.path.join(ROOT, "v7re", "steps", "pair_identity_check.json")
p("")
p("[3] 与仓库在库产物逐字节比对")
p("  repo md   sha256 = %s" % sha(repo_md))
p("  repo json sha256 = %s" % sha(repo_js))
r1md = open(runs[0][4], "rb").read()
r2md = open(runs[1][4], "rb").read()
repo = open(repo_md, "rb").read()
for i, cmd, rc, el, md, js, so in runs:
    p("  run%d md   == repo md  : %s (%d vs %d bytes)" % (i, open(md, "rb").read() == repo, len(open(md, "rb").read()), len(repo)))
    p("  run%d json == repo json: %s" % (i, open(js, "rb").read() == open(repo_js, "rb").read()))
p("  run1 md == run2 md : %s" % (r1md == r2md))

p("")
p("[4] stdout 关键行（run2；run1 与 run2 stdout 相同性见 [5]）")
for ln in runs[1][6].split("\n"):
    if ln.strip():
        p("  | " + ln.rstrip())

p("")
p("[5] 结论行")
same_stdout = runs[0][6] == runs[1][6]
p("  EXIT 全为 0 = %s ; run1/run2 md 逐字节相同 = %s ; run1 md 与仓库 md 逐字节相同 = %s ; stdout 相同 = %s"
  % (all(r[2] == 0 for r in runs), r1md == r2md, r1md == repo, same_stdout))
open(LOG, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
print("\nWROTE " + LOG)
