import json
a = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8-sig"))
b = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tp3.json", encoding="utf-8-sig"))
def find(d, sink):
    for v in d.values():
        if v["sink"] == sink: return v["sources"]
A = find(a, "IMUX_L8"); B = find(b, "IMUX_L8")
for w in ["GFAN0", "LOGIC_OUTS_L0", "EE2END0"]:
    print(w)
    print("  X6Y11:", A[w])
    print("  X6Y21:", B[w])
