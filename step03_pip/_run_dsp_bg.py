import subprocess, sys

remote_cmd = """wsl -d Ubuntu -u root -- bash -c '
cd /opt/lzh/step03/dsptest
export LANG=C.UTF-8
VIVADO=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado

echo "=== Synth ref ==="
$VIVADO -mode batch -source stage_dsp_ref.tcl 2>&1 | tail -8

echo "=== Synth var ==="
$VIVADO -mode batch -source stage_dsp_var.tcl 2>&1 | tail -8

echo "=== Files ==="
ls -la *.bit

echo "=== Diff ==="
python3 diff_dsp.py ref.bit var_cead0.bit
'"""

result = subprocess.run(
    ["ssh", "fpga", remote_cmd],
    capture_output=True, text=True, timeout=600
)
with open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\_dsp_out.txt", "w", encoding="utf-8") as f:
    f.write(result.stdout)
    if result.stderr:
        f.write("\n--- STDERR ---\n")
        f.write(result.stderr[:2000])
print("DONE RC=", result.returncode)
