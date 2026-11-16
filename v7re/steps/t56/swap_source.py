import os
import rapidwright
from java.util import ArrayList
from com.xilinx.rapidwright.design import Design

DCP = os.environ["DCP"]
EDF = os.environ["EDF"]
OUT = os.environ["OUT"]
SRC = os.environ["SRC"]          # e.g. EE2END0
SINK = os.environ.get("SINK", "IMUX_L8")
TILE = os.environ.get("TILE", "INT_L_X6Y11")
TYPE = os.environ.get("TYPE", "INT_L")

d = Design.readCheckpoint(DCP, EDF)
net = d.getNet("n1")
pips = list(net.getPIPs())

want = "%s/%s.%s->>%s" % (TILE, TYPE, SRC, SINK)
replacement = None
for pp in d.getDevice().getTile(TILE).getPIPs():
    if str(pp) == want:
        replacement = pp
        break
if replacement is None:
    raise SystemExit("PIP not found: " + want)

lst = ArrayList()
n = 0
for pp in pips:
    s = str(pp)
    if s.endswith("->>" + SINK):
        lst.add(replacement)
        n += 1
    else:
        lst.add(pp)
if n != 1:
    raise SystemExit("expected exactly one PIP into %s, got %d" % (SINK, n))
net.setPIPs(lst)
d.writeCheckpoint(OUT)
print("ok", SRC, "->", OUT)
