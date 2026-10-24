#!/bin/bash
set -u
export XILINXD_LICENSE_FILE=/data/lzh/Xilinx/Vivado_license_2037.lic
VIV=/data/lzh/Xilinx/Vivado/2017.2/bin/vivado
ROOT=/data/lzh/v7re/data/m2/fam/clbll_l
cd "$ROOT" || exit 1
for d in pin_a3 pin_a5; do
  ( cd "$d" && "$VIV" -mode batch -notrace -source build.tcl -log build.log -journal build.jou > run.out 2>&1 ) &
done
wait
for d in pin_a3 pin_a5; do
  echo "$d done=$(grep -c '^DONE' "$d/build.log" 2>/dev/null) bit=$(stat -c %s "$d/design.bit" 2>/dev/null)"
done
echo ALL_DONE
