#!/bin/bash
set -u
R=/opt/lzh/step03/reuse6; mkdir -p $R; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cp /opt/lzh/step03/pip2/top_y20.v /opt/lzh/step03/pip1/bit_any.tcl .
cp /mnt/c/Users/S.tschai/build_bel.tcl /mnt/c/Users/S.tschai/make_ref.py .
run_one() {
  PIN=$1; SL=$2; BEL=$3; TAG=${SL}_${BEL}_${PIN}
  $V -mode batch -notrace -source build_bel.tcl -tclargs $PIN $SL $BEL $TAG -log $TAG.bl -journal $TAG.j > $TAG.bo 2>&1
  grep -q BEL_DONE $TAG.bo || { echo "FAILBUILD $TAG"; return; }
  DCP=$TAG.dcp EDF=$TAG.edf OUT=ref_$TAG.dcp /opt/lzh/venv/bin/python make_ref.py > $TAG.sink 2>&1
  $V -mode batch -notrace -source bit_any.tcl -tclargs $TAG.dcp a_$TAG.bit -log $TAG.b1 -journal $TAG.j1 > $TAG.bo1 2>&1
  $V -mode batch -notrace -source bit_any.tcl -tclargs ref_$TAG.dcp r_$TAG.bit -log $TAG.b2 -journal $TAG.j2 > $TAG.bo2 2>&1
  echo "OK $TAG $(grep SINK $TAG.sink)"
}
export -f run_one; export V
for SLBEL in "SLICE_X10Y11:A6LUT" "SLICE_X10Y11:B6LUT" "SLICE_X10Y11:C6LUT" "SLICE_X10Y11:D6LUT"; do
  SL=${SLBEL%%:*}; BEL=${SLBEL##*:}
  for PIN in A1 A2 A3 A4 A5 A6; do echo "$PIN $SL $BEL"; done
done | xargs -P 6 -n 3 bash -c 'run_one "$0" "$1" "$2"'
echo "a=$(ls a_*.bit | wc -l) r=$(ls r_*.bit | wc -l)"
