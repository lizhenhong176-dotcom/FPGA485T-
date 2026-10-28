#!/usr/bin/env python3
"""patch_pip_law.py —— P0b：把长线族实测位覆盖写进 pip_law.py。"""
import re

P = "/opt/lzh/verify/step03_pip/pip_law.py"
src = open(P, encoding="utf-8").read()

OVERRIDE = '''
# ---------------------------------------------------------------- P0b 长线族
# artix7 迁移值在 V7 上错位（见 P0B_LONG_LINE.md）。实测 262/262 归因：
#   frame = block_start(col, Y) + off（off ∈ {0,1}），word = _word(Y, 0)，
#   LV 驱动 = (0,b9)+(1,b6)；LH 驱动 = (0,b2)+(1,b6)。
LL_OVERRIDE = {
    ("INT_L", "LV_L18", "LV_L0"): [(0, 9, 1, 0), (1, 6, 1, 0)],
    ("INT_L", "LH0", "LV_L0"): [(0, 2, 1, 0), (1, 6, 1, 0)],
    ("INT_R", "LV18", "LV0"): [(0, 9, 1, 0), (1, 6, 1, 0)],
    ("INT_R", "LH0", "LV0"): [(0, 2, 1, 0), (1, 6, 1, 0)],
}
_ALL.update(LL_OVERRIDE)
'''

if "LL_OVERRIDE" in src:
    print("already patched")
    raise SystemExit(0)
m = re.search(r"^_ALL = load_all\(\)\s*$", src, re.M)
if not m:
    # find any module-level _ALL assignment
    m = re.search(r"^_ALL = .*$", src, re.M)
assert m, "no _ALL assignment found"
src = src[:m.end()] + "\n" + OVERRIDE + src[m.end():]
open(P, "w", encoding="utf-8").write(src)
print("patched at line", src[:m.end()].count("\n") + 1)
