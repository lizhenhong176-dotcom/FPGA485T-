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

cat > jobs4.txt <<'EOF'
SLICE_X10Y20 C6LUT 64'h0 bc10_20
SLICE_X10Y20 C6LUT 64'h1 kc0_10_20
SLICE_X10Y20 C6LUT 64'h2 kc1_10_20
SLICE_X10Y20 B6LUT 64'h0 bb10_20
SLICE_X10Y20 B6LUT 64'h1 kb0_10_20
SLICE_X10Y40 C6LUT 64'h0 bc10_40
SLICE_X10Y40 C6LUT 64'h1 kc0_10_40
EOF

xargs -P 6 -L 1 -d '\n' bash -c 'run_one "$@"' _ < jobs4.txt

cat > s3_diff4.py <<'PYEOF'
import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame
pairs = [
    ("bc10_20", "kc0_10_20"), ("bc10_20", "kc1_10_20"),
    ("bb10_20", "kb0_10_20"),
    ("bc10_40", "kc0_10_40"),
]
for base, var in pairs:
    try:
        fa = frames_from_bit(base + ".bit"); fb = frames_from_bit(var + ".bit")
    except FileNotFoundError as e:
        print(var, "MISSING", e); continue
    frames = diff_frame_indices(fa, fb)
    cfg = [[x, w, b] for x in frames for w, b in diff_bits_in_frame(fa, fb, x) if w != 50]
    print(var, "vs", base, "->", cfg)
PYEOF
/opt/lzh/venv/bin/python s3_diff4.py 2>&1 | tee s3_results4.txt
cp s3_results4.txt /mnt/c/Users/S.tschai/
