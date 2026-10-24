import os
import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design

p = "/opt/lzh/step03/pip1"
d = Design.readCheckpoint(os.path.join(p, "routed.dcp"), os.path.join(p, "top.edf"))
net = d.getNet("n1")
pips = list(net.getPIPs())
print("base pips:", len(pips))
for i, pp in enumerate(pips):
    print(i, pp)
idx = int(os.environ.get("DROP", "1"))
keep = pips[:idx] + pips[idx + 1:]
lst = ArrayList()
for pp in keep:
    lst.add(pp)
net.setPIPs(lst)
print("after:", len(list(net.getPIPs())))
d.writeCheckpoint(os.path.join(p, "b.dcp"))
print("wrote b.dcp")
