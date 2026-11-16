#!/bin/bash
cd /opt/lzh/step06
export HOME=/root; export LANG=C; export LC_ALL=C
export XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic
( JOB=iof_i50 /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build_iof.tcl > iof/log_i50.txt 2>&1; echo "rc=$? i50" ) &
( JOB=iof_i51 /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build_iof.tcl > iof/log_i51.txt 2>&1; echo "rc=$? i51" ) &
( JOB=iof_i52 /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build_iof.tcl > iof/log_i52.txt 2>&1; echo "rc=$? i52" ) &
( JOB=iof_i53 /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build_iof.tcl > iof/log_i53.txt 2>&1; echo "rc=$? i53" ) &
wait
ls iof/*.bit | wc -l
