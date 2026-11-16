# -*- coding: utf-8 -*-
"""从 _e3_run.sh 抽出 diff_e3.py（修掉 dirname('.') 的路径 bug），生成只跑差分的脚本。"""
import re

src = open("_e3_run.sh", encoding="utf-8").read()
m = re.search(r"cat > diff_e3\.py <<'PYEOF'\n(.*?)\nPYEOF", src, re.S)
py = m.group(1)
old = 'd = os.path.dirname(os.path.abspath(sys.argv[1])) if len(sys.argv) > 1 else "."'
new = 'd = sys.argv[1] if len(sys.argv) > 1 else "."'
assert old in py, py[:800]
py = py.replace(old, new)
open("_e3_diff_e3.py", "w", encoding="utf-8", newline="\n").write(py + "\n")

sh = []
sh.append("set -u")
sh.append("export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE")
sh.append("export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64")
sh.append("D=/opt/lzh/v7re/work/e3; cd $D || exit 1")
sh.append("ls -1 *.bit")
sh.append("PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3")
sh.append("cat > diff_e3.py <<'PYEOF'\n" + py + "\nPYEOF")
sh.append("$PY diff_e3.py . e3_base,e3_a,e3_b,e3_c,e3_d,e3_e 2>diff.err > diff.json")
sh.append("echo ERR_BEGIN; cat diff.err; echo ERR_END")
sh.append("echo E3DIFF_JSON_BEGIN")
sh.append("cat diff.json")
sh.append("echo E3DIFF_JSON_END")
sh.append("echo E3DONE")
open("_e3_diff.sh", "w", encoding="utf-8", newline="\n").write("\n".join(sh) + "\n")
print("wrote _e3_diff.sh; patched line:", new)
