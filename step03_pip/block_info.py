import rapidwright
from com.xilinx.rapidwright.device import Device
from com.xilinx.rapidwright.bitstream import ConfigArray

dev = Device.getDevice("xc7vx485tffg1761-2")
ca = ConfigArray(dev)
ser = dev.getSeries()
for r, row in enumerate(ca.getConfigRows()):
    for b in row.getBlocks():
        bottom = b.getBottomTile()
        name = str(bottom.getName()) if bottom else ""
        if "CLBLL_L_X6" in name or "INT_L_X6" in name:
            print("row", r, "col", int(b.getColumn(ser)), "addr", hex(int(b.getAddress())),
                  "frames", int(b.getFrameCount()), "bottom", name)
