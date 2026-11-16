import os, sys, json
import rapidwright
from com.xilinx.rapidwright.design import Design

DCP = sys.argv[1]
d = Design.readCheckpoint(DCP)
out = {}
for net in d.getNets():
    pips = [str(p) for p in net.getPIPs()]
    if len(pips) > 3:
        out[str(net.getName())] = pips
print(json.dumps(out)[:6000])
