#!/bin/bash
cd /opt/lzh/step05
export HOME=/root
export LANG=C
export LC_ALL=C
export XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic
for v in 1 2; do
  V=$v /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build.tcl > dsp/log_$v.txt 2>&1
  echo "rc=$? v=$v"
done
ls -l dsp/*.bit
