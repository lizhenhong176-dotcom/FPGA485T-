#!/bin/bash
cd /opt/lzh/step06
export HOME=/root; export LANG=C; export LC_ALL=C
export XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic
( JOB=y50 /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build3.tcl > iof/log4_y50.txt 2>&1; echo "rc=$? y50" ) &
( JOB=y51 /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build3.tcl > iof/log4_y51.txt 2>&1; echo "rc=$? y51" ) &
wait
wc -l iof/pips_y50.tsv iof/pips_y51.tsv
