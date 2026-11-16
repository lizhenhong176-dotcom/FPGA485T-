# -*- coding: utf-8 -*-
"""修 diff_e3.py 的 Type2 计数掩码（Type2 用 27 位计数，不是 11 位），生成 _e3_diff2.sh。"""
import re

OLD = """        if typ == 2:
            out.extend(words[k:k + cnt])
            k += cnt
            continue"""
NEW = """        if typ == 2:
            c27 = h & 0x7FFFFFF
            out.extend(words[k:k + c27])
            k += c27
            continue"""

src = open("_e3_run.sh", encoding="utf-8").read()
m = re.search(r"cat > diff_e3\.py <<'PYEOF'\n(.*?)\nPYEOF", src, re.S)
py = m.group(1)
assert OLD in py
py = py.replace(OLD, NEW)
py = py.replace(
    'd = os.path.dirname(os.path.abspath(sys.argv[1])) if len(sys.argv) > 1 else "."',
    'd = sys.argv[1] if len(sys.argv) > 1 else "."')
assert "c27 = h & 0x7FFFFFF" in py

open("_e3_diff_e3.py", "w", encoding="utf-8", newline="\n").write(py + "\n")
# 同步把修好的版本写回 _e3_run.sh（存档一致性）
src2 = src.replace(OLD, NEW).replace(
    'd = os.path.dirname(os.path.abspath(sys.argv[1])) if len(sys.argv) > 1 else "."',
    'd = sys.argv[1] if len(sys.argv) > 1 else "."')
open("_e3_run.sh", "w", encoding="utf-8", newline="\n").write(src2)

sh = []
sh.append("set -u")
sh.append("export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE")
sh.append("export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64")
sh.append("D=/opt/lzh/v7re/work/e3; cd $D || exit 1")
sh.append("cat > diff_e3.py <<'PYEOF'\n" + py + "\nPYEOF")
sh.append("PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3")
sh.append("$PY diff_e3.py . e3_base,e3_a,e3_b,e3_c,e3_d,e3_e 2>diff.err > diff.json")
sh.append("echo ERR_BEGIN; cat diff.err; echo ERR_END")
sh.append("echo E3DIFF_JSON_BEGIN")
sh.append("cat diff.json")
sh.append("echo E3DIFF_JSON_END")
sh.append("echo E3DONE")
open("_e3_diff2.sh", "w", encoding="utf-8", newline="\n").write("\n".join(sh) + "\n")
print("patched: Type2 count = 27 bits; wrote _e3_diff2.sh and _e3_diff_e3.py")
