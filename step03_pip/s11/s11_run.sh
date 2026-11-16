#!/bin/bash
cd /opt/lzh/step03/s11
export PATH=/opt/lzh/Xilinx/Vivado/2017.2/bin:$PATH
export HOME=/root
export LANG=C LC_ALL=C
for v in r64s srl32 r128 r256 r64d r64d_bd r64s_we0 f5a f5b r64m; do
  if [ -f s11_$v.bit ]; then echo "SKIP $v"; continue; fi
  vivado -mode batch -nojournal -nolog -source s11_build.tcl -tclargs $v > s11_$v.log 2>&1
  echo "DONE $v rc=$?"
done
