cd /opt/lzh/v7re/work/clkmux3/out
for f in y1_s0 y2_s0 y4_s0; do
  echo "=== $f ==="
  grep -c HROW $f.pips
  grep -E 'MUX_OUT' $f.pips | head -6
done
