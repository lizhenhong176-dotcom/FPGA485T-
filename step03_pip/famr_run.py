"""famr_run.py —— INT_R 非 IMUX 家族：追加 PIP → bitgen → 差分。

在远端执行（/opt/lzh/venv/bin/python），一次完成 124 个变体。
"""
import json
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design

BASE = "/opt/lzh/step03/famr"
REF_DCP = "/opt/lzh/step03/right/rA1.dcp"
REF_BIT = "/opt/lzh/step03/right/ref_rA1.bit"
TILE = "INT_R_X7Y10"
VIVADO = "/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado"
PAYLOAD = 338
FRAME = 404

TCL = """open_checkpoint {dcp}
set_property SEVERITY {{Warning}} [get_drc_checks NSTD-1]
set_property SEVERITY {{Warning}} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force -bin_file {bit}
puts "BITSTREAM_DONE"
"""


def build(spec):
    d0 = Design.readCheckpoint(REF_DCP)
    dev = d0.getDevice()
    tile = dev.getTile(TILE)
    pips = {}
    for pp in tile.getPIPs():
        s = str(pp)
        if "->>" not in s:
            continue
        rest = s.split("/")[-1]
        src, dst = rest.split("->>")
        src = src.split(".")[-1]
        pips.setdefault(dst, {})[src] = pp
    print("tile", TILE, "families", len(pips), flush=True)

    made = []
    for family, src_wire, name in spec:
        path = os.path.join(BASE, name + ".dcp")
        if os.path.exists(path):
            made.append((name, path))
            continue
        if family not in pips or src_wire not in pips[family]:
            print("MISS", family, src_wire, flush=True)
            continue
        pp = pips[family][src_wire]
        d = Design.readCheckpoint(REF_DCP)
        net = d.getNet("n1")
        lst = ArrayList()
        for q in net.getPIPs():
            lst.add(q)
        lst.add(pp)
        net.setPIPs(lst)
        d.writeCheckpoint(os.path.join(BASE, name + ".dcp"))
        made.append((name, os.path.join(BASE, name + ".dcp")))
    print("built", len(made), "of", len(spec), flush=True)
    return made


def bitgen(item):
    name, dcp = item
    bit = os.path.join(BASE, name + ".bit")
    if os.path.exists(bit) and os.path.getsize(bit) > 1000000:
        return name, "cached"
    tcl = os.path.join(BASE, name + ".tcl")
    with open(tcl, "w") as fh:
        fh.write(TCL.format(dcp=dcp, bit=bit))
    env = dict(os.environ, LANG="C.UTF-8", LC_ALL="C.UTF-8")
    p = subprocess.run([VIVADO, "-mode", "batch", "-nojournal", "-notrace",
                        "-source", tcl],
                       capture_output=True, text=True, env=env, timeout=1800)
    ok = "BITSTREAM_DONE" in p.stdout and os.path.exists(bit)
    return name, "ok" if ok else ("fail:" + p.stderr[-200:].replace("\n", " "))


def diffs(name):
    a = open(REF_BIT, "rb").read()
    b = open(os.path.join(BASE, name + ".bit"), "rb").read()
    n = min(len(a), len(b))
    out = []
    i = PAYLOAD
    while i < n:
        if a[i] != b[i]:
            x = a[i] ^ b[i]
            off = i - PAYLOAD
            frame = off // FRAME
            r = off % FRAME
            word = r // 4
            byte_in_word = r % 4
            for k in range(8):
                if x & (1 << k):
                    bit = (3 - byte_in_word) * 8 + k
                    if word != 50:
                        out.append([frame, word, bit])
        i += 1
    return out


def main():
    spec = json.load(open(os.path.join(BASE, "spec.json")))
    print("spec", len(spec), flush=True)
    made = build(spec)
    with ThreadPoolExecutor(max_workers=8) as ex:
        for name, st in ex.map(bitgen, made):
            print(st, name, flush=True)
    res = {}
    for name, _ in made:
        bit = os.path.join(BASE, name + ".bit")
        if not os.path.exists(bit):
            continue
        res[name] = diffs(name)
    json.dump(res, open(os.path.join(BASE, "famdiff_r.json"), "w"))
    print("WROTE", len(res), flush=True)


if __name__ == "__main__":
    main()
