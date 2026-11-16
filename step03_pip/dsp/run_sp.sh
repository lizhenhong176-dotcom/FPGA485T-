#!/bin/bash
cd /opt/lzh/step05
export HOME=/root; export LANG=C; export LC_ALL=C
export XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic
( JOB=sp_CEAD_gnd /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_CEAD_gnd.txt 2>&1; echo "rc=$? CEAD_gnd" ) &
( JOB=sp_CEAD_vcc /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_CEAD_vcc.txt 2>&1; echo "rc=$? CEAD_vcc" ) &
( JOB=sp_CEAD_port /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_CEAD_port.txt 2>&1; echo "rc=$? CEAD_port" ) &
( JOB=sp_RSTD_gnd /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_RSTD_gnd.txt 2>&1; echo "rc=$? RSTD_gnd" ) &
( JOB=sp_RSTD_vcc /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_RSTD_vcc.txt 2>&1; echo "rc=$? RSTD_vcc" ) &
( JOB=sp_RSTD_port /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_RSTD_port.txt 2>&1; echo "rc=$? RSTD_port" ) &
( JOB=sp_D1_gnd /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_D1_gnd.txt 2>&1; echo "rc=$? D1_gnd" ) &
( JOB=sp_D1_vcc /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_D1_vcc.txt 2>&1; echo "rc=$? D1_vcc" ) &
( JOB=sp_D1_port /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_D1_port.txt 2>&1; echo "rc=$? D1_port" ) &
( JOB=sp_INMODE0_gnd /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_INMODE0_gnd.txt 2>&1; echo "rc=$? INMODE0_gnd" ) &
( JOB=sp_INMODE0_vcc /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_INMODE0_vcc.txt 2>&1; echo "rc=$? INMODE0_vcc" ) &
( JOB=sp_INMODE0_port /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source dsp/build_sp.tcl > dsp/log_sp_INMODE0_port.txt 2>&1; echo "rc=$? INMODE0_port" ) &
wait
ls -l dsp/sp_*.bit | wc -l
