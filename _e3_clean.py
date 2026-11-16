import re

p = "_e3_run.sh"
s = open(p, encoding="utf-8").read()
out = []
for line in s.split("\n"):
    if line.lstrip().startswith("#") and any(ord(c) > 127 for c in line):
        line = re.sub(r"[^\x20-\x7e]", "", line).rstrip()
    out.append(line)
s2 = "\n".join(out)
open(p, "w", encoding="utf-8", newline="\n").write(s2)
bad = [(i + 1, l) for i, l in enumerate(s2.split("\n")) if any(ord(c) > 127 for c in l)]
print("non-ascii lines left:", bad)
print("crlf:", b"\r" in s2.encode())
print("lines:", s2.count("\n"))
print("PYEOF block:", s2.count("<<'PYEOF'"), "VEOF:", s2.count("<<'VEOF'"), "TEOF:", s2.count("<<'TEOF'"))
