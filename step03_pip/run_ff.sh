#!/bin/bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic

mkdir -p /opt/lzh/step03/fftest
cd /opt/lzh/step03/fftest

VIVADO=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado

echo "=== Stage: synth + place + route ==="
$VIVADO -mode batch -notrace -source /opt/lzh/step03/fftest/stage_ff.tcl 2>&1 | tail -5

echo "=== Generate variants ==="
# ref: all INIT=0 (already the default from stage)
$VIVADO -mode batch -notrace -source /opt/lzh/step03/fftest/var_ff.tcl -tclargs 0 u_aff 2>&1 | tail -2
cp v_u_aff_0.bit ref.bit

# 4 variants: each FF with INIT=1
for ff in u_aff u_bff u_cff u_dff; do
  $VIVADO -mode batch -notrace -source /opt/lzh/step03/fftest/var_ff.tcl -tclargs 1 ${ff} 2>&1 | tail -2
done

echo "=== Files ==="
ls -la *.bit

echo "=== Diff + verify ==="
python3 /opt/lzh/step03/fftest/diff_ff.py ref.bit v_u_aff_1.bit AFF
python3 /opt/lzh/step03/fftest/diff_ff.py ref.bit v_u_bff_1.bit BFF
python3 /opt/lzh/step03/fftest/diff_ff.py ref.bit v_u_cff_1.bit CFF
python3 /opt/lzh/step03/fftest/diff_ff.py ref.bit v_u_dff_1.bit DFF

echo "=== DONE ==="
