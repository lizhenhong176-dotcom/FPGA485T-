# -*- coding: utf-8 -*-
"""远端 A 步：在右半（CLBLM_R/CLBLL_R）建一个走 IMUX_R 的设计，并生成 24 源变体 DCP。

做法：把 top.v / right_build.tcl / p6_make.py 写到远端 /opt/lzh/step03/right/，
跑 vivado 综合+布局布线，再用 rapidwright 枚举该 sink 的全部源，生成 ref/v_*.dcp。

输出（远端 right/build.log 与 stdout）：
  SINK <tile> ->> <mux>  sources N
"""
import base64
import gzip
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))

TOP_V = r'''module top(input clk, output b);
  (* DONT_TOUCH = "yes" *) wire n1;
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lut_a (.O(n1), .I0(clk), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lut_b (.O(b), .I0(n1), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
endmodule
'''

BUILD_TCL = r'''set TAG [lindex $argv 0]
read_verilog top.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X11Y10 [get_cells lut_a]
set_property LOC SLICE_X11Y11 [get_cells lut_b]
set_property BEL A6LUT [get_cells lut_a]
set_property BEL A6LUT [get_cells lut_b]
set_property LOCK_PINS "I0:A1" [get_cells lut_a]
set_property LOCK_PINS "I0:A1" [get_cells lut_b]
place_design
route_design
write_checkpoint -force $TAG.dcp
write_edif -force $TAG.edf
puts "BUILD_DONE $TAG"
'''

P6 = open(os.path.join(HERE, "p6_make.py"), encoding="utf-8").read()

SH_RUN = r'''#!/bin/bash
set -u
R=/opt/lzh/step03/right; mkdir -p $R; cd $R || exit 1
export LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
$V -mode batch -notrace -source right_build.tcl -tclargs rA1 -log build.log > build.out 2>&1
tail -5 build.out
DCP=rA1.dcp EDF=rA1.edf OUT=$R TAG=rA1 /opt/lzh/venv/bin/python p6_make.py 2>&1 | tail -5
cp /opt/lzh/step03/pip1/bit_any.tcl . 2>/dev/null || true
echo "dcps=$(ls v_*.dcp ref_*.dcp 2>/dev/null | wc -l)"
'''

PAYLOAD = r'''# -*- coding: utf-8 -*-
import base64, gzip, json, os, subprocess, textwrap

FILES = json.loads(gzip.decompress(base64.b64decode("__BLOB__")))
R = "/opt/lzh/step03/right"
os.makedirs(R, exist_ok=True)
for name, txt in FILES.items():
    open(os.path.join(R, name), "w", newline="\n").write(txt)
os.chmod(os.path.join(R, "run.sh"), 0o755)
print("staged", sorted(FILES))
p = subprocess.run(["bash", os.path.join(R, "run.sh")], capture_output=True, text=True)
print(p.stdout[-4000:])
print("STDERR", p.stderr[-2000:])
'''

def main():
    files = {"top.v": TOP_V, "right_build.tcl": BUILD_TCL, "p6_make.py": P6, "run.sh": SH_RUN}
    blob = base64.b64encode(gzip.compress(json.dumps(files).encode(), 9)).decode()
    out = os.path.join(HERE, "_right_stage.py")
    open(out, "w", encoding="utf-8", newline="\n").write(PAYLOAD.replace("__BLOB__", blob))
    print("wrote", out, os.path.getsize(out))


if __name__ == "__main__":
    main()
