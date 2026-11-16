import subprocess

with open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\_run_dsp.sh", "rb") as f:
    script = f.read()
script = script.replace(b"\r\n", b"\n")

result = subprocess.run(
    ["ssh", "fpga", "wsl", "-d", "Ubuntu", "-u", "root", "--", "bash"],
    input=script,
    capture_output=True,
    timeout=600
)

out = result.stdout.decode("utf-8", errors="replace")
err = result.stderr.decode("utf-8", errors="replace")

with open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\_dsp_out.txt", "w", encoding="utf-8") as f:
    f.write(out)
    if err:
        f.write("\n--- STDERR ---\n")
        f.write(err[:3000])

print(f"DONE RC={result.returncode} stdout={len(out)} stderr={len(err)}")
