import rapidwright
from com.xilinx.rapidwright.device import Device
from com.xilinx.rapidwright.bitstream import ConfigArray

dev = Device.getDevice("xc7vx485tffg1761-2")
ca = ConfigArray(dev)
ser = dev.getSeries()
entries = []
for r_idx, row in enumerate(ca.getConfigRows()):
    for b in row.getBlocks():
        base = int(b.getAddress()); n = int(b.getFrameCount())
        for k in range(n):
            entries.append((base + k, b, r_idx))
    entries.append((None, None, r_idx)); entries.append((None, None, r_idx))

for t in [26442, 26448, 31688, 31694]:
    far, b, r = entries[t]
    if b is None:
        print(t, "overhead row", r); continue
    bot = b.getBottomTile()
    print(t, hex(far), "row", r, "col", int(b.getColumn(ser)), "bottom", bot.getName() if bot else None)
