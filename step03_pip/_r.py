import subprocess
p=subprocess.run(['/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado','-mode','batch','-notrace','-source','/opt/lzh/step03/lutmap/var.tcl','-tclargs','0000000000000001'],cwd='/opt/lzh/step03/lutmap',capture_output=True,text=True,env={'LANG':'C.UTF-8','PATH':'/usr/bin:/bin','HOME':'/root'})
t=p.stdout+p.stderr
print([l for l in t.splitlines() if 'ERROR' in l][:3])
print([l for l in t.splitlines() if 'VAR_DONE' in l])
