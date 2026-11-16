#!/bin/bash
set -e
export LANG=C.UTF-8
cd /opt/lzh/step03/dsptest
VIVADO=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado

echo "=== Synth ref ==="
$VIVADO -mode batch -source stage_dsp_ref.tcl 2>&1 | tail -8

echo "=== Synth var ==="
$VIVADO -mode batch -source stage_dsp_var.tcl 2>&1 | tail -8

echo "=== Files ==="
ls -la *.bit

echo "=== Diff ==="
python3 diff_dsp.py ref.bit var_cead0.bit
