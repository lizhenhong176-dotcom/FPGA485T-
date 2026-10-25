import os, sys
import rapidwright
from com.xilinx.rapidwright.design import Design
d = Design.readCheckpoint("/opt/lzh/step03/tilepipe2/SLICE_X14Y11_A6LUT_A1.dcp", "/opt/lzh/step03/tilepipe2/SLICE_X14Y11_A6LUT_A1.edf")
n = d.getNet("n1")
for p in n.getPIPs():
    print(str(p))
