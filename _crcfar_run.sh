#!/bin/bash
export LANG=C LC_ALL=C
mkdir -p /opt/lzh/v7re/work/crcfar && cd /opt/lzh/v7re/work/crcfar || exit 1
cp _fr_f0.v _fr_f0.tcl _fr_f1.v _fr_f1.tcl .
for t in f0 f1; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1
  if grep -q "DONE_$t" $t.log; then echo "OK $t"; else echo "FAIL $t"; tail -n 5 $t.log; fi
done
tar czf /tmp/crcfar.tgz *.bit 2>/dev/null && echo TARDONE
