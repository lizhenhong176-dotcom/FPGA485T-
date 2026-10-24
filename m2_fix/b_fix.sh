#!/bin/bash
set -e
cd /data/lzh/v7re/data/m2/fam/clbll_l
rm -rf b3_fix b5_fix
cp -a b3 b3_fix
cp -a b5 b5_fix
for spec in "b3_fix A3" "b5_fix A5"; do
  set -- $spec
  v=$1
  pin=$2
  cd /data/lzh/v7re/data/m2/fam/clbll_l/$v
  rm -rf m2_pin design.bit design.bin routed.dcp pips.txt rc build.log
  cat > top.xdc <<EOF
set_property LOC SLICE_X8Y10 [get_cells lut_a]
set_property BEL A6LUT [get_cells lut_a]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells lut_a]
set_property LOC SLICE_X8Y11 [get_cells lut_b]
set_property BEL B6LUT [get_cells lut_b]
set_property LOCK_PINS {I0:${pin} I1:A1 I2:A2 I3:A4 I4:A5 I5:A6} [get_cells lut_b]
EOF
  grep LOCK_PINS top.xdc | tail -1
  nohup ./run.sh >/dev/null 2>&1 &
done
sleep 5
ps -ef | grep '[v]ivado' | wc -l
