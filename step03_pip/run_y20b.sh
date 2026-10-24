#!/bin/bash
cd /opt/lzh/step03/pip2
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
cp /opt/lzh/step03/pip1/bit_any.tcl .
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs routed20.dcp a20.bit -log bita20.log -journal bita20.jou > bita20.out 2>&1
echo "bita rc=$?"
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 /opt/lzh/venv/bin/python pip_edit20.py > edit20.log 2>&1
echo "edit rc=$?"
grep -E "base pips|wrote|Error|Traceback" edit20.log | head -5
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs b20.dcp b20.bit -log bitb20.log -journal bitb20.jou > bitb20.out 2>&1
echo "bitb rc=$?"
ls -l a20.bit b20.bit 2>&1
