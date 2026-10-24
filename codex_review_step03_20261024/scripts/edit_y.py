import os
import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design
P = os.environ["P"]
dcp, edf, out = os.environ["DCP"], os.environ["EDF"], os.environ["OUT"]
d = Design.readCheckpoint(dcp, edf)
net = d.getNet("n1")
pips = list(net.getPIPs())
for i, pp in enumerate(pips):
    print(i, pp)
idx = None
for i, pp in enumerate(pips):
    s = str(pp)
    if "NR1BEG" in s or ">NR" in s:
        idx = i
        break
if idx is None:
    idx = next(i for i, pp in enumerate(pips) if "INT_" in str(pp))
print("drop", idx, pips[idx])
lst = ArrayList()
for i, pp in enumerate(pips):
    if i != idx:
        lst.add(pp)
net.setPIPs(lst)
d.writeCheckpoint(out)
print("wrote", out)
