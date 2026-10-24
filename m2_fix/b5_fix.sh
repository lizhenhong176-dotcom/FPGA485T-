#!/bin/bash
set -e
cd /data/lzh/v7re/data/m2/fam/clbll_l/b5_fix
rm -rf m2_pin design.bit design.bin routed.dcp pips.txt rc build.log
cat > top.xdc <<'EOF'
set_property LOC SLICE_X8Y10 [get_cells lut_a]
set_property BEL A6LUT [get_cells lut_a]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells lut_a]
set_property LOC SLICE_X8Y11 [get_cells lut_b]
set_property BEL B6LUT [get_cells lut_b]
set_property LOCK_PINS {I0:A5 I1:A1 I2:A2 I3:A4 I4:A3 I5:A6} [get_cells lut_b]
EOF
./run.sh
