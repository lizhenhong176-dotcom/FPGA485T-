cd /opt/lzh/step03/bramtest
export LANG=C.UTF-8
VIVADO=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
echo "=== Synth ref ==="
$VIVADO -mode batch -source stage_bram_ref.tcl 2>&1 | grep -iE "error|write_bitstream|exiting" | head -10
echo "=== Synth var ==="
$VIVADO -mode batch -source stage_bram_var.tcl 2>&1 | grep -iE "error|write_bitstream|exiting" | head -10
echo "=== Files ==="
ls -la *.bit 2>/dev/null || echo "No .bit files"
echo "=== Diff ==="
python3 diff_bram.py ref.bit var_init1.bit 2>&1 | head -50
