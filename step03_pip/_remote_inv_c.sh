for d in bufgmux clkmux clkmux2 clkmux3 clkin clkin2 clk clk3 aoutmux aoutmux2 hclk hclk2 hclk3; do
  p=/opt/lzh/v7re/work/$d
  [ -d "$p" ] || continue
  echo "-- $d"
  ls -1 "$p" | head -10 | tr '\n' ' '
  echo
  find "$p" -maxdepth 2 -name "*.bit" -printf "   bit %s %f\n" 2>/dev/null | head -6
done