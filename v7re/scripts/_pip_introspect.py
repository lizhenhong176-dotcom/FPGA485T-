from __future__ import annotations
import os, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from routing import env
from config import work_root
env.bootstrap(work_root() / "pip_enum")
import rapidwright  # noqa
from com.xilinx.rapidwright.design import Design, Net
from com.xilinx.rapidwright.device import PIP
os.environ["RW_AUTO_GENERATE_READABLE_EDIF"] = "0"

# list public methods of PIP
cls = PIP.class_
names = sorted({str(m.getName()) for m in cls.getMethods()})
skip = {"wait","getClass","notify","notifyAll","hashCode","equals"}
print("PIP methods:", [n for n in names if not n.startswith("wait") and n not in skip])
print("---")
dcp = Path(r"E:\v7work\probe_boundary\SLICE_X10Y24\A6LUT\routed.dcp")
design = Design.readCheckpoint(str(dcp).replace("\\","/"))
for net in design.getNets():
    ps = list(net.getPIPs())
    if ps:
        p = ps[0]
        print("net", net.getName(), "n_pips", len(ps))
        for m in ("getWireName","getName","getTileName","isForwardingSitePIP","getSitePIP"):
            try:
                print("   ", m, "->", getattr(p, m)())
            except Exception as e:
                print("   ", m, "ERR", type(e).__name__)
        break
