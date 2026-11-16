cd /opt/lzh/step03/missingtest
export LANG=C.UTF-8
echo "=== Synth ref ==="
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -source stage_missing_ref.tcl 2>&1 | tail -5
echo "=== Synth var ==="
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -source stage_missing_var.tcl 2>&1 | tail -5
echo "=== Files ==="
ls -la *.bit 2>/dev/null
echo "=== Diff ==="
python3 diff_missing.py ref.bit var_cd.bit 2>&1 | head -60
