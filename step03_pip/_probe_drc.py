import subprocess

TCL = """open_checkpoint /opt/lzh/step03/lutmap/stage.dcp
puts "count=[llength [get_drc_checks NSTD-1]]"
if {[catch {set_property SEVERITY Warning [get_drc_checks NSTD-1]} e]} { puts "ERR1 $e" }
puts "sev=[get_property SEVERITY [get_drc_checks NSTD-1]]"
if {[catch {set_property IS_ENABLED false [get_drc_checks PDCN-1569]} e]} { puts "ERR2 $e" }
puts "PROBE_DONE"
"""
p = "/opt/lzh/step03/lutmap/probe.tcl"
open(p, "w", newline="\n").write(TCL)
env = {"LANG": "C.UTF-8", "PATH": "/usr/bin:/bin", "HOME": "/root"}
q = subprocess.run(["/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado", "-mode", "batch", "-notrace", "-source", p],
                   cwd="/opt/lzh/step03/lutmap", capture_output=True, text=True, env=env)
t = q.stdout + q.stderr
for line in t.splitlines():
    if "count=" in line or "sev=" in line or "ERR" in line or "PROBE_DONE" in line:
        print(line[:200])
