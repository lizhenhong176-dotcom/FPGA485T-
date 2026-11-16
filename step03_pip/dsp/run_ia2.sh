#!/bin/bash
cd /opt/lzh/step05
export HOME=/root; export LANG=C; export LC_ALL=C
export XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic
for j in p1 p2 p3; do
  JOB=$j /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_ia2.tcl > dsp/log_ia2_$j.txt 2>&1
  echo "rc=$? job=$j"
done
ls -l dsp/ia2_*.bit
