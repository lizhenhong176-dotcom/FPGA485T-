#!/bin/bash
cd /opt/lzh/step03/tilepipe3 || exit 1
ls ref_*.bo 2>/dev/null | head -2
for f in ref_*.bo; do echo "== $f"; grep -i -m3 -E "error|ERROR" "$f" || echo "(no error line)"; done 2>/dev/null | head -12
echo "--- ref dcp list"
ls -l ref_*.dcp | head -3
