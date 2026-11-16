#!/bin/bash
export LANG=C LC_ALL=C
for d in hclk4 hclk5 hclk6; do
  echo "== $d"
  for f in /opt/lzh/v7re/work/$d/out/*.pips; do
    n=$(basename "$f" .pips)
    echo "-- $n"
    grep -a "HCLK_CMT" "$f" | head -6
  done
done
