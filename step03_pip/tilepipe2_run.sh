#!/bin/bash
set -u
R=/opt/lzh/step03/tilepipe2; mkdir -p $R; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cp /opt/lzh/step03/pip2/top_y20.v /opt/lzh/step03/pip1/bit_any.tcl .
cp /mnt/c/Users/S.tschai/build_bel.tcl /mnt/c/Users/S.tschai/p6_make.py .
# place lut_b into the CLBLL/CLBLM pair that feeds INT_L_X12Y11
for SLBEL in "SLICE_X14Y11:A6LUT" "SLICE_X14Y11:B6LUT" "SLICE_X15Y11:A6LUT" "SLICE_X15Y11:B6LUT" "SLICE_X15Y11:C6LUT" "SLICE_X15Y11:D6LUT"; do
  SL=${SLBEL%%:*}; BEL=${SLBEL##*:}
  for PIN in A1 A2 A3 A4 A5 A6; do
    TAG=${SL}_${BEL}_${PIN}
    if [ ! -f "$TAG.dcp" ]; then
      $V -mode batch -notrace -source build_bel.tcl -tclargs $PIN $SL $BEL $TAG -log $TAG.bl -journal $TAG.j > $TAG.bo 2>&1
    fi
    grep -q BEL_DONE $TAG.bo 2>/dev/null || { echo "FAILBUILD $TAG"; continue; }
    DCP=$TAG.dcp EDF=$TAG.edf OUT=$R TAG=$TAG /opt/lzh/venv/bin/python p6_make.py > mk_$TAG.log 2>&1
    echo "MADE $TAG $(grep -c "v_${TAG}_" mk_$TAG.log) $(grep TAG mk_$TAG.log | head -1)"
  done
done
echo "STAGE1 done dcp=$(ls v_*.dcp 2>/dev/null | wc -l)"
for i in $(seq 1 40); do
  n=$(ls v_*.bit 2>/dev/null | wc -l); r=$(ls ref_*.bit 2>/dev/null | wc -l)
  echo "iter $i bits=$n refs=$r"
  [ "$n" -ge 900 ] && [ "$r" -ge 36 ] && break
  ls v_*.dcp ref_*.dcp 2>/dev/null | while read f; do b="${f%.dcp}.bit"; [ -f "$b" ] || echo "$f"; done > missing.txt
  [ -s missing.txt ] && cat missing.txt | xargs -P 12 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
  sleep 30
done
echo "FINAL bits=$(ls v_*.bit | wc -l) refs=$(ls ref_*.bit | wc -l)"
