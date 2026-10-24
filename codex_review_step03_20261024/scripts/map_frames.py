import rapidwright
from com.xilinx.rapidwright.device import Device
from com.xilinx.rapidwright.bitstream import ConfigArray

dev = Device.getDevice("xc7vx485tffg1761-2")
ca = ConfigArray(dev)
rows = list(ca.getConfigRows())
ser = dev.getSeries()

entries = []
for r_idx, row in enumerate(rows):
    for b in row.getBlocks():
        base = int(b.getAddress())
        n = int(b.getFrameCount())
        for k in range(n):
            entries.append((base + k, b, r_idx))
    entries.append((None, None, r_idx))
    entries.append((None, None, r_idx))

print("total linear frames:", len(entries))
targets = [31688, 31690, 31693, 31699, 31702, 31704, 31705]
for t in targets:
    far, b, r = entries[t]
    if b is None:
        print(f"{t}: overhead frame, row {r}")
        continue
    col = int(b.getColumn(ser))
    bt = int(b.getBlockType(ser))
    bot = b.getBottomTile()
    top = b.getTopTile()
    print(f"{t}: FAR={hex(far)} row={r} col={col} type={bt} bottom={bot.getName() if bot else None} top={top.getName() if top else None}")
