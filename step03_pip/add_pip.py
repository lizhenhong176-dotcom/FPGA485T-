import os
import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design

P = "/opt/lzh/step03/pip1"
d = Design.readCheckpoint(f"{P}/routed.dcp", f"{P}/top.edf")
net = d.getNet("n1")
pips = list(net.getPIPs())
tile = d.getDevice().getTile("INT_L_X6Y11")
want = "INT_L_X6Y11/INT_L.%s->>IMUX_L8" % os.environ["ADD"]
repl = None
for pp in tile.getPIPs():
    if str(pp) == want:
        repl = pp
        break
if repl is None:
    raise SystemExit("pip not found: " + want)
lst = ArrayList()
for i, pp in enumerate(pips):
    if i == 2:
        lst.add(repl)
    else:
        lst.add(pp)
net.setPIPs(lst)
out = os.environ["OUT"]
d.writeCheckpoint(f"{P}/{out}")
print("replaced idx2 with", repl, "->", out)


