#!/bin/bash
cd /opt/lzh/step05
export HOME=/root; export LANG=C; export LC_ALL=C
export XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic
for v in 0 1; do
  sed -e "s#dsp/d_\$v.v#dsp/ia_$v.v#" -e "s#dsp/out_\$v.bit#dsp/ia_$v.bit#" dsp/build.tcl > dsp/build_ia_$v.tcl
  V=$v /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_ia_$v.tcl > dsp/log_ia_$v.txt 2>&1
  echo "rc=$? v=$v"
done
ls -l dsp/ia_*.bit
