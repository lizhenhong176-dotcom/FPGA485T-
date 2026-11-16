import os, glob, re, collections, io, contextlib
import rapidwright
from com.xilinx.rapidwright.design import Design
D = "/opt/lzh/step03/reach"
rows = []
for dcp in sorted(glob.glob(os.path.join(D, "*.dcp"))):
    tag = os.path.basename(dcp)[:-4]
    try:
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            d = Design.readCheckpoint(dcp)
            net = d.getNet("n1")
            tgt = [p for p in list(net.getPIPs()) if str(p).split("->>")[-1].startswith("IMUX")]
        if len(tgt) != 1:
            rows.append((tag, "BAD", str(len(tgt)))); continue
        ts = str(tgt[0])
        rows.append((tag, ts.split("/")[0], ts.split("->>")[-1]))
    except Exception as e:
        rows.append((tag, "ERR", repr(e)[:50]))
with open(os.path.join(D, "results.txt"), "w") as fh:
    for tag, tile, mux in rows:
        fh.write("%s\t%s\t%s\n" % (tag, tile, mux))
bytile = collections.Counter(r[1] for r in rows)
print("BYTILE", dict(bytile))
lm = collections.defaultdict(list)
for tag, tile, mux in rows:
    if tile == "INT_L_X6Y11":
        m = re.match(r"IMUX_L(\d+)", mux)
        if m: lm[int(m.group(1))].append(tag)
missing = [22, 28, 29, 31, 32, 35, 38, 40, 43, 44, 45, 47]
print("REACHED_INT_L_X6Y11_IDX", sorted(lm))
for x in missing:
    print("MISS", x, lm.get(x))
sl = collections.Counter(r[0].split("_")[0] for r in rows if r[1] == "INT_L_X6Y11")
print("INT_L_X6Y11_BY_SLICE", dict(sl))
