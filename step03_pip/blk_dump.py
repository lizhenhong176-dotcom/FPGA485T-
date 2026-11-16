import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
import config
from rapidwright import Environment, Device
from java.lang import System
import com.xilinx.rapidwright.device.Device as JDevice
dev = Device.getDevice("xc7vx485tffg1761-2")
ca = dev.getConfigArray() if hasattr(dev, "getConfigArray") else None
print("ca", ca)
