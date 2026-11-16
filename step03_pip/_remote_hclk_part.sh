#!/bin/bash
# A0：核对远端 HCLK_CMT 构建用的器件型号 + tile 清单
export LANG=C LC_ALL=C
for d in /opt/lzh/v7re/work/hclk4 /opt/lzh/v7re/work/hclk5 /opt/lzh/v7re/work/hclk6; do
  echo "== $d"
  if [ -d "$d" ]; then
    ls -1 "$d" 2>/dev/null | head -12
    echo "-- PART in tcl/xdc:"
    grep -hoiE "xc7vx485t[a-z0-9-]*" "$d"/*.tcl "$d"/*.xdc 2>/dev/null | sort -u
    echo "-- PART in rpt/log:"
    grep -rhoiE "xc7vx485t[a-z0-9-]*" "$d"/*.rpt "$d"/*.log 2>/dev/null | sort | uniq -c | head -5
  else
    echo "(missing)"
  fi
done
echo "== 顶层 work 目录"
ls -1 /opt/lzh/v7re/work 2>/dev/null
