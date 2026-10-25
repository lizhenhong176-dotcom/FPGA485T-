#!/bin/bash
set -u
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
BASE=/opt/lzh/step03/colscan; mkdir -p $BASE
for COL in 9 11 12 13; do
  R=$BASE/c$COL; mkdir -p $R; cd $R || exit 1
  SX=$((2*COL-4)); SL=SLICE_X${SX}Y11
  cp /opt/lzh/step03/pip2/top_y20.v top_y20.v
  cp /opt/lzh/step03/pip1/bit_any.tcl .
  cp /mnt/c/Users/S.tschai/build_bel.tcl /mnt/c/Users/S.tschai/p6_make2.py .
  TAG=C$COL
  $V -mode batch -notrace -source build_bel.tcl -tclargs A5 $SL A6LUT $TAG -log $TAG.bl -journal $TAG.j > $TAG.bo 2>&1
  grep -q BEL_DONE $TAG.bo || { echo "FAILBUILD col=$COL"; tail -3 $TAG.bo; continue; }
  $V -mode batch -notrace -source bit_any.tcl -tclargs $TAG.dcp ref_$TAG.bit -log ref$TAG.bl > ref$TAG.bo 2>&1
  DCP=$TAG.dcp EDF=$TAG.edf OUT=$R TAG=$TAG /opt/lzh/venv/bin/python p6_make2.py > mk_$TAG.log 2>&1
  ls v_$TAG\_*.dcp | xargs -P 12 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
  COL=$COL TAG=$TAG R=$R /opt/lzh/venv/bin/python /mnt/c/Users/S.tschai/col_diff.py
done
echo ALLDONE
