export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clbdmux
rm -rf $D; mkdir -p $D
tar xzf /tmp/clbdmux.tgz -C $D --strip-components=1
cd $D
ls
for t in v1_dlut v2_dcout v3_both; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1
  if grep -q "DONE_$t" $t.log; then echo "OK $t"; grep "^CHK" $t.log || true; else echo "FAIL $t"; tail -n 7 $t.log; fi
done
tar czf /tmp/clbdmux_out.tgz *.bit *.pips 2>/dev/null || true
echo DMUXDONE
