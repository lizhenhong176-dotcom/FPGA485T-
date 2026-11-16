for d in hclk4 hclk5 hclk6 hclk8; do
  p=/opt/lzh/v7re/work/$d/out
  [ -d "$p" ] || continue
  echo "=== $d ==="
  grep -l "CLK_HROW" $p/*.pips 2>/dev/null | head -4
  grep -h "CLK_HROW_CK_MUX_OUT" $p/*.pips 2>/dev/null | sed 's/.*CLK_HROW_BOT_R\.//; s/.*CLK_HROW_TOP_R\.//' | sort | uniq -c | sort -rn | head -6
done