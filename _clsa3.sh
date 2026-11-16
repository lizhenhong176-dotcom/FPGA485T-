export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clsa; cd $D || exit 1
for f in p1a p1b p2a p2b; do
  sed -i 's/set_property CFGBVS VCCO/set_property CFGBVS GND/' ${f}.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source ${f}.tcl > ${f}.log 2>&1
  if grep -q "DONE_${f}" ${f}.log; then echo "OK ${f}"; grep -E "^CHK_PIN|^CHKPIP" ${f}.log | head -8; else echo "FAIL ${f}"; grep -m1 ERROR ${f}.log; fi
done
tar czf /tmp/clsa2.tgz *.bit 2>/dev/null && echo TAROK
echo CLSA2_DONE