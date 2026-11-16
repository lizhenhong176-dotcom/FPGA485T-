# -*- coding: utf-8 -*-
"""远端：LUT6 INIT 位映射实验。

步骤（全部在 /opt/lzh/step03/lutmap）：
1. 建一个 PLACE 到 SLICE_X8Y10/A6LUT（参考）与 SLICE_X10Y10/A6LUT（目标）的设计并 route；
2. 目标 LUT 的 INIT 取 0 与 1<<k (k=0..63)，逐个 bitgen；
3. 与 INIT=0 的位流做差，输出「INIT 位 k -> [(frame,word,bit)] + ECC 增量」。

输出 JSON 到 stdout（gzip+base64）。
"""

STAGE_TCL = r"""
set SL_A [lindex $argv 0]
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

VAR_TCL = r"""
set INIT [lindex $argv 1]
open_checkpoint stage.dcp
set_property INIT 64'h$INIT [get_cells lut_b]
write_bitstream -force v_$INIT.bit
close_design
puts "VAR_DONE $INIT"
"""

RUN_SH = r"""#!/bin/bash
cd /opt/lzh/step03/lutmap || exit 1
rm -f v_*.bit
# 0 与 64 个 one-hot
( echo 0000000000000000; for k in $(seq 0 63); do printf "%016x\n" $((1 << k)); done ) > inits.txt
cat inits.txt | xargs -P 12 -I{} vivado -mode batch -notrace -source var.tcl -tclargs {} > log_{}.txt 2>&1
ls v_*.bit | wc -l
"""

DIFF_PY = r"""
import base64, gzip, json, os, struct, sys

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
out = {}
ecc = {}
for k in range(64):
    name = "%016x" % (1 << k)
    v = frames(os.path.join(D, "v_%s.bit" % name))
    pos, d_ecc = [], None
    for i in range(len(base)):
        if base[i][:50] == v[i][:50]:
            continue
        for w in range(50):
            d = base[i][w] ^ v[i][w]
            for b in bits(d):
                pos.append([i, w, b])
        d_ecc = (v[i][50] & 0x1FFF) ^ (base[i][50] & 0x1FFF)
    out[k] = pos
    ecc[k] = d_ecc
payload = json.dumps({"bits": out, "ecc": ecc, "frames": len(base)}).encode()
print("GZ_B64 " + base64.b64encode(gzip.compress(payload, 9)).decode())
"""


def main():
    blob = __file__  # unused; 说明：远端脚本在下文生成
    print("run make_lutmap via runner")


if __name__ == "__main__":
    main()
