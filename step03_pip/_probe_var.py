import subprocess

print(open("/opt/lzh/step03/lutmap/var.tcl").read())
env = {"LANG": "C.UTF-8", "PATH": "/usr/bin:/bin", "HOME": "/root"}
q = subprocess.run(["/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado", "-mode", "batch", "-notrace",
                    "-source", "/opt/lzh/step03/lutmap/var.tcl", "-tclargs", "0000000000000001"],
                   cwd="/opt/lzh/step03/lutmap", capture_output=True, text=True, env=env)
t = q.stdout + q.stderr
for i, line in enumerate(t.splitlines()):
    if "drc" in line.lower() or "ERROR" in line or "VAR_DONE" in line or "INIT" in line:
        print(line[:220])
