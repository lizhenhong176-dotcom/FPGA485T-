#!/bin/bash
set -u
R=/opt/lzh/step03/blkcol3; mkdir -p $R; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cp /opt/lzh/step03/pip2/top_y20.v top_y20.v
cp /opt/lzh/step03/pip1/bit_any.tcl .
cp /mnt/c/Users/S.tschai/build_bel.tcl .
cp /mnt/c/Users/S.tschai/p6_make2.py .
$V -mode batch -notrace -source build_bel.tcl -tclargs A5 SLICE_X10Y11 A6LUT T10 -log T10.bl -journal T10.j > T10.bo 2>&1
grep -q BEL_DONE T10.bo && echo BUILT || { echo FAILBUILD; tail -5 T10.bo; exit 1; }
$V -mode batch -notrace -source bit_any.tcl -tclargs T10.dcp ref_T10.bit -log refT10.bl > refT10.bo 2>&1
DCP=T10.dcp EDF=T10.edf OUT=$R TAG=T10 /opt/lzh/venv/bin/python p6_make2.py > mk_T10.log 2>&1 || { echo MKFAIL; cat mk_T10.log; exit 1; }
echo "made=$(ls v_T10_*.dcp | wc -l)"
ls v_T10_*.dcp | xargs -P 12 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
echo "bits=$(ls v_T10_*.bit | wc -l)"
grep -h "sink" mk_T10.log | head -2
