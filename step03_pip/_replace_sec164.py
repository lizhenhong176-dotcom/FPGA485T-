import io, re
P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(P, encoding="utf-8").read()
new = io.open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\_sec164.md", encoding="utf-8").read()
new = new.replace("__N__", "164")
idx = txt.find("## 164. ")
assert idx > 0, "section 164 not found"
assert txt.find("## 164. ", idx + 1) == -1, "duplicate 164"
body = txt[:idx].rstrip("\r\n")
io.open(P, "w", encoding="utf-8", newline="").write(body + "\r\n\r\n" + new.replace("\n", "\r\n"))
t2 = io.open(P, encoding="utf-8").read()
nums = [int(m) for m in re.findall(r"^## (\d+)\.", t2, re.M)]
print("lines", t2.count("\n") + 1, "ufffd", t2.count("\ufffd"), "sections", len(nums), "max", max(nums), "dup164", t2.count("## 164."))
print("has formula:", "24 + floor(k / 2)" in t2)