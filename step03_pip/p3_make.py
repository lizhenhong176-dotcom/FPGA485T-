"""P3: for one design checkpoint, emit variant DCPs that drive the same IMUX sink
from different source wires, plus the empty reference (PIP removed)."""

import os
import sys

import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design

DCP = os.environ["DCP"]
EDF = os.environ["EDF"]
OUTDIR = os.environ["OUTDIR"]
TAG = os.environ["TAG"]
NSRC = int(os.environ.get("NSRC", "8"))

base = os.path.basename(DCP)[:-4]
d = Design.readCheckpoint(DCP, EDF)
net = d.getNet("n1")
pips = list(net.getPIPs())
sink_pips = [p for p in pips if str(p).split("->>")[-1].startswith("IMUX_")]
if len(sink_pips) != 1:
    print("TAG", TAG, "unexpected sink pips:", [str(p) for p in sink_pips])
    sys.exit(2)
target = sink_pips[0]
ts = str(target)
tile_name = ts.split("/")[0]
sink = ts.split("->>")[-1]
print("TAG", TAG, "tile", tile_name, "sink", sink)

tile = d.getDevice().getTile(tile_name)
sources = []
for pp in tile.getPIPs():
    s = str(pp)
    if s.endswith("->>" + sink):
        sources.append((s.split("/")[1].split("->")[0].split(".")[-1], pp))
sources.sort(key=lambda x: x[0])
print("TAG", TAG, "sources", len(sources), [n for n, _ in sources])

# empty reference
lst = ArrayList()
for pp in pips:
    if pp is not target:
        lst.add(pp)
net.setPIPs(lst)
d.writeCheckpoint(os.path.join(OUTDIR, "ref_%s.dcp" % TAG))

for name, pp in sources[:NSRC]:
    d2 = Design.readCheckpoint(DCP, EDF)
    n2 = d2.getNet("n1")
    lst = ArrayList()
    for q in n2.getPIPs():
        lst.add(pp if str(q) == ts else q)
    n2.setPIPs(lst)
    d2.writeCheckpoint(os.path.join(OUTDIR, "v_%s_%s.dcp" % (TAG, name)))

print("TAG", TAG, "done")

