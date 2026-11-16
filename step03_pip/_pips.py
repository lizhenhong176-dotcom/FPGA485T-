import sys
import rapidwright
from com.xilinx.rapidwright.design import Design

d = Design.readCheckpoint("/opt/lzh/step03/right/rA1.dcp", "/opt/lzh/step03/right/rA1.edf")
n = d.getNet("n1")
names = []
for p in n.getPIPs():
    s = str(p)
    tile = s.split("/")[0]
    t = d.getDevice().getTile(tile)
    try:
        tt = t.getTileType().toString()
    except Exception:
        tt = "?"
    if (tt, tile) not in names:
        names.append((tt, tile))
print("TILES", "|".join(f"{tt}:{tile}" for tt, tile in names))
for c in ("lut_a", "lut_b"):
    cell = d.getCell(c)
    print("CELL", c, cell.getSiteName() if cell else None)
