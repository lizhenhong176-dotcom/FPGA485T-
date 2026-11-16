#!/bin/bash
set -u
export LANG=C LC_ALL=C HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
mkdir -p /opt/lzh/step03/s7
cd /opt/lzh/step03/s7

for v in A_d1 A_d2 B_d1 B_d2 C_d1 C_d2 D_d1 D_d2; do
  if [ ! -f s7_$v.bit ]; then
    $VIV -mode batch -notrace -source s7_build.tcl -tclargs $v \
      -log s7_$v.log > s7_$v.out 2>&1
    [ -f s7_$v.bit ] && echo "OK $v" || { echo "FAIL $v"; tail -12 s7_$v.out; }
  fi
done
/opt/lzh/venv/bin/python /opt/lzh/step03/s7/s7_dump.py
