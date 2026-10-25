#!/bin/bash
set -u
R=/opt/lzh/step03/tilepipe2; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cp /mnt/c/Users/S.tschai/p6_make2.py .
for dcp in SLICE_*.dcp; do
  case "$dcp" in ref_*|v_*) continue;; esac
  TAG=${dcp%.dcp}
  DCP=$dcp EDF=${TAG}.edf OUT=$R TAG=$TAG /opt/lzh/venv/bin/python p6_make2.py > mk2_$TAG.log 2>&1
  echo "MADE $TAG $(grep -o 'sink IMUX_L[0-9]*' mk2_$TAG.log | head -1)"
done
echo "vdcp=$(ls v_*.dcp 2>/dev/null | wc -l) refdcp=$(ls ref_*.dcp 2>/dev/null | wc -l)"
