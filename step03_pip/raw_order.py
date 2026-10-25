import json, os, sys
sys.path.insert(0, "/opt/lzh/v7re")
import rapidwright
from com.xilinx.rapidwright.device import Device

dev = Device.getDevice("xc7vx485tffg1761-2")
t = dev.getTile("INT_L_X6Y11")
order = [str(p) for p in t.getPIPs() if str(p).endswith("->>IMUX_L8")]
rank = {p.split(".")[-1].split("->>")[0]: i for i, p in enumerate(order)}
print("raw order count", len(order))
json.dump(rank, open("/mnt/c/Users/S.tschai/pip_order_L8.json", "w"))
for src, i in sorted(rank.items(), key=lambda kv: kv[1])[:26]:
    print(i, src)
