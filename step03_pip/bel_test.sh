#!/bin/bash
set -u
R=/opt/lzh/step03/reuse4; mkdir -p $R; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C
cp /opt/lzh/step03/pip2/top_y20.v .
cp /mnt/c/Users/S.tschai/build_bel.tcl .
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source build_bel.tcl -tclargs A1 SLICE_X9Y11 A6LUT -log t.log -journal t.jou > t.out 2>&1
echo rc=$?; grep -E "BEL_DONE|ERROR" t.out | head -5
