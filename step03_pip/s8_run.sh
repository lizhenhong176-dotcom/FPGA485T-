#!/bin/bash
set -u
export LANG=C LC_ALL=C HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cd /opt/lzh/step03/s8
$VIV -mode batch -source s8_build.tcl -log s8.log -journal s8.jou > s8_run.out 2>&1
/opt/lzh/venv/bin/python /opt/lzh/step03/s8/s8_dump.py
echo S8_ALL_DONE
