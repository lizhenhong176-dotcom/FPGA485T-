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
  if [ -f $TAG.bit ]; then echo "OK $TAG"; else echo "FAIL $TAG $(tail -2 $TAG.out | tr '\n' ' ')"; fi
}
export -f run_one; export VIV

cat > jobs.txt <<'EOF'
SLICE_X10Y20 A6LUT 64'h0 base10
SLICE_X10Y20 A6LUT 64'h1 k0_10
SLICE_X10Y20 A6LUT 64'h2 k1_10
SLICE_X11Y20 A6LUT 64'h0 base11
SLICE_X11Y20 A6LUT 64'h1 k0_11
SLICE_X11Y20 A6LUT 64'h2 k1_11
SLICE_X52Y20 A6LUT 64'h0 base52
SLICE_X52Y20 A6LUT 64'h1 k0_52
SLICE_X52Y20 A6LUT 64'h2 k1_52
SLICE_X53Y20 A6LUT 64'h0 base53
SLICE_X53Y20 A6LUT 64'h1 k0_53
SLICE_X53Y20 A6LUT 64'h2 k1_53
EOF

xargs -P 6 -L 1 -d '\n' bash -c 'run_one "$@"' _ < jobs.txt

echo "=== bits ==="; ls -la *.bit 2>/dev/null | awk '{print $NF, $5}'
echo "=== diffs ==="
for tag in k0_10 k1_10 k0_11 k1_11 k0_52 k1_52 k0_53 k1_53; do
  base=base${tag#*_}
  if [ -f $tag.bit ] && [ -f $base.bit ]; then
    echo "--- $tag vs $base ---"
    python3 difbit.py $base.bit $tag.bit
  fi
done
