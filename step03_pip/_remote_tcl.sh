cd /opt/lzh/v7re/work/clkmux3/out
echo "=== y2_s0.tcl ==="
cat -v y2_s0.tcl | sed -n '1,80p'
echo "=== pips y2_s0 (clk lines) ==="
grep -i -E "HROW|BUFG|BUFH" y2_s0.pips | head -12
echo "=== pips y1_s0 (clk lines) ==="
grep -i -E "HROW|BUFG|BUFH" y1_s0.pips | head -12
