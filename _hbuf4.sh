export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/hbuf || exit 1
for t in d0 d1 d2; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1
  if grep -q "DONE_$t" $t.log; then echo "OK $t | $(grep CHK_BH $t.log | head -1)"; else echo "FAIL $t"; grep -E "ERROR|Aborted" $t.log | head -4; fi
done
tar czf /tmp/hbuf_out.tgz *.bit *.pips *.log 2>/dev/null || true
echo BUFDONE
