#!/bin/bash
export LANG=C LC_ALL=C
for d in /opt/lzh/v7re/work/hclk4 /opt/lzh/v7re/work/hclk5 /opt/lzh/v7re/work/hclk6; do
  echo "== $d"
  ls -1 "$d/out" 2>/dev/null | head -20
  echo "-- bits:"
  find "$d" -maxdepth 3 -name '*.bit' -printf '%p %s\n' 2>/dev/null | head -20
  echo "-- pips:"
  find "$d" -maxdepth 3 -name '*.pips' -printf '%p %s\n' 2>/dev/null | head -8
done
