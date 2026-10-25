import os, sys
import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design

DCP = os.environ["DCP"]; EDF = os.environ["EDF"]; OUT = os.environ["OUT"]; TAG = os.environ["TAG"]

def dst(s):
    s = str(s)
    return s.split("->>")[-1] if "->>" in s else s.split("->")[-1]

def sep(s):
    return "->>" if "->>" in str(s) else "->"

d = Design.readCheckpoint(DCP, EDF)
net = d.getNet("n1")
pips = list(net.getPIPs())
tgt = [p for p in pips if dst(p).replace("_", "").startswith("IMUX")]
if len(tgt) != 1:
    print("TAG", TAG, "bad sink pips", [str(p) for p in pips])
    sys.exit(2)
ts = str(tgt[0]); sink = dst(ts)
tile_name = ts.split("/")[0]
tile = d.getDevice().getTile(tile_name)
srcs = []
for pp in tile.getPIPs():
    s = str(pp)
    if dst(s) == sink and s.split("/")[0] == tile_name:
        srcs.append((s.split("/")[1].split("->")[0].split(".")[-1], pp))
srcs.sort(key=lambda x: x[0])
print("TAG", TAG, "sink", sink, "sources", len(srcs))

lst = ArrayList()
for p in pips:
    if p is not tgt[0]:
        lst.add(p)
net.setPIPs(lst)
d.writeCheckpoint(os.path.join(OUT, "ref_%s.dcp" % TAG))

for name, pp in srcs:
    d2 = Design.readCheckpoint(DCP, EDF)
    n2 = d2.getNet("n1")
    l2 = ArrayList()
    for q in n2.getPIPs():
        l2.add(pp if str(q) == ts else q)
    n2.setPIPs(l2)
    d2.writeCheckpoint(os.path.join(OUT, "v_%s_%s.dcp" % (TAG, name)))
print("TAG", TAG, "done")

