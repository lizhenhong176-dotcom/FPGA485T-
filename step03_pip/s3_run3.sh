#!/bin/bash
set -u
export LANG=C LC_ALL=C HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cd /opt/lzh/step03/s3site

run_one() {
  SL=$1; BEL=$2; INIT=$3; TAG=$4
  $VIV -mode batch -notrace -source s3_init.tcl -tclargs $SL $BEL "$INIT" $TAG \
    -log $TAG.log > $TAG.out 2>&1
  if [ -f $TAG.bit ]; then echo "OK $TAG"; else echo "FAIL $TAG"; fi
}
export -f run_one; export VIV

cat > jobs3.txt <<'EOF'
SLICE_X8Y20 A6LUT 64'h0 b_x8
SLICE_X8Y20 A6LUT 64'h1 k0_x8
SLICE_X8Y20 A6LUT 64'h2 k1_x8
SLICE_X9Y20 A6LUT 64'h0 b_x9
SLICE_X9Y20 A6LUT 64'h1 k0_x9
SLICE_X9Y20 A6LUT 64'h2 k1_x9
SLICE_X12Y20 A6LUT 64'h0 b_x12
SLICE_X12Y20 A6LUT 64'h1 k0_x12
SLICE_X12Y20 A6LUT 64'h2 k1_x12
SLICE_X13Y20 A6LUT 64'h0 b_x13
SLICE_X13Y20 A6LUT 64'h1 k0_x13
SLICE_X13Y20 A6LUT 64'h2 k1_x13
SLICE_X44Y20 A6LUT 64'h0 b_x44
SLICE_X44Y20 A6LUT 64'h1 k0_x44
SLICE_X44Y20 A6LUT 64'h2 k1_x44
SLICE_X45Y20 A6LUT 64'h0 b_x45
SLICE_X45Y20 A6LUT 64'h1 k0_x45
SLICE_X45Y20 A6LUT 64'h2 k1_x45
EOF

xargs -P 6 -L 1 -d '\n' bash -c 'run_one "$@"' _ < jobs3.txt

cat > s3_diff3.py <<'PYEOF'
import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame
pairs = [
    ("b_x8", "k0_x8"), ("b_x8", "k1_x8"),
    ("b_x9", "k0_x9"), ("b_x9", "k1_x9"),
    ("b_x12", "k0_x12"), ("b_x12", "k1_x12"),
    ("b_x13", "k0_x13"), ("b_x13", "k1_x13"),
    ("b_x44", "k0_x44"), ("b_x44", "k1_x44"),
    ("b_x45", "k0_x45"), ("b_x45", "k1_x45"),
]
for base, var in pairs:
    try:
        fa = frames_from_bit(base + ".bit")
        fb = frames_from_bit(var + ".bit")
    except FileNotFoundError as e:
        print(var, "MISSING", e); continue
    frames = diff_frame_indices(fa, fb)
    cfg = [[x, w, b] for x in frames for w, b in diff_bits_in_frame(fa, fb, x) if w != 50]
    print(var, "vs", base, "->", cfg)
PYEOF
/opt/lzh/venv/bin/python s3_diff3.py 2>&1 | tee s3_results3.txt
cp s3_results3.txt /mnt/c/Users/S.tschai/
