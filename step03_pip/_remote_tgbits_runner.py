import sys, base64, os, json, subprocess

os.makedirs("/tmp/tgbits", exist_ok=True)

# Read all of stdin — it's the base64 payload
raw = sys.stdin.read()
parts = raw.split("===SPLIT===")
assert len(parts) == 2, "expected 2 parts, got " + str(len(parts))

with open("/tmp/tgbits/gen_tilegrid_bits.py", "wb") as f:
    f.write(base64.b64decode(parts[0].strip()))
with open("/tmp/tgbits/frame_index_far.csv", "wb") as f:
    f.write(base64.b64decode(parts[1].strip()))

print("script:", os.path.getsize("/tmp/tgbits/gen_tilegrid_bits.py"), "bytes")
print("csv:", os.path.getsize("/tmp/tgbits/frame_index_far.csv"), "bytes")

TG_IN = "/opt/lzh/v7re/data/fasm_shell/db/xc7vx485t/tilegrid.json"
TG_OUT = "/opt/lzh/v7re/data/fasm_shell/db/xc7vx485t/tilegrid.json.filled"
print("=== run generator ===")
r = subprocess.run([
    "/usr/bin/python3", "/tmp/tgbits/gen_tilegrid_bits.py",
    TG_IN, TG_OUT, "--far-csv", "/tmp/tgbits/frame_index_far.csv"
], capture_output=True, text=True)
print(r.stdout)
if r.stderr:
    print("STDERR:", r.stderr[:1000])
print("exit", r.returncode)

if r.returncode == 0:
    print("=== verify ===")
    d = json.load(open(TG_OUT))
    filled = sum(1 for v in d.values() if v.get("bits"))
    total = len(d)
    print("tiles=" + str(total) + " filled=" + str(filled) + " (" + str(round(100.0*filled/total, 1)) + "%)")
    for p in ["INT_L_X6Y11","INT_R_X7Y10","CLBLL_L_X6Y10","CLBLM_R_X7Y10",
              "CLBLL_L_X10Y303","INT_L_X128Y10","CLBLM_L_X150Y69","BRAM_L_X130Y90"]:
        if p in d:
            e = d[p]
            b = e.get("bits", {}).get("CLB_IO_CLK", {})
            cr = e.get("clock_region", "?")
            s = json.dumps(b, separators=(",", ":")) if b else "(empty)"
            print("  " + p.ljust(22) + " cr=" + str(cr).ljust(5) + " " + s)
    print("output size:", os.path.getsize(TG_OUT), "bytes")
