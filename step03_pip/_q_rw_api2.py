import jpype
jvm = r"E:\tools\jdk17\jdk-17.0.20.1+1\bin\server\jvm.dll"
if not jpype.isJVMStarted():
    jpype.startJVM(jvm, classpath=[r"D:\Anaconda3\Lib\site-packages\rapidwright\rapidwright-2026.1.1-standalone-win64.jar"], convertStrings=True)
Device = jpype.JClass("com.xilinx.rapidwright.device.Device")
dev = Device.getDevice("xc7vx485tffg1157-3")
tile = dev.getTile("INT_L_X0Y0")
print([m for m in dir(tile) if "ire" in m])
print([m for m in dir(dev) if "ire" in m][:12])