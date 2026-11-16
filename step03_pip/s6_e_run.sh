#!/bin/bash
set -u
export LANG=C LC_ALL=C HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cd /opt/lzh/step03/s5

$VIV -mode batch -notrace -source s5_build.tcl -tclargs e_both \
  -log s5_e_both.log > s5_e_both.out 2>&1
[ -f s5_e_both.bit ] && echo "OK e_both" || { echo FAIL; tail -15 s5_e_both.out; }

/opt/lzh/venv/bin/python /opt/lzh/step03/s5/s6_e_dump.py
