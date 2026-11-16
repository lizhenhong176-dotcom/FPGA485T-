import rapidwright
from com.xilinx.rapidwright.design import Design
for tag, dcp, edf in [("T16", "/opt/lzh/step03/blkcol/T16.dcp", "/opt/lzh/step03/blkcol/T16.edf"),
                      ("T12", "/opt/lzh/step03/blkcol2/T12.dcp", "/opt/lzh/step03/blkcol2/T12.edf"),
                      ("X6", "/opt/lzh/step03/reuse5/SLICE_X8Y11_A6LUT_A5.dcp", "/opt/lzh/step03/reuse5/SLICE_X8Y11_A6LUT_A5.edf")]:
    d = Design.readCheckpoint(dcp, edf)
    net = d.getNet("n1")
    for p in net.getPIPs():
        s = str(p)
        if "IMUX" in s:
            print(tag, "sink:", s)