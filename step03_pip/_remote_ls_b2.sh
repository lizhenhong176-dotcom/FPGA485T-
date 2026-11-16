set -e
cd /opt/lzh/v7re/work/p1
for n in d8b_dense d9_wide d10_long d11_mix d12_fanout2; do
  if [ -f "out/$n.bit" ]; then
    echo "OK $n $(stat -c%s out/$n.bit) pips=$(wc -l < out/$n.pips)"
  else
    echo "MISSING $n"
  fi
done
