set -u
for d in reuse reuse3 reuse4 reuse5 reuse6 tilepipe pip1 pip2; do
  p=/opt/lzh/step03/$d
  [ -d $p ] || continue
  echo "===== $d ====="
  echo "-- top level --"; ls -lt --time-style=+%F_%T $p | sed -n '1,12p'
  echo "-- counts --"; find $p -maxdepth 2 -type f | wc -l
  for ext in dcp bo bit json md csv log py sh; do
    n=$(find $p -maxdepth 2 -name "*.$ext" | wc -l); [ $n -gt 0 ] && echo "  *.$ext = $n"
  done
  echo "-- newest 5 --"; find $p -maxdepth 2 -type f -printf '%TY-%Tm-%Td %TH:%TM %p\n' | sort -r | sed -n '1,5p'
done
echo "===== running procs ====="; ps aux | grep -Ei 'vivado|python3|v7re' | grep -v grep | sed -n '1,15p'