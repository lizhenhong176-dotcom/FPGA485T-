cd /opt/lzh/v7re/work
for pair in "bufgmux/out/s0sel bufgmux/out/s1sel" "clkmux3/out/y2_s0 clkmux3/out/y2_s1" "clkmux3/out/y4_s0 clkmux3/out/y4_s1" "clkmux3/out/y5_s0 clkmux3/out/y5_s1" "clkmux3/out/y6_s0 clkmux3/out/y6_s1" "clkmux3/out/y7_s0 clkmux3/out/y7_s1" "clkmux2/c0_s0 clkmux2/c0_s1" "clkmux2/c32_s0 clkmux2/c32_s1" "clkmux2/c40_s0 clkmux2/c40_s1" "clkmux2/c48_s0 clkmux2/c48_s1"; do
  set -- $pair
  a=$1; b=$2
  if [ -f "$a.pips" ] && [ -f "$b.pips" ]; then
    n=$(diff <(sort -u "$a.pips") <(sort -u "$b.pips") | grep -c '^[<>]')
    echo "$a vs $b : diff_lines=$n"
  else
    echo "$a vs $b : MISSING pips"
  fi
done