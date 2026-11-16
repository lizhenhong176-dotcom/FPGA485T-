export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/hclk8
echo "== tail n_0.log"; tail -25 $D/out/n_0.log
echo "== ERROR lines"; grep -a "^ERROR" $D/out/n_0.log | head -5
