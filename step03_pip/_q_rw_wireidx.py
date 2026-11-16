import jpype
jvm = r"E:\tools\jdk17\jdk-17.0.20.1+1\bin\server\jvm.dll"
if not jpype.isJVMStarted():
    jpype.startJVM(jvm, classpath=[r"D:\Anaconda3\Lib\site-packages\rapidwright\rapidwright-2026.1.1-standalone-win64.jar"], convertStrings=True)
Device = jpype.JClass("com.xilinx.rapidwright.device.Device")
dev = Device.getDevice("xc7vx485tffg1157-3")
tile = dev.getTile("INT_L_X0Y0")
groups = {
 "G1": ["EE2END0","NL1END0","SE2END0","SR1END_N3_3"],
 "G2": ["NE2END0","NN2END0","NR1END0","SL1END0"],
 "G3": ["EL1END0","SS2END0","SW2END0","WR1END0"],
 "G4": ["WW2END_N0_3","ER1END0","NW2END0","WL1END0"],
}
for g, ws in groups.items():
    for w in ws:
        try:
            wire = dev.getWire("INT_L_X0Y0/" + w)
        except Exception as e:
            print("  %-3s %-16s ERR %s" % (g, w, type(e).__name__)); continue
        if wire is None: print("  %-3s %-16s MISSING" % (g, w)); continue
        print("  %-3s %-16s idx=%-4d intent=%s" % (g, w, wire.getWireIndex(), wire.getIntentCode()))