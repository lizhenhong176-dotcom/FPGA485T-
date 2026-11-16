import io
p = r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\_replace_sec164.py"
s = io.open(p, encoding="utf-8").read()
s = s.replace('new = new.replace("__N__", "164")', 'new = new.replace("__N__", "164")')
io.open(p, "w", encoding="utf-8", newline="").write(s)