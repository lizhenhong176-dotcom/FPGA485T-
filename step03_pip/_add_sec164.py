import io, re
P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(P, encoding="utf-8").read()
nums = [int(m) for m in re.findall(r"^## (\d+)\.", txt, re.M)]
n = max(nums) + 1
sec = io.open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\_sec164.md", encoding="utf-8").read()
sec = sec.replace("__N__", str(n))
if ("## %d." % n) in txt:
    raise SystemExit("collision")
io.open(P, "w", encoding="utf-8", newline="").write(txt.rstrip("\r\n") + "\r\n\r\n" + sec.replace("\n", "\r\n"))
t2 = io.open(P, encoding="utf-8").read()
print("section", n, "lines", t2.count("\n") + 1, "ufffd", t2.count("\ufffd"), "nums", len(re.findall(r"^## \d+\.", t2, re.M)))