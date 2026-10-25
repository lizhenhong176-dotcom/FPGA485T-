import rapidwright, os
from com.xilinx.rapidwright.design import Design
d = Design.readCheckpoint("/opt/lzh/step03/reuse6/SLICE_X10Y11_A6LUT_A2.dcp", "/opt/lzh/step03/reuse6/SLICE_X10Y11_A6LUT_A2.edf")
n = d.getNet("n1")
for p in n.getPIPs():
    print(str(p))
