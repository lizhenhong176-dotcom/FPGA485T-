#!/bin/bash
cd /opt/lzh/step03/tilepipe2 || exit 1
echo "refs_ok=$(ls ref_*.bit 2>/dev/null | wc -l)"
echo "ref_dcp=$(ls ref_*.dcp 2>/dev/null | wc -l)"
echo "missing_ref_example:"
for f in ref_*.dcp; do b="${f%.dcp}.bit"; [ -f "$b" ] || { echo "$f"; break; }; done
