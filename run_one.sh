#!/bin/bash
set -u
export XILINXD_LICENSE_FILE=/data/lzh/Xilinx/Vivado_license_2037.lic
VIV=/data/lzh/Xilinx/Vivado/2017.2/bin/vivado
D=${1:?usage: run_one.sh DIR}
cd "$D" || exit 1
"$VIV" -mode batch -notrace -source build.tcl -log build.log -journal build.jou > run.out 2>&1
echo "done=$(grep -c '^DONE' build.log 2>/dev/null) bit=$(stat -c %s design.bit 2>/dev/null)"
