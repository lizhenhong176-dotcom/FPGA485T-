import os
import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design
P = "/opt/lzh/step03/pip2"
d = Design.readCheckpoint(f"{P}/routed20.dcp", f"{P}/top20.edf")
net = d.getNet("n1")
pips = list(net.getPIPs())
drop = int(os.environ.get("DROP", "2"))
lst = ArrayList()
for i, pp in enumerate(pips):
    if i != drop:
        lst.add(pp)
net.setPIPs(lst)
print("dropped", drop, pips[drop])
d.writeCheckpoint(f"{P}/b20.dcp")
print("wrote b20.dcp")
