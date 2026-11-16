cd /opt/lzh/v7re/work/p1
for n in d5_srl d7_spread d8_dense; do echo "== $n"; grep -m3 -E "^ERROR|ERROR: \[" out/$n.log | head -3; done