# -*- coding: utf-8 -*-
"""生成远端编排脚本 _lutmap_run.py（通过 stdin 送远端 python3 执行）。

远端流程：建 X8Y10/A6LUT + X10Y10/A6LUT 的 route 设计 → 65 个 INIT 变体 bitgen → 逐位差分。
"""
import base64
import gzip
import os

HERE = os.path.dirname(os.path.abspath(__file__))

TOP_V = r"""module top(input clk, output b);
  (* DONT_TOUCH = "yes" *) wire n1;
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h0000000000000000)) lut_a (.O(n1), .I0(clk), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h0000000000000000)) lut_b (.O(b), .I0(n1), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
endmodule
"""

STAGE_TCL = r"""set SL_A [lindex $argv 0]
set SL_B [lindex $argv 1]
read_verilog top_lut.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC $SL_A [get_cells lut_a]
set_property LOC $SL_B [get_cells lut_b]
set_property BEL A6LUT [get_cells lut_a]
set_property BEL A6LUT [get_cells lut_b]
place_design
route_design
write_checkpoint -force stage.dcp
puts "STAGE_DONE"
"""

VAR_TCL = r"""set INIT [lindex $argv 0]
open_checkpoint stage.dcp
foreach c {PDCN-1568 PDCN-1569 PDCN-1570} {
  if {[llength [get_drc_checks -quiet $c]]} { set_property IS_ENABLED false [get_drc_checks $c] }
}
foreach c {NSTD-1 UCIO-1} {
  if {[llength [get_drc_checks -quiet $c]]} { set_property SEVERITY {Warning} [get_drc_checks $c] }
}
set_property INIT 64'h$INIT [get_cells lut_b]
write_bitstream -force v_$INIT.bit
close_design
puts "VAR_DONE $INIT"
"""

RUN_SH = r"""#!/bin/bash
cd /opt/lzh/step03/lutmap || exit 1
VIVADO=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
rm -f v_*.bit
: > inits.txt
echo 0000000000000000 >> inits.txt
for k in $(seq 0 63); do printf "%016x\n" $((1 << k)) >> inits.txt; done
export LANG=C.UTF-8
cat inits.txt | xargs -P 12 -I{} $VIVADO -mode batch -notrace -source var.tcl -tclargs {} > log_{}.txt 2>&1
ls v_*.bit | wc -l
"""

DIFF_PY = r"""import base64, gzip, json, os, struct

D = "/opt/lzh/step03/lutmap"
FW, SYNC = 101, b"\xaa\x99\x55\x66"


def frames(path):
    data = open(path, "rb").read()
    pos = data.find(SYNC)
    body = data[pos + 4:]
    n = len(body) // 4
    w = list(struct.unpack(">%dI" % n, body[:n * 4]))
    pay, i = [], 0
    while i < len(w):
        h = w[i]; i += 1
        t, op, a, c = (h >> 29) & 7, (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF
        if t == 2:
            k = h & 0x7FFFFFF; pay.extend(w[i:i+k]); i += k; continue
        if t != 1: break
        if op == 0: continue
        if op == 1: i += 1; continue
        if a == 2:
            if c == 0:
                k = w[i] & 0x7FFFFFF; i += 1
            else:
                k = c
            pay.extend(w[i:i+k]); i += k; continue
        i += c
    return [pay[k*FW:(k+1)*FW] for k in range(len(pay)//FW)]


def bits(x):
    out = []
    while x:
        b = x & -x; out.append(b.bit_length()-1); x ^= b
    return out


base = frames(os.path.join(D, "v_0000000000000000.bit"))
out, ecc = {}, {}
for k in range(64):
    v = frames(os.path.join(D, "v_%016x.bit" % (1 << k)))
    pos, d_ecc = [], None
    for i in range(min(len(base), len(v))):
        if base[i][:50] == v[i][:50]:
            continue
        for w in range(50):
            d = base[i][w] ^ v[i][w]
            for b in bits(d):
                pos.append([i, w, b])
        d_ecc = (v[i][50] & 0x1FFF) ^ (base[i][50] & 0x1FFF)
    out[k] = pos
    ecc[k] = d_ecc
print("GZ_B64 " + base64.b64encode(gzip.compress(json.dumps({"bits": out, "ecc": ecc,
                                                             "frames": len(base)}).encode(), 9)).decode())
"""

DRIVER = r'''# -*- coding: utf-8 -*-
import os, subprocess, sys

D = "/opt/lzh/step03/lutmap"
VIVADO = "/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado"
os.makedirs(D, exist_ok=True)
for name, text in __FILES__.items():
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
'''


def main():
    files = {"top_lut.v": TOP_V, "stage.tcl": STAGE_TCL, "var.tcl": VAR_TCL,
             "run.sh": RUN_SH, "diff.py": DIFF_PY}
    inner = dict(files)
    driver = DRIVER.replace("__FILES__", repr(inner))
    out = os.path.join(HERE, "_lutmap_run.py")
    open(out, "w", encoding="utf-8", newline="\n").write(driver)
    print("wrote", out, os.path.getsize(out))


if __name__ == "__main__":
    main()
