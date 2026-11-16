import sys, base64, os, subprocess

raw = sys.stdin.read()
parts = raw.split("===SEGBITS===")
os.makedirs("/tmp/bit2fasm", exist_ok=True)
os.makedirs("/tmp/bit2fasm/segbits", exist_ok=True)

# Decode script
with open("/tmp/bit2fasm/bit2fasm_py.py", "wb") as f:
    f.write(base64.b64decode(parts[0].strip()))
print("script:", os.path.getsize("/tmp/bit2fasm/bit2fasm_py.py"))

# Decode segbits
for line in parts[1].strip().split("\n"):
    if not line.strip():
        continue
    fname, b64 = line.split(":", 1)
    data = base64.b64decode(b64.strip())
    with open("/tmp/bit2fasm/segbits/" + fname, "wb") as f:
        f.write(data)
    print("segbits:", fname, len(data), "bytes")

# Run decoder on a.bit
print("=== running decoder on a.bit ===")
r = subprocess.run([
    "/usr/bin/python3", "/tmp/bit2fasm/bit2fasm_py.py",
    "/opt/lzh/v7re/data/fasm_shell/a.bit",
    "-t", "/opt/lzh/v7re/data/fasm_shell/db/xc7vx485t/tilegrid.json.filled",
    "-s", "/tmp/bit2fasm/segbits",
    "-f", "/tmp/tgbits/frame_index_far.csv",
], capture_output=True, text=True, timeout=120)
print("STDOUT:")
print(r.stdout)
print("STDERR:")
print(r.stderr[:3000])
print("exit:", r.returncode)

# Also run on b.bit
print("=== running decoder on b.bit ===")
r2 = subprocess.run([
    "/usr/bin/python3", "/tmp/bit2fasm/bit2fasm_py.py",
    "/opt/lzh/v7re/data/fasm_shell/b.bit",
    "-t", "/opt/lzh/v7re/data/fasm_shell/db/xc7vx485t/tilegrid.json.filled",
    "-s", "/tmp/bit2fasm/segbits",
    "-f", "/tmp/tgbits/frame_index_far.csv",
], capture_output=True, text=True, timeout=120)
print("STDOUT:")
print(r2.stdout)
print("STDERR:")
print(r2.stderr[:3000])
print("exit:", r2.returncode)
