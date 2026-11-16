#!/bin/bash
export LANG=C LC_ALL=C
echo "== v7re 目录"
ls -1 /opt/lzh/v7re 2>/dev/null | head -20
echo "== bitstream 包"
ls -1 /opt/lzh/v7re/bitstream 2>/dev/null
echo "== python"
which python3; python3 -V
echo "== 解析器自检"
cd /opt/lzh/v7re 2>/dev/null && python3 - <<'PY'
import sys
sys.path.insert(0, '/opt/lzh/v7re')
try:
    from bitstream import parser as P
    print("parser ok:", [x for x in dir(P) if not x.startswith('_')][:12])
except Exception as e:
    print("import fail:", e)
PY
