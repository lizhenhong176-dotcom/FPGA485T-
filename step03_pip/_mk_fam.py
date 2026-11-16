import os, sys, json
import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design

REF = sys.argv[1]           # 参考 dcp
OUT = sys.argv[2]           # 输出目录
SPEC = json.loads(sys.argv[3])   # [[family, src_wire, dcp_name], ...]

d0 = Design.readCheckpoint(REF)
tile_name = "INT_L_X6Y11"
dev = d0.getDevice()
tile = dev.getTile(tile_name)
pips = {}
for pp in tile.getPIPs():
    s = str(pp)                      # e.g. INT_L_X6Y11/INT_L.EE2END3->>EE2BEG1
    if "->>" not in s:
        continue
    rest = s.split("/")[-1]
    src, dst = rest.split("->>")
    src = src.split(".")[-1]
    pips.setdefault(dst, {})[src] = pp

print("families in tile:", len(pips))

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
    path = os.path.join(OUT, name + ".dcp")
    d.writeCheckpoint(path)
    print("WROTE", name, str(pp))
print("BUILDDONE")
