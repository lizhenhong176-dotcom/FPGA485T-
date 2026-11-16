import os, sys, json
import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design

REF = sys.argv[1]
OUT = sys.argv[2]
TILE = sys.argv[3]
SPEC = json.loads(sys.argv[4])

d0 = Design.readCheckpoint(REF)
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
print("tile", TILE, "families", len(pips))

done = 0
for family, src_wire, name in SPEC:
    if family not in pips or src_wire not in pips[family]:
        print("MISS", family, src_wire)
        continue
    pp = pips[family][src_wire]
    d = Design.readCheckpoint(REF)
    net = d.getNet("n1")
    lst = ArrayList()
    for q in net.getPIPs():
        lst.add(q)
    lst.add(pp)
    net.setPIPs(lst)
    d.writeCheckpoint(os.path.join(OUT, name + ".dcp"))
    done += 1
print("BUILDDONE", done, "of", len(SPEC))
