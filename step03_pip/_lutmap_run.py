# -*- coding: utf-8 -*-
import os, subprocess, sys

D = "/opt/lzh/step03/lutmap"
VIVADO = "/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado"
os.makedirs(D, exist_ok=True)
for name, text in {'top_lut.v': 'module top(input clk, output b);\n  (* DONT_TOUCH = "yes" *) wire n1;\n  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64\'h0000000000000000)) lut_a (.O(n1), .I0(clk), .I1(1\'b0), .I2(1\'b0), .I3(1\'b0), .I4(1\'b0), .I5(1\'b0));\n  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64\'h0000000000000000)) lut_b (.O(b), .I0(n1), .I1(1\'b0), .I2(1\'b0), .I3(1\'b0), .I4(1\'b0), .I5(1\'b0));\nendmodule\n', 'stage.tcl': 'set SL_A [lindex $argv 0]\nset SL_B [lindex $argv 1]\nread_verilog top_lut.v\nsynth_design -top top -part xc7vx485tffg1761-2\nset_property LOC $SL_A [get_cells lut_a]\nset_property LOC $SL_B [get_cells lut_b]\nset_property BEL A6LUT [get_cells lut_a]\nset_property BEL A6LUT [get_cells lut_b]\nplace_design\nroute_design\nwrite_checkpoint -force stage.dcp\nputs "STAGE_DONE"\n', 'var.tcl': 'set INIT [lindex $argv 0]\nopen_checkpoint stage.dcp\nforeach c {PDCN-1568 PDCN-1569 PDCN-1570} {\n  if {[llength [get_drc_checks -quiet $c]]} { set_property IS_ENABLED false [get_drc_checks $c] }\n}\nforeach c {NSTD-1 UCIO-1} {\n  if {[llength [get_drc_checks -quiet $c]]} { set_property SEVERITY {Warning} [get_drc_checks $c] }\n}\nset_property INIT 64\'h$INIT [get_cells lut_b]\nwrite_bitstream -force v_$INIT.bit\nclose_design\nputs "VAR_DONE $INIT"\n', 'run.sh': '#!/bin/bash\ncd /opt/lzh/step03/lutmap || exit 1\nVIVADO=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado\nrm -f v_*.bit\n: > inits.txt\necho 0000000000000000 >> inits.txt\nfor k in $(seq 0 63); do printf "%016x\\n" $((1 << k)) >> inits.txt; done\nexport LANG=C.UTF-8\ncat inits.txt | xargs -P 12 -I{} $VIVADO -mode batch -notrace -source var.tcl -tclargs {} > log_{}.txt 2>&1\nls v_*.bit | wc -l\n', 'diff.py': 'import base64, gzip, json, os, struct\n\nD = "/opt/lzh/step03/lutmap"\nFW, SYNC = 101, b"\\xaa\\x99\\x55\\x66"\n\n\ndef frames(path):\n    data = open(path, "rb").read()\n    pos = data.find(SYNC)\n    body = data[pos + 4:]\n    n = len(body) // 4\n    w = list(struct.unpack(">%dI" % n, body[:n * 4]))\n    pay, i = [], 0\n    while i < len(w):\n        h = w[i]; i += 1\n        t, op, a, c = (h >> 29) & 7, (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF\n        if t == 2:\n            k = h & 0x7FFFFFF; pay.extend(w[i:i+k]); i += k; continue\n        if t != 1: break\n        if op == 0: continue\n        if op == 1: i += 1; continue\n        if a == 2:\n            if c == 0:\n                k = w[i] & 0x7FFFFFF; i += 1\n            else:\n                k = c\n            pay.extend(w[i:i+k]); i += k; continue\n        i += c\n    return [pay[k*FW:(k+1)*FW] for k in range(len(pay)//FW)]\n\n\ndef bits(x):\n    out = []\n    while x:\n        b = x & -x; out.append(b.bit_length()-1); x ^= b\n    return out\n\n\nbase = frames(os.path.join(D, "v_0000000000000000.bit"))\nout, ecc = {}, {}\nfor k in range(64):\n    v = frames(os.path.join(D, "v_%016x.bit" % (1 << k)))\n    pos, d_ecc = [], None\n    for i in range(min(len(base), len(v))):\n        if base[i][:50] == v[i][:50]:\n            continue\n        for w in range(50):\n            d = base[i][w] ^ v[i][w]\n            for b in bits(d):\n                pos.append([i, w, b])\n        d_ecc = (v[i][50] & 0x1FFF) ^ (base[i][50] & 0x1FFF)\n    out[k] = pos\n    ecc[k] = d_ecc\nprint("GZ_B64 " + base64.b64encode(gzip.compress(json.dumps({"bits": out, "ecc": ecc,\n                                                             "frames": len(base)}).encode(), 9)).decode())\n'}.items():
    open(os.path.join(D, name), "w", newline="\n").write(text)

os.chmod(os.path.join(D, "run.sh"), 0o755)
env = dict(os.environ, LANG="C.UTF-8", LC_ALL="C.UTF-8")
print("== stage ==", flush=True)
p = subprocess.run([VIVADO, "-mode", "batch", "-notrace", "-source", os.path.join(D, "stage.tcl"),
                    "-tclargs", "SLICE_X8Y10", "SLICE_X10Y10"], cwd=D, capture_output=True, text=True, env=env)
print(p.stdout[-1500:]); print("ERR", p.stderr[-800:], flush=True)
if "STAGE_DONE" not in p.stdout:
    sys.exit("stage failed")
print("== variants ==", flush=True)
p = subprocess.run(["bash", os.path.join(D, "run.sh")], capture_output=True, text=True, env=env)
print(p.stdout[-500:]); print("ERR", p.stderr[-500:], flush=True)
print("== diff ==", flush=True)
p = subprocess.run(["/usr/bin/python3", os.path.join(D, "diff.py")], capture_output=True, text=True)
sys.stdout.write(p.stdout[-200000:])
print("ERR", p.stderr[-800:], flush=True)
