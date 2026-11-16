#!/bin/bash
set -u
export LANG=C LC_ALL=C HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cd /opt/lzh/step03/s8
$VIV -mode batch -source s8_route.tcl -log s8_route.log -journal s8_route.jou > s8_route.out 2>&1
md5sum s8_v0.bit
echo S8_ROUTE_JOB_DONE
