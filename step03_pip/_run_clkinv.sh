#!/bin/bash
set -e
export LANG=C.UTF-8
export PATH=/opt/lzh/Xilinx/Vivado/2017.2/bin:$PATH
cd /opt/lzh/step03/clkinvtest
mkdir -p /opt/lzh/step03/clkinvtest
cd /opt/lzh/step03/clkinvtest

# Files are already pushed via stdin

echo "=== Stage: synth + place + route + v_clkinv.bit ==="
vivado -mode batch -notrace -source stage_clkinv.tcl 2>&1 | tail -20

echo "=== Ref: remove IS_C_INVERTED → ref.bit ==="
vivado -mode batch -notrace -source ref_clkinv.tcl 2>&1 | tail -10

echo "=== Diff ==="
python3 diff_clkinv.py ref.bit v_clkinv.bit
