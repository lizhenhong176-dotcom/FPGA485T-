#!/bin/bash
set -u
R=/opt/lzh/step03/reuse6; mkdir -p $R; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cp /opt/lzh/step03/pip1/bit_any.tcl .
cp /mnt/c/Users/S.tschai/p6_make.py .
cp /opt/lzh/step03/reuse3/p_A1.dcp /opt/lzh/step03/reuse3/p_A1.edf .
cp /opt/lzh/step03/reuse3/p_A2.dcp /opt/lzh/step03/reuse3/p_A2.edf .
for T in A1 A2; do
  DCP=p_$T.dcp EDF=p_$T.edf OUT=$R TAG=$T /opt/lzh/venv/bin/python p6_make.py > mk_$T.log 2>&1
  grep TAG mk_$T.log
done
ls v_*.dcp ref_*.dcp | xargs -P 12 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
echo "bits=$(ls v_*.bit | wc -l) refs=$(ls ref_*.bit | wc -l)"
