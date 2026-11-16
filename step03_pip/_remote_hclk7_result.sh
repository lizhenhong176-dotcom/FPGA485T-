export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/hclk7
echo "== status"; cat $D/out/status.txt 2>/dev/null
echo "== bits"; ls -la $D/out/*.bit 2>/dev/null
echo "== logs tail"; for v in def y0 y6 y12 y18; do echo "-- $v"; tail -3 $D/out/m_$v.log 2>/dev/null; done
echo "== hclk pips"; for v in def y0 y6 y12 y18; do echo "-- $v"; grep -a "HCLK_CMT" $D/out/m_$v.pips 2>/dev/null | head -4; done
echo "== bufh pips"; for v in def y0 y6 y12 y18; do echo "-- $v"; grep -a "BUFH" $D/out/m_$v.pips 2>/dev/null | head -3; done
