#!/bin/bash
set -e
mkdir -p /opt/lzh/step03/pip2
cp /mnt/c/Users/S.tschai/top_y20.v /mnt/c/Users/S.tschai/top_y20.xdc /mnt/c/Users/S.tschai/build20.tcl /mnt/c/Users/S.tschai/pip_edit20.py /opt/lzh/step03/pip2/
cd /opt/lzh/step03/pip2
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source build20.tcl -log build20.log -journal build20.jou > build20.out 2>&1
echo "build rc=$?"
grep -E "BUILD20_DONE|ERROR" build20.out | head -3
cp /opt/lzh/step03/pip1/bit_any.tcl .
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs routed20.dcp a20.bit -log bita20.log -journal bita20.jou > bita20.out 2>&1
echo "bita rc=$?"
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 /opt/lzh/venv/bin/python pip_edit20.py > edit20.log 2>&1
echo "edit rc=$?"
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs b20.dcp b20.bit -log bitb20.log -journal bitb20.jou > bitb20.out 2>&1
echo "bitb rc=$?"
ls -l a20.bit b20.bit
