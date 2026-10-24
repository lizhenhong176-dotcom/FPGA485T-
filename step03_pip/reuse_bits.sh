#!/bin/bash
set -u
cd /opt/lzh/step03/reuse || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
ls v_*.dcp | xargs -P 10 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.blog" > "${f%.dcp}.bout" 2>&1; echo "BIT ${f%.dcp} $?"'
echo "bits=$(ls v_*.bit 2>/dev/null | wc -l)"
