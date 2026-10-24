#!/bin/bash
cd /opt/lzh/step03/pip2
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
cp /mnt/c/Users/S.tschai/pip_edit20.py .
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 DROP=2 /opt/lzh/venv/bin/python pip_edit20.py > edit20b.log 2>&1
echo "edit rc=$?"; grep dropped edit20b.log
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs b20.dcp b20.bit -log bitb20.log -journal bitb20.jou > bitb20.out 2>&1
echo "bit rc=$?"
/opt/lzh/venv/bin/python /mnt/c/Users/S.tschai/diff20.py
