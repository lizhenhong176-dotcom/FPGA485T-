#!/bin/bash
cd /opt/lzh/step05
export HOME=/root; export LANG=C; export LC_ALL=C
export XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic
for j in gnd vcc port; do
  ( JOB=$j /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_dd.tcl > dsp/log_dd_$j.txt 2>&1; echo "rc=$? $j" ) &
done
wait
ls -l dsp/dd_*.bit
