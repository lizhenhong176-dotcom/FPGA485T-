import json, re
d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\mux32.json", encoding="utf-8"))
by = {}
for tag, rec in d.items():
    s = rec["sink"]
    if not s: continue
    L = int(s.split("_L")[1])
    by.setdefault(L, set()).update((w, b) for _f, w, b in rec["config"])

def f(L):
    return 22 + ((L // 4) % 2), 1 + 8 * (L % 4) + (L // 8)

ok = bad = 0
extra = {}
for L in sorted(by):
    w, b = f(L)
    if (w, b) in by[L]:
        ok += 1
    else:
        bad += 1
        print("MISS", L, "pred", (w, b), "obs", sorted(by[L]))
    ex = sorted(by[L] - {(w, b)})
    if ex:
        extra[L] = ex
print("fit", ok, "miss", bad, "of", len(by))
print("extra bits:", extra)
