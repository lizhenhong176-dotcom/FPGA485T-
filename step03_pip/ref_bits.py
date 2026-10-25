import glob
import os
import subprocess

R = "/opt/lzh/step03/tilepipe3"
os.chdir(R)
V = "/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado"
env = dict(os.environ, XILINXD_LICENSE_FILE="/opt/lzh/Xilinx/Vivado_license_2037.lic", LANG="C", LC_ALL="C")
todo = [d for d in sorted(glob.glob("ref_*.dcp")) if not os.path.exists(d[:-4] + ".bit")]
print("refs to build:", todo)
procs = []
for d in todo:
    b = d[:-4] + ".bit"
    log = d[:-4] + ".bl"
    bo = d[:-4] + ".bo"
    with open(bo, "w") as fh:
        procs.append(subprocess.Popen([V, "-mode", "batch", "-notrace", "-source", "bit_any.tcl", "-tclargs", d, b, "-log", log], stdout=fh, stderr=subprocess.STDOUT, env=env))
for p in procs:
    p.wait()
print("ref bits now:", len(glob.glob("ref_*.bit")))
