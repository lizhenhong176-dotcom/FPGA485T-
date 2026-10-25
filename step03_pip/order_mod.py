import json
order = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\pip_order_L8.json", encoding="utf-8"))
by = {}
for s, i in order.items():
    by.setdefault(i % 6, []).append(s)
for k in sorted(by):
    print("i%6=", k, sorted(by[k]))
