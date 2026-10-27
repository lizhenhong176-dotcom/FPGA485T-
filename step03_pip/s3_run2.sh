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

cat > jobs2.txt <<'EOF'
SLICE_X10Y21 A6LUT 64'h0 b10_21
SLICE_X10Y21 A6LUT 64'h1 k0_10_21
SLICE_X10Y21 A6LUT 64'h2 k1_10_21
SLICE_X11Y21 A6LUT 64'h0 b11_21
SLICE_X11Y21 A6LUT 64'h1 k0_11_21
SLICE_X11Y21 A6LUT 64'h2 k1_11_21
SLICE_X10Y40 A6LUT 64'h0 b10_40
SLICE_X10Y40 A6LUT 64'h1 k0_10_40
SLICE_X10Y40 A6LUT 64'h2 k1_10_40
SLICE_X10Y20 A6LUT 64'h4 k2_10
SLICE_X10Y20 A6LUT 64'h8 k3_10
SLICE_X10Y20 A6'h100 k8_10
EOF

xargs -P 6 -L 1 -d '\n' bash -c 'run_one "$@"' _ < jobs2.txt

cat > s3_diff2.py <<'PYEOF'
import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame
pairs = [
    ("b10_21", "k0_10_21"), ("b10_21", "k1_10_21"),
    ("b11_21", "k0_11_21"), ("b11_21", "k1_11_21"),
    ("b10_40", "k0_10_40"), ("b10_40", "k1_10_40"),
    ("base10", "k2_10"), ("base10", "k3_10"), ("base10", "k8_10"),
]
for base, var in pairs:
    fa = frames_from_bit(base + ".bit")
    fb = frames_from_bit(var + ".bit")
    frames = diff_frame_indices(fa, fb)
    cfg = [[x, w, b] for x in frames for w, b in diff_bits_in_frame(fa, fb, x) if w != 50]
    print(var, "vs", base, "->", cfg)
PYEOF
/opt/lzh/venv/bin/python s3_diff2.py 2>&1
cp s3_results2.txt /mnt/c/Users/S.tschai/ 2>/dev/null || true
