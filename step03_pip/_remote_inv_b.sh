set -e
echo "== work dirs =="
ls -d /opt/lzh/v7re/work/*/ 2>/dev/null | head -40
echo "== bit files (size, path) =="
find /opt/lzh/v7re/work -maxdepth 3 -name "*.bit" -printf "%s %p\n" 2>/dev/null | sort -k2 | head -60
echo "== tcl / design per dir =="
for d in /opt/lzh/v7re/work/hclk6 /opt/lzh/v7re/work/hclk7 /opt/lzh/v7re/work/hclk8; do
  echo "-- $d"; ls -1 $d 2>/dev/null | head -20
done
