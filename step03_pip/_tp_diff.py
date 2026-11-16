"""§5.5 tilepipe bitgen+diff driver. For a DIR containing ref_<TAG>.dcp and
v_<TAG>_<src>.dcp, bitgen all, diff each v vs its ref -> OUT json
{TAG: {"sink": <imux>, "sources": {src: [[f,w,b],...]}}}.
Usage: _tp_diff.py <DIR> <OUT> <JOBS>
"""
import json, os, subprocess, sys, glob, re
from concurrent.futures import ThreadPoolExecutor
BASE, OUT = sys.argv[1], sys.argv[2]
JOBS = int(sys.argv[3])
VIVADO = "/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado"
PAYLOAD, FRAME = 338, 404
TCL = """open_checkpoint {dcp}
set_property SEVERITY {{Warning}} [get_drc_checks NSTD-1]
set_property SEVERITY {{Warning}} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force -bin_file {bit}
puts "BITSTREAM_DONE"
"""
# EDF next to each dcp? variants were written without edf; bitgen needs only dcp (netlist embedded).
dcps = sorted(glob.glob(os.path.join(BASE, "*.dcp")))
def bitgen(dcp):
    bit = dcp[:-4] + ".bit"
    if os.path.exists(bit) and os.path.getsize(bit) > 1000000:
        return dcp, "cached"
    tcl = dcp[:-4] + ".tcl"
    open(tcl, "w").write(TCL.format(dcp=dcp, bit=bit))
    env = dict(os.environ, LANG="C.UTF-8", LC_ALL="C.UTF-8")
    try:
        p = subprocess.run([VIVADO, "-mode", "batch", "-nojournal", "-notrace", "-source", tcl],
                           capture_output=True, text=True, env=env, timeout=1800)
        return dcp, ("ok" if "BITSTREAM_DONE" in p.stdout and os.path.exists(bit) else "fail")
    except Exception:
        return dcp, "err"
print("bitgen", len(dcps), "dcps", flush=True)
with ThreadPoolExecutor(max_workers=JOBS) as ex:
    nok = sum(1 for _, s in ex.map(bitgen, dcps) if s in ("ok", "cached"))
print("bitgen ok", nok, flush=True)

def cells(path):
    a = open(path, "rb").read(); out = set(); i = PAYLOAD; n = len(a)
    while i < n:
        x = a[i]
        if x:
            off = i - PAYLOAD; fr = off // FRAME; r = off % FRAME; w = r // 4; bi = r % 4
            for k in range(8):
                if x & (1 << k) and w != 50:
                    out.add((fr, w, (3 - bi) * 8 + k))
        i += 1
    return out
# diff each v_ vs its ref_ (xor)
res = {}
for dcp in dcps:
    bn = os.path.basename(dcp)[:-4]
    m = re.match(r"v_(.+?)_([A-Za-z0-9]+)$", bn)
    if not m:
        continue
    tag, src = m.group(1), m.group(2)
    refbit = os.path.join(BASE, "ref_%s.bit" % tag)
    vbit = dcp[:-4] + ".bit"
    if not (os.path.exists(refbit) and os.path.exists(vbit)):
        continue
    rc, vc = cells(refbit), cells(vbit)
    res.setdefault(tag, {"sink": "", "sources": {}})["sources"][src] = sorted(vc ^ rc)
# recover sink from tag via reach results
try:
    for l in open("/opt/lzh/step03/reach/results.txt"):
        tag, tile, mux = l.rstrip("\n").split("\t")
        if tag in res:
            res[tag]["sink"] = mux
except OSError:
    pass
json.dump(res, open(OUT, "w"))
print("WROTE", len(res), "muxes ->", OUT, flush=True)
