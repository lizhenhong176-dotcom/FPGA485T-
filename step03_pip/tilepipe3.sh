#!/bin/bash
set -u
R=/opt/lzh/step03/tilepipe3; mkdir -p $R; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cp /opt/lzh/step03/pip2/top_y20.v /opt/lzh/step03/pip1/bit_any.tcl .
cp /mnt/c/Users/S.tschai/build_bel.tcl /mnt/c/Users/S.tschai/p6_make2.py .
echo "=== stage 1: build 6 designs (same INT_L type, instance Y21) ==="
for PIN in A1 A2 A3 A4 A5 A6; do
  TAG=Y21_A6_$PIN
  [ -f "$TAG.dcp" ] || $V -mode batch -notrace -source build_bel.tcl -tclargs $PIN SLICE_X8Y21 A6LUT $TAG -log $TAG.bl -journal $TAG.j > $TAG.bo 2>&1
  grep -q BEL_DONE $TAG.bo && echo "BUILD $TAG ok" || echo "BUILD $TAG FAILED"
  DCP=$TAG.dcp EDF=$TAG.edf OUT=$R TAG=$TAG /opt/lzh/venv/bin/python p6_make2.py > mk_$TAG.log 2>&1
  echo "MAKE $TAG $(grep -m1 TAG mk_$TAG.log)"
done
echo "=== stage 2: bitgen ==="
for i in $(seq 1 40); do
  n=$(ls v_*.bit 2>/dev/null | wc -l); r=$(ls ref_*.bit 2>/dev/null | wc -l)
  echo "iter $i bits=$n refs=$r"
  [ "$n" -ge 150 ] && [ "$r" -ge 6 ] && break
  : > missing.txt
  for f in v_*.dcp ref_*.dcp; do b="${f%.dcp}.bit"; [ -f "$b" ] || echo "$f" >> missing.txt; done
  [ -s missing.txt ] && cat missing.txt | xargs -P 8 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
  sleep 20
done
echo "STAGE2 FINAL bits=$(ls v_*.bit | wc -l) refs=$(ls ref_*.bit | wc -l)"
