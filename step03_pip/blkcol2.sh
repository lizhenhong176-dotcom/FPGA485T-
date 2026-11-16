#!/bin/bash
set -u
R=/opt/lzh/step03/blkcol2; mkdir -p $R; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cp /opt/lzh/step03/pip2/top_y20.v top_y20.v
cp /opt/lzh/step03/pip1/bit_any.tcl .
cp /mnt/c/Users/S.tschai/build_bel.tcl .
cp /mnt/c/Users/S.tschai/p6_make2.py .
$V -mode batch -notrace -source build_bel.tcl -tclargs A5 SLICE_X12Y11 A6LUT T12 -log T12.bl -journal T12.j > T12.bo 2>&1
grep -q BEL_DONE T12.bo && echo BUILT || { echo FAILBUILD; tail -5 T12.bo; exit 1; }
$V -mode batch -notrace -source bit_any.tcl -tclargs T12.dcp ref_T12.bit -log refT12.bl > refT12.bo 2>&1
DCP=T12.dcp EDF=T12.edf OUT=$R TAG=T12 /opt/lzh/venv/bin/python p6_make2.py > mk_T12.log 2>&1 || { echo MKFAIL; cat mk_T12.log; exit 1; }
echo "made=$(ls v_T12_*.dcp | wc -l)"
ls v_T12_*.dcp | xargs -P 12 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
echo "bits=$(ls v_T12_*.bit | wc -l)"
grep -h "sink" mk_T12.log | head -2
