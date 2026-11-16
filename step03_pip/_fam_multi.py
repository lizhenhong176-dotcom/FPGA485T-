"""§5.6 multi-source driver: for each [family, src_wire, name] in SPEC, add pip
src_wire->>family to net n1 of REF, write name.dcp, bitgen via vivado (bit_any.tcl),
diff v.bit vs REFBIT (skip word50) -> OUT json {name: [(frame,word,bit),...]}.
Side L or R only differ by REF/REFBIT/SPEC; both use net n1.
Usage: _fam_multi.py <REF> <REFBIT> <SPEC> <OUT> <SIDE> <JOBS>
"""
import os, sys, subprocess, json, glob
import rapidwright
from com.xilinx.rapidwright.design import Design
REF, REFBIT, SPEC, OUT, SIDE, JOBS = sys.argv[1:7]
JOBS = int(JOBS)
WORK = os.path.dirname(os.path.abspath(OUT))
os.makedirs(WORK, exist_ok=True)
spec = json.load(open(SPEC))
print(SIDE, "variants", len(spec), flush=True)

def build():
    made = 0
    for fam, src, name in spec:
        dp = os.path.join(WORK, name + ".dcp")
        if os.path.exists(dp):
            made += 1; continue
        d = Design.readCheckpoint(REF)
        net = d.getNet("n1")
        ok = net.addPip(src + ">>" + fam)
        if not ok:
            print("ADDFAIL", name, fam, src, flush=True); continue
        d.writeCheckpoint(dp)
        made += 1
        if made % 50 == 0:
            print(SIDE, "built", made, flush=True)
    print(SIDE, "build done", made, flush=True)

def bitgen(name):
    dp = os.path.join(WORK, name + ".dcp")
    bp = os.path.join(WORK, name + ".bit")
    if os.path.exists(bp):
        return
    tcl = os.path.join(WORK, "bg_%s.tcl" % name)
    open(tcl, "w").write(
        "open_checkpoint %s\n" % dp.replace("\\", "/") +
        "set_property NSTD-1 [current_design]\nset_property UCIO-1 [current_design]\n" +
        "set_property CFGBVS VCCO [current_design]\nset_property CONFIG_VOLTAGE 3.3 [current_design]\n" +
        "write_bitstream -force -bin_file %s\n" % bp.replace("\\", "/"))

build()
dcps = sorted(glob.glob(os.path.join(WORK, "v_*.dcp")))
names = [os.path.basename(x)[:-4] for x in dcps]
for n in names:
    bitgen(n)
procs = []
running = []
i = 0
def reap():
    global running
    still = []
    for (n, p, lg) in running:
        if p.poll() is None:
            still.append((n, p, lg))
        else:
            try: os.remove(os.path.join(WORK, "bg_%s.tcl" % n))
            except OSError: pass
    running = still
while i < len(names) or running:
    while i < len(names) and len(running) < JOBS:
        n = names[i]; i += 1
        lg = open(os.path.join(WORK, n + ".bit.log"), "w")
        p = subprocess.Popen(["vivado", "-mode", "batch", "-nojournal", "-source",
                              os.path.join(WORK, "bg_%s.tcl" % n)],
                             stdout=lg, stderr=subprocess.STDOUT)
        running.append((n, p, lg))
    reap()
import time
while running:
    reap(); time.sleep(2)
print(SIDE, "bitgen done", len(names), flush=True)

# diff vs ref
def cells(path):
    data = open(path, "rb").read()
    out = set()
    for f in range(50148):
        base = 150 + 4 + f * 404
        for w in range(101):
            if w == 50:
                continue
            word = int.from_bytes(data[base + w*4:base + w*4 + 4], "big")
            if word:
                for b in range(32):
                    if word >> b & 1:
                        out.add((f, w, b))
    return out
refc = cells(REFBIT)
res = {}
for n in names:
    bp = os.path.join(WORK, n + ".bit")
    if not os.path.exists(bp):
        continue
    res[n] = sorted(cells(bp) - refc)
json.dump(res, open(OUT, "w"))
print(SIDE, "DIFF done", len(res), "variants ->", OUT, flush=True)
