export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/hclkall
cd $D || exit 1
for t in m12 m13 p12 p13; do
  grep -q "CLOCK_DEDICATED_ROUTE FALSE \[get_nets clk\]" $t.tcl || sed -i 's|^set_property CLOCK_DEDICATED_ROUTE FALSE \[get_nets c\]|set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets c]\nset_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]\nset_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]|' $t.tcl
done
ls m12.tcl >/dev/null && grep -c CLOCK_DEDICATED_ROUTE m12.tcl
for t in m12 m13 p12 p13; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1 &
done
wait
for t in m12 m13 p12 p13; do
  if grep -q "DONE_$t" $t.log; then echo "OK $t"; else echo "FAIL $t :: $(grep -m1 'ERROR:' $t.log | cut -c1-160)"; fi
done
cd $D && tar czf /tmp/hclkall_out.tgz *.bit *.pips 2>/dev/null
echo HADONE2
