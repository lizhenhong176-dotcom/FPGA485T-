#!/bin/bash
cd /opt/lzh/step05
export HOME=/root; export LANG=C; export LC_ALL=C
export XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic
for j in q1 q2 q3 q4; do
  ( JOB=$j /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_r.tcl > dsp/log_r_$j.txt 2>&1; echo "rc=$? job=$j" ) &
done
wait
ls -l dsp/r*.bit dsp/pips_*.tsv
