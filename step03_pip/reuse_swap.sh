#!/bin/bash
set -u
mkdir -p /opt/lzh/step03/reuse
cd /opt/lzh/step03/reuse || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
P1=/opt/lzh/step03/pip1
cp -f $P1/routed.dcp base.dcp
cp -f $P1/top.edf base.edf
cp -f $P1/bit_any.tcl .
for S in BYP_BOUNCE_N3_2 BYP_BOUNCE_N3_6 EE2END0 EL1END0 ER1END_N3_3 FAN_BOUNCE2 FAN_BOUNCE7 GFAN0 LOGIC_OUTS_L0 LOGIC_OUTS_L12 LOGIC_OUTS_L22 NE2END0 NL1END0 NN2END0 NR1END0 NW2END0 SE2END0 SL1END0 SR1END_N3_3 SS2END_N0_3 SW2END_N0_3 VCC_WIRE WL1END_N1_3 WR1END0 WW2END_N0_3; do
  SRC=$S DCP=base.dcp EDF=base.edf OUT=v_$S.dcp /opt/lzh/venv/bin/python /mnt/c/Users/S.tschai/swap_source.py > swap_$S.log 2>&1 || echo "SWAPFAIL $S"
done
echo "dcp=$(ls v_*.dcp 2>/dev/null | wc -l) logs=$(ls swap_*.log 2>/dev/null | wc -l)"
