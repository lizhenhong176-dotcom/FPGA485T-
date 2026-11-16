export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/hclk48
cd $D || exit 1
rm -f *.log *.bit *.pips
printf '%s\n' m0 m1 m2 m3 m4 m5 m6 p0 p1 p2 p3 p4 p5 | xargs -P 13 -I{} sh -c '/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source {}.tcl > {}.log 2>&1 && grep -q DONE_{} {}.log && echo "OK {}" || echo "FAIL {}"'
tar czf /tmp/hclk48_out.tgz *.bit *.pips 2>/dev/null
echo HCLK48DONE
