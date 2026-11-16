export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/hclk7
ls -la $D | head -20
echo "== out"; ls $D/out | head -30
echo "== q tcl"; for f in $D/out/q*.tcl; do echo "-- $f"; head -20 "$f"; done
echo "== q pips hclk"; for f in $D/out/q*.pips; do echo "-- $f"; grep -a "HCLK_CMT" "$f" | head -3; done
