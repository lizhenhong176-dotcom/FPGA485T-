#!/bin/bash
cd /opt/lzh/step03/pip1 || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
for D in 2 3; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs b_d$D.dcp b_d$D.bit -log bitb_$D.log -journal bitb_$D.jou > bitb_$D.out 2>&1
  echo "D=$D rc=$?"
done
ls -l b_d*.bit
