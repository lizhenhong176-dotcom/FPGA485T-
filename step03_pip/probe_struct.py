import json
d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8"))
t = sorted(d)[0]
print("tag", t, "keys", list(d[t].keys()))
s = d[t]["sources"]
print("sources type", type(s), "len", len(s))
k = sorted(s)[0]
print("first src", k, type(s[k]))
print(json.dumps(s[k])[:200])
