export LANG=C LC_ALL=C
for d in c0 c1 c2 c3 c4 c5; do
  echo "=== $d"; grep -m3 "^ERROR" /opt/lzh/v7re/work/clk/$d/build.log 2>/dev/null || echo "  (no ERROR line)"
done