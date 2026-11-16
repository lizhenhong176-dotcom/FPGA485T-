import os
import jpype
jvm = r"E:\tools\jdk17\jdk-17.0.20.1+1\bin\server\jvm.dll"
if not jpype.isJVMStarted():
    jpype.startJVM(jvm, classpath=[r"D:\Anaconda3\Lib\site-packages\rapidwright\rapidwright-2026.1.1-standalone-win64.jar"], convertStrings=True)
Device = jpype.JClass("com.xilinx.rapidwright.device.Device")
dev = Device.getDevice("xc7vx485tffg1157-3")
site = dev.getSite("SLICE_X0Y0")
print("site", site.getName(), site.getSiteTypeEnum(), "sitewires", site.getSiteWireCount())
print("sample", [site.getSiteWireName(i) for i in range(10)])
sp = list(site.getSitePIPs()) if hasattr(site, "getSitePIPs") else None
print("sitePIPs", None if sp is None else len(sp))
if sp: print("  first", [str(x) for x in sp[:8]])