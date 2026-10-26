"""delete ONE pip (by index) from a routed DCP, keeping the rest."""
import os, sys
import rapidwright
from com.xilinx.rapidwright.design import Design
from java.util import ArrayList

dcp = os.environ["DCP"]; edf = os.environ["EDF"]
out = os.environ["OUT"]; idx = int(os.environ["IDX"])
d = Design.readCheckpoint(dcp, edf)
net = d.getNet("n1")
pips = list(net.getPIPs())
if idx >= len(pips):
    print("IDX_OUT_OF_RANGE", idx, len(pips)); sys.exit(2)
target = pips[idx]
keep = ArrayList()
for i, p in enumerate(pips):
    if i != idx:
        keep.add(p)
net.setPIPs(keep)
d.writeCheckpoint(out)
print("DELETED", idx, str(target), "keep", len(pips) - 1)
