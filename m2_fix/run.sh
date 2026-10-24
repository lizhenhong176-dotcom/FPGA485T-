#!/bin/bash
export XILINXD_LICENSE_FILE=/data/lzh/Xilinx/Vivado_license_2037.lic
/data/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -notrace -source build.tcl > build.log 2>&1
echo $? > rc
