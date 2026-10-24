#!/bin/bash
set -u
cd /opt/lzh/step03/pip1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
for D in 0 2 3; do
  DROP=$D /opt/lzh/venv/bin/python pip_edit.py > edit_$D.log 2>&1 || { echo "edit fail $D"; continue; }
  cp b.dcp b_d$D.dcp
done
ls -l b_d*.dcp
for D in 0 2 3; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl \
     -tclargs b_d$D.dcp b_d$D.bit -log bitb_$D.log -journal bitb_$D.jou > bitb_$D.out 2>&1
  echo "D=$D rc=$? $(ls -l b_d$D.bit 2>/dev/null | awk '{print $5}')"
done

