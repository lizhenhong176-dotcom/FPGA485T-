#!/bin/bash
for d in /opt/lzh/step03/colscan/*/; do
  n=$(ls $d/v_*.bit 2>/dev/null | wc -l)
  echo "DIR $d bits=$n"
  ls $d/*.bo 2>/dev/null | head -3
done
echo "=== json ==="
ls /mnt/c/Users/S.tschai/col_*.json 2>/dev/null
echo "=== build tail c9 ==="
tail -4 /opt/lzh/step03/colscan/c9/C9.bo 2>/dev/null
