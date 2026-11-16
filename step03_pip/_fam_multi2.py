"""§5.6 multi-source driver (clone of famr_run.py, parameterized).
Usage: _fam_multi2.py <BASE> <REF_DCP> <REF_BIT> <TILE> <SPEC> <OUT> <JOBS>
Adds pip src_wire->>family to net n1 of REF, bitgens, diffs vs REF_BIT (skip word50).
"""
import json, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design

BASE, REF_DCP, REF_BIT, TILE, SPEC, OUT = sys.argv[1:7]
JOBS = int(sys.argv[7])
VIVADO = "/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado"
PAYLOAD, FRAME = 338, 404
os.makedirs(BASE, exist_ok=True)
TCL = """open_checkpoint {dcp}
set_property SEVERITY {{Warning}} [get_drc_checks NSTD-1]
set_property SEVERITY {{Warning}} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force -bin_file {bit}
puts "BITSTREAM_DONE"
"""
spec = json.load(open(SPEC))
print(os.path.basename(BASE), "spec", len(spec), flush=True)

def build():
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
    made = []
    for family, src_wire, name in spec:
        path = os.path.join(BASE, name + ".dcp")
        if os.path.exists(path):
            made.append((name, path)); continue
        if family not in pips or src_wire not in pips[family]:
            print("MISS", family, src_wire, flush=True); continue
        pp = pips[family][src_wire]
        d = Design.readCheckpoint(REF_DCP)
        net = d.getNet("n1")
        lst = ArrayList()
        for q in net.getPIPs():
            lst.add(q)
        lst.add(pp)
        net.setPIPs(lst)
        d.writeCheckpoint(path)
        made.append((name, path))
    print("built", len(made), "of", len(spec), flush=True)
    return made

def bitgen(item):
    name, dcp = item
    bit = os.path.join(BASE, name + ".bit")
    if os.path.exists(bit) and os.path.getsize(bit) > 1000000:
        return name, "cached"
    tcl = os.path.join(BASE, name + ".tcl")
    open(tcl, "w").write(TCL.format(dcp=dcp, bit=bit))
    env = dict(os.environ, LANG="C.UTF-8", LC_ALL="C.UTF-8")
    try:
        p = subprocess.run([VIVADO, "-mode", "batch", "-nojournal", "-notrace", "-source", tcl],
                           capture_output=True, text=True, env=env, timeout=1800)
        ok = "BITSTREAM_DONE" in p.stdout and os.path.exists(bit)
        return name, "ok" if ok else ("fail:" + (p.stderr or "")[-160:].replace("\n", " "))
    except Exception as e:
        return name, "err:" + repr(e)[:120]

def diffs(name):
    a = open(REF_BIT, "rb").read()
    b = open(os.path.join(BASE, name + ".bit"), "rb").read()
    n = min(len(a), len(b)); out = []; i = PAYLOAD
    while i < n:
        if a[i] != b[i]:
            x = a[i] ^ b[i]; off = i - PAYLOAD; fr = off // FRAME; r = off % FRAME
            w = r // 4; bi = r % 4
            for k in range(8):
                if x & (1 << k) and w != 50:
                    out.append([fr, w, (3 - bi) * 8 + k])
        i += 1
    return out

made = build()
with ThreadPoolExecutor(max_workers=JOBS) as ex:
    ok = 0
    for name, st in ex.map(bitgen, made):
        if st != "ok" and st != "cached":
            print("BITGEN", st, name, flush=True)
        else:
            ok += 1
print("bitgen ok", ok, "of", len(made), flush=True)
res = {}
for name, _ in made:
    bit = os.path.join(BASE, name + ".bit")
    if os.path.exists(bit):
        res[name] = diffs(name)
json.dump(res, open(OUT, "w"))
print("WROTE", len(res), "->", OUT, flush=True)
