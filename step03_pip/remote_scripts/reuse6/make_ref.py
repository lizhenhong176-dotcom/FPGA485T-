import os, sys
import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design

DCP = os.environ["DCP"]; EDF = os.environ["EDF"]; OUT = os.environ["OUT"]
d = Design.readCheckpoint(DCP, EDF)
net = d.getNet("n1")
pips = list(net.getPIPs())
tgt = [p for p in pips if str(p).split("->>")[-1].startswith("IMUX")]
print("SINK", " ".join(str(p) for p in tgt))
if len(tgt) != 1:
    sys.exit(3)
lst = ArrayList()
for p in pips:
    if p is not tgt[0]:
        lst.add(p)
net.setPIPs(lst)
d.writeCheckpoint(OUT)

