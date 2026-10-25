#!/bin/bash
set -u
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
R=/opt/lzh/step03/tilepipe4; mkdir -p $R; cd $R || exit 1
cp /opt/lzh/step03/pip2/top_y20.v .
cp /opt/lzh/step03/pip1/bit_any.tcl .
cp /mnt/c/Users/S.tschai/build_bel.tcl /mnt/c/Users/S.tschai/p6_make2.py .
[ -f refs_ok ] && { echo REFS_EXIST; } || {
for LUT in SLICE_X14Y11:A6LUT SLICE_X14Y11:B6LUT SLICE_X15Y11:A6LUT SLICE_X15Y11:B6LUT SLICE_X15Y11:C6LUT SLICE_X15Y11:D6LUT; do
  SL=${LUT%%:*}; BE=${LUT##*:}
  for PIN in A1 A2 A3 A4 A5 A6; do
    TAG=Q_${SL#SLICE_}_${BE}_${PIN}
    $V -mode batch -notrace -source build_bel.tcl -tclargs $PIN $SL $BE $TAG -log $TAG.bl -journal $TAG.j > $TAG.bo 2>&1
    grep -q BEL_DONE $TAG.bo || { echo "BUILDFAIL $TAG"; continue; }
    $V -mode batch -notrace -source bit_any.tcl -tclargs $TAG.dcp ref_$TAG.bit -log ref$TAG.bl > ref$TAG.bo 2>&1
    DCP=$TAG.dcp EDF=$TAG.edf OUT=$R TAG=$TAG /opt/lzh/venv/bin/python p6_make2.py > mk_$TAG.log 2>&1
  done
done
touch refs_ok
}
ls -d v_*.dcp | wc -l
echo MAKEDONE
ls v_*.dcp | xargs -P 12 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
ls v_*.bit | wc -l
echo BITS_DONE
