import json, os, sys
import rapidwright
from com.xilinx.rapidwright.design import Design
from java.util import ArrayList
DCP=os.environ["DCP"]; EDF=os.environ.get("EDF") or None; TAG=os.environ["TAG"]; OUT=os.environ["OUT"]
d = Design.readCheckpoint(DCP, EDF) if EDF else Design.readCheckpoint(DCP)
net = d.getNet("n1")
pips = list(net.getPIPs())
rows=[]
for p in pips:
    rows.append({"tile": str(p.getTile().getName()), "src": str(p.getStartWireName()), "sink": str(p.getEndWireName())})
json.dump(rows, open(os.path.join(OUT, "pips_%s.json" % TAG), "w"), indent=1)
net.setPIPs(ArrayList())
d.writeCheckpoint(os.path.join(OUT, "ref_%s.dcp" % TAG))
print("PIPS", len(rows), TAG)